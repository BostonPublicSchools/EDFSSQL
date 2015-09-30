SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 12/12/2012
-- Description:	Get all the roles
-- =============================================
CREATE PROCEDURE [dbo].[getAllUserLogInfoById]
	@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT LogId, UserId, BrowserInfo, LoginIssue, CreatedDt, LogoutDt,UserLogOut, IsOverridePwd,
			ISNULL(e.NameFirst, '')+ ' ' +ISNULL(e.NameMiddle,'')+ ' '+ISNULL(e.NameLast,'') as EmplName
	FROM UserLog usr (NOLOCK)
	LEFT JOIN Empl e(NOLOCK) ON e.EmplID = usr.UserId
	WHERE UserId = @UserID
	ORDER BY CreatedDt Desc
END
GO
