SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[updUserLog] 
	@LogId int =0 output
	,@UserID as nchar(6)=null
	,@UserLogOut bit = 0
AS
BEGIN

	SET NOCOUNT ON;
		
	UPDATE UserLog set logoutDt = GETDATE(),UserLogOut = @UserLogOut where (logID = @LogId or UserID = @UserID)
	and UserLogOut = 0  
	--INSERT INTO UserLog(UserId,BrowserInfo,LoginIssue)
	--	VALUES (@UserID,@BrowserInfo,@LoginIssue)
	--sel
End
GO
