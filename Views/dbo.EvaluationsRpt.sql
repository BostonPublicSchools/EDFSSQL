SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 05/17/2012
-- Description:	All evaluation information from evaluation report
-- =============================================
CREATE VIEW [dbo].[EvaluationsRpt]
AS
	SELECT
		eh.EvalID
		,eh.EmplID + CAST(eh.EvalID AS varchar) AS EmplIDEvalID
		,eh.MgrID
		,eh.ManagerName
		,eh.MgrJobCode
		,eh.MgrJobName
		,eh.SubEvalID 
		,eh.SubEvalName
		,eh.SubEvalJobCode
		,eh.SubEvalJobName
		,eh.EmplID
		,eh.NameFirst
		,eh.NameMiddle
		,eh.NameLast
		,eh.EmplName
		,eh.EmplActive
		,eh.EmplJobID
		,eh.JobCode
		,eh.JobName
		,eh.DeptID
		,eh.DeptName
		,eh.PlanTypeID
		,eh.PlanTypeName
		,eh.PlanStartDt
		,eh.PlanEndDt
		,eh.EvalTypeID
		,eh.EvalTypeName
		,eh.EvalDt
		,eh.EvaluatorsSignature
		,eh.EvaluatorSignedDt
		,eh.EmplSignature
		,eh.EmplSignedDt
		,eh.EmplCmnt
		,eh.EvaluatorsCmnt
		,eh.OverAllRatingTypeID
		,eh.OverAllRatingName
		,eh.OverallRatingRationale
		,eh.PlanMovingForwardID
		,eh.PlanMovingForwardName
		,eg.GoalTypeID
		,eg.GoalTypeText
		,eg.GoalID
		,eg.GoalText
		,eg.Rationale
		,eg.ProgressCodeID
		,eg.ProgressCodeTest
		,es.StandardID
		,es.StandardText
		,es.StandardDesc
		,es.Rationale AS StandardRationale
		,es.RatingID
		,es.RatingText
		,ep.StandardText AS PrescriptionStandardText
		,ep.StandardDesc AS PrescriptionStandardDesc
		,ep.IndicatorID
		,ep.IndicatorText
		,ep.IndicatorDesc
		,ep.ProblemStmt
		,ep.EvidenceStmt
		,ep.PrscriptionStmt
	FROM
		EvaluationHeader eh
	LEFT OUTER JOIN EvaluationGoals eg (NOLOCK) On eh.PlanID = eg.PlanID
	LEFT OUTER JOIN EvaluationStandards es (NOLOCK) On eh.EvalID = es.EvalID
	LEFT OUTER JOIN EvaluationPrescriptions ep (NOLOCK) On eh.EvalID = ep.EvalID
	
GO
