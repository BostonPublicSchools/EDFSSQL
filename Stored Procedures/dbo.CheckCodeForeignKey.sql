SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/15/2012
-- Description:	Check for foreign key association with 
--				other tables.
-- =============================================

CREATE PROCEDURE [dbo].[CheckCodeForeignKey]
    @CodeID NVARCHAR(10) ,
    @ReturnTotalCount INT OUTPUT
AS
    BEGIN
        DECLARE @tableName NVARCHAR(MAX) ,
            @columnName NVARCHAR(MAX) ,
            @sql NVARCHAR(MAX) ,
            @params NVARCHAR(100) ,
            @fkFound INT = 0 ,
            @codeIDParam NCHAR(10) ,
            @totalCount INT = 0; 		
		
        DECLARE CURSOR_CODERELATEDTABLES CURSOR
        FOR
            SELECT  tc.TABLE_NAME ,
                    ccu.COLUMN_NAME
            FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
                    JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
                    JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc ON tc.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
                    JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc2 ON tc2.TABLE_NAME = 'CodeLookUp'
                                                              AND rc.UNIQUE_CONSTRAINT_NAME = tc2.CONSTRAINT_NAME
                    JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu2 ON ccu2.COLUMN_NAME = 'CodeID'
                                                              AND tc2.CONSTRAINT_NAME = ccu2.CONSTRAINT_NAME
            WHERE   tc.CONSTRAINT_TYPE = 'Foreign Key'
            ORDER BY tc.TABLE_NAME;

        OPEN CURSOR_CODERELATEDTABLES;
        FETCH NEXT FROM CURSOR_CODERELATEDTABLES INTO @tableName, @columnName;

        SET @codeIDParam = @CodeID;

        WHILE @@FETCH_STATUS = 0
            BEGIN 
                SELECT  @sql = 'SELECT @retvalOUT = count(' + @columnName
                        + ') FROM ' + @tableName + ' WHERE ' + @columnName
                        + ' = ' + @codeIDParam;
                SET @params = N'@retvalOUT int OUTPUT';
                EXEC sys.sp_executesql @sql, @params,
                    @retvalOUT = @fkFound OUTPUT;
	
                SET @totalCount = ( @totalCount + @fkFound );
                FETCH NEXT FROM CURSOR_CODERELATEDTABLES INTO @tableName,
                    @columnName;
            END;

        CLOSE CURSOR_CODERELATEDTABLES;
        DEALLOCATE CURSOR_CODERELATEDTABLES;

        SET @ReturnTotalCount = @totalCount;
    END;

GO
