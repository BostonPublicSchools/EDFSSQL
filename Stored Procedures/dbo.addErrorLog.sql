SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara Krunal	
-- Create date: 10/02/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[addErrorLog] 
	@BrowserInfo as nvarchar(50) = null
	,@UserID AS nchar(6) = null
	,@Url AS nvarchar(255) = null
	,@EmplJobID int = null
	,@ErrorMsg as nvarchar(max) = null
	
	
AS
BEGIN

	SET NOCOUNT ON;
		
	INSERT INTO ErrorLog(EmplID,Browser,Url,ErrorMsg,EmplJobID)
		VALUES (@UserID,@BrowserInfo,@Url,@ErrorMsg,@EmplJobID)

END


--drop procedure addErrorLog
GO
