SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/24/2012
-- Description:	Updates a goals status based on plan 
--				And when Goal is approved, update EmpPlan(PlanStartDt,GoalStatusID, IsMultiYearPlan)
--				Set IsMultiYearPlan when PlanType is Self Directed
-- =============================================
CREATE PROCEDURE [dbo].[updGoalStatus]
	@PlanID	AS int = null
	,@GoalStatus AS nvarchar(50) = null
	,@UserID AS nchar(6) = null
	,@IsAdmin as int = 0
	,@IsEval as int = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @PlanYear AS INT
	DECLARE @GoalStatusID AS int
	DECLARE @GoalStatusIDNextYear AS int
	
----------------------------------------------------------------------------	
	SELECT 
		@PlanYear = PlanYear from EmplPlan where PlanID=@PlanID	
	
----------------------------------------------------------------------------
	SELECT
		@GoalStatusID =	CodeID 
	FROM 
		CodeLookUp 
	WHERE
		CodeText = @GoalStatus and CodeType = 'GoalStatus'	
-------------------@PlanYear = 1---------------------------------------------
IF @PlanYear = 1
BEGIN
	IF NOT @GoalStatus = 'Returned'
	BEGIN
		-----IF IsAdmin is true, then allow admin to reset all goals
		IF @IsAdmin = 0
		BEGIN
			IF @IsEval = 0
			BEGIN
				UPDATE PlanGoal
				SET
					GoalStatusID = @GoalStatusID
					,LastUpdatedByID = @UserID
					,LastUpdatedDt = GETDATE()
				WHERE
					IsDeleted = 0
				AND	PlanID = @PlanID
				AND CreatedByID = @UserID
				AND NOT GoalStatusID IN (SELECT 
											CodeID
										FROM
											CodeLookUp
										WHERE
											CodeText IN ('Approved','Ignored')
										AND CodeType = 'GoalStatus')
			END
			ELSE
			BEGIN
				UPDATE PlanGoal
				SET
					GoalStatusID = @GoalStatusID
					,LastUpdatedByID = @UserID
					,LastUpdatedDt = GETDATE()
				WHERE
					IsDeleted = 0
				AND	PlanID = @PlanID
				AND NOT GoalStatusID IN (SELECT 
											CodeID
										FROM
											CodeLookUp
										WHERE
											CodeText IN ('Approved','Ignored')
										AND CodeType = 'GoalStatus')
			END
		END
		ELSE --allowing admin to reset all goals
		BEGIN
				UPDATE PlanGoal
				SET
					GoalStatusID = @GoalStatusID
					,LastUpdatedByID = @UserID
					,LastUpdatedDt = GETDATE()
				WHERE
					IsDeleted = 0
				AND	PlanID = @PlanID
		END
		
		IF @GoalStatus = 'Approved'
		BEGIN
			DECLARE @Duration as int
			DECLARE @PlanStartDt as datetime = null			
			DECLARE @CreatedByDt as datetime = null			
			DECLARE @PlanEndDt as datetime =null
			DECLARE @PlanTypeID as bit = null
			
			SELECT
				@Duration = (DATEDIFF(day, GETDATE(), PlanSchedEndDt))
				,@PlanStartDt = ISNULL(PlanStartDt,GETDATE())				
				,@PlanEndDt=ISNULL(PlanSchedEndDt,GETDATE())
				,@CreatedByDt = ISNULL(CreatedByDt,GETDATE())
				,@PlanTypeID=PlanTypeID
			FROM
				EmplPlan
			WHERE
				PlanID = @PlanID
			
			IF NOT @Duration = 0
			BEGIN	
				UPDATE EmplPlan
				SET
					PlanStartDt = @PlanStartDt
					-- This will need to be updated next Fall to use school days instead of calendar days.
					--,PlanEndDt = DATEADD(D, DATEDIFF(day, PlanStartDt, PlanEndDt), GETDATE())
					,GoalStatusDt = GETDATE()
					,LastUpdatedByID = @UserID
					,LastUpdatedDt = GETDATE()
				WHERE
					PlanID = @PlanID				
			END
			ELSE
			BEGIN	
				UPDATE EmplPlan
				SET
					PlanStartDt = @PlanStartDt
					,GoalStatusDt = GETDATE()
					,LastUpdatedByID = @UserID
					,LastUpdatedDt = GETDATE()
				WHERE
					PlanID = @PlanID				
			END			
	-- change the goal status to draft if its not yet submitted when approving.
			UPDATE PlanGoal
			SET
			GoalStatusID = (SELECT
								CodeID
							FROM
								CodeLookUp
							WHERE
								CodeText = 'Draft' and CodeType = 'GoalStatus')
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE
			IsDeleted = 0
		AND	PlanID = @PlanID
		AND GoalStatusID = (SELECT
								CodeID
							FROM
								CodeLookUp
							WHERE
								CodeText = 'Not Yet Submitted' and CodeType = 'GoalStatus')
			
			
		END
		if @GoalStatus = 'In Process' ---if goals created by manager/subeval, and reset by admin then emplplan status should be 11 
		begin
			SELECT	@GoalStatusID =	CodeID 	FROM  CodeLookUp WHERE CodeText = 'Not Yet Submitted' and CodeType = 'GoalStatus'
		end
		UPDATE EmplPlan
		SET
			GoalStatusID = @GoalStatusID
			,GoalStatusDt = GETDATE()
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE
			PlanID = @PlanID
		AND ((NOT GoalStatusID IN (SELECT 
											CodeID
										FROM
											CodeLookUp
										WHERE
											CodeText IN ('Approved','Ignored')
										AND CodeType = 'GoalStatus')) OR GoalStatusID IS NULL)
	END
	ELSE --@GoalStatus = 'Returned'
	BEGIN
		UPDATE PlanGoal
		SET
			GoalStatusID = @GoalStatusID
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE
			IsDeleted = 0
		AND	PlanID = @PlanID
		AND GoalStatusID = (SELECT
								CodeID
							FROM
								CodeLookUp
							WHERE
								CodeText = 'Awaiting Approval' and CodeType = 'GoalStatus')
		
		UPDATE EmplPlan
		SET
			GoalStatusID = @GoalStatusID
			,GoalStatusDt = GETDATE()
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE
			PlanID = @PlanID

	END
END
-------------------@PlanYear = 2---------------------------------------------
ELSE IF @PlanYear = 2  -- This is SD SECOND YR PLAN and multiyear plan
BEGIN
	declare @GoalYear as int = 2
	declare @SDPlanTypeID as int
	select @SDPlanTypeID=plantypeid from EmplPlan where PlanID=@PlanID --should be sd plan
	
	IF NOT @GoalStatus = 'Returned'
	BEGIN
	-----------Non-Admin-----------
		IF @IsAdmin =0
		BEGIN
			-------------eduator -'awaiting approval'-------------
			IF(@IsEval = 0)
			BEGIN
				IF @GoalStatus = 'Approved'
				BEGIN
					-- change the goal status to draft if its not yet submitted when approving.
					UPDATE PlanGoal
					SET
					GoalStatusID = (SELECT
										CodeID
									FROM
										CodeLookUp
									WHERE
										CodeText = 'Draft' and CodeType = 'GoalStatus')
					,LastUpdatedByID = @UserID
					,LastUpdatedDt = GETDATE()
					WHERE
						IsDeleted = 0
					AND	PlanID = @PlanID
					AND GoalStatusID = (SELECT
											CodeID
										FROM
											CodeLookUp
										WHERE
											CodeText = 'Not Yet Submitted' and CodeType = 'GoalStatus')
					AND GOALYEAR=@GoalYear												
			
				END
				UPDATE EMPLPLAN 
				SET 
					MULTIYEARGOALSTATUSID =@GoalStatusID
					,MultiYearGoalStatusDt=GETDATE()
				WHERE 
					PLANID=@PlanID
					AND PLANYEAR=@PlanYear
					AND PLANTYPEID = @SDPlanTypeID
					
				UPDATE PLANGOAL
				SET
					GOALSTATUSID=@GoalStatusID
					,LASTUPDATEDBYID=@UserID
					,LASTUPDATEDDT=GETDATE()
				WHERE
					PLANID=@PlanID
					AND CREATEDBYID=@UserID
					AND ISDELETED=0 
					AND GOALYEAR=@GoalYear			
			END
			-------------evaluator/manager -'Approved'-------------
			IF(@IsEval = 1)
			BEGIN
				UPDATE EMPLPLAN 
				SET 
					MULTIYEARGOALSTATUSID =@GoalStatusID
					,MultiYearGoalStatusDt=GETDATE()
				WHERE 
					PLANID=@PlanID
					AND PLANYEAR=@PlanYear
					AND PLANTYPEID = @SDPlanTypeID
								
				UPDATE PLANGOAL
				SET
					GOALSTATUSID=@GoalStatusID
					,LASTUPDATEDBYID=@UserID
					,LASTUPDATEDDT=GETDATE()
				WHERE
					PLANID=@PlanID					
					AND ISDELETED=0 
					AND GOALYEAR=@GoalYear
			END
				
		END
	-----------Non-Admin(Reset)----reset all goals		
		ELSE --IF @IsAdmin =1
		BEGIN
			
		IF @GoalStatus = 'In Process'	-- Revert goal staus (if approved)	
			BEGIN
				SELECT @GoalStatusID = CodeID FROM  CodeLookUp WHERE CodeText = 'Not Yet Submitted' and CodeType = 'GoalStatus'
			END
			--1. Update PlanGoal
			UPDATE PlanGoal
			SET
				GoalStatusID = @GoalStatusID
				,LastUpdatedByID = @UserID
				,LastUpdatedDt = GETDATE()
			WHERE
				IsDeleted = 0
			AND	PlanID = @PlanID
			AND GoalYear= @SDPlanTypeID
			--2. Update EmplPlan
			UPDATE EmplPlan
			SET 
				MultiYearGoalStatusID=@GoalStatusID
				,MultiYearGoalStatusDt=GETDATE()					
				,LastUpdatedByID=@UserID
				,LastUpdatedDt=GETDATE()
			WHERE PlanID=@PlanID					
				AND PLANYEAR=@PlanYear
				AND PLANTYPEID = @SDPlanTypeID 	
			end		
	END
	
	----------Returned-----------
	ELSE --IF @GoalStatus = 'Returned'  
	BEGIN		
			UPDATE PlanGoal
			SET
				GoalStatusID=@GoalStatusID
				,LastUpdatedByID = @UserID
				,LastUpdatedDt = GETDATE()			
			WHERE PlanID=@PlanID
						AND GoalYear=@PlanYear
						AND IsDeleted=0
						AND GoalStatusID =(SELECT
												TOP 1 CodeID
											FROM
												CodeLookUp
											WHERE
												CodeText = 'Awaiting Approval' and CodeType = 'GoalStatus')
		
			--2. Update EmplPlan
			UPDATE EmplPlan
			SET 
				MultiYearGoalStatusID=@GoalStatusID
				,MultiYearGoalStatusDt=GETDATE()
				,LastUpdatedByID=@UserID
				,LastUpdatedDt=GETDATE()
			WHERE PlanID=@PlanID					
				AND PLANYEAR=@PlanYear
				AND PLANTYPEID = @SDPlanTypeID 
		END
	END
	
END
GO
