SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 06/1/2012
-- Description:	Returns single code record by codeID
-- =============================================
CREATE PROCEDURE [dbo].[getCodesByCodeID]
	@CodeID AS int = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		c.CodeType
		,c.CodeID
		,c.Code
		,c.CodeText
		,c.CodeSubText
		,c.CodeSortOrder
	FROM
		CodeLookUp AS c (NOLOCK)
	WHERE
		c.CodeActive = 1
	AND c.CodeID = @CodeID
		
END
GO
