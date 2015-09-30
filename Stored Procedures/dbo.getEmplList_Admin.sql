SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 03/26/2012
-- Description:	List all employees 
-- =============================================
CREATE PROCEDURE [dbo].[getEmplList_Admin]
	@ncUserId AS nchar(6) = NULL
	,@input nvarchar(50) = null
AS
BEGIN
SET NOCOUNT ON;
	
	SET @input = '%' + @input + '%'
	
	SELECT 
		e.EmplID
		,e.NameFirst
		,e.NameMiddle
		,e.NameLast
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmplName
		,e.EmplActive
	FROM
		Empl			AS e	(NOLOCK)
	WHERE
		e.EmplActive = 1 and
		e.NameLast + ' ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' ' + e.EmplID like @input
END

GO
