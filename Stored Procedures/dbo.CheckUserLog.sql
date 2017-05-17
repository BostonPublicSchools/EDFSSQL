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
    @UserID AS NCHAR(6) ,
    @IsLogged AS INT = NULL OUTPUT
AS
    BEGIN

        SET NOCOUNT ON;

        DECLARE @logId INT;
		
        SELECT  @logId = MAX(LogId)
        FROM    dbo.UserLog (NOLOCK)
        WHERE   UserId = @UserID;

        IF EXISTS ( SELECT  LogId
                    FROM    dbo.UserLog (NOLOCK)
                    WHERE   LogId = ( SELECT    MAX(LogId)
                                      FROM      dbo.UserLog (NOLOCK)
                                      WHERE     UserId = @UserID
                                    )
                            AND UserLogOut = 0
                            AND LoginIssue = 'Login Successful'
                            AND DATEDIFF(MINUTE, CreatedDt, GETDATE()) < 5 )
            BEGIN
                UPDATE  dbo.UserLog
                SET     LogoutDt = GETDATE() ,
                        UserLogOut = 0
                WHERE   LogId = @logId;

                SET @IsLogged = 1;
            END;
        PRINT @IsLogged;

    END;


GO
