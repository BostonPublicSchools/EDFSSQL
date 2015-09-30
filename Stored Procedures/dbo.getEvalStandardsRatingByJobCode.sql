SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/12/2012
-- Description:	Get evaluation standards rating by  JobCode
-- =============================================
CREATE PROCEDURE [dbo].[getEvalStandardsRatingByJobCode]
	@JobCode as nchar(6) 
AS
BEGIN
	SET NOCOUNT ON;
select	esr.EvalStdRatingID
		,esr.EvalID
		,rs.StandardID
		,rs.StandardText
		,rs.JobCode
		--,rs.SortOrder as StandardSortOrder
		,esr.RatingID
		,isnull(c.CodeText,'') as Rating
		,isnull(esr.Rationale,'') as Rationale
		,minc.CodeID as minCodeID
		,minc.CodeText as minCodeText
		,m.MinCodeSortOrder
		,maxc.CodeID as maxCodeID
		,maxc.CodeText as maxCodeText
		,m.MaxCodeSortOrder 
		,eval.EvaluatorSignedDt
from vwRubricStandards rs
left join EvaluationStandardRating esr on rs.StandardID = esr.StandardID --and esr.EvalID =@EvalID
left join CodeLookUp c on c.CodeID = esr.RatingID and c.CodeType ='stdRating'
left join (SELECT
				esr.EvalID
				,MAX(c.CodeSortOrder) as MaxCodeSortOrder
				,MIN(c.CodeSortOrder) as MinCodeSortOrder
			FROM
				CodeLookUp as c
			JOIN EvaluationStandardRating as esr  on c.CodeID = esr.RatingID 	
			WHERE 
				c.CodeType = 'stdRating'
			GROUP BY
				esr.EvalID) as m on m.EvalID = esr.EvalID
left join CodeLookUp as maxc on m.MaxCodeSortOrder = maxc.CodeSortOrder
							and maxc.CodeType ='stdRating'
left join CodeLookUp as minc on m.MinCodeSortOrder = minc.CodeSortOrder
							and minc.CodeType ='stdRating'
left join Evaluation as eval on esr.EvalID = eval.EvalID							
WHERE rs.JobCode = 	@JobCode	
AND rs.StandardIsActive = 1
AND rs.StandardIsDeleted = 0			
							
END	
GO
