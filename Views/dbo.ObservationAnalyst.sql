SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Avery, Bryce
-- Create date: 11/06/2012
-- Description:	View for observation analyst
-- =============================================
CREATE VIEW [dbo].[ObservationAnalyst]
AS
    WITH    cte ( PlanID, EmplJobId, JobCode, EmplId )
              AS ( SELECT   p.PlanID ,
                            ej.EmplJobID ,
                            ej.JobCode ,
                            ej.EmplID
                   FROM     dbo.EmplEmplJob AS ej ( NOLOCK )
                            JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                            JOIN dbo.EmplPlan AS p ( NOLOCK ) ON ej.EmplJobID = p.EmplJobID
                   WHERE    ej.IsActive = 1
                            AND p.PlanActive = 1
                 )
    SELECT  d.DeptID ,
            d.DeptName ,
            dc.CodeID AS DeptCatID ,
            dc.CodeText AS DeptCat ,
            ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN emplEx.MgrID
                   ELSE ej.MgrID
              END ) AS MgrID ,
            ( SELECT    ISNULL(e1.NameFirst, '') + ' ' + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                        + ISNULL(e1.NameLast, '')
              FROM      dbo.Empl e1 ( NOLOCK )
              WHERE     e1.EmplID = CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                         THEN emplEx.MgrID
                                         ELSE ej.MgrID
                                    END
            ) AS ManagerName ,
            ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN emplEx.MgrID
                   ELSE ej.MgrID
              END ) + '@boston.k12.ma.us' AS MgrEmailAddr ,
            ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN 1
                   ELSE 0
              END ) AS EmplExceptionExists ,
            CASE WHEN s.EmplID IS NULL
                 THEN CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN emplEx.MgrID
                           ELSE ej.MgrID
                      END
                 ELSE s.EmplID
            END SubEvalID ,
            ( SELECT    ISNULL(e1.NameFirst, '') + ' ' + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                        + ISNULL(e1.NameLast, '')
              FROM      dbo.Empl e1 ( NOLOCK )
              WHERE     e1.EmplID = CASE WHEN s.EmplID IS NULL
                                         THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                                   THEN emplEx.MgrID
                                                   ELSE ej.MgrID
                                              END
                                         ELSE s.EmplID
                                    END
            ) AS SubEvalName ,
            ( CASE WHEN s.EmplID IS NULL
                   THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                             THEN emplEx.MgrID
                             ELSE ej.MgrID
                        END
                   ELSE s.EmplID
              END ) + '@boston.k12.ma.us' SubEvalEmailaddr ,
            ej.EmplID ,
            e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '')
            + ' (' + e.EmplID + ')' AS EmplName ,
            CASE WHEN ISNULL(pt.CodeText, '') = 'Developing'
                      AND ej.EmplClass = 'U'
                 THEN ISNULL(pt.CodeText, '') + ' (Prov 1)'
                 WHEN ISNULL(pt.CodeText, '') = 'Developing'
                      AND ej.EmplClass IN ( 'B', 'V', 'W', 'X' )
                 THEN ISNULL(pt.CodeText, '') + ' (Prov 2-4)'
                 WHEN ISNULL(pt.CodeText, '') = 'Developing'
                      AND NOT ej.EmplClass IN ( 'U', 'B', 'V', 'W', 'X' )
                 THEN ISNULL(pt.CodeText, '')
                 WHEN ISNULL(pt.CodeText, '') = 'Improvement'
                      AND DATEDIFF(d, p.PlanStartDt, p.PlanSchedEndDt) < 180
                 THEN ISNULL(pt.CodeText, '') + ' (duration <1 year)'
                 WHEN ISNULL(pt.CodeText, '') = 'Improvement'
                      AND DATEDIFF(d, p.PlanStartDt, p.PlanSchedEndDt) >= 180
                 THEN ISNULL(pt.CodeText, '') + ' (duration 1 year)'
                 ELSE ISNULL(pt.CodeText, '')
            END AS PlanType ,
            ISNULL(CONVERT(VARCHAR, p.PlanStartDt, 101), '') AS PlanStartDt ,
            ISNULL(CONVERT(VARCHAR, p.PlanSchedEndDt, 101), '') AS PlanEndDt ,
            CASE WHEN p.PlanStartDt IS NOT NULL
                 THEN DATEDIFF(d, p.PlanStartDt, p.PlanSchedEndDt)
                 WHEN p.PlanStartDt IS NULL THEN p.Duration
                 ELSE 0
            END AS PlanDuration ,
            ISNULL(CONVERT(VARCHAR, ( SELECT TOP 1
                                                ObsvDt
                                      FROM      dbo.ObservationHeader (NOLOCK)
                                      WHERE     IsDeleted = 0
                                                AND ObsvRelease = 1
                                                AND PlanID = p.PlanID
                                      ORDER BY  ObsvDt
                                    ), 101), '') AS FirstObsvDt ,
            ( SELECT    COUNT(ObsvID)
              FROM      dbo.ObservationHeader (NOLOCK)
              WHERE     IsDeleted = 0
                        AND ObsvTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp (NOLOCK)
                        WHERE   CodeType = 'ObsvType'
                                AND CodeText = 'Unannounced' )
                        AND PlanID = p.PlanID
            ) AS UnAnnouncedObsvCnt ,
            ISNULL(( SELECT MaxLimit
                     FROM   dbo.PlanTypeMaxObservation (NOLOCK)
                     WHERE  CASE WHEN EmplClass IS NULL THEN ej.EmplClass
                                 WHEN EmplClass = '' THEN ej.EmplClass
                                 ELSE EmplClass
                            END = ej.EmplClass
                            AND ObservationTypeID IN (
                            SELECT  CodeID
                            FROM    dbo.CodeLookUp (NOLOCK)
                            WHERE   CodeType = 'ObsvType'
                                    AND CodeText = 'Unannounced' )
                            AND PlanTypeID = p.PlanTypeID
                   ), 0) AS UnAnnouncedMax ,
            ( SELECT    COUNT(ObsvID)
              FROM      dbo.ObservationHeader (NOLOCK)
              WHERE     IsDeleted = 0
                        AND ObsvTypeID IN ( SELECT  CodeID
                                            FROM    dbo.CodeLookUp (NOLOCK)
                                            WHERE   CodeType = 'ObsvType'
                                                    AND CodeText = 'Announced' )
                        AND PlanID = p.PlanID
            ) AS AnnouncedObsvCnt ,
            ISNULL(( SELECT MaxLimit
                     FROM   dbo.PlanTypeMaxObservation (NOLOCK)
                     WHERE  PlanTypeID = p.PlanTypeID
                            AND CASE WHEN EmplClass IS NULL THEN ej.EmplClass
                                     WHEN EmplClass = '' THEN ej.EmplClass
                                     ELSE EmplClass
                                END = ej.EmplClass
                            AND ObservationTypeID IN (
                            SELECT  CodeID
                            FROM    dbo.CodeLookUp (NOLOCK)
                            WHERE   CodeType = 'ObsvType'
                                    AND CodeText = 'Announced' )
                   ), 0) AS AnnouncedMax ,
            ( SELECT    COUNT(ObsvID)
              FROM      dbo.ObservationHeader (NOLOCK)
              WHERE     IsDeleted = 0
                        AND DATEDIFF(n, ObsvStartTime, ObsvEndTime) >= 30
                        AND PlanID = p.PlanID
            ) AS GreaterThan30ObsvCnt ,
            ( SELECT    COUNT(ObsvID)
              FROM      dbo.ObservationHeader (NOLOCK)
              WHERE     IsDeleted = 0
                        AND PlanID = p.PlanID
                        AND DATEDIFF(n, ObsvStartTime, ObsvEndTime) < 30
            ) AS LessThan30ObsvCnt ,
            ISNULL(( SELECT SUM(DATEDIFF(n, ObsvStartTime, ObsvEndTime))
                     FROM   dbo.ObservationHeader (NOLOCK)
                     WHERE  IsDeleted = 0
                            AND PlanID = p.PlanID
                   ), 0) AS TotalTimeObsv ,
            ( SELECT    COUNT(oh.ObsvID)
              FROM      dbo.ObservationHeader AS oh ( NOLOCK )
                        JOIN dbo.ObservationDetail AS od ( NOLOCK ) ON od.IsDeleted = 0
                                                              AND NOT ( ISNULL(od.ObsvDEvidence,
                                                              '') = ''
                                                              AND ISNULL(od.ObsvDFeedBack,
                                                              '') = ''
                                                              )
                                                              AND oh.ObsvID = od.ObsvID
                        JOIN dbo.RubricIndicator AS ri ( NOLOCK ) ON od.IndicatorID = ri.IndicatorID
                        JOIN dbo.RubricStandard AS s ( NOLOCK ) ON s.StandardText LIKE 'I.%'
                                                              AND ri.StandardID = s.StandardID
              WHERE     oh.IsDeleted = 0
                        AND oh.PlanID = p.PlanID
            ) AS ObsvStdI ,
            ( SELECT    COUNT(oh.ObsvID)
              FROM      dbo.ObservationHeader AS oh ( NOLOCK )
                        JOIN dbo.ObservationDetail AS od ( NOLOCK ) ON od.IsDeleted = 0
                                                              AND NOT ( ISNULL(od.ObsvDEvidence,
                                                              '') = ''
                                                              AND ISNULL(od.ObsvDFeedBack,
                                                              '') = ''
                                                              )
                                                              AND oh.ObsvID = od.ObsvID
                        JOIN dbo.RubricIndicator AS ri ( NOLOCK ) ON od.IndicatorID = ri.IndicatorID
                        JOIN dbo.RubricStandard AS s ( NOLOCK ) ON s.StandardText LIKE 'II.%'
                                                              AND ri.StandardID = s.StandardID
              WHERE     oh.IsDeleted = 0
                        AND oh.PlanID = p.PlanID
            ) AS ObsvStdII ,
            ( SELECT    COUNT(oh.ObsvID)
              FROM      dbo.ObservationHeader AS oh ( NOLOCK )
                        JOIN dbo.ObservationDetail AS od ( NOLOCK ) ON oh.ObsvID = od.ObsvID
                                                              AND od.IsDeleted = 0
                                                              AND NOT ( ISNULL(od.ObsvDEvidence,
                                                              '') = ''
                                                              AND ISNULL(od.ObsvDFeedBack,
                                                              '') = ''
                                                              )
                        JOIN dbo.RubricIndicator AS ri ( NOLOCK ) ON od.IndicatorID = ri.IndicatorID
                        JOIN dbo.RubricStandard AS s ( NOLOCK ) ON s.StandardText LIKE 'III.%'
                                                              AND ri.StandardID = s.StandardID
              WHERE     oh.IsDeleted = 0
                        AND oh.PlanID = p.PlanID
            ) AS ObsvStdIII ,
            ( SELECT    COUNT(oh.ObsvID)
              FROM      dbo.ObservationHeader AS oh ( NOLOCK )
                        JOIN dbo.ObservationDetail AS od ( NOLOCK ) ON oh.ObsvID = od.ObsvID
                                                              AND od.IsDeleted = 0
                                                              AND NOT ( ISNULL(od.ObsvDEvidence,
                                                              '') = ''
                                                              AND ISNULL(od.ObsvDFeedBack,
                                                              '') = ''
                                                              )
                        JOIN dbo.RubricIndicator AS ri ( NOLOCK ) ON od.IndicatorID = ri.IndicatorID
                        JOIN dbo.RubricStandard AS s ( NOLOCK ) ON s.StandardText LIKE 'IV.%'
                                                              AND ri.StandardID = s.StandardID
              WHERE     oh.IsDeleted = 0
                        AND oh.PlanID = p.PlanID
            ) AS ObsvStdIV ,
            ISNULL(CONVERT(VARCHAR, ev.EvalDt, 101), '') AS FormAsmtEvalDt ,
            CASE WHEN ISNULL(ep.RxCnt, 0) > 0 THEN 'Yes'
                 ELSE 'No'
            END AS StdRateBelow ,
            ISNULL(CONVERT(VARCHAR, DATEADD(d, 30, ev.EvaluatorSignedDt), 101),
                   '') AS FollowUpDt
    FROM    dbo.EmplEmplJob AS ej ( NOLOCK )
            LEFT JOIN dbo.SubevalAssignedEmplEmplJob AS ase ( NOLOCK ) ON ase.IsActive = 1
                                                              AND ase.IsDeleted = 0
                                                              AND ase.IsPrimary = 1
                                                              AND ej.EmplJobID = ase.EmplJobID
            LEFT JOIN dbo.SubEval s ( NOLOCK ) ON s.EvalActive = 1
                                                  AND ase.SubEvalID = s.EvalID
            JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
            JOIN dbo.Department AS d ( NOLOCK ) ON ej.DeptID = d.DeptID
            LEFT JOIN dbo.CodeLookUp AS dc ( NOLOCK ) ON d.DeptCategoryID = dc.CodeID
            JOIN dbo.RptUnionCode AS ruc ( NOLOCK ) ON ruc.IsActive = 1
                                                       AND j.JobCode = ruc.JobCode
            JOIN dbo.Empl AS e ( NOLOCK ) ON e.EmplActive = 1
                                             AND ej.EmplID = e.EmplID
            LEFT JOIN dbo.Empl AS de ( NOLOCK ) ON de.EmplID = ej.MgrID
            LEFT JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
            LEFT JOIN ( SELECT  cte.EmplJobId ,
                                cte.EmplId ,
                                cte.JobCode
                        FROM    cte
                        WHERE   cte.PlanID IS NOT NULL
                      ) AS c ON ej.EmplID = c.EmplId
            LEFT JOIN dbo.EmplPlan AS p ( NOLOCK ) ON p.PlanActive = 1
                                                      AND c.EmplJobId = p.EmplJobID
            LEFT JOIN dbo.CodeLookUp AS pt ( NOLOCK ) ON p.PlanTypeID = pt.CodeID
            LEFT JOIN ( SELECT  PlanID ,
                                EvalDt ,
                                EvaluatorSignedDt ,
                                MAX(EvalID) AS EvalID
                        FROM    dbo.Evaluation (NOLOCK)
                        WHERE   IsSigned = 1
                                AND EvalTypeID IN (
                                SELECT  CodeID
                                FROM    dbo.CodeLookUp (NOLOCK)
                                WHERE   CodeType = 'EvalType'
                                        AND CodeText = 'Formative Assessment' )
                        GROUP BY PlanID ,
                                EvalDt ,
                                EvaluatorSignedDt
                      ) AS ev ON p.PlanID = ev.PlanID
            LEFT JOIN ( SELECT  EvalID ,
                                COUNT(*) AS RxCnt
                        FROM    dbo.EvaluationPrescription (NOLOCK)
                        GROUP BY EvalID
                      ) AS ep ON ev.EvalID = ep.EvalID
    WHERE   ej.IsActive = 1;	
GO
