SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Avery, Bryce
-- Create date: 08/01/2012
-- Description:	View for Evaluator caseload report
-- =============================================
CREATE VIEW [dbo].[EvaluatorCaseLoad]
AS
    WITH    cte ( PlanID, EmplJobId, JobCode, EmplId )
              AS ( SELECT   p.PlanID ,
                            ej.EmplJobID ,
                            ej.JobCode ,
                            ej.EmplID
                   FROM     dbo.EmplEmplJob AS ej ( NOLOCK )
                            JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                            JOIN dbo.EmplPlan AS p ( NOLOCK ) ON p.PlanActive = 1
                                                              AND ej.EmplJobID = p.EmplJobID
                   WHERE    ej.IsActive = 1
                 )
    SELECT  MainTable.* ,
            ( CASE WHEN ( MainTable.PlanType = 'Self-Directed'
                          AND MainTable.CurrentPlanEvalCount = 0
                          AND MainTable.[Self-Directed] != '2 Year(s)'
                        ) THEN 'Formative Assessment'  	-- self directed 
                   WHEN ( MainTable.PlanType = 'Self-Directed'
                          AND MainTable.CurrentPlanEvalCount = 0
                          AND MainTable.[Self-Directed] = '2 Year(s)'
                        ) THEN 'Formative Evaluation'
                   WHEN ( MainTable.PlanType = 'Self-Directed'
                          AND MainTable.[Self-Directed] = '1 Year(s)'
                          AND MainTable.CurrentPlanEvalCount > 0
                          AND MainTable.forReleaseDtActvPlan = ''
                        ) THEN 'Formative Assessment'  	-- self directed - 1yr
                   WHEN ( MainTable.PlanType = 'Self-Directed'
                          AND MainTable.[Self-Directed] = '1 Year(s)'
                          AND MainTable.CurrentPlanEvalCount > 0
                          AND MainTable.forReleaseDtActvPlan != ''
                        ) THEN 'Summative Evaluation'  	-- self directed - 1yr
                   WHEN ( MainTable.PlanType = 'Self-Directed'
                          AND MainTable.[Self-Directed] = '2 Year(s)'
                          AND MainTable.CurrentPlanEvalCount = 1
                          AND MainTable.forEvalReleaseDtActvPlan = ''
                        ) THEN 'Formative Evaluation'
                   WHEN ( MainTable.PlanType = 'Self-Directed'
                          AND MainTable.[Self-Directed] = '2 Year(s)'
                          AND MainTable.CurrentPlanEvalCount > 1
                          AND MainTable.forEvalReleaseDtActvPlan != ''
                        ) THEN 'Summative Evaluation' 	-- self directed
                   WHEN ( MainTable.CurrentPlanEvalCount = 0
                          AND MainTable.forReleaseDtActvPlan = ''
                        ) THEN 'Formative Assessment'
                   WHEN ( MainTable.CurrentPlanEvalCount > 0
                          AND MainTable.forReleaseDtActvPlan != ''
                        ) THEN 'Summative Evaluation'
                   ELSE 'Formative Assessment'
              END ) AS NextEvaluation
    FROM    ( SELECT    d.DeptID ,
                        d.DeptName ,
                        dc.CodeID AS DeptCatID ,
                        dc.CodeText AS DeptCat ,
                        ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                               THEN emplEx.MgrID
                               ELSE ej.MgrID
                          END ) AS MgrID ,
                        ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                                    + ISNULL(e1.NameMiddle, '') + ' '
                                    + ISNULL(e1.NameLast, '')
                          FROM      dbo.Empl e1 ( NOLOCK )
                          WHERE     e1.EmplID = CASE WHEN emplEx.MgrID IS NOT NULL
                                                     THEN emplEx.MgrID
                                                     ELSE ej.MgrID
                                                END
                        ) AS ManagerName ,
                        ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                               THEN emplEx.MgrID + '@boston.k12.ma.us'
                               ELSE ej.MgrID + '@boston.k12.ma.us'
                          END ) AS MgrEmailAddr ,
                        ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN 'Yes'
                               ELSE 'No'
                          END ) AS EmplExceptionExists ,
                        see.EmplID AS SubEvalID ,
                        ( SELECT    ISNULL(see.NameFirst, '') + ' '
                                    + ISNULL(see.NameMiddle, '') + ' '
                                    + ISNULL(see.NameLast, '')
                        ) AS SubEvalName ,
                        see.EmplID + '@boston.k12.ma.us' AS SubEvalEmailaddr ,
                        ej.EmplID ,
                        e.NameLast + ', ' + e.NameFirst + ' '
                        + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmplName ,
                        ISNULL(pt.CodeText, '') AS PlanType ,
                        ISNULL(CONVERT(VARCHAR, p.PlanStartDt, 101), '') AS PlanStartDt ,
                        ISNULL(CONVERT(VARCHAR, p.PlanSchedEndDt, 101), '') AS PlanEndDt ,
                        CASE WHEN p.PlanStartDt IS NOT NULL
                             THEN DATEDIFF(d, p.PlanStartDt, p.PlanSchedEndDt)
                             WHEN p.PlanStartDt IS NULL
                             THEN DATEDIFF(d, GETDATE(), p.PlanSchedEndDt)
                             ELSE 0
                        END AS PlanDuration ,
                        CASE WHEN p.PlanTypeID = 1
                                  AND p.IsMultiYearPlan = 'true'
                             THEN '2 Year(s)'
                             WHEN p.PlanTypeID = 1
                                  AND ( p.IsMultiYearPlan = 'false'
                                        OR p.IsMultiYearPlan IS NULL
                                      ) THEN '1 Year(s)'
                             ELSE NULL
                        END AS [Self-Directed] ,
                        CASE WHEN p.AnticipatedEvalWeek IS NOT NULL
                             THEN p.AnticipatedEvalWeek
                             ELSE ''
                        END AS FormativeTargetDt ,
                        ISNULL(CONVERT(VARCHAR, p.PlanSchedEndDt, 101), '') AS SummativeTargetDt ,
                        CASE WHEN p.PlanID IS NULL THEN 'Plan'
                             WHEN p.IsSignedAsmt = 0 THEN 'Self-Assessment'
                             WHEN ISNULL(gs.CodeText, '') = 'Awaiting Approval'
                                  AND p.PlanYear = 1
                             THEN 'Approve Goals & Action Steps'
                             WHEN ISNULL(gs.CodeText, '') = 'Returned'
                                  AND p.PlanYear = 1
                             THEN 'Goal & Action Steps Returned'
                             WHEN NOT ISNULL(gs.CodeText, '') = 'Approved'
                                  AND p.PlanYear = 1
                             THEN 'Goals & Action Steps'
                             WHEN gs.CodeText = 'Approved'
                                  AND ( gsMulti.CodeText = 'Awaiting Approval' )
                                  AND ( p.IsMultiYearPlan = 'true'
                                        AND p.PlanYear = 2
                                      )
                             THEN 'Approve Next Year Goals & Action Steps'
                             WHEN gs.CodeText = 'Approved'
                                  AND ( gsMulti.CodeText = 'Returned' )
                                  AND ( p.IsMultiYearPlan = 'true'
                                        AND p.PlanYear = 2
                                      )
                             THEN 'Next Year Goals & Action Steps Returned'
                             WHEN gs.CodeText = 'Approved'
                                  AND NOT ISNULL(gsMulti.CodeText, '') = 'Approved'
                                  AND ( p.IsMultiYearPlan = 'true'
                                        AND p.PlanYear = 2
                                      ) THEN 'Next Year Goals & Action Steps'
                             ELSE 'Collect Evidence'
                        END AS Overdue ,
                        '' AS Approaching ,
                        ( SELECT    COUNT(ObsvID)
                          FROM      dbo.ObservationHeader (NOLOCK)
                          WHERE     ObsvRelease = 1
                                    AND PlanID = p.PlanID
                        ) AS Observations ,
                        ( SELECT    ISNULL(SUM(ISNULL(evid.EvidenceCount, 0)
                                               + ISNULL(obsv.ObservationCount,
                                                        0)), 0)
                          FROM      ( SELECT    epe.PlanID ,
                                                COUNT(epe.EvidenceID) AS EvidenceCount
                                      FROM      dbo.EmplPlanEvidence AS epe ( NOLOCK )
                                                JOIN dbo.CodeLookUp AS et ( NOLOCK ) ON et.CodeText IN (
                                                              'Standard Evidence' )
                                                              AND epe.EvidenceTypeID = et.CodeID
                                                JOIN dbo.RubricStandard AS s ( NOLOCK ) ON s.StandardText LIKE 'I.%'
                                                              AND epe.ForeignID = s.StandardID
                                      WHERE     epe.IsDeleted = 0
                                      GROUP BY  epe.PlanID
                                    ) AS evid
                                    LEFT JOIN ( SELECT  oh.PlanID ,
                                                        COUNT(od.ObsvDID) AS ObservationCount
                                                FROM    dbo.ObservationHeader
                                                        AS oh ( NOLOCK )
                                                        JOIN dbo.ObservationDetail
                                                        AS od ( NOLOCK ) ON od.IsDeleted = 0
                                                              AND oh.ObsvID = od.ObsvID
                                                        JOIN dbo.RubricIndicator
                                                        AS ri ( NOLOCK ) ON od.IndicatorID = ri.IndicatorID
                                                        JOIN dbo.RubricStandard
                                                        AS s ( NOLOCK ) ON s.StandardText LIKE 'I.%'
                                                              AND ri.StandardID = s.StandardID
                                                WHERE   oh.IsDeleted = 0
                                                GROUP BY oh.PlanID
                                              ) AS obsv ON evid.PlanID = obsv.PlanID
                          WHERE     evid.PlanID = p.PlanID
                        ) AS ArtifactStdI ,
                        ( SELECT    ISNULL(SUM(ISNULL(evid.EvidenceCount, 0)
                                               + ISNULL(obsv.ObservationCount,
                                                        0)), 0)
                          FROM      ( SELECT    epe.PlanID ,
                                                COUNT(epe.EvidenceID) AS EvidenceCount
                                      FROM      dbo.EmplPlanEvidence AS epe ( NOLOCK )
                                                JOIN dbo.CodeLookUp AS et ( NOLOCK ) ON et.CodeText IN (
                                                              'Standard Evidence' )
                                                              AND epe.EvidenceTypeID = et.CodeID
                                                JOIN dbo.RubricStandard AS s ( NOLOCK ) ON s.StandardText LIKE 'II.%'
                                                              AND epe.ForeignID = s.StandardID
                                      WHERE     epe.IsDeleted = 0
                                      GROUP BY  epe.PlanID
                                    ) AS evid
                                    LEFT JOIN ( SELECT  oh.PlanID ,
                                                        COUNT(od.ObsvDID) AS ObservationCount
                                                FROM    dbo.ObservationHeader
                                                        AS oh ( NOLOCK )
                                                        JOIN dbo.ObservationDetail
                                                        AS od ( NOLOCK ) ON od.IsDeleted = 0
                                                              AND oh.ObsvID = od.ObsvID
                                                        JOIN dbo.RubricIndicator
                                                        AS ri ( NOLOCK ) ON od.IndicatorID = ri.IndicatorID
                                                        JOIN dbo.RubricStandard
                                                        AS s ( NOLOCK ) ON s.StandardText LIKE 'II.%'
                                                              AND ri.StandardID = s.StandardID
                                                WHERE   oh.IsDeleted = 0
                                                GROUP BY oh.PlanID
                                              ) AS obsv ON evid.PlanID = obsv.PlanID
                          WHERE     evid.PlanID = p.PlanID
                        ) AS ArtifactStdII ,
                        ( SELECT    ISNULL(SUM(ISNULL(evid.EvidenceCount, 0)
                                               + ISNULL(obsv.ObservationCount,
                                                        0)), 0)
                          FROM      ( SELECT    epe.PlanID ,
                                                COUNT(epe.EvidenceID) AS EvidenceCount
                                      FROM      dbo.EmplPlanEvidence AS epe ( NOLOCK )
                                                JOIN dbo.CodeLookUp AS et ( NOLOCK ) ON et.CodeText IN (
                                                              'Standard Evidence' )
                                                              AND epe.EvidenceTypeID = et.CodeID
                                                JOIN dbo.RubricStandard AS s ( NOLOCK ) ON s.StandardText LIKE 'III.%'
                                                              AND epe.ForeignID = s.StandardID
                                      WHERE     epe.IsDeleted = 0
                                      GROUP BY  epe.PlanID
                                    ) AS evid
                                    LEFT JOIN ( SELECT  oh.PlanID ,
                                                        COUNT(od.ObsvDID) AS ObservationCount
                                                FROM    dbo.ObservationHeader
                                                        AS oh ( NOLOCK )
                                                        JOIN dbo.ObservationDetail
                                                        AS od ( NOLOCK ) ON od.IsDeleted = 0
                                                              AND oh.ObsvID = od.ObsvID
                                                        JOIN dbo.RubricIndicator
                                                        AS ri ( NOLOCK ) ON od.IndicatorID = ri.IndicatorID
                                                        JOIN dbo.RubricStandard
                                                        AS s ( NOLOCK ) ON s.StandardText LIKE 'III.%'
                                                              AND ri.StandardID = s.StandardID
                                                WHERE   oh.IsDeleted = 0
                                                GROUP BY oh.PlanID
                                              ) AS obsv ON evid.PlanID = obsv.PlanID
                          WHERE     evid.PlanID = p.PlanID
                        ) AS ArtifactStdIII ,
                        ( SELECT    ISNULL(SUM(ISNULL(evid.EvidenceCount, 0)
                                               + ISNULL(obsv.ObservationCount,
                                                        0)), 0)
                          FROM      ( SELECT    epe.PlanID ,
                                                COUNT(epe.EvidenceID) AS EvidenceCount
                                      FROM      dbo.EmplPlanEvidence AS epe ( NOLOCK )
                                                JOIN dbo.CodeLookUp AS et ( NOLOCK ) ON et.CodeText IN (
                                                              'Standard Evidence' )
                                                              AND epe.EvidenceTypeID = et.CodeID
                                                JOIN dbo.RubricStandard AS s ( NOLOCK ) ON s.StandardText LIKE 'IV.%'
                                                              AND epe.ForeignID = s.StandardID
                                      WHERE     epe.IsDeleted = 0
                                      GROUP BY  epe.PlanID
                                    ) AS evid
                                    LEFT JOIN ( SELECT  oh.PlanID ,
                                                        COUNT(od.ObsvDID) AS ObservationCount
                                                FROM    dbo.ObservationHeader
                                                        AS oh ( NOLOCK )
                                                        JOIN dbo.ObservationDetail
                                                        AS od ( NOLOCK ) ON od.IsDeleted = 0
                                                              AND oh.ObsvID = od.ObsvID
                                                        JOIN dbo.RubricIndicator
                                                        AS ri ( NOLOCK ) ON od.IndicatorID = ri.IndicatorID
                                                        JOIN dbo.RubricStandard
                                                        AS s ( NOLOCK ) ON s.StandardText LIKE 'IV.%'
                                                              AND ri.StandardID = s.StandardID
                                                WHERE   oh.IsDeleted = 0
                                                GROUP BY oh.PlanID
                                              ) AS obsv ON evid.PlanID = obsv.PlanID
                          WHERE     evid.PlanID = p.PlanID
                        ) AS ArtifactStdIV ,
                        ( SELECT    COUNT(ev.EvidenceID)
                          FROM      dbo.Evidence ev
                          WHERE     ev.EvidenceID IN (
                                    SELECT DISTINCT
                                            ( epe.EvidenceID )
                                    FROM    dbo.EmplPlanEvidence epe
                                    WHERE   epe.IsDeleted = 0
                                            AND epe.PlanID = p.PlanID )
                                    AND ev.IsDeleted = 0
                        ) AS ArtifactCount ,
                        ( SELECT    COUNT(epe.PlanEvidenceID)
                          FROM      dbo.EmplPlanEvidence AS epe ( NOLOCK )
                                    JOIN dbo.CodeLookUp AS et ( NOLOCK ) ON et.CodeText IN (
                                                              'Goal Evidence' )
                                                              AND epe.EvidenceTypeID = et.CodeID
                          WHERE     epe.IsDeleted = 0
                                    AND epe.PlanID = p.PlanID
                        ) AS ArtifactGoal ,
                        ( SELECT    COUNT(PlanID)
                          FROM      dbo.EmplPlan (NOLOCK)
                          WHERE     PlanStartDt >= '2012-07-01'
                                    AND IsInvalid = 0
                                    AND EmplJobID IN (
                                    SELECT  EmplJobID
                                    FROM    dbo.EmplEmplJob (NOLOCK)
                                    WHERE   EmplID = e.EmplID )
                        ) AS PlanCount ,
                        ( SELECT    COUNT(EvalID)
                          FROM      dbo.Evaluation (NOLOCK)
                          WHERE     EvaluatorSignedDt > '2012-07-01'
                                    AND PlanID IN (
                                    SELECT  PlanID
                                    FROM    dbo.EmplPlan (NOLOCK)
                                    WHERE   IsInvalid = 0
                                            AND EmplJobID IN (
                                            SELECT  EmplJobID
                                            FROM    dbo.EmplEmplJob (NOLOCK)
                                            WHERE   EmplID = e.EmplID ) )
                        ) AS EvalCount ,
                        ( SELECT    COUNT(EvalID)
                          FROM      dbo.Evaluation (NOLOCK)
                          WHERE     IsDeleted = 0
                                    AND PlanID = p.PlanID
                        ) AS CurrentPlanEvalCount ,
                        ISNULL(( SELECT TOP 1
                                        ser.CodeText AS OverAllRating
                                 FROM   dbo.EmplEmplJob AS sej ( NOLOCK )
                                        JOIN dbo.EmplPlan AS sp ( NOLOCK ) ON sej.EmplJobID = sp.EmplJobID
                                                              AND sp.IsInvalid = 0
                                        JOIN dbo.Evaluation AS sev ( NOLOCK ) ON sp.PlanID = sev.PlanID
                                        JOIN dbo.CodeLookUp AS st ( NOLOCK ) ON st.CodeText = 'Summative Evaluation'
                                                              AND sev.EvalTypeID = st.CodeID
                                        JOIN dbo.CodeLookUp AS ser ( NOLOCK ) ON sev.OverallRatingID = ser.CodeID
                                 WHERE  sev.IsSigned = 1
                                        AND sev.IsDeleted = 0
                                        AND sej.EmplID = e.EmplID
                                 ORDER BY sev.EvalDt DESC
                               ), '') AS sumOverAllRating ,
                        ISNULL(( SELECT TOP 1
                                        CONVERT(VARCHAR, sev.EvaluatorSignedDt, 101)
                                 FROM   dbo.EmplEmplJob AS sej ( NOLOCK )
                                        JOIN dbo.EmplPlan AS sp ( NOLOCK ) ON sp.IsInvalid = 0
                                                              AND sej.EmplJobID = sp.EmplJobID
                                        JOIN dbo.Evaluation AS sev ( NOLOCK ) ON sev.IsSigned = 1
                                                              AND sev.IsDeleted = 0
                                                              AND sp.PlanID = sev.PlanID
                                        JOIN dbo.CodeLookUp AS st ( NOLOCK ) ON st.CodeText = 'Summative Evaluation'
                                                              AND sev.EvalTypeID = st.CodeID
                                        JOIN dbo.CodeLookUp AS ser ( NOLOCK ) ON sev.OverallRatingID = ser.CodeID
                                 WHERE  sej.EmplID = e.EmplID
                                 ORDER BY sev.EvalDt DESC
                               ), '') AS sumReleaseDt ,
                        ISNULL(( SELECT TOP 1
                                        ser.CodeText AS OverAllRating
                                 FROM   dbo.EmplEmplJob AS sej ( NOLOCK )
                                        JOIN dbo.EmplPlan AS sp ( NOLOCK ) ON sp.IsInvalid = 0
                                                              AND sej.EmplJobID = sp.EmplJobID
                                        JOIN dbo.Evaluation AS sev ( NOLOCK ) ON sp.PlanID = sev.PlanID
                                        JOIN dbo.CodeLookUp AS st ( NOLOCK ) ON st.CodeText LIKE 'Formative%'
                                                              AND sev.EvalTypeID = st.CodeID
                                                              AND sev.IsSigned = 1
                                                              AND sev.IsDeleted = 0
                                        JOIN dbo.CodeLookUp AS ser ( NOLOCK ) ON sev.OverallRatingID = ser.CodeID
                                 WHERE  sej.EmplID = e.EmplID
                                 ORDER BY sev.EvalDt DESC
                               ), '') AS forOverAllRating ,
                        ISNULL(( SELECT TOP 1
                                        CONVERT(VARCHAR, sev.EvaluatorSignedDt, 101)
                                 FROM   dbo.EmplEmplJob AS sej ( NOLOCK )
                                        JOIN dbo.EmplPlan AS sp ( NOLOCK ) ON sej.EmplJobID = sp.EmplJobID
                                                              AND sp.IsInvalid = 0
                                        JOIN dbo.Evaluation AS sev ( NOLOCK ) ON sev.IsSigned = 1
                                                              AND sev.IsDeleted = 0
                                                              AND sp.PlanID = sev.PlanID
                                        JOIN dbo.CodeLookUp AS st ( NOLOCK ) ON st.CodeText LIKE 'Formative%'
                                                              AND sev.EvalTypeID = st.CodeID
                                        JOIN dbo.CodeLookUp AS ser ( NOLOCK ) ON sev.OverallRatingID = ser.CodeID
                                 WHERE  sej.EmplID = e.EmplID
                                 ORDER BY sev.EvalDt DESC
                               ), '') AS forReleaseDt ,
                        ISNULL(( SELECT TOP 1
                                        CONVERT(VARCHAR, sev.EvaluatorSignedDt, 101)
                                 FROM   dbo.EmplEmplJob AS sej ( NOLOCK )
                                        JOIN dbo.EmplPlan AS sp ( NOLOCK ) ON sej.EmplJobID = sp.EmplJobID
                                                              AND sp.IsInvalid = 0
                                        JOIN dbo.Evaluation AS sev ( NOLOCK ) ON sev.IsSigned = 1
                                                              AND sev.IsDeleted = 0
                                                              AND sp.PlanID = sev.PlanID
                                        JOIN dbo.CodeLookUp AS st ( NOLOCK ) ON st.CodeText = 'Formative Evaluation'
                                                              AND sev.EvalTypeID = st.CodeID
                                        JOIN dbo.CodeLookUp AS ser ( NOLOCK ) ON sev.OverallRatingID = ser.CodeID
                                 WHERE  sej.EmplID = e.EmplID
                                 ORDER BY sev.EvalDt DESC
                               ), '') AS forEvalReleaseDt ,
                        clEmpCl.CodeText + ' (' + RTRIM(clEmpCl.Code) + ')' AS EmplClass ,
                        ISNULL(CONVERT(VARCHAR, p.GoalFirstSubmitDt, 101), '') GoalFirstSubmitDate
		
---current current active plan evals: used in NextEvaluation
                        ,
                        ISNULL(( SELECT TOP 1
                                        CONVERT(VARCHAR, sev.EvaluatorSignedDt, 101)
                                 FROM   dbo.EmplEmplJob AS sej ( NOLOCK )
                                        JOIN dbo.EmplPlan AS sp ( NOLOCK ) ON sp.IsInvalid = 0
                                                              AND sp.PlanID = p.PlanID
                                                              AND sej.EmplJobID = sp.EmplJobID
                                        JOIN dbo.Evaluation AS sev ( NOLOCK ) ON sev.IsSigned = 1
                                                              AND sev.IsDeleted = 0
                                                              AND sp.PlanID = sev.PlanID
                                        JOIN dbo.CodeLookUp AS st ( NOLOCK ) ON st.CodeText LIKE 'Formative%'
                                                              AND sev.EvalTypeID = st.CodeID
                                        JOIN dbo.CodeLookUp AS ser ( NOLOCK ) ON sev.OverallRatingID = ser.CodeID
                                 WHERE  sej.EmplID = e.EmplID
                                 ORDER BY sev.EvalDt DESC
                               ), '') AS forReleaseDtActvPlan ,
                        ISNULL(( SELECT TOP 1
                                        CONVERT(VARCHAR, sev.EvaluatorSignedDt, 101)
                                 FROM   dbo.EmplEmplJob AS sej ( NOLOCK )
                                        JOIN dbo.EmplPlan AS sp ( NOLOCK ) ON sp.IsInvalid = 0
                                                              AND sp.PlanID = p.PlanID
                                                              AND sej.EmplJobID = sp.EmplJobID
                                        JOIN dbo.Evaluation AS sev ( NOLOCK ) ON sev.IsSigned = 1
                                                              AND sev.IsDeleted = 0
                                                              AND sp.PlanID = sev.PlanID
                                        JOIN dbo.CodeLookUp AS st ( NOLOCK ) ON st.CodeText = 'Formative Evaluation'
                                                              AND sev.EvalTypeID = st.CodeID
                                        JOIN dbo.CodeLookUp AS ser ( NOLOCK ) ON sev.OverallRatingID = ser.CodeID
                                 WHERE  sej.EmplID = e.EmplID
                                 ORDER BY sev.EvalDt DESC
                               ), '') AS forEvalReleaseDtActvPlan
---	
              FROM      dbo.Empl AS e ( NOLOCK )
                        JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON ej.IsActive = 1
                                                              AND NOT ej.RubricID IN (
                                                              SELECT
                                                              RubricID
                                                              FROM
                                                              dbo.RubricHdr (NOLOCK)
                                                              WHERE
                                                              Is5StepProcess = 0 )
                                                              AND e.EmplID = ej.EmplID
                        JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                        JOIN dbo.Department AS d ( NOLOCK ) ON ej.DeptID = d.DeptID
                        LEFT OUTER JOIN dbo.CodeLookUp AS dc ( NOLOCK ) ON d.DeptCategoryID = dc.CodeID
                        LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
                        LEFT JOIN dbo.SubevalAssignedEmplEmplJob ase ( NOLOCK ) ON ase.IsActive = 1
                                                              AND ase.IsDeleted = 0
                                                              AND ase.IsPrimary = 1
                                                              AND ase.EmplJobID = ej.EmplJobID
                        LEFT JOIN dbo.SubEval s ( NOLOCK ) ON s.EvalActive = 1
                                                              AND s.EvalID = ase.SubEvalID
                        LEFT JOIN ( SELECT  ( CASE WHEN ex.MgrID IS NOT NULL
                                                   THEN ex.MgrID
                                                   ELSE ej1.MgrID
                                              END ) AS managerID ,
                                            ej1.EmplJobID ,
                                            ej1.EmplID
                                    FROM    dbo.EmplEmplJob ej1 ( NOLOCK )
                                            LEFT OUTER JOIN dbo.EmplExceptions ex ( NOLOCK ) ON ex.EmplJobID = ej1.EmplJobID
                                    WHERE   ej1.EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej1.EmplID)
                                  ) AS PrimaryEmplJobTable ON PrimaryEmplJobTable.EmplJobID = ej.EmplJobID
                        LEFT JOIN dbo.Empl see ( NOLOCK ) ON see.EmplID = ( CASE
                                                              WHEN s.EmplID IS NOT NULL
                                                              THEN s.EmplID
                                                              WHEN PrimaryEmplJobTable.managerID IS NOT NULL
                                                              THEN PrimaryEmplJobTable.managerID
                                                              ELSE ( CASE
                                                              WHEN ( emplEx.MgrID IS NOT NULL )
                                                              THEN emplEx.MgrID
                                                              ELSE ej.MgrID
                                                              END )
                                                              END )
                        LEFT JOIN ( SELECT  cte.EmplJobId ,
                                            cte.EmplId ,
                                            cte.JobCode
                                    FROM    cte
                                    WHERE   cte.PlanID IS NOT NULL
                                  ) AS c ON ej.EmplID = c.EmplId
                        LEFT JOIN dbo.EmplPlan AS p ( NOLOCK ) ON p.PlanActive = 1
                                                              AND c.EmplJobId = p.EmplJobID
                        LEFT JOIN dbo.CodeLookUp AS pt ( NOLOCK ) ON p.PlanTypeID = pt.CodeID
                        LEFT JOIN dbo.CodeLookUp AS gs ( NOLOCK ) ON p.GoalStatusID = gs.CodeID
                        LEFT JOIN dbo.CodeLookUp AS gsMulti ( NOLOCK ) ON p.MultiYearGoalStatusID = gsMulti.CodeID
                        LEFT JOIN dbo.CodeLookUp AS clEmpCl ( NOLOCK ) ON clEmpCl.CodeType = 'emplclass'
                                                              AND clEmpCl.Code = ej.EmplClass
              WHERE     e.EmplActive = 1
                        AND ej.EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID)
            ) AS MainTable;
GO
