SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[SplitInts]
    (
      @List VARCHAR(MAX) ,
      @Delimiter VARCHAR(255)
    )
RETURNS TABLE
AS
  RETURN
    ( SELECT    Item = CONVERT(INT, y.Item)
      FROM      ( SELECT    Item = x.i.value('(./text())[1]', 'varchar(max)')
                  FROM      ( SELECT    XML = CONVERT(XML, '<i>'
                                        + REPLACE(@List, @Delimiter, '</i><i>')
                                        + '</i>').query('.')
                            ) AS a
                            CROSS APPLY XML.nodes('i') AS x ( i )
                ) AS y
      WHERE     Item IS NOT NULL
    );
GO
