SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 08/09/2012
-- Description:	get goal by goalID
-- =============================================
CREATE PROCEDURE [dbo].[getGoalByID] @GoalID AS INT
AS
    BEGIN
        SET NOCOUNT ON;
	
        DECLARE @GoalTagIDList AS NVARCHAR(MAX);
	
        SELECT  g.GoalID ,
                p.PlanID ,
                g.GoalYear ,
                g.GoalTypeID ,
                gt.CodeText AS GoalType ,
                g.GoalLevelID ,
                gl.CodeText AS GoalLevel ,
                g.GoalStatusID ,
                gs.CodeText AS GoalStatus ,
                g.GoalText ,
                g.IsDeleted ,
                gep.GoalEvalID ,
                gep.EvalId ,
                gep.ProgressCodeID ,
                gp.CodeText AS ProgressCode ,
                gep.Rationale ,
                SUBSTRING(( SELECT  ',' + CAST(gt.GoalTagID AS NVARCHAR)
                            FROM    GoalTag AS gt ( NOLOCK )
                            WHERE   gt.GoalID = g.GoalID
                          FOR
                            XML PATH('')
                          ), 2, 9999) AS GoalTagIDs ,
                SUBSTRING(( SELECT  ', ' + CAST(c.CodeText AS VARCHAR(50))
                            FROM    GoalTag AS gt ( NOLOCK )
                                    JOIN CodeLookUp AS c ( NOLOCK ) ON gt.GoalTagID = c.CodeID
                            WHERE   gt.GoalID = g.GoalID
                          FOR
                            XML PATH('')
                          ), 2, 9999) AS GoalTagTexts ,
                e.EmplID ,
                e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle,
                                                              '') AS EmplName ,
                ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN emplEx.MgrID
                       ELSE ej.MgrID
                  END ) AS MgrID ,
                ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                            + ISNULL(e1.NameMiddle, '') + ' '
                            + ISNULL(e1.NameLast, '')
                  FROM      Empl e1 ( NOLOCK )
                  WHERE     e1.EmplID = CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                             THEN emplEx.MgrID
                                             ELSE ej.MgrID
                                        END
                ) AS MgrName ,
                CASE WHEN s.EmplID IS NULL
                     THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                               THEN emplEx.MgrID
                               ELSE ej.MgrID
                          END
                     ELSE s.EmplID
                END SubEvalID ,
                ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                            + ISNULL(e1.NameMiddle, '') + ' '
                            + ISNULL(e1.NameLast, '')
                  FROM      Empl e1 ( NOLOCK )
                  WHERE     e1.EmplID = CASE WHEN s.EmplID IS NULL
                                             THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                                       THEN emplEx.MgrID
                                                       ELSE ej.MgrID
                                                  END
                                             ELSE s.EmplID
                                        END
                ) AS SubEvalName ,
                g.CreatedByID ,
                ce.NameLast + ', ' + ce.NameFirst + ' ' + ISNULL(ce.NameMiddle,
                                                              '') AS CreatedBy
        FROM    EmplPlan AS p ( NOLOCK )
                JOIN PlanGoal AS g ( NOLOCK ) ON p.PlanID = g.PlanID
                JOIN Empl AS ce ( NOLOCK ) ON g.CreatedByID = ce.EmplID
                JOIN EmplEmplJob AS ej ( NOLOCK ) ON p.EmplJobID = ej.EmplJobID
                LEFT JOIN SubevalAssignedEmplEmplJob AS ase ( NOLOCK ) ON ase.IsActive = 1
                                                              AND ase.IsDeleted = 0
                                                              AND ase.IsPrimary = 1
															  AND ej.EmplJobID = ase.EmplJobID
                LEFT JOIN SubEval s ( NOLOCK ) ON s.EvalActive = 1
                                                  AND ase.SubEvalID = s.EvalID
                LEFT OUTER JOIN EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
                JOIN Empl AS e ( NOLOCK ) ON ej.EmplID = e.EmplID
                JOIN CodeLookUp AS gt ( NOLOCK ) ON g.GoalTypeID = gt.CodeID
                JOIN CodeLookUp AS gl ( NOLOCK ) ON g.GoalLevelID = gl.CodeID
                JOIN CodeLookUp AS gs ( NOLOCK ) ON g.GoalStatusID = gs.CodeID
                LEFT OUTER JOIN GoalEvaluationProgress AS gep ( NOLOCK ) ON g.GoalID = gep.GoalID
                LEFT OUTER JOIN CodeLookUp AS gp ( NOLOCK ) ON gep.ProgressCodeID = gp.CodeID
        WHERE   g.IsDeleted = 0
                AND g.GoalID = @GoalID;
				
    END;
GO
