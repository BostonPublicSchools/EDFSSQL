SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 01/17/2013
-- Description: 
-- =============================================
CREATE VIEW [dbo].[ViewUnderPerformerCaseLoad]
AS
    SELECT  ( SELECT    ISNULL(e1.NameFirst, '') + ' ' + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                        + ISNULL(e1.NameLast, '')
              FROM      dbo.Empl e1 ( NOLOCK )
              WHERE     e1.EmplID = ( CASE WHEN emplEx.MgrID IS NOT NULL
                                           THEN emplEx.MgrID
                                           ELSE ej.MgrID
                                      END )
            ) AS ManagerName ,
            ( CASE WHEN emplEx.MgrID IS NOT NULL THEN emplEx.MgrID
                   ELSE ej.MgrID
              END ) AS ManagerID ,
            ( SELECT    ISNULL(e1.NameFirst, '') + ' ' + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                        + ISNULL(e1.NameLast, '')
              FROM      dbo.Empl e1 ( NOLOCK )
              WHERE     e1.EmplID = ej.EmplID
            ) AS EmployeeName ,
            ej.EmplID AS EmployeeID ,
            s.EmplID AS SubEvalID ,
            ( SELECT    ISNULL(e1.NameFirst, '') + ' ' + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                        + ISNULL(e1.NameLast, '')
              FROM      dbo.Empl e1 ( NOLOCK )
              WHERE     e1.EmplID = s.EmplID
            ) AS Evaluator ,
            dept.DeptName AS DepartmentName ,
            dept.DeptID AS DepartmentID ,
            ep.PlanID ,
            ( CASE WHEN ep.IsMultiYearPlan = 'true'
                        AND ep.PlanTypeID = 1 THEN 'Two Year '
                   WHEN ( ep.IsMultiYearPlan IS NULL
                          OR ep.IsMultiYearPlan = 'false'
                        )
                        AND ep.PlanTypeID = 1 THEN 'One Year '
                   ELSE ''
              END ) + ( SELECT  ISNULL(cdl.CodeText, '')
                        FROM    dbo.CodeLookUp (NOLOCK)
                        WHERE   CodeID = ep.PlanTypeID
                      ) AS PlanType ,
            ep.PlanTypeID ,
            dbo.funPlanCurrentStatus(ep.PlanID, PlanEval.EvalID) AS CurrentStepStatus ,
            dbo.funGetExpectedApproach(eval.EvalTypeID, eval.EditEndDt) AS ExpectedApproach ,
            ep.AnticipatedEvalWeek AS FormativeTargetWeek ,
            ( SELECT TOP 1
                        ( FormativeActualDt )
              FROM      dbo.vwFormativeEvalDt(ep.PlanID)
              ORDER BY  FormativeEvalID DESC
            ) AS FormativeActualDate ,
            ep.PlanStartDt ,
            ep.PlanSchedEndDt ,
            ( SELECT TOP 1
                        evalSumm.EvalDt
              FROM      dbo.Evaluation evalSumm ( NOLOCK )
              WHERE     evalSumm.PlanID = ep.PlanID
                        AND evalSumm.EvalTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp (NOLOCK)
                        WHERE   CodeType = 'EvalType  '
                                AND CodeText = 'Summative Evaluation' )
            ) SummativeDate ,
            ( CASE WHEN ep.PlanStartDt IS NULL THEN 0
                   ELSE DATEDIFF(DAY, ep.PlanStartDt, ep.PlanSchedEndDt)
              END ) AS PlanDuration ,
            ( CASE WHEN eval.EvalTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp (NOLOCK)
                        WHERE   CodeType = 'EvalType'
                                AND CodeText LIKE 'Formative%' )
                   THEN cdEval.CodeText
                   ELSE NULL
              END ) AS OverallRating ,
            ( CASE WHEN eval.EvalTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp (NOLOCK)
                        WHERE   CodeType = 'EvalType'
                                AND CodeText LIKE 'Summative%' )
                   THEN cdEval.CodeText
                   ELSE NULL
              END ) AS SummativeRating ,
            ( SELECT    COUNT(ep.PlanID)
              FROM      dbo.EmplPlan ep ( NOLOCK )
                        JOIN dbo.EmplEmplJob ej1 ( NOLOCK ) ON ej1.EmplID = ej.EmplID
                                                              AND ep.IsInvalid = 0
                                                              AND ej1.EmplJobID = ep.EmplJobID
            ) AS PlanCount ,
            ( CASE WHEN PlanEval.EvalCount IS NULL THEN 0
                   ELSE PlanEval.EvalCount
              END ) AS EvalCount ,
            ( SELECT    COUNT(obs.ObsvID)
              FROM      dbo.ObservationHeader obs ( NOLOCK )
              WHERE     obs.PlanID = ep.PlanID
                        AND obs.IsDeleted = 0
                        AND obs.ObsvTypeID = ( SELECT   CodeID
                                               FROM     dbo.CodeLookUp (NOLOCK)
                                               WHERE    CodeText = 'Unannounced'
                                                        AND CodeType = 'ObsvType'
                                             )
            ) AS AnnouncedObsCount ,
            ( SELECT    COUNT(obs.ObsvID)
              FROM      dbo.ObservationHeader obs ( NOLOCK )
              WHERE     obs.PlanID = ep.PlanID
                        AND obs.IsDeleted = 0
                        AND obs.ObsvTypeID = ( SELECT   CodeID
                                               FROM     dbo.CodeLookUp (NOLOCK)
                                               WHERE    CodeText = 'Announced'
                                                        AND CodeType = 'ObsvType'
                                             )
            ) AS UnAnnouncedObsCount ,
            ( SELECT    COUNT(PlanID)
              FROM      dbo.vwObservationByPlan (NOLOCK)
              WHERE     PlanID = ep.PlanID
                        AND SortOrder = 1
            ) AS StandardI ,
            ( SELECT    COUNT(PlanID)
              FROM      dbo.vwObservationByPlan (NOLOCK)
              WHERE     PlanID = ep.PlanID
                        AND SortOrder = 2
            ) AS StandardII ,
            ( SELECT    COUNT(PlanID)
              FROM      dbo.vwObservationByPlan (NOLOCK)
              WHERE     PlanID = ep.PlanID
                        AND SortOrder = 3
            ) AS StandardIII ,
            ( SELECT    COUNT(PlanID)
              FROM      dbo.vwObservationByPlan (NOLOCK)
              WHERE     PlanID = ep.PlanID
                        AND SortOrder = 4
            ) AS StandardIV ,
            0 AS GoalCount ,
            ISNULL(( SELECT SUM(EvidenceCount)
                     FROM   dbo.vwArtifactsByEviType (NOLOCK)
                     WHERE  PlanID = ep.PlanID
                            AND SortOrder = 1
                            AND EvidenceTypeID = '109'
                   ), 0) AS StandardI2 ,
            ISNULL(( SELECT SUM(EvidenceCount)
                     FROM   dbo.vwArtifactsByEviType (NOLOCK)
                     WHERE  PlanID = ep.PlanID
                            AND SortOrder = 2
                            AND EvidenceTypeID = '109'
                   ), 0) AS StandardII3 ,
            ISNULL(( SELECT SUM(EvidenceCount)
                     FROM   dbo.vwArtifactsByEviType (NOLOCK)
                     WHERE  PlanID = ep.PlanID
                            AND SortOrder = 3
                            AND EvidenceTypeID = '109'
                   ), 0) AS StandardIII4 ,
            ISNULL(( SELECT SUM(EvidenceCount)
                     FROM   dbo.vwArtifactsByEviType (NOLOCK)
                     WHERE  PlanID = ep.PlanID
                            AND SortOrder = 4
                            AND EvidenceTypeID = '109'
                   ), 0) AS StandardIV5 ,
            ISNULL(( SELECT SUM(EvidenceCount)
                     FROM   dbo.vwArtifactsByEviType (NOLOCK)
                     WHERE  PlanID = ep.PlanID
                            AND EvidenceTypeID = '108'
                   ), 0) AS Goals3 ,
            ( ( SELECT  COUNT(PlanID)
                FROM    dbo.vwObservationByPlan (NOLOCK)
                WHERE   PlanID = ep.PlanID
                        AND SortOrder = 1
              ) + ISNULL(( SELECT   SUM(EvidenceCount)
                           FROM     dbo.vwArtifactsByEviType (NOLOCK)
                           WHERE    PlanID = ep.PlanID
                                    AND SortOrder = 1
                                    AND EvidenceTypeID = '109'
                         ), 0) ) AS StandardI7 ,
            ( ( SELECT  COUNT(PlanID)
                FROM    dbo.vwObservationByPlan (NOLOCK)
                WHERE   PlanID = ep.PlanID
                        AND SortOrder = 2
              ) + ISNULL(( SELECT   SUM(EvidenceCount)
                           FROM     dbo.vwArtifactsByEviType (NOLOCK)
                           WHERE    PlanID = ep.PlanID
                                    AND SortOrder = 2
                                    AND EvidenceTypeID = '109'
                         ), 0) ) AS StandardI8 ,
            ( ( SELECT  COUNT(PlanID)
                FROM    dbo.vwObservationByPlan (NOLOCK)
                WHERE   PlanID = ep.PlanID
                        AND SortOrder = 3
              ) + ISNULL(( SELECT   SUM(EvidenceCount)
                           FROM     dbo.vwArtifactsByEviType (NOLOCK)
                           WHERE    PlanID = ep.PlanID
                                    AND SortOrder = 3
                                    AND EvidenceTypeID = '109'
                         ), 0) ) AS StandardI9 ,
            ( ( SELECT  COUNT(PlanID)
                FROM    dbo.vwObservationByPlan (NOLOCK)
                WHERE   PlanID = ep.PlanID
                        AND SortOrder = 4
              ) + ISNULL(( SELECT   SUM(EvidenceCount)
                           FROM     dbo.vwArtifactsByEviType (NOLOCK)
                           WHERE    PlanID = ep.PlanID
                                    AND SortOrder = 4
                                    AND EvidenceTypeID = '109'
                         ), 0) ) AS StandardI10 ,
            ISNULL(( SELECT SUM(EvidenceCount)
                     FROM   dbo.vwArtifactsByEviType (NOLOCK)
                     WHERE  PlanID = ep.PlanID
                            AND EvidenceTypeID = '108'
                   ), 0) AS Goals2 ,
            eval.EvaluatorSignedDt AS ReleasedDt ,
            ( SELECT    STUFF(( SELECT  ', ' + ' Commented On '
                                        + CONVERT(VARCHAR, cin.CommentDt, 101)
                                        + ': '
                                        + dbo.udf_StripHTML(cin.CommentText)
                                FROM    dbo.Comment cin ( NOLOCK )
                                WHERE   cin.PlanID = c.PlanID
                              FOR
                                XML PATH('')
                              ), 1, 2, '') AS comm
              FROM      dbo.Comment c ( NOLOCK )
              WHERE     c.CommentTypeID = ( SELECT TOP 1
                                                    CodeID
                                            FROM    dbo.CodeLookUp (NOLOCK)
                                            WHERE   CodeType = 'ComType'
                                                    AND Code = 'AdminCom'
                                          )
                        AND c.PlanID = ep.PlanID
              GROUP BY  c.PlanID
            ) AS AdminComment
    FROM    dbo.EmplPlan ep ( NOLOCK )
            JOIN dbo.CodeLookUp cdl ( NOLOCK ) ON ( cdl.CodeText = 'Improvement'
                                                    OR cdl.CodeText = 'Directed Growth'
                                                    OR cdl.CodeText = 'Self-Directed'
                                                  )
                                                  AND cdl.CodeID = ep.PlanTypeID
            JOIN dbo.EmplEmplJob ej ( NOLOCK ) ON ej.IsActive = 1
                                                  AND ej.EmplJobID = ep.EmplJobID
            JOIN dbo.Empl e ( NOLOCK ) ON e.EmplActive = 1
                                          AND e.EmplID = ej.EmplID
            LEFT JOIN dbo.SubevalAssignedEmplEmplJob AS ase ( NOLOCK ) ON ase.IsActive = 1
                                                              AND ase.IsDeleted = 0
                                                              AND ase.IsPrimary = 1
                                                              AND ej.EmplJobID = ase.EmplJobID
            LEFT JOIN dbo.SubEval s ( NOLOCK ) ON s.EvalActive = 1
                                                  AND ase.SubEvalID = s.EvalID
            LEFT OUTER JOIN dbo.EmplExceptions emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
            LEFT OUTER JOIN dbo.Department dept ( NOLOCK ) ON dept.DeptID = ej.DeptID
            LEFT OUTER JOIN ( SELECT    PlanID ,
                                        MAX(EvalID) AS EvalID ,
                                        COUNT(EvalID) AS EvalCount
                              FROM      dbo.Evaluation (NOLOCK)
                              GROUP BY  PlanID
                            ) AS PlanEval ON PlanEval.PlanID = ep.PlanID
            LEFT OUTER JOIN dbo.Evaluation eval ( NOLOCK ) ON eval.EvalID = PlanEval.EvalID
            LEFT OUTER JOIN dbo.CodeLookUp cdEval ( NOLOCK ) ON cdEval.CodeID = eval.OverallRatingID
    WHERE   ep.PlanActive = 1;
GO
