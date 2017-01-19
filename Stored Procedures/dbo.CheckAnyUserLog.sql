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
    @IpAddress AS NCHAR(15) ,
    @IsLogged AS INT = NULL OUTPUT
AS
    BEGIN

        SET NOCOUNT ON;
		
        IF EXISTS ( SELECT TOP 1
                            LogId ,
                            UserId ,
                            BrowserInfo ,
                            LoginIssue ,
                            CreatedDt ,
                            LogoutDt ,
                            IsOverridePwd ,
                            UserLogOut ,
                            IpAddress
                    FROM    dbo.UserLog
                    WHERE   IpAddress = @IpAddress 
		--and logid= (select MAX(logid) from UserLog where UserId=@UserID)	
                            AND UserLogOut = 0
                            AND LoginIssue = 'Login Successful' --and  DATEDIFF(MINUTE,CreatedDt,GETDATE())<15
		)
            BEGIN
                SET @IsLogged = 0;--1;
            END;
        PRINT @IsLogged;

    END;


GO
