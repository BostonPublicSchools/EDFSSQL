SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 04/24/2012
-- Description:	Goal status report
-- =============================================
CREATE PROCEDURE [dbo].[Report_GoalStatus]
    @ncUserId AS NCHAR(6) = NULL
AS
    BEGIN
        SET NOCOUNT ON;

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
                       ELSE ( de.NameLast + ', ' + de.NameFirst + ' '
                              + ISNULL(de.NameMiddle, '') )
                  END ) AS ManagerName ,
                CASE WHEN p.SubEvalID = '000000'
                     THEN CASE WHEN ase.SubEvalID IS NULL
                               THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                         THEN emplEx.MgrID
                                         ELSE ej.MgrID
                                    END
                               ELSE s.EmplID
                          END
                     ELSE p.SubEvalID
                END AS SubEvalID ,
                sub.NameLast + ', ' + sub.NameFirst + ' '
                + ISNULL(sub.NameMiddle, '') AS SubEvalName ,
                e.NameFirst ,
                e.NameMiddle ,
                e.NameLast ,
                e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle,
                                                              '') AS EmplName ,
                e.EmplActive ,
                ej.EmplJobID ,
                j.JobCode ,
                j.JobName ,
                e.NameLast + ' ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '')
                + ' ' + e.EmplID + ' ' + sub.NameLast + ' ' + sub.NameFirst AS Search ,
                1 AS PlanCount ,
                ISNULL(p.PlanActive, 0) AS PlanActive ,
                ISNULL(p.PlanTypeID, 0) AS PlanTypeId ,
                ( SELECT    ISNULL(CodeText, '')
                  FROM      dbo.CodeLookUp (NOLOCK)
                  WHERE     CodeID = p.PlanTypeID
                ) AS PlanType ,
                p.PlanStartDt ,
                p.PlanSchedEndDt AS PlanEndDt ,
                p.IsSignedAsmt ,
                p.DateSignedAsmt ,
                ISNULL(pc.CodeText, 'None') AS GoalStatus ,
                ( SELECT    COUNT(PlanID)
                  FROM      dbo.PlanGoal (NOLOCK)
                  WHERE     GoalTypeID IN ( SELECT  CodeID
                                            FROM    dbo.CodeLookUp (NOLOCK)
                                            WHERE   Code = 'pp' )
                            AND PlanID = p.PlanID
                ) AS ppGoalCount ,
                ( SELECT    COUNT(PlanID)
                  FROM      dbo.PlanGoal (NOLOCK)
                  WHERE     GoalTypeID IN ( SELECT  CodeID
                                            FROM    dbo.CodeLookUp (NOLOCK)
                                            WHERE   Code = 'sl' )
                            AND PlanID = p.PlanID
                ) AS slGoalCount
        FROM    dbo.Empl AS e ( NOLOCK )
                JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON ej.MgrID = @ncUserId
                                                         AND e.EmplID = ej.EmplID
                JOIN dbo.Department AS d ( NOLOCK ) ON ej.DeptID = d.DeptID
                JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
                LEFT JOIN dbo.SubevalAssignedEmplEmplJob AS ase ( NOLOCK ) ON ase.IsActive = 1
                                                              AND ase.IsDeleted = 0
                                                              AND ase.IsPrimary = 1
                                                              AND ej.EmplJobID = ase.EmplJobID
                LEFT JOIN dbo.SubEval s ( NOLOCK ) ON s.EvalActive = 1
                                                      AND ase.SubEvalID = s.EvalID
                JOIN dbo.Empl AS sub ( NOLOCK ) ON CASE WHEN ase.SubEvalID IS NULL
                                                        THEN CASE
                                                              WHEN ( emplEx.MgrID IS NOT NULL )
                                                              THEN emplEx.MgrID
                                                              ELSE ej.MgrID
                                                             END
                                                        ELSE s.EmplID
                                                   END = sub.EmplID
                JOIN dbo.Empl AS de ( NOLOCK ) ON de.EmplID = d.MgrID
                LEFT OUTER JOIN dbo.EmplPlan AS p ( NOLOCK ) ON p.PlanActive = 1
                                                              AND ej.EmplJobID = p.EmplJobID
                LEFT OUTER JOIN dbo.CodeLookUp AS pc ( NOLOCK ) ON p.GoalStatusID = pc.CodeID
        WHERE   e.EmplActive = 1; 		
    END;
GO
