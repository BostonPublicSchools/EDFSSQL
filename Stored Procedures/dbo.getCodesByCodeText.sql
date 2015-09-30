SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Krunal, Khanpara
-- Create date: 04/08/2013
-- Description:	Returns single code record
-- =============================================
CREATE PROCEDURE [dbo].[getCodesByCodeText]
	@CodeType AS nvarchar(10) = NULL
	,@CodeText as nvarchar(50) = null
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
	AND c.CodeType = @CodeType
	AND c.CodeText = @CodeText	
END
GO
