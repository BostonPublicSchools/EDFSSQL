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
	  @UserID AS nchar(6)	
	 ,@Password As nvarchar(25) --Decrypted Pwd
	 ,@intReturn AS int = null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;	

OPEN SYMMETRIC KEY EDFSTableKey DECRYPTION
BY CERTIFICATE EncryptEDFSCert
		
Declare 
		@IsEmplActive as bit 
		,@HasTempActiveAccess as bit =0 
		,@DecryptPassword as nvarchar(25)--varbinary(max)
		,@DecryptPasswordFromUser varbinary(max)

IF EXISTS(	Select top 1 EmplID from Empl Where EmplID = @UserID)
BEGIN
	
	Select 
		@IsEmplActive = EmplActive
		,@HasTempActiveAccess = (Case 
									When EmplActive=0 And (DATEDIFF(dd, GETDATE(),EmplActiveDt) > -1 
															and DATEDIFF(dd, GETDATE(),EmplActiveDt)< 31)
									Then 1 Else 0 End)
		--,@DecryptPassword= EmplPWord
		,@DecryptPassword = CONVERT(NVARCHAR, DecryptByKey([EmplPWord])) 
	From Empl where EmplID=@UserID
		
	IF @IsEmplActive = 1
		Set @intReturn = -1;
	ELSE IF @IsEmplActive = 0 and @HasTempActiveAccess = 1
	Begin		 
		--Set @DecryptPasswordFromUser =ENCRYPTBYKEY(KEY_GUID('EdfsTableKey'),@Password)-- ENCRYPTBYKEY(KEY_GUID('EdfsTableKey'),@Password)
		print @Password
		print @DecryptPassword
		 --If(@DecryptPasswordFromUser=@DecryptPassword)		 
		 
		 if( CAST(@Password as varbinary(25))= cast(@DecryptPassword as varbinary(25)) )
			Set @intReturn = 1;
		 Else
			Set @intReturn = 2;				
	End
	Else	
		Set @intReturn = 0;
END
Else
	Set @intReturn = -2; 	

--Select 	@intReturn
END	

GO
