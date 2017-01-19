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
	--,@IsNonLic as bit = 0 	
AS
    BEGIN
        SET NOCOUNT ON;
	
	;
        WITH    cte ( PlanID, EmplJobId, JobCode, EmplId )
                  AS ( SELECT   p.PlanID ,
                                ej.EmplJobID ,
                                ej.JobCode ,
                                ej.EmplID
                       FROM     EmplEmplJob AS ej ( NOLOCK )
                                JOIN EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                                JOIN EmplPlan AS p ( NOLOCK ) ON ej.EmplJobID = p.EmplJobID
                                JOIN RubricHdr AS r ( NOLOCK ) ON r.RubricID = ( CASE
                                                              WHEN p.RubricID IS NOT NULL
                                                              THEN p.RubricID
                                                              ELSE ej.RubricID
                                                              END )
                       WHERE    ej.IsActive = 1
                                AND p.PlanActive = 1
		--AND r.Is5StepProcess = @IsNonLic	
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
                                  FROM      Empl e1
                                  WHERE     e1.EmplID = emplEx.MgrID
                                )
                           ELSE ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                                            + ISNULL(e1.NameMiddle, '') + ' '
                                            + ISNULL(e1.NameLast, '')
                                  FROM      Empl e1
                                  WHERE     e1.EmplID = ej.MgrID
                                )
                      END ) AS ManagerName ,
                    COALESCE(( SELECT TOP 1
                                        s.EmplID
                               FROM     SubevalAssignedEmplEmplJob AS ase ( NOLOCK )
                                        JOIN SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
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
                                               FROM     Department )
                         THEN 'Manager'
                         WHEN ( SELECT TOP 1
                                        EmplID
                                FROM    SubEval
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
                      FROM      CodeLookUp
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
                    ( SELECT    COUNT(*)
                      FROM      PlanGoal
                      WHERE     PlanID = p.PlanID
                                AND GoalYear = 1
                                AND IsDeleted = 0
                    ) AS GoalCount ,
                    ( SELECT    COUNT(*)
                      FROM      ObservationHeader
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                    ) AS ObservationCount ,
                    ( SELECT    COUNT(*)
                      FROM      ObservationHeader
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                                AND CreatedByID = @ncUserId
                                AND ObsvRelease = 0
                    ) AS ObservationUnReleasedCountByEval ,
                    ( SELECT    COUNT(*)
                      FROM      ObservationHeader
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                                AND ObsvRelease = 0
                    ) AS ObservationUnReleasedTotalCount ,
                    ( SELECT    COUNT(*)
                      FROM      ObservationHeader
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                                AND CreatedByID = @ncUserId
                                AND ObsvRelease = 1
                    ) AS ObservationReleasedCountByEval ,
                    ( SELECT    COUNT(*)
                      FROM      ObservationHeader
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                                AND ObsvRelease = 1
                    ) AS ObservationReleasedTotalCount ,
                    ( SELECT    COUNT(*)
                      FROM      EmplPlanEvidence
                      WHERE     PlanID = p.PlanID
                                AND IsDeleted = 0
                    ) AS ArtifactCount ,
                    e.Sex AS EmplImage ,
                    ( SELECT TOP 1
                                eval.EvaluatorSignedDt
                      FROM      Evaluation AS eval
                                JOIN EmplPlan AS p ON eval.PlanID = p.PlanID
                                JOIN EmplEmplJob AS sej ON p.EmplJobID = sej.EmplJobID
                      WHERE     sej.EmplID = ej.EmplID
                                AND eval.IsDeleted = 0
                      ORDER BY  eval.EvalDt DESC
                    ) AS EvaluatorSignedDt ,
                    ( SELECT TOP 1
                                Eval.EvaluatorSignedDt
                      FROM      Evaluation AS Eval
                                JOIN EmplPlan AS p ON Eval.PlanID = p.PlanID
                                                      AND p.PlanActive = 1
                                JOIN EmplEmplJob AS sej ON p.EmplJobID = sej.EmplJobID
                      WHERE     sej.EmplID = ej.EmplID
                                AND Eval.IsDeleted = 0
                                AND Eval.EvalTypeID IN ( 83, 84 )
                                AND Eval.EvaluatorSignedDt IS NOT NULL
                      ORDER BY  Eval.EvaluatorSignedDt DESC
                    ) AS FormativeDate ,
                    ( SELECT TOP 1
                                Eval.EvaluatorSignedDt
                      FROM      Evaluation AS Eval
                                JOIN EmplPlan AS p ON Eval.PlanID = p.PlanID
                                                      AND p.PlanActive = 1
                                JOIN EmplEmplJob AS sej ON p.EmplJobID = sej.EmplJobID
                      WHERE     sej.EmplID = ej.EmplID
                                AND Eval.IsDeleted = 0
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
                    rh.Is5StepProcess AS Is5StepProcess
		--,case when ISNULL(p.PlanActive, 0) = 1 
		--	then ISNULL(rh.Is5StepProcess, 0)
		--	else ISNULL(ejrh.Is5StepProcess, 0)
		--	end Is5StepProcess
                    ,
                    rh.IsDESELic ,
                    ( CASE WHEN @UserRoleID = 1
                                AND @ncUserId = dbo.funcGetPrimaryManagerByEmplID(e.EmplID)
                           THEN 1
                           WHEN @UserRoleID = 2
                                AND @ncUserId IN (
                                SELECT  s.EmplID
                                FROM    SubevalAssignedEmplEmplJob AS ase ( NOLOCK )
                                        JOIN SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                WHERE   ase.EmplJobID IN (
                                        SELECT  EmplJobID
                                        FROM    EmplEmplJob
                                        WHERE   IsActive = 1
                                                AND EmplID = e.EmplID )
                                        AND ase.IsActive = 1
                                        AND ase.IsDeleted = 0
                                        AND ase.IsPrimary = 1 ) THEN 1
                           WHEN @UserRoleID = 3 THEN 0
                           ELSE 0
                      END ) IsPrimaryEvaluator ,
                    ISNULL(pcmulti.CodeText, 'None') AS MultiGoalStatus ,
                    ( SELECT    COUNT(*)
                      FROM      PlanGoal
                      WHERE     PlanID = p.PlanID
                                AND GoalYear = 2
                                AND IsDeleted = 0
                    ) AS SecondYearGoalCount ,
                    ISNULL(acmulti.CodeText, 'None') AS MultiActionStepStatus
            FROM    Empl AS e ( NOLOCK )
                    JOIN EmplEmplJob AS ej ( NOLOCK ) ON ej.IsActive = 1
					 AND e.EmplID = ej.EmplID
                    LEFT OUTER JOIN EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
                    JOIN Department AS d ( NOLOCK ) ON ej.DeptID = d.DeptID
                    JOIN EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                    LEFT JOIN ( SELECT  EmplJobId ,
                                        EmplId ,
                                        JobCode
                                FROM    cte
                                WHERE   PlanID IS NOT NULL
                              ) AS c ON ej.EmplID = c.EmplID
                    LEFT JOIN EmplPlan AS p ( NOLOCK ) ON p.PlanActive = 1
                                                          AND p.IsInvalid = 0
															AND c.EmplJobID = p.EmplJobID
                    LEFT JOIN RubricHdr AS rh ( NOLOCK ) ON rh.RubricID = ( CASE
                                                              WHEN p.RubricID IS NULL
                                                              THEN ej.RubricID
                                                              ELSE p.RubricID
                                                              END )									
	--left join RubricHdr as rh (nolock) on rh.RubricID = p.RubricID
                    LEFT OUTER JOIN CodeLookUp AS pc ( NOLOCK ) ON p.GoalStatusID = pc.CodeID
                    LEFT OUTER JOIN CodeLookUp AS ac ( NOLOCK ) ON p.ActnStepStatusID = ac.CodeID
                    LEFT OUTER JOIN CodeLookUp AS pcmulti ( NOLOCK ) ON p.MultiYearGoalStatusID = pcmulti.CodeID
                    LEFT OUTER JOIN CodeLookUp AS acmulti ( NOLOCK ) ON p.MultiYearActnStepStatusID = acmulti.CodeID
            WHERE   e.EmplActive = 1
                    AND ( ( ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                   THEN emplEx.MgrID
                                   ELSE ej.MgrID
                              END = @ncUserId )
                            AND @UserRoleID = 1
                          )
                          OR ( @ncUserId IN (
                               SELECT   s.EmplID
                               FROM     SubevalAssignedEmplEmplJob AS ase ( NOLOCK )
                                        JOIN SubEval s ( NOLOCK ) ON s.EvalActive = 1
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
