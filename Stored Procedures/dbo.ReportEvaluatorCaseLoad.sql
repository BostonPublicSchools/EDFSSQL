SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[ReportEvaluatorCaseLoad]
    @ncUserId AS NCHAR(6) = NULL ,
    @UserRoleID AS INT
AS
    BEGIN
        SET NOCOUNT ON; 
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
            SELECT  MainTable.*
            FROM    ( SELECT    e.NameLast + ', ' + e.NameFirst + ' '
                                + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID
                                + ')' AS EducatorName ,
                                ( SELECT    e1.NameLast + ', ' + e1.NameFirst
                                            + ' ' + ISNULL(e1.NameMiddle, '')
                                            + ' (' + e1.EmplID + ')'
                                  FROM      dbo.Empl e1 ( NOLOCK )
                                  WHERE     e1.EmplID = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)
                                ) AS PrimaryEval ,
                                ( CASE WHEN p.PlanTypeID = 1
                                            AND p.IsMultiYearPlan = 'true'
                                       THEN '2 Years ' + pt.CodeText
                                       WHEN p.PlanTypeID = 1
                                            AND ( p.IsMultiYearPlan = 'false'
                                                  OR p.IsMultiYearPlan IS NULL
                                                ) THEN '1 Year ' + pt.CodeText
                                       ELSE pt.CodeText
                                  END ) AS PlanType ,
                                ISNULL(CONVERT(VARCHAR, p.PlanSchedEndDt, 101),
                                       '') AS PlanEnd ,
                                ( SELECT TOP 1
                                            CodeText + ' ('
                                            + RTRIM(clEmpCl.Code) + ')'
                                  FROM      dbo.CodeLookUp (NOLOCK)
                                  WHERE     CodeType = 'EmplClass'
                                            AND Code = ej.EmplClass
                                ) AS EmplClass ,
                                CASE WHEN p.PlanID IS NULL THEN 'Plan'
                                     WHEN p.IsSignedAsmt = 0
                                     THEN 'Self-Assessment'
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
                                              )
                                     THEN 'Next Year Goals & Action Steps'
                                     ELSE 'Collect Evidence'
                                END AS CurrentStep ,
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
                                       ), '') AS SummativeDate ,
                                ISNULL(( SELECT TOP 1
                                                ser.CodeText AS OverAllRating
                                         FROM   dbo.EmplEmplJob AS sej ( NOLOCK )
                                                JOIN dbo.EmplPlan AS sp ( NOLOCK ) ON sp.IsInvalid = 0
                                                              AND sej.EmplJobID = sp.EmplJobID
                                                JOIN dbo.Evaluation AS sev ( NOLOCK ) ON sp.PlanID = sev.PlanID
                                                JOIN dbo.CodeLookUp AS st ( NOLOCK ) ON st.CodeText = 'Summative Evaluation'
                                                              AND sev.IsSigned = 1
                                                              AND sev.IsDeleted = 0
                                                              AND sev.EvalTypeID = st.CodeID
                                                JOIN dbo.CodeLookUp AS ser ( NOLOCK ) ON sev.OverallRatingID = ser.CodeID
                                         WHERE  sej.EmplID = e.EmplID
                                         ORDER BY sev.EvalDt DESC
                                       ), '') AS SummativeRating ,
                                ISNULL(( SELECT TOP 1
                                                CONVERT(VARCHAR, sev.EvaluatorSignedDt, 101)
                                         FROM   dbo.EmplEmplJob AS sej ( NOLOCK )
                                                JOIN dbo.EmplPlan AS sp ( NOLOCK ) ON sp.IsInvalid = 0
                                                              AND sej.EmplJobID = sp.EmplJobID
                                                JOIN dbo.Evaluation AS sev ( NOLOCK ) ON sev.IsSigned = 1
                                                              AND sev.IsDeleted = 0
                                                              AND sp.PlanID = sev.PlanID
                                                JOIN dbo.CodeLookUp AS st ( NOLOCK ) ON st.CodeText LIKE 'Formative%'
                                                              AND sev.EvalTypeID = st.CodeID
                                                JOIN dbo.CodeLookUp AS ser ( NOLOCK ) ON sev.OverallRatingID = ser.CodeID
                                         WHERE  sej.EmplID = e.EmplID
                                         ORDER BY sev.EvalDt DESC
                                       ), '') AS FormativeDate ,
                                ISNULL(( SELECT TOP 1
                                                ser.CodeText AS OverAllRating
                                         FROM   dbo.EmplEmplJob AS sej ( NOLOCK )
                                                JOIN dbo.EmplPlan AS sp ( NOLOCK ) ON sp.IsInvalid = 0
                                                              AND sej.EmplJobID = sp.EmplJobID
                                                JOIN dbo.Evaluation AS sev ( NOLOCK ) ON sev.IsSigned = 1
                                                              AND sev.IsDeleted = 0
                                                              AND sp.PlanID = sev.PlanID
                                                JOIN dbo.CodeLookUp AS st ( NOLOCK ) ON st.CodeText LIKE 'Formative%'
                                                              AND sev.EvalTypeID = st.CodeID
                                                JOIN dbo.CodeLookUp AS ser ( NOLOCK ) ON sev.OverallRatingID = ser.CodeID
                                         WHERE  sej.EmplID = e.EmplID
                                         ORDER BY sev.EvalDt DESC
                                       ), '') AS FormativeRating ,
                                ( SELECT    COUNT(ev.EvidenceID)
                                  FROM      dbo.Evidence ev ( NOLOCK )
                                  WHERE     ev.EvidenceID IN (
                                            SELECT DISTINCT
                                                    ( epe.EvidenceID )
                                            FROM    dbo.EmplPlanEvidence epe ( NOLOCK )
                                            WHERE   epe.PlanID = p.PlanID
                                                    AND epe.IsDeleted = 0 )
                                            AND ev.IsDeleted = 0
                                ) AS Artifacts ,
                                ( SELECT    COUNT(ObsvID)
                                  FROM      dbo.ObservationHeader (NOLOCK)
                                  WHERE     ObsvRelease = 1
                                            AND PlanID = p.PlanID
                                ) AS Observations ,
                                rh.RubricID ,
                                ( CASE WHEN @ncUserId = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)
                                       THEN 1
                                       ELSE 0
                                  END ) AS IsPrimaryEvaluator ,
                                CASE WHEN p.AnticipatedEvalWeek IS NOT NULL
                                     THEN p.AnticipatedEvalWeek
                                     ELSE ''
                                END AS FormativeTargetedWeek
                      FROM      dbo.Empl AS e ( NOLOCK )
                                JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON ej.IsActive = 1
                                                              AND NOT ej.RubricID IN (
                                                              SELECT
                                                              RubricID
                                                              FROM
                                                              dbo.RubricHdr (NOLOCK)
                                                              WHERE
                                                              Is5StepProcess = 0 )
                                                              AND ej.EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID)
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
                                LEFT JOIN dbo.EmplPlan AS p ( NOLOCK ) ON c.EmplJobId = p.EmplJobID
                                                              AND p.PlanActive = 1
                                LEFT JOIN dbo.CodeLookUp AS pt ( NOLOCK ) ON p.PlanTypeID = pt.CodeID
                                LEFT JOIN dbo.CodeLookUp AS gs ( NOLOCK ) ON p.GoalStatusID = gs.CodeID
                                LEFT JOIN dbo.CodeLookUp AS gsMulti ( NOLOCK ) ON p.MultiYearGoalStatusID = gsMulti.CodeID
                                LEFT JOIN dbo.CodeLookUp AS clEmpCl ( NOLOCK ) ON clEmpCl.CodeType = 'emplclass'
                                                              AND clEmpCl.Code = ej.EmplClass
                                LEFT JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON rh.RubricID = ( CASE
                                                              WHEN p.RubricID IS NULL
                                                              THEN ej.RubricID
                                                              ELSE p.RubricID
                                                              END )
                      WHERE     e.EmplActive = 1
                                AND ( ( ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                               THEN emplEx.MgrID
                                               ELSE ej.MgrID
                                          END = @ncUserId )
                                        AND @UserRoleID = 1
                                      )
                                      OR ( @ncUserId IN (
                                           SELECT   s.EmplID
                                           FROM     dbo.SubevalAssignedEmplEmplJob
                                                    AS ase ( NOLOCK )
                                                    JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                                              AND s.EvalActive = 1
                                           WHERE    ase.EmplJobID = ej.EmplJobID
                                                    AND ase.IsActive = 1
                                                    AND ase.IsDeleted = 0 )
                                           AND @UserRoleID = 2
                                         )
                                      OR ( ej.EmplID = @ncUserId
                                           AND @UserRoleID = 3
                                         )
                                    )
                    ) AS MainTable;
    END;
GO
