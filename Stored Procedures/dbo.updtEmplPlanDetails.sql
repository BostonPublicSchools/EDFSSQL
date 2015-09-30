SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 08/23/2012
-- Description:	Update the changes in plan details.
-- =============================================

CREATE PROCEDURE [dbo].[updtEmplPlanDetails]
@PlanID as int,
	@EmplID as nchar(6),
	@UserID as nchar(6),
	@UserName as nvarchar(150),
	--@PlanType 
	@PlanTypeID as int, 
	@PlanStartDt as DateTime,
	@PlanEndDt as DateTime,
	--@PlanDuration as int,
	@PlanActive as bit,
	@PlanEndDate datetime= null,
	@PlanEndReasonID int = null,
	@GoalStatus as nvarchar(50),
	@GoalStatusID as int,
	@GoalStatusDt as DateTime,
	@SelfAssmntSigned as  bit,
	@SelfAssmntStatusChangeDt as DateTime,
	
	@EvalTypeID as  int,
	@EvalEndDt as DateTime,
	@EvalID as int,
	@IsGoalStatusChanged as bit,
	--@IsActionStepStatusChanged as bit,	
	@IsEvaluationChanged as bit,
	@IsMultiYearPlan as bit =null,	
	
	@GoalStatusID_NextYear as int =null,
	@GoalStatusDt_NextYear as DateTime =null,
		
	--@ActionStepStatusID_NextYear as int =null,
	--@ActionStepStatusDt_NextYear as Datetime =null,
	
	@IsNextYearGoalStatusChanged as bit =null
	--@IsNextYearActionStepStatusChanged as bit =null
AS
BEGIN
SET NOCOUNT ON;

DECLARE @PlanYear int 
Declare @OldPlanTypeID int, @OldPlanYear int
Declare @oldPlanEndDt DateTime, @CreatedByDt datetime
DECLARE @ActionStepStatus as nvarchar(50) = null
DECLARE @ActionStepStatusID as int = 0
DECLARE @ActionStepStatusChangeDt as DateTime = null

SELECT @OldPlanTypeID=PlanTypeID,@OldPlanYear=PlanYear, @oldPlanEndDt=PlanSchedEndDt, @CreatedByDt=CreatedByDt FROM EmplPlan WHERE PlanID = @PlanID
SELECT @EmplID = emplid from EmplEmplJob where empljobid = (select empljobid from EmplPlan WHERE PlanID = @PlanID)

IF @IsMultiYearPlan = 1 AND @OldPlanYear=2-- Only for SD Plan and ALREADY IN 2ND yr plan	
	set @PlanYear=@OldPlanYear
ELSE
	set @PlanYear=1

UPDATE EmplPlan SET
		PlanTypeID = @PlanTypeID,
		PlanStartDt = (CASE
						WHEN
						@PlanStartDt = NULL OR @PlanStartDt = ''
						THEN
						NULL
						ELSE
						@PlanStartDt
						END
						),
		PlanSchedEndDt = (CASE
					WHEN
					@PlanEndDt = NULL OR @PlanEndDt = ''
					THEN
					NULL
					ELSE
					@PlanEndDt
					END
					) ,
		PlanYear =@PlanYear,
		IsMultiYearPlan = (CASE
					WHEN
					@IsMultiYearPlan = NULL OR @IsMultiYearPlan = ''
					THEN
					NULL
					ELSE
					@IsMultiYearPlan
					END
					) ,		
		PlanActive = @PlanActive,
		PlanActEndDt = (CASE
						WHEN 
						@PlanEndDate = null or @PlanEndDate =''
						THEN 
						NULL
						ELSE
						@PlanEndDate
						end
						),
		PlanEndReasonID = (CASE
							WHEN 
							@PlanEndReasonID = null OR @PlanEndReasonID = ''
							THEN
							NULL
							ELSE
							@PlanEndReasonID
							end 
							),
		--Duration = @PlanDuration,
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE(),
		GoalStatusID = @GoalStatusID,
		GoalStatusDt = @GoalStatusDt,
		IsSignedAsmt = @SelfAssmntSigned,
		SignatureAsmt = (CASE
						WHEN @SelfAssmntSigned=0
						THEN NULL
						WHEN SignatureAsmt IS null And @SelfAssmntSigned=1 
						THEN @UserName
						ELSE SignatureAsmt
						END
						),
		DateSignedAsmt = (CASE
						WHEN @SelfAssmntSigned=0 
						THEN NULL
						WHEN (@SelfAssmntStatusChangeDt IS NOT NULL OR @SelfAssmntStatusChangeDt != '' ) And @SelfAssmntSigned=1 
						THEN @SelfAssmntStatusChangeDt
						ELSE DateSignedAsmt
						END
						),
		--ActnStepStatusID = @ActionStepStatusID,
		--ActnStepDt = (CASE
		--				WHEN
		--				@ActionStepStatusChangeDt = NULL OR @ActionStepStatusChangeDt = ''
		--				THEN
		--				NULL
		--				ELSE
		--				@ActionStepStatusChangeDt
		--				END
		--				),
		--DateSignedActnStep = (CASE
		--				WHEN
		--				@ActionStepStatusChangeDt = NULL OR @ActionStepStatusChangeDt = ''
		--				THEN
		--				NULL
		--				ELSE
		--				@ActionStepStatusChangeDt
		--				END
		--				),
		MultiYearGoalStatusID = (case when @GoalStatusID_NextYear IS NOT NULL AND @IsNextYearGoalStatusChanged = 1 THEN @GoalStatusID_NextYear ELSE MultiYearGoalStatusID END),		
		MultiYearGoalStatusDt =  (case when @GoalStatusDt_NextYear IS NOT NULL AND @IsNextYearGoalStatusChanged = 1 THEN @GoalStatusDt_NextYear ELSE MultiYearGoalStatusDt END)
		--MultiYearActnStepStatusID =(case when @ActionStepStatusID_NextYear IS NOT NULL AND @IsNextYearActionStepStatusChanged =1 THEN @ActionStepStatusID_NextYear ELSE MultiYearActnStepStatusID END),
		--MultiYearActnStepDt=(case when @ActionStepStatusDt_NextYear IS NOT NULL AND @IsNextYearActionStepStatusChanged =1 THEN @ActionStepStatusDt_NextYear ELSE MultiYearActnStepDt END)						
WHERE PlanID = @PlanID	


IF @EvalTypeID != 0 AND @EvalID > 0 AND @IsEvaluationChanged = 1
BEGIN
 UPDATE Evaluation SET
		EvalTypeID = @EvalTypeID,
		EditEndDt =  (CASE
						WHEN
						@EvalEndDt = NULL OR @EvalEndDt = ''
						THEN
						NULL
						ELSE
						(Convert(varchar(50), CONVERT(date, @EvalEndDt))+' 23:59:59.999')						
						END
						),
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE()
	WHERE PlanID = @PlanID AND EvalID = @EvalID
END

IF  @IsGoalStatusChanged =1
	BEGIN
		IF  @GoalStatus = 'Approved'			
			BEGIN 
			  SELECT @ActionStepStatusID =  CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Approved'	
			  
				UPDATE PlanGoal 
				SET GoalStatusID = @GoalStatusID,
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE GoalStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and (CodeText='Approved' OR CodeText = 'Not Applicable' OR CodeText='Draft'))
				AND PlanID = @PlanID
				And GoalYear=1 And IsDeleted=0
				
				UPDATE GoalActionStep 
				SET ActionStepStatusID = @ActionStepStatusID,
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE ActionStepStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='AcnStatus' and (CodeText='Approved' OR CodeText = 'Not Applicable' OR CodeText='Draft'))
				AND GoalID IN (SELECT  GoalID FROM PlanGoal WHERE PlanID = @PlanID And GoalYear=1 And IsDeleted=0)
				AND IsDeleted=0
			END 	
		ELSE IF   @GoalStatus = 'Not Yet Submitted'
			BEGIN 
				SELECT @ActionStepStatusID =  CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Not Yet Submitted'	
				UPDATE PlanGoal 
				SET GoalStatusID = (CASE WHEN CreatedByID = @EmplID THEN @GoalStatusID 
										 ELSE (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and (CodeText='In Process')) END) ,
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE 				
					PlanID = @PlanID And GoalYear=1	And IsDeleted=0	
					
				UPDATE GoalActionStep 
				SET ActionStepStatusID = (CASE WHEN CreatedByID = @EmplID THEN @ActionStepStatusID 
											   ELSE (SELECT TOP 1 CodeID from CodeLookUp where CodeType='AcnStatus' and (CodeText='In Process')) END),
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()				
				WHERE GoalID IN (SELECT  GoalID FROM PlanGoal WHERE PlanID = @PlanID And GoalYear=1 And IsDeleted=0)				
				AND IsDeleted=0		
			END 	

		ELSE IF @GoalStatus = 'Returned' 
			BEGIN 
				SELECT @ActionStepStatusID =  CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Returned'
				UPDATE PlanGoal 
				SET GoalStatusID = (CASE WHEN CreatedByID = @EmplID AND GoalStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and CodeText='Draft') 
												THEN @GoalStatusID  -- 'Returned'
										WHEN CreatedByID = @EmplID AND GoalStatusID IN (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and (CodeText='Draft' or CodeText='Not Yet Submitted') )
												THEN (SELECT TOP 1 CodeID from CodeLookUp where CodeType='GoalStatus' and CodeText='Not Yet Submitted')
										WHEN CreatedByID != @EmplID 
											THEN (SELECT TOP 1 CodeID from CodeLookUp where CodeType='GoalStatus' and CodeText='In Process')											
										 END) ,
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE PlanID = @PlanID	And GoalYear=1 And IsDeleted=0	
				
				UPDATE GoalActionStep 
				SET ActionStepStatusID = (CASE 
											WHEN CreatedByID = @EmplID AND ActionStepStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Draft') 
												THEN @ActionStepStatusID  -- 'Returned'
											WHEN CreatedByID = @EmplID AND ActionStepStatusID IN (SELECT CodeID from CodeLookUp where CodeType='AcnStatus' and (CodeText='Draft' or CodeText='Not Yet Submitted') )
												THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Not Yet Submitted')
											WHEN CreatedByID != @EmplID 
												THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='In Process')
											END),
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()				
				WHERE GoalID IN (SELECT  GoalID FROM PlanGoal WHERE PlanID = @PlanID And GoalYear=1 And IsDeleted=0)						
					  AND IsDeleted=0				
			END 
			
		ELSE IF @GoalStatus = 'Awaiting Approval'
			BEGIN 
				SELECT @ActionStepStatusID =  CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Awaiting Approval'
				UPDATE PlanGoal 
				SET GoalStatusID = (CASE 
										WHEN CreatedByID = @EmplID AND GoalStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and (CodeText = 'Draft') )
											THEN @GoalStatusID 	-- 'Awaiting Approval'
										WHEN CreatedByID = @EmplID AND GoalStatusID IN (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and (CodeText='Not Yet Submitted' or  CodeText = 'Draft') )
											THEN (SELECT TOP 1 CodeID from CodeLookUp where CodeType='GoalStatus' and CodeText='Draft')
										WHEN CreatedByID != @EmplID 
											THEN (SELECT TOP 1 CodeID from CodeLookUp where CodeType='GoalStatus' and CodeText='In Process')											
										 END) ,
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE PlanID = @PlanID	And GoalYear=1 And IsDeleted=0					
				
				UPDATE GoalActionStep 
				SET ActionStepStatusID = (CASE 
											WHEN CreatedByID = @EmplID AND ActionStepStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='AcnStatus' and (CodeText = 'Draft') )
												THEN @ActionStepStatusID 	-- 'Awaiting Approval'					
											WHEN CreatedByID = @EmplID AND ActionStepStatusID IN (SELECT CodeID from CodeLookUp where CodeType='AcnStatus' and (CodeText='Not Yet Submitted' or  CodeText = 'Draft') )
												THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Draft')										
											WHEN CreatedByID != @EmplID 
												THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='In Process')											   
											END),
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()				
				WHERE GoalID IN (SELECT  GoalID FROM PlanGoal WHERE PlanID = @PlanID And GoalYear=1 And IsDeleted=0)						
					AND IsDeleted=0
				
			END 						
	END

--IF  @IsActionStepStatusChanged =1
--	BEGIN
--		IF  @ActionStepStatus = 'Approved'
--			BEGIN 
				
--			END 	
--		ELSE IF   @ActionStepStatus = 'Not Yet Submitted'
--			BEGIN 
				
--			END 	
--		ELSE IF @ActionStepStatus = 'Returned' 
--			BEGIN 
				
--			END 
--		ELSE IF @ActionStepStatus = 'Awaiting Approval'
--			BEGIN 
			
--			END 		
--END

--######Next Year goal /action steps update######
IF  @IsNextYearGoalStatusChanged = 1
	BEGIN
		DECLARE @GoalStatusNext as nvarchar(50)
		SELECT @GoalStatusNext = CodeText from codelookup where codeid= @GoalStatusID_NextYear 
		
		IF  @GoalStatusNext = 'Approved'
			BEGIN 
			    SELECT @ActionStepStatusID =  CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Approved'		
			    			
				UPDATE PlanGoal 
				SET GoalStatusID = @GoalStatusID_NextYear,
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE GoalStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and (CodeText='Approved' OR CodeText = 'Not Applicable' OR CodeText='Draft'))
					AND PlanID = @PlanID And GoalYear=2 AND IsDeleted=0		
					
				UPDATE GoalActionStep 
				SET ActionStepStatusID = @ActionStepStatusID,
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE ActionStepStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='AcnStatus' and (CodeText='Approved' OR CodeText = 'Not Applicable'OR CodeText='Draft'))
				AND GoalID IN (SELECT  GoalID FROM PlanGoal WHERE PlanID = @PlanID And GoalYear=2 And IsDeleted=0)
				AND IsDeleted=0	
			END 	
		ELSE IF   @GoalStatusNext = 'Not Yet Submitted'
			BEGIN 
				SELECT @ActionStepStatusID =  CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Not Yet Submitted'	
				  
				UPDATE PlanGoal 
				SET GoalStatusID = (CASE WHEN CreatedByID = @EmplID THEN @GoalStatusID_NextYear 
										 ELSE (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and (CodeText='In Process')) END) ,
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE 		
					PlanID = @PlanID And GoalYear=2	AND IsDeleted=0	
				
				UPDATE GoalActionStep 
				SET ActionStepStatusID = (CASE WHEN CreatedByID = @EmplID THEN @ActionStepStatusID 
											   ELSE (SELECT CodeID from CodeLookUp where CodeType='AcnStatus' and (CodeText='In Process')) END),
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE GoalID IN (SELECT  GoalID FROM PlanGoal WHERE PlanID = @PlanID And GoalYear=2 And IsDeleted=0)
				AND IsDeleted=0					
			END 	
		ELSE IF @GoalStatusNext = 'Returned' 
			BEGIN 
				SELECT @ActionStepStatusID =  CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Returned'					
				UPDATE PlanGoal 				
				SET GoalStatusID = (CASE WHEN CreatedByID = @EmplID AND GoalStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and CodeText='Draft') 
												THEN @GoalStatusID_NextYear  -- 'Returned'
											WHEN CreatedByID = @EmplID AND GoalStatusID IN (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and (CodeText='Draft' or CodeText='Not Yet Submitted') )
												THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='GoalStatus' and CodeText='Not Yet Submitted')
										WHEN CreatedByID != @EmplID 
											THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='GoalStatus' and CodeText='In Process')											
										 END) ,										 
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()				
				WHERE PlanID = @PlanID	AND GoalYear=2 AND IsDeleted=0		
				
				UPDATE GoalActionStep 				
				SET ActionStepStatusID = (CASE 
											WHEN CreatedByID = @EmplID AND ActionStepStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Draft') 
												THEN @ActionStepStatusID  -- 'Returned'
											WHEN CreatedByID = @EmplID AND ActionStepStatusID IN (SELECT CodeID from CodeLookUp where CodeType='AcnStatus' and (CodeText='Draft' or CodeText='Not Yet Submitted') )
												THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Not Yet Submitted')
											WHEN CreatedByID != @EmplID 
												THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='In Process')
											END),											   
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE GoalID IN (SELECT  GoalID FROM PlanGoal WHERE PlanID = @PlanID And GoalYear=2 And IsDeleted=0)
				AND IsDeleted=0	
			END 
		ELSE IF @GoalStatusNext = 'Awaiting Approval'
			BEGIN 
				SELECT @ActionStepStatusID =  CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Awaiting Approval'
				UPDATE PlanGoal 				
				SET GoalStatusID = (CASE 
										WHEN CreatedByID = @EmplID AND GoalStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and (CodeText = 'Draft') )
											THEN @GoalStatusID_NextYear 	-- 'Awaiting Approval'
										WHEN CreatedByID = @EmplID AND GoalStatusID IN (SELECT CodeID from CodeLookUp where CodeType='GoalStatus' and (CodeText='Not Yet Submitted' or  CodeText = 'Draft') )
											THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='GoalStatus' and CodeText='Draft')
										WHEN CreatedByID != @EmplID 
											THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='GoalStatus' and CodeText='In Process')											
										 END) ,									 
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()				
				WHERE PlanID = @PlanID	And GoalYear=2 And IsDeleted=0		
				
				UPDATE GoalActionStep 				
				SET ActionStepStatusID = (CASE 
											WHEN CreatedByID = @EmplID AND ActionStepStatusID NOT IN (SELECT CodeID from CodeLookUp where CodeType='AcnStatus' and (CodeText = 'Draft') )
												THEN @ActionStepStatusID 	-- 'Awaiting Approval'					
											WHEN CreatedByID = @EmplID AND ActionStepStatusID IN (SELECT CodeID from CodeLookUp where CodeType='AcnStatus' and (CodeText='Not Yet Submitted' or  CodeText = 'Draft') )
												THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='Draft')										
											WHEN CreatedByID != @EmplID 
												THEN (SELECT top 1 CodeID from CodeLookUp where CodeType='AcnStatus' and CodeText='In Process')											   
											END),											   
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE GoalID IN (SELECT  GoalID FROM PlanGoal WHERE PlanID = @PlanID And GoalYear=2 And IsDeleted=0)
				AND IsDeleted=0	
			END 			
	END

--IF  @IsNextYearActionStepStatusChanged=1
--	BEGIN
--		DECLARE @ActionStepStatusNext as nvarchar(50)
--		SELECT @ActionStepStatusNext= CodeText from codelookup where codeid= @ActionStepStatusID_NextYear
		
--		IF  @ActionStepStatusNext = 'Approved'
--			BEGIN 
			
--			END 	
--		ELSE IF   @ActionStepStatusNext = 'Not Yet Submitted'
--			BEGIN 
					
--			END 	
--		ELSE IF @ActionStepStatusNext = 'Returned' 
--			BEGIN 
				
--			END 
--		ELSE IF @ActionStepStatusNext = 'Awaiting Approval'
--			BEGIN 
				
--			END 			
--END

	
	
	
END

GO
