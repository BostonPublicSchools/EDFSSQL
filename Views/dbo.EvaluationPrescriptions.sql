SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 05/16/2012
-- Description:	Prescription information for evaluation reports
-- =============================================
CREATE VIEW [dbo].[EvaluationPrescriptions]
AS
	SELECT 
		ev.EvalID
		,rs.StandardID
		,rs.StandardText
		,rs.StandardDesc
		,ri.IndicatorID
		,ri.IndicatorText
		,ri.IndicatorDesc
		,ep.ProblemStmt
		,ep.EvidenceStmt
		,ep.PrscriptionStmt
	FROM
		Evaluation				AS ev	(NOLOCK)
	JOIN EmplPlan				AS p	(NOLOCK)	ON ev.PlanID = p.PlanID and p.IsInvalid = 0		
	JOIN EvaluationPrescription AS ep	(NOLOCK)	ON ev.EvalID = ep.EvalID
													AND ep.IsDeleted = 0
	JOIN RubricIndicator AS ri (NOLOCK)	ON ep.IndicatorID = ri.IndicatorID
	JOIN RubricStandard				AS rs	(NOLOCK)	On ri.StandardID = rs.StandardID
														AND rs.IsDeleted = 0

GO
