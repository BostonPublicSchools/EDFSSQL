SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [dbo].[RTF2TXT](@in varchar(8000)) RETURNS  varchar(8000) AS 
BEGIN

DECLARE @object int
DECLARE @hr int
DECLARE @out varchar(8000)

-- Create an object that points to the SQL Server
EXEC @hr = sp_OACreate 'RICHTEXT.RichtextCtrl', @object OUT
EXEC @hr = sp_OASetProperty @object, 'TextRTF', @in
EXEC @hr = sp_OAGetProperty @object, 'Text', @out OUT
EXEC @hr = sp_OADestroy @object
return @out

END
GO
