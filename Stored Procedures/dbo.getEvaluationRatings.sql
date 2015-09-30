SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 04/2/2012
-- Description:	List of available Evaluation Rating
-- =============================================
Create PROCEDURE [dbo].[getEvaluationRatings]
	@CodeSortOrderMin as int = 1
	,@RubricID as int 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		c.CodeID
		,c.Code
		,c.CodeText
		,c.CodeSortOrder
		,dbo.udf_StripHTML(c.CodeSubText)
	FROM
		CodeLookUp AS c (NOLOCK)
		JOIN RubricHdr AS rh (NOLOCK) ON rh.RubricName = dbo.udf_StripHTML(c.CodeSubText)
	WHERE
		c.CodeActive = 1
	AND c.CodeType = 'EvalRating'		
	AND c.CodeSortOrder >= @CodeSortOrderMin
	AND rh.RubricID = @RubricID
	ORDER BY 
		rh.RubricID,c.CodeSortOrder
END

GO
