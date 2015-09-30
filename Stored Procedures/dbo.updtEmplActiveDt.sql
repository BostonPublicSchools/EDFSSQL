SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Newa,Matina
-- Create date: 05/01/2014
-- Description:	Updated EmplActiveDt to access edfs temporailty till 30 days 
-- =============================================
CREATE PROCEDURE [dbo].[updtEmplActiveDt]
	@ncEmplID AS nchar(6)
	,@ncUserID AS nchar(6)	
	,@nvTempPwd AS nvarchar(25)
	,@IsResetPwd AS bit =false
	,@EmplActiveDt AS DateTime
AS
BEGIN
	SET NOCOUNT ON;		

	OPEN SYMMETRIC KEY EDFSTableKey DECRYPTION
	BY CERTIFICATE EncryptEDFSCert

	UPDATE Empl
	SET 		
		EmplActiveDt = Case When @IsResetPwd= 0 then 
							CAST(CONVERT(VARCHAR(10), @EmplActiveDt, 110) + ' 23:59:59' AS DATETIME) 
							When @IsResetPwd =1 then
							EmplActiveDt
						End
		,EmplPWord = ENCRYPTBYKEY(KEY_GUID('EdfsTableKey'),@nvTempPwd)
		,LastUpdatedByID = @ncUserID
		,LastUpdatedDt = GETDATE()	
	WHERE EmplID = @ncEmplID
		
	
END


GO
