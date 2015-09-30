SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/02/2012
-- Description:	Get evaluation standards rating by EvalStdRatingID
-- =============================================
CREATE PROCEDURE [dbo].[getEvalStandardRating]
	@EvalStdRatingID AS int

AS
BEGIN
	SET NOCOUNT ON;
	
select	esr.EvalStdRatingID
		,esr.EvalID
		,esr.StandardID
		,rs.StandardText
		,esr.RatingID
		,c.CodeText as Rating
		,esr.Rationale 
		,eval.EvaluatorSignedDt
		,eval.IsSigned
from EvaluationStandardRating esr
left join RubricStandard rs on rs.StandardID = esr.StandardID
left join CodeLookUp c on c.CodeID = esr.RatingID and c.CodeType ='stdRating'
left join Evaluation as eval on esr.EvalID = eval.EvalID
WHERE EvalStdRatingID = @EvalStdRatingID

END	
GO
