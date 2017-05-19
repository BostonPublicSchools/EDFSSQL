SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/07/2012
-- Description:	Get  evaluation by EvalID
-- =============================================
CREATE PROCEDURE [dbo].[getEvaluationByEval] @EvalID AS NCHAR(6)
AS
    BEGIN
        SET NOCOUNT ON;
	
        SELECT  e.EvalID ,
                e.PlanID ,
                e.EvalTypeID ,
                ( SELECT    CodeText
                  FROM      dbo.CodeLookUp (NOLOCK)
                  WHERE     CodeID = e.EvalTypeID
                ) AS EvalType ,
                CONVERT(VARCHAR, e.EvalDt, 101) AS EvalDt ,
                e.EvaluatorsCmnt ,
                e.EmplCmnt ,
                e.OverallRatingID ,
                ( SELECT    CodeText
                  FROM      dbo.CodeLookUp (NOLOCK)
                  WHERE     CodeID = e.OverallRatingID
                ) AS OverallRating ,
                e.Rationale ,
                e.EvaluatorsSignature ,
                e.EvaluatorSignedDt ,
                e.EmplSignature ,
                e.EmplSignedDt ,
                e.WitnessSignature ,
                e.WitnessSignDt ,
                e.IsSigned ,
                e.EmplSignedDt ,
                e.EditEndDt ,
                e.EvalRubricID ,
                ep.PlanActive ,
                ep.EmplJobID ,
                j.JobName ,
                j.JobCode ,
                ej.RubricID ,
                RTRIM(clEjCls.Code) EmplClass ,
                ( CASE WHEN ep.SubEvalID IS NULL
                       THEN CASE WHEN s.EmplID IS NULL
                                 THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                           THEN emplEx.MgrID
                                           ELSE ej.MgrID
                                      END
                                 ELSE s.EmplID
                            END
                       ELSE ep.SubEvalID
                  END ) AS SubEvalID ,
                ( SELECT    NameLast + ', ' + NameFirst + ' '
                            + ISNULL(NameMiddle, '')
                  FROM      dbo.Empl (NOLOCK)
                  WHERE     EmplID = CASE WHEN ep.SubEvalID IS NULL
                                          THEN CASE WHEN s.EmplID IS NULL
                                                    THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                                              THEN emplEx.MgrID
                                                              ELSE ej.MgrID
                                                         END
                                                    ELSE s.EmplID
                                               END
                                          ELSE ep.SubEvalID
                                     END
                ) AS SubEvalName ,
                ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN emplEx.MgrID
                       ELSE ej.MgrID
                  END ) AS MgrID ,
                ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                       THEN ( SELECT    NameLast + ', ' + NameFirst + ' '
                                        + ISNULL(NameMiddle, '')
                              FROM      dbo.Empl (NOLOCK)
                              WHERE     EmplID = emplEx.MgrID
                            )
                       ELSE ( SELECT    NameLast + ', ' + NameFirst + ' '
                                        + ISNULL(NameMiddle, '')
                              FROM      dbo.Empl (NOLOCK)
                              WHERE     EmplID = ej.MgrID
                            )
                  END ) AS MgrName ,
                ej.EmplID ,
                ( SELECT    NameLast + ', ' + NameFirst + ' '
                            + ISNULL(NameMiddle, '') + ' (' + EmplID + ')'
                  FROM      dbo.Empl (NOLOCK)
                  WHERE     EmplID = ej.EmplID
                ) AS EmplName ,
                minc.CodeID AS minCodeID ,
                minc.CodeText AS minCodeText ,
                ISNULL(m.MinCodeSortOrder, 1) AS MinCodeSortOrder ,
                ISNULL(m.MaxCodeSortOrder, 4) AS MaxCodeSortOrder ,
                e.EvalSignOffCount ,
                COALESCE(e.EvalPlanYear, 1) AS EvalPlanYear ,
                e.EvalManagerID ,
                ( SELECT    NameLast + ', ' + NameFirst + ' '
                            + ISNULL(NameMiddle, '')
                  FROM      dbo.Empl (NOLOCK)
                  WHERE     EmplID = e.EvalManagerID
                ) AS EvalManagerName ,
                e.EvalSubEvalID ,
                ( SELECT    NameLast + ', ' + NameFirst + ' '
                            + ISNULL(NameMiddle, '')
                  FROM      dbo.Empl (NOLOCK)
                  WHERE     EmplID = e.EvalSubEvalID
                ) AS EvalSubEvalName ,
                ( CASE WHEN ( SELECT    COUNT(EvalStdRatingID)
                              FROM      dbo.EvaluationStandardRating (NOLOCK)
                              WHERE     RatingID IN (
                                        SELECT  CodeID
                                        FROM    dbo.CodeLookUp (NOLOCK)
                                        WHERE   CodeType = 'StdRating'
                                                AND CodeText IN (
                                                'Needs Improvement',
                                                'Unsatisfactory' ) )
                                        AND EvalID = e.EvalID
                            ) > 0 THEN 1
                       ELSE 0
                  END ) AS HasEvalPrescript
        FROM    dbo.Evaluation e
                LEFT JOIN dbo.EmplPlan ep ( NOLOCK ) ON ep.PlanID = e.PlanID
                LEFT JOIN dbo.EmplEmplJob ej ( NOLOCK ) ON ej.EmplRcdNo <= 20
                                                           AND ej.EmplJobID = ep.EmplJobID
                LEFT JOIN dbo.CodeLookUp clEjCls ( NOLOCK ) ON  clEjCls.CodeType = 'emplclass'
                                                              AND clEjCls.Code = ej.EmplClass
                JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
                LEFT JOIN dbo.SubevalAssignedEmplEmplJob AS ase ( NOLOCK ) ON ase.IsActive = 1
                                                              AND ase.IsDeleted = 0
                                                              AND ase.IsPrimary = 1
                                                              AND ej.EmplJobID = ase.EmplJobID
                LEFT JOIN dbo.SubEval s ( NOLOCK ) ON s.EvalActive = 1
                                                      AND ase.SubEvalID = s.EvalID
                LEFT JOIN ( SELECT  esr.EvalID ,
                                    MAX(c.CodeSortOrder) AS MaxCodeSortOrder ,
                                    MIN(c.CodeSortOrder) AS MinCodeSortOrder
                            FROM    dbo.CodeLookUp AS c ( NOLOCK )
                                    JOIN dbo.EvaluationStandardRating AS esr ( NOLOCK ) ON c.CodeID = esr.RatingID
                            WHERE   c.CodeType = 'stdRating'
                            GROUP BY esr.EvalID
                          ) AS m ON m.EvalID = e.EvalID
                LEFT JOIN dbo.CodeLookUp AS maxc ( NOLOCK ) ON maxc.CodeType = 'stdRating'
                                                              AND m.MaxCodeSortOrder = maxc.CodeSortOrder
                LEFT JOIN dbo.CodeLookUp AS minc ON minc.CodeType = 'stdRating'
                                                    AND m.MinCodeSortOrder = minc.CodeSortOrder
        WHERE   e.EvalID = @EvalID
                AND e.IsDeleted = 0
        ORDER BY e.EvalDt DESC;	
    END;


GO
