SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 05/16/2012
-- Description:	Standards information for evaluation reports
-- =============================================
CREATE VIEW [dbo].[EvaluationStandards]
AS
	SELECT 
		ev.EvalID
		,rs.StandardID
		,rs.StandardText
		,rs.StandardDesc
		,esr.Rationale
		,sr.CodeID AS RatingID
		,sr.CodeText AS RatingText
	FROM
		Evaluation				AS ev	(NOLOCK)
	JOIN EmplPlan				AS p	(NOLOCK)	ON ev.PlanID = p.PlanID and p.IsInvalid = 0		
	JOIN EvaluationStandardRating AS esr	(NOLOCK)	ON ev.EvalID = esr.EvalId
														
	JOIN RubricStandard				AS rs	(NOLOCK)	On esr.StandardID = rs.StandardID
														AND rs.IsDeleted = 0
	JOIN CodeLookUp				AS sr	(NOLOCK)	On esr.RatingID = sr.CodeID

GO
