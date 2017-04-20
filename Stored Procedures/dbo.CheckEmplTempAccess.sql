SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Newa,Matina
-- Create date: 05/06/2014
-- Description:	Check InActive Empl with temporary access
--Return Values
--/// If -2 then No User Exists
--/// If -1 then is still Active     
--/// If 0 then Inactive with No Access
--/// If 1 then Inactive access with Password Correct  --Ok
--/// If 2 then Inactive acces with No correct Password
-- exec [CheckEmplTempAccess] '1X2097','000',0
-- =============================================
CREATE PROCEDURE [dbo].[CheckEmplTempAccess]
    @UserID AS NCHAR(6) ,
    @Password AS NVARCHAR(25) --Decrypted Pwd
    ,
    @intReturn AS INT = NULL OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;	

        OPEN SYMMETRIC KEY EDFSTableKey DECRYPTION
BY CERTIFICATE EncryptEDFSCert;
		
        DECLARE @IsEmplActive AS BIT ,
            @HasTempActiveAccess AS BIT = 0 ,
            @DecryptPassword AS NVARCHAR(25)--varbinary(max)
            ,
            @DecryptPasswordFromUser VARBINARY(MAX);

        IF EXISTS ( SELECT TOP 1
                            EmplID
                    FROM    dbo.Empl ( NOLOCK )
                    WHERE   EmplID = @UserID )
            BEGIN
	
                SELECT  @IsEmplActive = EmplActive ,
                        @HasTempActiveAccess = ( CASE WHEN EmplActive = 0
                                                           AND ( DATEDIFF(dd,
                                                              GETDATE(),
                                                              EmplActiveDt) > -1
                                                              AND DATEDIFF(dd,
                                                              GETDATE(),
                                                              EmplActiveDt) < 31
                                                              ) THEN 1
                                                      ELSE 0
                                                 END )  ,
                        @DecryptPassword = CONVERT(NVARCHAR, DECRYPTBYKEY(EmplPWord))
                FROM    dbo.Empl ( NOLOCK )
                WHERE   EmplID = @UserID;
		
                IF @IsEmplActive = 1
                    SET @intReturn = -1;
                ELSE
                    IF @IsEmplActive = 0
                        AND @HasTempActiveAccess = 1
                        BEGIN		 
                            PRINT @Password;
                            PRINT @DecryptPassword;

                            IF ( CAST(@Password AS VARBINARY(25)) = CAST(@DecryptPassword AS VARBINARY(25)) )
                                SET @intReturn = 1;
                            ELSE
                                SET @intReturn = 2;				
                        END;
                    ELSE
                        SET @intReturn = 0;
            END;
        ELSE
            SET @intReturn = -2; 	

    END;	

GO
