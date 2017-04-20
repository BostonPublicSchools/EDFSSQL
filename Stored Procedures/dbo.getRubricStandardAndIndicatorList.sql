SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[getRubricStandardAndIndicatorList] @RubricID AS INT
AS
    BEGIN
        SELECT  ( rs.StandardID - 101 ) AS StandardIndiCombine ,
                rs.StandardText AS StandardIndiText ,
                -100000 AS ParentID ,
                rs.StandardText ,
                NULL AS IndicatorText ,
                NULL AS ElementText
        FROM    dbo.RubricStandard rs ( NOLOCK )
        WHERE   rs.RubricID = @RubricID
                AND rs.IsDeleted = 0
        UNION
        SELECT  ri.IndicatorID AS StandardIndiCombine ,
                ri.IndicatorText AS StandardIndiText ,
                CASE WHEN ri.ParentIndicatorID = 0
                     THEN ( rs.StandardID - 101 )
                     ELSE ri.ParentIndicatorID
                END AS ParentID ,
                NULL AS StandardText ,
                CASE WHEN ri.ParentIndicatorID = 0 THEN ri.IndicatorText
                     ELSE NULL
                END AS IndicatorText ,
                CASE WHEN ri.ParentIndicatorID <> 0 THEN ri.IndicatorText
                     ELSE NULL
                END AS ElementText
        FROM    dbo.RubricIndicator ri ( NOLOCK )
                LEFT JOIN dbo.RubricStandard rs ( NOLOCK ) ON rs.RubricID = @RubricID
                                                              AND rs.StandardID = ri.StandardID
        WHERE   ri.IsDeleted = 0;
    END;
GO
