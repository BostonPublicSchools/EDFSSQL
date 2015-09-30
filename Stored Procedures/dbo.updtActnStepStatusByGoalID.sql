SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 05/09/2014	
-- Description:	Update the action step status by goalID after submiting.
-- =============================================

CREATE PROCEDURE [dbo].[updtActnStepStatusByGoalID]
	@GoalID int = null,	
	@GoalStatus nvarchar(50),	
	@UserID nchar(6)
AS
BEGIN
 
	IF  @GoalStatus = 'Approved'
	BEGIN 
		UPDATE GoalActionStep 
		SET ActionStepStatusID = (Select CodeID FROM CodeLookUp WHERE CodeType='AcnStatus' and CodeText=@GoalStatus),
			LastUpdatedByID = @UserID, LastUpdatedDt = GETDATE()
		WHERE 
			GoalActionStep.GoalID = @GoalID
			AND GoalActionStep.ActionStepStatusID NOT IN (SELECT CodeID FROM CodeLookUp WHERE CodeType='AcnStatus' and (CodeText='Not Applicable' OR CodeText ='Not Yet Submitted'))

	-- change the action step status to draft if its not yet submitted when approving.
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
		AND	GoalID =@GoalID
		AND ActionStepStatusID = (SELECT
								CodeID
							FROM
								CodeLookUp
							WHERE
								CodeText = 'Not Yet Submitted' and CodeType = 'AcnStatus')			
					
	END 
	-----------------------------------------------
	--ELSE IF @GoalStatus = 'Awaiting Approval'
	--BEGIN		
	--	UPDATE GoalActionStep 
	--	SET ActionStepStatusID = (Select CodeID FROM CodeLookUp WHERE CodeType='AcnStatus' and CodeText=@GoalStatus),
	--		LastUpdatedByID = @UserID, LastUpdatedDt = GETDATE()
	--	Where 
	--		GoalActionStep.GoalID = @GoalID
	--		AND GoalActionStep.ActionStepStatusID NOT IN (Select CodeID FROM CodeLookUp WHERE CodeType='AcnStatus' and (CodeText='Approved' OR CodeText = 'In Process' OR CodeText='Not Applicable'))
	--END	
	ELSE IF @GoalStatus = 'Returned'
	BEGIN		
		UPDATE GoalActionStep 
		SET ActionStepStatusID = (Select CodeID FROM CodeLookUp WHERE CodeType='AcnStatus' and CodeText=@GoalStatus),
			LastUpdatedByID = @UserID, LastUpdatedDt = GETDATE()
		Where 
			GoalActionStep.GoalID = @GoalID
			AND GoalActionStep.ActionStepStatusID NOT IN (Select CodeID FROM CodeLookUp WHERE CodeType='AcnStatus' and (CodeText = 'In Process'))
	END	
	ELSE IF @GoalStatus = 'Not Applicable'
	BEGIN
		UPDATE GoalActionStep 
		SET ActionStepStatusID = (Select CodeID FROM CodeLookUp WHERE CodeType='AcnStatus' and CodeText=@GoalStatus),
			LastUpdatedByID = @UserID, LastUpdatedDt = GETDATE()
		Where 
			GoalActionStep.GoalID = @GoalID
			
	
	END	

END
GO
