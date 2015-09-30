SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/04/2012
-- Description:	Get evaluation prescription by EvalID
-- =============================================
CREATE PROCEDURE [dbo].[getEvalPrescriptionsByEvalID]
	@EvalID AS int

AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT	ep.PrescriptionId
			,rs.StandardID
			,rs.StandardText
			,ep.EvalID
			,ep.IndicatorID
			,ri.IndicatorText
			,ep.ProblemStmt
			,ep.EvidenceStmt
			,ep.PrscriptionStmt
			,rs.RubricID
			,e.EvalRubricID
			,ev.PlanID
	FROM EvaluationPrescription ep
	LEFT JOIN Evaluation ev on ep.EvalID =ev.EvalID	
	LEFT JOIN RubricIndicator ri on ri.IndicatorID = ep.IndicatorID
	LEFT JOIN RubricStandard rs on rs.StandardID = ri.StandardID
	LEFT OUTER JOIN Evaluation e on ep.EvalID = e.EvalID
	Where ep.EvalID = @EvalID and ep.IsDeleted = 0
	
END	
GO
