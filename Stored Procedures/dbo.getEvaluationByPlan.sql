SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 04/04/2012
-- Description:	Get list of evaluations by PlanID AND isdelete=0 (by default) 
-- 				If isdeleted=1 then retrived both deleted and non-deleted records [Updated by Newa, Matina on 03/15/2013]
-- =============================================
CREATE PROCEDURE [dbo].[getEvaluationByPlan]
    @PlanID AS NCHAR(6) ,
    @IsDeleted BIT = 0
AS
    BEGIN
        SET NOCOUNT ON;
        PRINT @IsDeleted;
        SELECT  e.EvalID ,
                e.PlanID ,
                e.EvalTypeID ,
                etc.CodeText AS EvalType ,
                CONVERT(VARCHAR, e.EvalDt, 101) AS EvalDt ,
                e.EvaluatorsCmnt ,
                e.EmplCmnt ,
                e.OverallRatingID ,
                orc.CodeText AS OverallRating ,
                e.Rationale ,
                e.EvaluatorsSignature ,
                e.EvaluatorSignedDt ,
                e.EmplSignature ,
                e.EmplSignedDt ,
                e.WitnessSignature ,
                e.WitnessSignDt ,
                e.EditEndDt ,
                j.JobName ,
                j.JobCode ,
                e.IsSigned ,
                ep.EmplJobID ,
                ep.HasPrescript ,
                ep.PrescriptEvalID ,
                ( CASE WHEN ( SELECT    COUNT(EvalStdRatingID)
                              FROM      dbo.EvaluationStandardRating ( NOLOCK )
                              WHERE     RatingID IN (
                                        SELECT  CodeID
                                        FROM    dbo.CodeLookUp ( NOLOCK )
                                        WHERE   CodeType = 'StdRating'
                                                AND CodeText IN (
                                                'Needs Improvement',
                                                'Unsatisfactory' ) )
                                        AND EvalID = e.EvalID
                            ) > 0 THEN 1
                       ELSE 0
                  END ) AS HasEvalPrescript ,
                CASE WHEN s.EmplID IS NULL
                     THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                               THEN emplEx.MgrID
                               ELSE ej.MgrID
                          END
                     ELSE s.EmplID
                END SubEvalID ,
                sub.NameLast + ', ' + sub.NameFirst + ' '
                + ISNULL(sub.NameMiddle, '') AS SubEvalName ,
                ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN emplEx.MgrID
                       ELSE ej.MgrID
                  END ) AS MgrID ,
                ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                       THEN ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                                        + ISNULL(e1.NameMiddle, '') + ' '
                                        + ISNULL(e1.NameLast, '')
                              FROM      dbo.Empl e1 ( NOLOCK )
                              WHERE     e1.EmplID = emplEx.MgrID
                            )
                       ELSE mgr.NameLast + ', ' + mgr.NameFirst + ' '
                            + ISNULL(mgr.NameMiddle, '')
                  END ) AS MgrName ,
                epl.EmplID ,
                epl.NameLast + ', ' + epl.NameFirst + ' '
                + ISNULL(epl.NameMiddle, '') + ' (' + epl.EmplID + ')' AS EmplName ,
                evlr.EmplID AS EvaluatorID ,
                evlr.NameLast + ', ' + evlr.NameFirst + ' '
                + ISNULL(evlr.NameMiddle, '') AS EvaluatorName ,
                e.IsDeleted ,
                COALESCE(e.EvalPlanYear, 1) AS EvalPlanYear ,
                e.EvalManagerID ,
                ( SELECT    Empl.NameLast + ', ' + Empl.NameFirst + ' '
                            + ISNULL(Empl.NameMiddle, '')
                  FROM      dbo.Empl ( NOLOCK )
                  WHERE     EmplID = e.EvalManagerID
                ) AS EvalManagerName ,
                e.EvalSubEvalID ,
                ( SELECT    Empl.NameLast + ', ' + Empl.NameFirst + ' '
                            + ISNULL(Empl.NameMiddle, '')
                  FROM      dbo.Empl ( NOLOCK )
                  WHERE     EmplID = e.EvalSubEvalID
                ) AS EvalSubEvalName
        FROM    dbo.Evaluation AS e ( NOLOCK )
                JOIN dbo.CodeLookUp AS etc ON e.EvalTypeID = etc.CodeID
                LEFT JOIN dbo.CodeLookUp AS orc ON e.OverallRatingID = orc.CodeID
                JOIN dbo.EmplPlan AS ep ( NOLOCK ) ON ep.PlanID = e.PlanID
                JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON ej.EmplJobID = ep.EmplJobID
                LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
                LEFT JOIN dbo.SubevalAssignedEmplEmplJob AS ase ( NOLOCK ) ON ase.IsActive = 1
                                                              AND ase.IsDeleted = 0
                                                              AND ase.IsPrimary = 1
															  AND ej.EmplJobID = ase.EmplJobID
                LEFT JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                                  AND s.EvalActive = 1
                JOIN dbo.Empl AS epl ( NOLOCK ) ON ej.EmplID = epl.EmplID
                LEFT OUTER JOIN dbo.Empl AS mgr ( NOLOCK ) ON ej.MgrID = mgr.EmplID
                LEFT JOIN dbo.Empl AS sub ( NOLOCK ) ON CASE WHEN s.EmplID IS NULL
                                                         THEN CASE
                                                              WHEN ( emplEx.MgrID IS NOT NULL )
                                                              THEN emplEx.MgrID
                                                              ELSE ej.MgrID
                                                              END
                                                         ELSE s.EmplID
                                                    END = sub.EmplID
                LEFT OUTER JOIN dbo.Empl AS evlr ( NOLOCK ) ON ep.SubEvalID = evlr.EmplID
                JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
        WHERE   e.PlanID = @PlanID
                AND ( e.IsDeleted = 0
                      OR e.IsDeleted = @IsDeleted
                    )
        ORDER BY e.EvalDt DESC;				
		
    END;

GO
