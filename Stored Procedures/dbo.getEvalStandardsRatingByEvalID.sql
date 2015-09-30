SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/02/2012
-- Description:	Get evaluation standards rating by evaluation id
-- =============================================
CREATE PROCEDURE [dbo].[getEvalStandardsRatingByEvalID]
	@EvalID AS int

AS
BEGIN
	SET NOCOUNT ON;
select	esr.EvalStdRatingID
		,esr.EvalID
		,rs.RubricID
		,rs.StandardID
		,rs.StandardText
		,rs.SortOrder as StandardSortOrder
		,esr.RatingID
		,isnull(c.CodeText,'') as Rating
		,isnull(esr.Rationale,'') as Rationale
		,minc.CodeID as minCodeID
		,minc.CodeText as minCodeText
		,m.MinCodeSortOrder
		,maxc.CodeID as maxCodeID
		,maxc.CodeText as maxCodeText
		,m.MaxCodeSortOrder
		--,e.EvaluatorSignedDt
		,(select EvaluatorSignedDt from Evaluation where EvalID=@EvalID) [EvaluatorSignedDt]  -- to get EvaluatorSignedDt w/o respect to evaluationStandard
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
--left join Evaluation as e on esr.EvalID = e.EvalID 
Where rs.IsActive = 1		
order  by rs.SortOrder						
END	

GO
