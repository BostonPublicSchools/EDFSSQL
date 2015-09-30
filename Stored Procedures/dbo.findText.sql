SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[findText] ( 
@text VARCHAR(50) 
) AS 

--Declare @text varchar(50)

--set @text  = 'SmIepHeader'

-- Adjust search text to find all contains. 
SET @text = '%' + @text + '%' 
-- Declare general purpose variables. 
DECLARE @line VARCHAR(300) 
DECLARE @char CHAR 
DECLARE @lineNo INTEGER 
DECLARE @counter INTEGER 
-- Declare cursor structure. 
DECLARE @proc VARCHAR(50), 
@usage VARCHAR(4000) 
-- Declare cursor of stored procedures. 
DECLARE codeCursor CURSOR 
FOR 
SELECT SUBSTRING(OBJECT_NAME(id),1,50) AS sproc, 
text 
FROM syscomments 
WHERE text LIKE @text 
-- Open cursor and fetch first row. 
OPEN codeCursor 
FETCH NEXT FROM codeCursor 
INTO @proc,@usage 
-- Check if any stored procedures were found. 
IF @@FETCH_STATUS <> 0 BEGIN 
PRINT 'Text ''' + SUBSTRING(@text,2,LEN(@text)-2) + ''' not found in stored procedures on database ' + @@SERVERNAME + '.' + DB_NAME() 
-- Close and release code cursor. 
CLOSE codeCursor 
DEALLOCATE codeCursor 
RETURN 
END 
-- Display column titles. 
PRINT 'Procedure' + CHAR(39) + 'Line' + CHAR(9) + 'Reference ' + CHAR(13) + CHAR(13) 
-- Search each stored procedure within code cursor. 
WHILE @@FETCH_STATUS = 0 BEGIN 
SET @lineNo = 0 
SET @counter = 1 
-- Process each line. 
WHILE (@counter <> LEN(@usage)) BEGIN 
SET @char = SUBSTRING(@usage,@counter,1) 
-- Check for line breaks. 
IF (@char = CHAR(13)) BEGIN 
SET @lineNo = @lineNo + 1 
-- Check if we found the specified text. 
IF (PATINDEX(@text,@line) <> 0) 
PRINT @proc + CHAR(39) + STR(@lineNo) + CHAR(9) + LTRIM(@line) 

SET @line = '' 
END ELSE 
IF (@char <> CHAR(10)) 
SET @line = @line + @char 
SET @counter = @counter + 1 

END 

FETCH NEXT FROM codeCursor 
INTO @proc,@usage 
END 
-- Close and release cursor. 
CLOSE codeCursor 
DEALLOCATE codeCursor 
RETURN

GO
