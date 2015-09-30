SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[sp_RTF2TEXT](@RTFFileIn VARCHAR(255),@TXTFileOut VARCHAR(255) )
AS
BEGIN
--usage sp_RTF2TEXT 'c:\test.rtf', 'c:ewfile.txt'
--note that this function will not take kindly to spaces in a filename
SET NOCOUNT ON 
DECLARE @COMMAND VARCHAR(1000)
SET @COMMAND = 'c:\FreeRTF2Text.exe ' + @RTFFileIn + ' ' + @TXTFileOut
EXEC master.dbo.xp_cmdshell @COMMAND
CREATE TABLE #tempRTF (line varchar(8000)) 
EXEC ('bulk INSERT #tempRTF FROM "' + @TXTFileOut + '"') 
SELECT * FROM #tempRTF 
DROP TABLE #tempRTF 
END 
GO
