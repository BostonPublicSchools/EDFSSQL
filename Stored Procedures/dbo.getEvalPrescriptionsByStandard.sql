SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/08/2012
-- Description:	Get evaluation prescription by EvalID and StandardID
-- =============================================
Create PROCEDURE [dbo].[getEvalPrescriptionsByStandard]
		@EvalID AS int
		,@StandardID as int
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
			
	FROM EvaluationPrescription ep
	LEFT JOIN RubricIndicator ri on ri.IndicatorID = ep.IndicatorID
	LEFT JOIN RubricStandard rs on rs.StandardID = ri.StandardID
	Where ep.EvalID = @EvalID and ri.StandardID =@StandardID and ep.IsDeleted = 0
END	
GO
