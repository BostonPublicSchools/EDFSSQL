SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara Krunal	
-- Create date: 10/02/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[addUserLog] 
	@BrowserInfo as nvarchar(100) = null
	,@UserID AS nchar(6) = null
	,@LoginIssue AS nvarchar(50) = null
	,@IsOverridPwd AS bit
	,@IpAddress As nchar(15) = null
	,@LogId AS int = null OUTPUT

	
AS
BEGIN

	SET NOCOUNT ON;
		
	INSERT INTO UserLog(UserId,BrowserInfo,LoginIssue, IsOverridePwd,IpAddress)
		VALUES (@UserID,@BrowserInfo,@LoginIssue, @IsOverridPwd,@IpAddress)
	set @LogId = SCOPE_IDENTITY()
END
GO
