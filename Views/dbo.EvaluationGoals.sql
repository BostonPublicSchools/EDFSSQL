SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Avery, Bryce
-- Create date: 05/15/2012
-- Description:	Goal information for evaluation reports
-- =============================================
CREATE VIEW [dbo].[EvaluationGoals]
AS
	SELECT 
		ev.EvalID
		,gt.CodeID AS GoalTypeID
		,gt.CodeText AS GoalTypeText
		,pg.GoalID
		,pg.GoalText
		,gep.Rationale
		,gp.CodeID AS ProgressCodeID
		,gp.CodeText AS ProgressCodeTest
	FROM
		Evaluation				AS ev	(NOLOCK)	
	JOIN EmplPlan				AS ep	(NOLOCK)	ON ev.PlanID = ep.PlanID and ep.IsInvalid = 0		
	JOIN GoalEvaluationProgress	AS gep	(NOLOCK)	ON ev.EvalID = gep.EvalId
	JOIN PlanGoal				AS pg	(NOLOCK)	On gep.GoalID = pg.GoalID	
	JOIN CodeLookUp				AS gt	(NOLOCK)	On pg.GoalTypeID = gt.CodeID
	JOIN CodeLookUp				AS gp	(NOLOCK)	On gep.ProgressCodeID = gp.CodeID


GO
