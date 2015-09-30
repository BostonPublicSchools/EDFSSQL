SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 01/17/2013
-- Description: 
-- =============================================


CREATE Function [dbo].[vwFormativeEvalDt](@PlanID Int)
RETURNS TABLE
AS 
RETURN (SELECT MAX(eval.EvalID) AS FormativeEvalID, eval.PlanID, DATEADD(d,(DATEDIFF(DAYOFYEAR, ep.PlanStartDt, ep.PlanSchedEndDt)/2),ep.PlanStartDt) as FormativeTargetDate 
			,eval.EvalDt AS FormativeActualDt FROM EmplPlan ep
		JOIN Evaluation eval on ep.PlanID = eval.PlanID 
		WHERE eval.EvalTypeID in (Select CodeID from CodeLookUp where CodeType = 'EvalType' and CodeText like 'Formative%')and ep.PlanID = @PlanID
		GROUP BY eval.PlanID, ep.PlanStartDt, ep.PlanSchedEndDt, eval.EvalDt 
		)
GO
