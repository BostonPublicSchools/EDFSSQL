SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 04/02/2012
-- Description:	List of available Evaluations Type
-- =============================================
Create PROCEDURE [dbo].[getEvalTypes]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		c.CodeID
		,c.Code
		,c.CodeText
		,c.CodeSortOrder
	FROM
		CodeLookUp AS c (NOLOCK)
	WHERE
		c.CodeActive = 1
	AND c.CodeType = 'EvalType'		
		
END
GO
