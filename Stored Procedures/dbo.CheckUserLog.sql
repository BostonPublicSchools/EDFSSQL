SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:	Matina Newa
-- Create date: 12/02/2013
-- Description:	This checks if user is still logged in
--  Returns 1 when true else null
-- =============================================
CREATE PROCEDURE [dbo].[CheckUserLog] 	
	@UserID AS nchar(6) 	
	,@IsLogged AS int = null OUTPUT
	
AS
BEGIN

	SET NOCOUNT ON;
		
	if exists(
		select top 1 * from UserLog
		where UserId=@UserID 
		and logid= (select MAX(logid) from UserLog where UserId=@UserID)	
		and UserLogOut=0
		and LoginIssue ='Login Successful'
		and  DATEDIFF(MINUTE,CreatedDt,GETDATE())<10
		)
	Begin
		Set @IsLogged=1;
	End
print @IsLogged

END


GO
