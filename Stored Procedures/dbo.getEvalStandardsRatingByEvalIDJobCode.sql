SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 06/14/2012
-- Description:	Get evaluation standards rating by evaluation id and JobCode
-- =============================================
CREATE PROCEDURE [dbo].[getEvalStandardsRatingByEvalIDJobCode]
		@EvalID AS int
	,@RubricID as int
AS
BEGIN
	SET NOCOUNT ON;
select	esr.EvalStdRatingID
		,esr.EvalID
		,rs.StandardID
		,rs.StandardText
		,esr.RatingID
		,isnull(c.CodeText,'') as Rating
		,isnull(esr.Rationale,'') as Rationale
		,minc.CodeID as minCodeID
		,minc.CodeText as minCodeText
		,m.MinCodeSortOrder
		,maxc.CodeID as maxCodeID
		,maxc.CodeText as maxCodeText
		,m.MaxCodeSortOrder 
		,0 as PreviousRating
		,eval.EvaluatorSignedDt
from RubricStandard rs
left join EvaluationStandardRating esr on rs.StandardID = esr.StandardID and esr.EvalID =@EvalID
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
join Evaluation as eval on esr.EvalID = eval.EvalID
							
WHERE rs.RubricID = @RubricID	
AND rs.IsActive = 1
AND rs.IsDeleted = 0			
and eval.EvalID = @EvalID
UNION	
select	esr.EvalStdRatingID
		,esr.EvalID
		,rs.StandardID
		,rs.StandardText
		,esr.RatingID
		,isnull(c.CodeText,'') as Rating
		,isnull(esr.Rationale,'') as Rationale
		,minc.CodeID as minCodeID
		,minc.CodeText as minCodeText
		,m.MinCodeSortOrder
		,maxc.CodeID as maxCodeID
		,maxc.CodeText as maxCodeText
		,m.MaxCodeSortOrder 
		,1 as PreviousRating
		,eval.EvaluatorSignedDt
from RubricStandard rs
join Evaluation e on e.EvalID = @EvalID
left join EmplPlan p on p.PlanID = e.PlanID
left join EvaluationStandardRating esr on rs.StandardID = esr.StandardID and esr.EvalID = p.PrescriptEvalID
--left join EvaluationStandardRating esr on rs.StandardID = esr.StandardID and esr.EvalID =@EvalID
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
WHERE rs.RubricID = @RubricID	
AND rs.IsActive = 1
AND rs.IsDeleted = 0				
and esr.RatingID is not NULL
and eval.EvalID = @EvalID
							
END	
GO
