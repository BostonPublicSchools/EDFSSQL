SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 08/01/2012
-- Description:	Update the action step status after submiting.
-- =============================================

CREATE PROCEDURE [dbo].[updtActnStepStatus]
	@PlanID int = null,
	@IsSignedActnStep bit,
	@ActnStepStatus nvarchar(50),
	@SignatureActnStep nvarchar(50),
	@UserID nchar(6)
AS
BEGIN
SET NOCOUNT ON;
SET NOCOUNT ON;
 DECLARE @ActionStepStatusID AS int	
 DECLARE @PlanYear AS INT
 DECLARE @PlanTypeID AS INT
----------------------------------------------------------------------------	
	SELECT @ActionStepStatusID = CodeID 
	FROM  CodeLookUp 
	WHERE  CodeText = @ActnStepStatus and CodeType = 'AcnStatus'	
----------------------------------------------------------------------------	
	SELECT 
		@PlanYear = PlanYear, 
		@PlanTypeID =PlanTypeID
	FROM EmplPlan where PlanID=@PlanID		
----------------------------------------------------------------------------	
IF @PlanYear = 1 
BEGIN
	UPDATE EmplPlan 
	SET ActnStepStatusID = @ActionStepStatusID,
		SignatureActnStep = @SignatureActnStep,
		IsSignedActnStep = @IsSignedActnStep,
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE(),
		ActnStepDt = GETDATE(),
		DateSignedActnStep = GETDATE()
	WHERE 
		PlanID = @PlanID
END
ELSE IF (@PlanYear=2 AND @PlanTypeID=1)
BEGIN		
	UPDATE EmplPlan 
	SET MultiYearActnStepStatusID = @ActionStepStatusID,		
		MultiYearActnStepDt = GETDATE(),
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE()
	WHERE 
		PlanID = @PlanID	
END

	----------------------------------------------------------------------------	
	IF  @ActnStepStatus = 'Approved'
	BEGIN 
		UPDATE GoalActionStep 
		SET ActionStepStatusID = (Select CodeID FROM CodeLookUp WHERE CodeType='AcnStatus' and CodeText=@ActnStepStatus),
			LastUpdatedByID = @UserID, LastUpdatedDt = GETDATE()
		WHERE 
			GoalActionStep.GoalID in (SELECT PlanGoal.GoalID FROM PlanGoal WHERE PlanGoal.PlanID = @PlanID AND GoalYear=@PlanYear) 
			AND GoalActionStep.ActionStepStatusID NOT IN (SELECT CodeID FROM CodeLookUp WHERE CodeType='AcnStatus' and (CodeText='Not Applicable' OR CodeText ='Not Yet Submitted'))

	-- change the goal status to draft if its not yet submitted when approving.
			UPDATE GoalActionStep
			SET
			ActionStepStatusID = (SELECT
								CodeID
							FROM
								CodeLookUp
							WHERE
								CodeText = 'Draft' and CodeType = 'AcnStatus')
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE
			IsDeleted = 0
		AND	GoalID in (SELECT PlanGoal.GoalID FROM PlanGoal WHERE PlanGoal.PlanID = @PlanID AND GoalYear=@PlanYear) 
		AND ActionStepStatusID = (SELECT
								CodeID
							FROM
								CodeLookUp
							WHERE
								CodeText = 'Not Yet Submitted' and CodeType = 'AcnStatus')			
					
	END 
	-----------------------------------------------
	IF @ActnStepStatus = 'Awaiting Approval' OR @ActnStepStatus = 'Returned'
	BEGIN		
		UPDATE GoalActionStep 
		SET ActionStepStatusID = (Select CodeID FROM CodeLookUp WHERE CodeType='AcnStatus' and CodeText=@ActnStepStatus),
			LastUpdatedByID = @UserID, LastUpdatedDt = GETDATE()
		Where 
			GoalActionStep.GoalID in (SELECT PlanGoal.GoalID FROM PlanGoal WHERE PlanGoal.PlanID = @PlanID AND GoalYear=@PlanYear) 
			AND GoalActionStep.ActionStepStatusID NOT IN (Select CodeID FROM CodeLookUp WHERE CodeType='AcnStatus' and (CodeText='Approved' OR CodeText = 'In Process' OR CodeText='Not Applicable'))
	END	




END
GO
