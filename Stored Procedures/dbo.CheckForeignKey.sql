SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CheckForeignKey]
   @CodeID  nchar(10)
AS
BEGIN
DECLARE @tableName nvarchar(max),
		@columnName nvarchar(max),
		@sql nvarchar(max),
		@params nvarchar(100),
		@fkFound int =0,
		@codeIDParam nchar(10),
		@totalCount int = 0 		
		
DECLARE CURSOR_CODERELATEDTABLES CURSOR FOR
select tc.table_name, ccu.column_name
from 
    information_schema.table_constraints tc join
    information_schema.constraint_column_usage ccu on tc.constraint_name = ccu.constraint_name join
    information_schema.referential_constraints rc on tc.constraint_name = rc.constraint_name join
    information_schema.table_constraints tc2 on rc.unique_constraint_name = tc2.constraint_name join
    information_schema.constraint_column_usage ccu2 on tc2.constraint_name = ccu2.constraint_name 
where tc.constraint_type = 'Foreign Key' and tc2.table_name = 'CodeLookUp' and ccu2.column_name = 'CodeID'
order by tc.table_name

OPEN CURSOR_CODERELATEDTABLES
FETCH NEXT FROM CURSOR_CODERELATEDTABLES INTO @tableName, @columnName

set @codeIDParam = @CodeID

WHILE @@FETCH_STATUS = 0 
BEGIN 
	SELECT @sql =  'select @retvalOUT = count(*) FROM ' +@tableName +' WHERE '+@columnName+' = ' + @codeIDParam
	SET @params = N'@retvalOUT int OUTPUT';
	exec sp_executesql @sql, @params, @retvalOUT=@fkFound output
	
	Set @totalCount = (@totalCount + @fkFound)
	FETCH NEXT FROM CURSOR_CODERELATEDTABLES INTO @tableName, @columnName
END

CLOSE CURSOR_CODERELATEDTABLES
deallocate CURSOR_CODERELATEDTABLES

return @totalCount 
END

GO
