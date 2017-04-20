SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/02/2012
-- Description:	Get evaluation standards rating by evaluation id
-- =============================================
CREATE PROCEDURE [dbo].[getEvalStandardsRatingByEvalID] @EvalID AS INT
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT  esr.EvalStdRatingID ,
                esr.EvalID ,
                rs.RubricID ,
                rs.StandardID ,
                rs.StandardText ,
                rs.SortOrder AS StandardSortOrder ,
                esr.RatingID ,
                ISNULL(c.CodeText, '') AS Rating ,
                ISNULL(esr.Rationale, '') AS Rationale ,
                minc.CodeID AS minCodeID ,
                minc.CodeText AS minCodeText ,
                m.MinCodeSortOrder ,
                maxc.CodeID AS maxCodeID ,
                maxc.CodeText AS maxCodeText ,
                m.MaxCodeSortOrder ,
                ( SELECT    EvaluatorSignedDt
                  FROM      dbo.Evaluation ( NOLOCK )
                  WHERE     EvalID = @EvalID
                ) EvaluatorSignedDt  -- to get EvaluatorSignedDt w/o respect to evaluationStandard
        FROM    dbo.RubricStandard rs ( NOLOCK )
                LEFT JOIN dbo.EvaluationStandardRating esr ( NOLOCK ) ON esr.EvalID = @EvalID
                                                              AND rs.StandardID = esr.StandardID
                LEFT JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeType = 'stdRating'
                                                         AND c.CodeID = esr.RatingID
                LEFT JOIN ( SELECT  esr.EvalID ,
                                    MAX(c.CodeSortOrder) AS MaxCodeSortOrder ,
                                    MIN(c.CodeSortOrder) AS MinCodeSortOrder
                            FROM    dbo.CodeLookUp AS c ( NOLOCK )
                                    JOIN dbo.EvaluationStandardRating AS esr ( NOLOCK ) ON c.CodeID = esr.RatingID
                            WHERE   c.CodeType = 'stdRating'
                            GROUP BY esr.EvalID
                          ) AS m ON m.EvalID = esr.EvalID
                LEFT JOIN dbo.CodeLookUp AS maxc ( NOLOCK ) ON maxc.CodeType = 'stdRating'
                                                              AND m.MaxCodeSortOrder = maxc.CodeSortOrder
                LEFT JOIN dbo.CodeLookUp AS minc ( NOLOCK ) ON minc.CodeType = 'stdRating'
                                                              AND m.MinCodeSortOrder = minc.CodeSortOrder
        WHERE   rs.IsActive = 1
        ORDER BY rs.SortOrder;						
    END;	

GO
