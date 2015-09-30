SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 04/10/2012
-- Description:	Returns single code record
-- =============================================
CREATE PROCEDURE [dbo].[getCodesByCode]
	@Code AS nvarchar(10) = NULL
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
		,c.CodeActive
	FROM
		CodeLookUp AS c (NOLOCK)
	WHERE
--		c.CodeActive = 1
--	AND 
		c.Code = @Code
		
END
GO
