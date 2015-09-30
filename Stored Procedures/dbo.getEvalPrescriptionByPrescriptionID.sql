SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[getEvalPrescriptionByPrescriptionID]
	@PrescriptionID AS int

AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT	ep.PrescriptionId
			,ri.ParentIndicatorID
			,rs.StandardID
			,rs.StandardText
			,ep.EvalID
			,ep.IndicatorID
			,ri.IndicatorText
			,ep.ProblemStmt
			,ep.EvidenceStmt
			,ep.PrscriptionStmt
			
	FROM EvaluationPrescription ep
	LEFT JOIN RubricIndicator ri on ri.IndicatorID = ep.IndicatorID
	LEFT JOIN RubricStandard rs on rs.StandardID = ri.StandardID
	Where ep.PrescriptionId = @PrescriptionID and ep.IsDeleted = 0
END	
GO
