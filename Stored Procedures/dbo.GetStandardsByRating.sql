SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/08/2012
-- Description:	Returns List of Stnadards with id which has needs improvement/unsatisfactory rating 
-- =============================================
Create PROCEDURE [dbo].[GetStandardsByRating]
	@EvalID AS NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
SELECT 
	esr.StandardID
	,rs.StandardText
	,rs.SortOrder as StandardSortOrder 
	,ESR.RatingID 
	,c.CodeText as StandardRating
FROM 
	EvaluationStandardRating esr
join RubricStandard rs on esr.StandardID = rs.StandardID
join CodeLookUp c on esr.RatingID = c.CodeID
						and c.CodeText in ('Unsatisfactory','Needs Improvement') 
						and CodeType='StdRating'
where 
	esr.EvalID =@EvalID

		
END
GO
