SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/12/2012
-- Description:	Get evaluation prescription by PlanID
-- =============================================
CREATE procedure [dbo].[sp_getEvalPrescriptionsByPlanID]
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
			,esr.EvalStdRatingID
			--,  ( select top 1 CodeText from CodeLookUp where CodeID =(
			--(select  PreviousText from changelog where TableName='EvaluationStandardRating' and IdentityID=esr.EvalStdRatingID and LoggedEvent='EvalStd rating change for EvalStdRatingID '+CAST(esr.EvalStdRatingID as NCHAR(6) ))
			--) ) [Rating]
			
	FROM EvaluationPrescription ep
	LEFT JOIN RubricIndicator ri on ri.IndicatorID = ep.IndicatorID
	LEFT JOIN RubricStandard rs on rs.StandardID = ri.StandardID
	LEFT JOIN Evaluation e on e.EvalID = ep.EvalID
	LEFT JOIN EvaluationStandardRating esr on esr.EvalID =ep.EvalID and esr.StandardID = ri.StandardID
	WHERE e.PlanID = @PlanID and ep.IsDeleted = 0 and e.IsSigned = 1
	--Where ep.EvalID = @EvalID and ri.StandardID =@StandardID and ep.IsDeleted = 0
END	
GO
