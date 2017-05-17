SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 04/10/2012
-- Description:	List of codes by codetype
-- =============================================
CREATE PROCEDURE [dbo].[getCodes]
    @CodeType AS NVARCHAR(10) = NULL ,
    @IsDeleted BIT
AS
    BEGIN
        SET NOCOUNT ON;

        IF @IsDeleted = 0
            BEGIN
                SELECT  c.CodeType ,
                        c.CodeID ,
                        c.Code ,
                        c.CodeText ,
                        ( CASE WHEN c.IsManaged = 1
                               THEN dbo.udf_StripHTML(c.CodeSubText)
                               ELSE c.CodeSubText
                          END ) CodeSubText ,
                        c.CodeSortOrder ,
                        c.CodeActive ,
                        c.IsManaged ,
                        ( SELECT    MAX(c2.CodeSortOrder)
                          FROM      dbo.CodeLookUp c2 ( NOLOCK )
                          WHERE     c2.CodeType = c.CodeType
                          GROUP BY  c2.CodeType
                        ) AS MaxSortOrder ,
                        rh.RubricID
                FROM    dbo.CodeLookUp AS c ( NOLOCK )
                        LEFT JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON rh.RubricName = dbo.udf_StripHTML(c.CodeSubText)
                WHERE   c.CodeActive = 1
                        AND c.CodeType = @CodeType;
            END;
        ELSE
            BEGIN
                SELECT  c.CodeType ,
                        c.CodeID ,
                        c.Code ,
                        c.CodeText ,
                        dbo.udf_StripHTML(c.CodeSubText) CodeSubText ,
                        c.CodeSortOrder ,
                        c.CodeActive ,
                        c.IsManaged ,
                        ( SELECT    MAX(c2.CodeSortOrder)
                          FROM      dbo.CodeLookUp c2 ( NOLOCK )
                          WHERE     c2.CodeType = c.CodeType
                          GROUP BY  c2.CodeType
                        ) AS MaxSortOrder ,
                        rh.RubricID
                FROM    dbo.CodeLookUp AS c ( NOLOCK )
                        LEFT JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON rh.RubricName = dbo.udf_StripHTML(c.CodeSubText)
                WHERE   c.CodeType = @CodeType;
            END;		
    END;
GO
