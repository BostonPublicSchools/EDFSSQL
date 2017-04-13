SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/17/2012
-- Description:	List employees assigned to a supervisor
-- =============================================
CREATE PROCEDURE [dbo].[getEmplList]
    @ncUserId AS NCHAR(6) = NULL ,
    @UserRoleID AS INT
AS
    BEGIN
        SET NOCOUNT ON;
	
	;
        WITH    cte ( PlanID, EmplJobId, JobCode, EmplId )
                  AS ( SELECT   p.PlanID ,
                                ej.EmplJobID ,
                                ej.JobCode ,
                                ej.EmplID
                       FROM     dbo.EmplEmplJob AS ej ( NOLOCK )
                                JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                                JOIN dbo.EmplPlan AS p ( NOLOCK ) ON p.PlanActive = 1
                                                              AND ej.EmplJobID = p.EmplJobID
                                JOIN dbo.RubricHdr AS r ( NOLOCK ) ON r.RubricID = ( CASE
                                                              WHEN p.RubricID IS NOT NULL
                                                              THEN p.RubricID
                                                              ELSE ej.RubricID
                                                              END )
                       WHERE    ej.IsActive = 1
                     )
            SELECT DISTINCT
                    e.EmplID ,
                    ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN emplEx.MgrID
                           ELSE d.MgrID
                      END ) AS MgrID ,
                    ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                           THEN ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                                            + ISNULL(e1.NameMiddle, '') + ' '
                                            + ISNULL(e1.NameLast, '')
                                  FROM      dbo.Empl e1
                                  WHERE     e1.EmplID = emplEx.MgrID
                                )
                           ELSE ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                                            + ISNULL(e1.NameMiddle, '') + ' '
                                            + ISNULL(e1.NameLast, '')
                                  FROM      dbo.Empl e1
                                  WHERE     e1.EmplID = ej.MgrID
                                )
                      END ) AS ManagerName ,
                    COALESCE(( SELECT TOP 1
                                        s.EmplID
                               FROM     dbo.SubevalAssignedEmplEmplJob AS ase ( NOLOCK )
                                        JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                               WHERE    ase.EmplJobID = ej.EmplJobID
                                        AND ase.IsActive = 1
                                        AND ase.IsDeleted = 0
                                        AND ( ( ase.IsPrimary = 1
                                                AND @UserRoleID = 1
                                              )
                                              OR ( @UserRoleID = 2
                                                   AND s.EmplID = @ncUserId
                                                   AND ase.IsPrimary = 1
                                                 )
                                            )
                             ), dbo.funcGetPrimaryManagerByEmplID(e.EmplID)) SubEvalID  --if its manager , then get the primary subeval or if its subeval, then get the matching subeval id.
                    ,
                    e.NameFirst ,
                    e.NameMiddle ,
                    e.NameLast ,
                    e.NameLast + ', ' + e.NameFirst + ' '
                    + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmplName ,
                    e.EmplActive ,
                    ej.EmplJobID ,
                    rh.RubricID ,
                    rh.RubricName ,
                    CASE WHEN ej.MgrID = '000000'
                              OR emplEx.MgrID IS NOT NULL
                              OR e.EmplID IN ( SELECT   MgrID
                                               FROM     dbo.Department )
                         THEN 'Manager'
                         WHEN ( SELECT TOP 1
                                        EmplID
                                FROM    dbo.SubEval  (NOLOCK)
                                WHERE   EmplID = e.EmplID
                                        AND EvalActive = 1
                              ) IS NOT NULL THEN 'Subevaluator'
                         ELSE 'Employee'
                    END AS EmplRoleDesc ,
                    ej.DeptID ,
                    d.DeptName ,
                    j.JobCode ,
                    j.JobName ,
                    e.NameLast + ' ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle,
                                                              '') + ' '
                    + e.EmplID AS Search ,
                    1 AS PlanCount ,
                    ISNULL(p.PlanActive, 0) AS PlanActive ,
                    ISNULL(p.PlanTypeID, 0) AS PlanTypeId ,
                    ( SELECT    ISNULL(CodeText, '')
                      FROM      dbo.CodeLookUp
                      WHERE     CodeID = p.PlanTypeID
                    ) AS PlanType ,
                    p.PlanYear AS PlanYear ,
                    p.IsMultiYearPlan AS IsMultiYearPlan ,
                    p.IsSignedAsmt ,
                    p.DateSignedAsmt ,
                    ( CASE WHEN p.PlanStartDt IS NOT NULL
                           THEN DATEDIFF(DAY, p.PlanStartDt, p.PlanSchedEndDt)
                           ELSE 0
                      END ) AS Duration ,
                    ISNULL(pc.CodeText, 'None') AS GoalStatus ,
                    ISNULL(ac.CodeText, 'None') AS ActionStepStatus ,
                    ( SELECT    COUNT(PlanID)
                      FROM      dbo.PlanGoal (NOLOCK)
                      WHERE     PlanID = p.PlanID
                                AND GoalYear = 1
                                AND IsDeleted = 0
                    ) AS GoalCount ,
                    ( SELECT    COUNT(PlanID)
                      FROM      dbo.ObservationHeader (NOLOCK)
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                    ) AS ObservationCount ,
                    ( SELECT    COUNT(PlanID)
                      FROM      dbo.ObservationHeader (NOLOCK)
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                                AND CreatedByID = @ncUserId
                                AND ObsvRelease = 0
                    ) AS ObservationUnReleasedCountByEval ,
                    ( SELECT    COUNT(PlanID)
                      FROM      dbo.ObservationHeader (NOLOCK)
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                                AND ObsvRelease = 0
                    ) AS ObservationUnReleasedTotalCount ,
                    ( SELECT    COUNT(PlanID)
                      FROM      dbo.ObservationHeader (NOLOCK)
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                                AND CreatedByID = @ncUserId
                                AND ObsvRelease = 1
                    ) AS ObservationReleasedCountByEval ,
                    ( SELECT    COUNT(PlanID)
                      FROM      dbo.ObservationHeader (NOLOCK)
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                                AND ObsvRelease = 1
                    ) AS ObservationReleasedTotalCount ,
                    ( SELECT    COUNT(PlanID)
                      FROM      dbo.EmplPlanEvidence (NOLOCK)
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                    ) AS ArtifactCount ,
                    e.Sex AS EmplImage ,
                    ( SELECT TOP 1
                                eval.EvaluatorSignedDt
                      FROM      dbo.Evaluation AS eval ( NOLOCK )
                                JOIN dbo.EmplPlan AS p ( NOLOCK ) ON eval.PlanID = p.PlanID
                                JOIN dbo.EmplEmplJob AS sej ( NOLOCK ) ON sej.EmplID = ej.EmplID
                                                              AND p.EmplJobID = sej.EmplJobID
                      WHERE     eval.IsDeleted = 0
                      ORDER BY  eval.EvalDt DESC
                    ) AS EvaluatorSignedDt ,
                    ( SELECT TOP 1
                                Eval.EvaluatorSignedDt
                      FROM      dbo.Evaluation AS Eval ( NOLOCK )
                                JOIN dbo.EmplPlan AS p ( NOLOCK ) ON Eval.PlanID = p.PlanID
                                                              AND p.PlanActive = 1
                                JOIN dbo.EmplEmplJob AS sej ( NOLOCK ) ON sej.EmplID = ej.EmplID
                                                              AND p.EmplJobID = sej.EmplJobID
                      WHERE     Eval.IsDeleted = 0
                                AND Eval.EvalTypeID IN ( 83, 84 )
                                AND Eval.EvaluatorSignedDt IS NOT NULL
                      ORDER BY  Eval.EvaluatorSignedDt DESC
                    ) AS FormativeDate ,
                    ( SELECT TOP 1
                                Eval.EvaluatorSignedDt
                      FROM      dbo.Evaluation AS Eval ( NOLOCK )
                                JOIN dbo.EmplPlan AS p ( NOLOCK ) ON p.PlanActive = 1
                                                              AND Eval.PlanID = p.PlanID
                                JOIN dbo.EmplEmplJob AS sej ( NOLOCK ) ON p.EmplJobID = sej.EmplJobID
                                                              AND sej.EmplID = ej.EmplID
                      WHERE     Eval.IsDeleted = 0
                                AND Eval.EvalTypeID = 85
                                AND Eval.EvaluatorSignedDt IS NOT NULL
                      ORDER BY  Eval.EvaluatorSignedDt DESC
                    ) AS SummativeDate ,
                    p.HasPrescript ,
                    p.PlanID ,
                    ej.EmplClass ,
                    j.UnionCode ,
                    ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN 1
                           ELSE 0
                      END ) AS EmplExceptionExists ,
                    rh.Is5StepProcess AS Is5StepProcess ,
                    rh.IsDESELic ,
                    ( CASE WHEN @UserRoleID = 1
                                AND @ncUserId = dbo.funcGetPrimaryManagerByEmplID(e.EmplID)
                           THEN 1
                           WHEN @UserRoleID = 2
                                AND @ncUserId IN (
                                SELECT  s.EmplID
                                FROM    dbo.SubevalAssignedEmplEmplJob AS ase ( NOLOCK )
                                        JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                WHERE   ase.EmplJobID IN (
                                        SELECT  EmplJobID
                                        FROM    dbo.EmplEmplJob (NOLOCK)
                                        WHERE   IsActive = 1
                                                AND EmplID = e.EmplID )
                                        AND ase.IsActive = 1
                                        AND ase.IsDeleted = 0
                                        AND ase.IsPrimary = 1 ) THEN 1
                           WHEN @UserRoleID = 3 THEN 0
                           ELSE 0
                      END ) IsPrimaryEvaluator ,
                    ISNULL(pcmulti.CodeText, 'None') AS MultiGoalStatus ,
                    ( SELECT    COUNT(PlanID)
                      FROM      dbo.PlanGoal (NOLOCK)
                      WHERE     GoalYear = 2
                                AND IsDeleted = 0
                                AND PlanID = p.PlanID
                    ) AS SecondYearGoalCount ,
                    ISNULL(acmulti.CodeText, 'None') AS MultiActionStepStatus
            FROM    dbo.Empl AS e ( NOLOCK )
                    JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON ej.IsActive = 1
                                                             AND e.EmplID = ej.EmplID
                    LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
                    JOIN dbo.Department AS d ( NOLOCK ) ON ej.DeptID = d.DeptID
                    JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                    LEFT JOIN ( SELECT  cte.EmplJobId ,
                                        cte.EmplId ,
                                        cte.JobCode
                                FROM    cte
                                WHERE   cte.PlanID IS NOT NULL
                              ) AS c ON ej.EmplID = c.EmplId
                    LEFT JOIN dbo.EmplPlan AS p ( NOLOCK ) ON p.PlanActive = 1
                                                              AND p.IsInvalid = 0
                                                              AND c.EmplJobId = p.EmplJobID
                    LEFT JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON rh.RubricID = ( CASE
                                                              WHEN p.RubricID IS NULL
                                                              THEN ej.RubricID
                                                              ELSE p.RubricID
                                                              END )
                    LEFT OUTER JOIN dbo.CodeLookUp AS pc ( NOLOCK ) ON p.GoalStatusID = pc.CodeID
                    LEFT OUTER JOIN dbo.CodeLookUp AS ac ( NOLOCK ) ON p.ActnStepStatusID = ac.CodeID
                    LEFT OUTER JOIN dbo.CodeLookUp AS pcmulti ( NOLOCK ) ON p.MultiYearGoalStatusID = pcmulti.CodeID
                    LEFT OUTER JOIN dbo.CodeLookUp AS acmulti ( NOLOCK ) ON p.MultiYearActnStepStatusID = acmulti.CodeID
            WHERE   e.EmplActive = 1
                    AND ( ( ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                   THEN emplEx.MgrID
                                   ELSE ej.MgrID
                              END = @ncUserId )
                            AND @UserRoleID = 1
                          )
                          OR ( @ncUserId IN (
                               SELECT   s.EmplID
                               FROM     dbo.SubevalAssignedEmplEmplJob AS ase ( NOLOCK )
                                        JOIN dbo.SubEval s ( NOLOCK ) ON s.EvalActive = 1
                                                              AND ase.SubEvalID = s.EvalID
                               WHERE    ase.IsActive = 1
                                        AND ase.IsDeleted = 0
                                        AND ase.EmplJobID = ej.EmplJobID )
                               AND @UserRoleID = 2
                             )
                          OR ( @UserRoleID = 3
                               AND ej.EmplID = @ncUserId
                             )
                        )
            ORDER BY rh.Is5StepProcess ,
                    e.NameLast ,
                    e.NameFirst;
    END;
GO
