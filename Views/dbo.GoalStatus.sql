SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Avery, Bryce
-- Create date: 04/27/2012
-- Description:	Goal status report
-- =============================================
CREATE VIEW [dbo].[GoalStatus]
AS
    SELECT  e.EmplID ,
            ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN emplEx.MgrID
                   ELSE d.MgrID
              END ) AS MgrID ,
            ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                   THEN ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                                    + ISNULL(e1.NameMiddle, '') + ' '
                                    + ISNULL(e1.NameLast, '')
                          FROM      dbo.Empl e1 ( NOLOCK )
                          WHERE     e1.EmplID = emplEx.MgrID
                        )
                   ELSE ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                                    + ISNULL(e1.NameMiddle, '') + ' '
                                    + ISNULL(e1.NameLast, '')
                          FROM      dbo.Empl e1 ( NOLOCK )
                          WHERE     e1.EmplID = ej.MgrID
                        )
              END ) AS ManagerName ,
            CASE WHEN s.EmplID IS NULL
                 THEN CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN emplEx.MgrID
                           ELSE ej.MgrID
                      END
                 ELSE s.EmplID
            END SubEvalID ,
            ( CASE WHEN s.EmplID IS NULL
                   THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                             THEN ( SELECT  ISNULL(e1.NameFirst, '') + ' '
                                            + ISNULL(e1.NameMiddle, '') + ' '
                                            + ISNULL(e1.NameLast, '')
                                    FROM    dbo.Empl e1 ( NOLOCK )
                                    WHERE   e1.EmplID = emplEx.MgrID
                                  )
                             ELSE ( SELECT  ISNULL(e1.NameFirst, '') + ' '
                                            + ISNULL(e1.NameMiddle, '') + ' '
                                            + ISNULL(e1.NameLast, '')
                                    FROM    dbo.Empl e1 ( NOLOCK )
                                    WHERE   e1.EmplID = ej.MgrID
                                  )
                        END
                   ELSE ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                                    + ISNULL(e1.NameMiddle, '') + ' '
                                    + ISNULL(e1.NameLast, '')
                          FROM      dbo.Empl e1 ( NOLOCK )
                          WHERE     e1.EmplID = s.EmplID
                        )
              END ) AS SubEvalName ,
            e.NameFirst ,
            e.NameMiddle ,
            e.NameLast ,
            e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName ,
            e.EmplActive ,
            ej.EmplJobID ,
            j.JobCode ,
            j.JobName ,
            e.NameLast + ' ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '')
            + ' ' + e.EmplID AS Search ,
            1 AS PlanCount ,
            ISNULL(p.PlanActive, 0) AS PlanActive ,
            ISNULL(p.PlanTypeID, 0) AS PlanTypeId ,
            ( SELECT    ISNULL(CodeText, '')
              FROM      dbo.CodeLookUp ( NOLOCK )
              WHERE     CodeID = p.PlanTypeID
            ) AS PlanType ,
            p.PlanStartDt ,
            p.PlanSchedEndDt AS PlanEndDt ,
            p.IsSignedAsmt ,
            p.DateSignedAsmt ,
            ISNULL(pc.CodeText, 'None') AS GoalStatus ,
            ( SELECT    COUNT(PlanID)
              FROM      dbo.PlanGoal
              WHERE     GoalTypeID IN ( SELECT  CodeID
                                        FROM    dbo.CodeLookUp ( NOLOCK )
                                        WHERE   Code = 'pp' )
                        AND PlanID = p.PlanID
            ) AS ppGoalCount ,
            ( SELECT    COUNT(PlanID)
              FROM      dbo.PlanGoal ( NOLOCK )
              WHERE     GoalTypeID IN ( SELECT  CodeID
                                        FROM    dbo.CodeLookUp ( NOLOCK )
                                        WHERE   Code = 'sl' )
                        AND PlanID = p.PlanID
            ) AS slGoalCount ,
            ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN 1
                   ELSE 0
              END ) AS EmplExceptionExists
    FROM    dbo.Empl AS e ( NOLOCK )
            JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON e.EmplID = ej.EmplID
                                                 AND ej.IsActive = 1
                                                 AND ej.RubricID IN (
                                                 SELECT RubricID
                                                 FROM   dbo.RubricHdr(NOLOCK)
                                                 WHERE  Is5StepProcess = 1 )
            JOIN dbo.Department AS d ( NOLOCK ) ON ej.DeptID = d.DeptID
            JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
            LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
            LEFT JOIN dbo.SubevalAssignedEmplEmplJob AS ase ( NOLOCK ) ON ase.IsActive = 1
                                                              AND ase.IsDeleted = 0
                                                              AND ase.IsPrimary = 1
															  AND ej.EmplJobID = ase.EmplJobID
            LEFT JOIN dbo.SubEval s ( NOLOCK ) ON s.EvalActive = 1
                                              AND ase.SubEvalID = s.EvalID
            LEFT OUTER JOIN dbo.EmplPlan AS p ( NOLOCK ) ON p.PlanActive = 1
                                                        AND ej.EmplJobID = p.EmplJobID
            LEFT OUTER JOIN dbo.CodeLookUp AS pc ( NOLOCK ) ON p.GoalStatusID = pc.CodeID
    WHERE   e.EmplActive = 1;

GO
