SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 01/17/2013
-- Description: 
-- =============================================

CREATE Function [dbo].[funPlanCurrentStatus](@PlanID Integer, @EvalID Integer)
Returns nvarchar(100)
AS
BEGIN
	DECLARE @Final nvarchar(100)
	SET @Final = 'Plan'
	IF(@EvalID IS NOT NULL)
	Begin
		SET @Final = (select cd.CodeText from EmplPlan ep												 
						JOIN Evaluation ev on ev.EvalID = @EvalID
						LEFT JOIN CodeLookUp cd on cd.CodeID = ev.EvalTypeID                    
						where ep.PlanActive = 1 and ep.PlanID = @PlanID)
	END
	ELSE IF(Exists(Select * from PlanGoal where PlanID = @PlanID))
	BEGIN 
		DECLARE @GoalStatus nvarchar(100)
		SET @GoalStatus = (Select CodeText from CodeLookUp where CodeID = (Select GoalStatusID from EmplPlan where PlanID = @PlanID))
		IF(Exists(Select * from GoalActionStep where GoalID in (Select GoalID from PlanGoal where PlanID = @PlanID) AND @GoalStatus = 'Approved'))
			BEGIN
			 DECLARE @AcnStepStatus nvarchar(100)
			 SET @AcnStepStatus = (Select CodeText from CodeLookUp where CodeID = (Select ActnStepStatusID from EmplPlan where PlanID = @PlanID))
			 SET @Final =  (CASE WHEN @AcnStepStatus IS NULL THEN 'Action Steps' ELSE 'Action Steps ' + @AcnStepStatus END)
			END
		ELSE
			BEGIN
			 SET @Final =  (CASE WHEN @GoalStatus IS NULL THEN 'Goals' ELSE 'Goals ' + @AcnStepStatus END)
			END		
	END
	ELSE IF(Exists(Select * from PlanSelfAsmt where PlanID = @PlanID))
	BEGIN
		SET @Final = 'Self-Assessment'
	END
	ELSE IF(Exists(Select * from EmplPlanEvidence where PlanID = @PlanID))
	BEGIN
		SET @Final = 'Collect Evidence'
	END
	ELSE
	BEGIN 
	 set @Final = '#N/A'
	END
	
	return CASE WHEN @Final IS NULL THEN 'Plan' ELSE @Final END
END
GO
