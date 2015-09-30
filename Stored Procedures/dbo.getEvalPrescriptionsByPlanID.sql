SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/12/2012
-- Description:	Get evaluation prescription by PlanID
-- =============================================
CREATE PROCEDURE [dbo].[getEvalPrescriptionsByPlanID]
		@PlanID AS int
		
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
			--,(select codetext from CodeLookUp where CodeID= esr.RatingID ) [Rating]
			, c.CodeText [Rating]
			,(ri.IndicatorText + ' | ' + ep.PrscriptionStmt)[DisplayTag]
	FROM 
		EvaluationPrescription ep
		LEFT JOIN RubricIndicator ri on ri.IndicatorID = ep.IndicatorID
		LEFT JOIN RubricStandard rs on rs.StandardID = ri.StandardID
		LEFT JOIN Evaluation e on e.EvalID = ep.EvalID
		LEFT JOIN EvaluationStandardRating esr on esr.EvalID =ep.EvalID and esr.StandardID = ri.StandardID
		LEFT JOIN CodeLookUp c on c.CodeID=esr.RatingID
	WHERE 
		e.PlanID = @PlanID and ep.IsDeleted = 0 and e.IsSigned = 1 and e.IsDeleted = 0
		and CodeID in (select codeid from codelookup where codetype='StdRating' and (codetext='Needs Improvement' or codetext='Unsatisfactory'))
	ORDER BY 
		rs.StandardText,ri.IndicatorText
	--Where ep.EvalID = @EvalID and ri.StandardID =@StandardID and ep.IsDeleted = 0
END	
GO
