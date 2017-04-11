SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[updUserLog]
    @LogId INT = 0 OUTPUT ,
    @UserID AS NCHAR(6) = NULL ,
    @UserLogOut BIT = 0
AS
    BEGIN

        SET NOCOUNT ON;
		
        UPDATE  dbo.UserLog
        SET     LogoutDt = GETDATE() ,
                UserLogOut = @UserLogOut
        WHERE   ( LogId = @LogId
                  OR UserId = @UserID
                )
                AND UserLogOut = 0;  
    END;
GO
