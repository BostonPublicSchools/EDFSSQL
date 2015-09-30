SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:	Matina Newa
-- Create date: 12/02/2013
-- Description:	This checks if any user is still logged via same IP address
--  Returns 1 when true else null
-- =============================================
CREATE PROCEDURE [dbo].[CheckAnyUserLog] 	
	@IpAddress AS nchar(15) 	
	,@IsLogged AS int = null OUTPUT
	
AS
BEGIN

	SET NOCOUNT ON;
		
	if exists(
		select top 1 * from UserLog
		where IpAddress=@IpAddress 
		--and logid= (select MAX(logid) from UserLog where UserId=@UserID)	
		and UserLogOut=0
		and LoginIssue ='Login Successful'
		--and  DATEDIFF(MINUTE,CreatedDt,GETDATE())<15
		)
	Begin
		Set @IsLogged=0;--1;
	End
print @IsLogged

END


GO
