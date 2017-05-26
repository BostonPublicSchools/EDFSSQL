SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 05/26/2017
-- Description:	List of goals associated with a plan
-- =============================================
CREATE PROCEDURE [dbo].[getGoalsByEvalID] @EvalID AS INT = NULL
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
                SUBSTRING(( SELECT  ','
                                    + ( CASE WHEN cd.CodeText = 'Student Learning'
                                             THEN 	  -- the value of goalTagID changes if we use the new goalTag which is mapped to rubricElement.
                                                  CAST(gt.GoalTagID AS NVARCHAR)
                                             ELSE cdElementTag.Code
                                        END )
                            FROM    dbo.GoalTag AS gt ( NOLOCK )
                                    LEFT OUTER JOIN dbo.CodeLookUp cdElementTag ( NOLOCK ) ON cdElementTag.CodeType = 'GoalTag'
                                                              AND cdElementTag.CodeID = gt.GoalTagID
                                    JOIN dbo.CodeLookUp cd ( NOLOCK ) ON cd.CodeType = 'GoalType'
                                                              AND cdElementTag.CodeSubText LIKE ( cd.CodeSubText )
                                                              + CAST(cd.CodeID AS CHAR(250))
                            WHERE   gt.GoalID = g.GoalID
                          FOR
                            XML PATH('')
                          ), 2, 9999) AS GoalTagIDs ,
                SUBSTRING(( SELECT  ', ' + CAST(c.CodeText AS VARCHAR(50))
                            FROM    dbo.GoalTag AS gt ( NOLOCK )
                                    JOIN dbo.CodeLookUp AS c ( NOLOCK ) ON gt.GoalTagID = c.CodeID
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
                  FROM      dbo.Empl e1 ( NOLOCK )
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
                  FROM      dbo.Empl e1 ( NOLOCK )
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
                                                              '') AS CreatedBy ,
                ( CASE WHEN g.GoalYear = 1 THEN oag.CodeText
                       ELSE oagnyr.CodeText
                  END ) AS OveralGoalStatus ,
                ( SELECT    COUNT(CodeID)
                  FROM      dbo.CodeLookUp (NOLOCK)
                  WHERE     CodeType = 'GoalType'
                            AND CodeSubText = ( SELECT  r.RubricName
                                                FROM    dbo.RubricHdr AS r ( NOLOCK )
                                                        JOIN dbo.EmplJob AS j ( NOLOCK ) ON j.JobCode = ej.JobCode
                                                              AND r.RubricID = j.RubricID
                                              )
                ) AS TotalGoalTypeCount ,
                CASE WHEN ( SELECT  COUNT(b.IsAllGoalTypesIncluded)
                            FROM    ( SELECT DISTINCT
                                                CASE WHEN a.TypeTotal < 0
                                                     THEN 'FALSE'
                                                     ELSE 'TRUE'
                                                END IsAllGoalTypesIncluded
                                      FROM      ( SELECT    PlanID ,
                                                            GoalTypeID ,
                                                            COUNT(GoalTypeID) AS TypeTotal
                                                  FROM      dbo.PlanGoal (NOLOCK)
                                                  WHERE     NOT GoalStatusID = ( SELECT
                                                              CodeID
                                                              FROM
                                                              dbo.CodeLookUp (NOLOCK)
                                                              WHERE
                                                              CodeText = 'Not Applicable'
                                                              AND CodeType = 'GoalStatus'
                                                              )
                                                  GROUP BY  PlanID ,
                                                            GoalTypeID
                                                  HAVING    COUNT(GoalTypeID) > 0
                                                ) AS a
                                    ) AS b
                          ) = 1
                     THEN ( SELECT  COUNT(CodeID)
                            FROM    dbo.CodeLookUp (NOLOCK)
                            WHERE   CodeType = 'GoalType'
                                    AND CodeSubText = ( SELECT
                                                              r.RubricName
                                                        FROM  dbo.RubricHdr AS r ( NOLOCK )
                                                              JOIN dbo.EmplJob
                                                              AS j ( NOLOCK ) ON j.JobCode = ej.JobCode
                                                              AND r.RubricID = j.RubricID
                                                      )
                          )
                     ELSE 0
                END AS SelectGoalTypesCount ,
                oagnyr.CodeID AS MultiYearGoalStatusID ,
                oagnyr.CodeText AS MultiYearGoalStatus ,
                ( gt.CodeText + '  |  ' + gl.CodeText + '  |  ' + g.GoalText ) AS DisplayText ,
                ( SELECT    COUNT(GoalID)
                  FROM      dbo.GoalActionStep (NOLOCK)
                  WHERE     GoalID = g.GoalID
                ) AS GoalActionStepCount
        FROM    dbo.EmplPlan AS p ( NOLOCK )
                JOIN dbo.PlanGoal AS g ( NOLOCK ) ON p.PlanID = g.PlanID
                JOIN dbo.Empl AS ce ( NOLOCK ) ON g.CreatedByID = ce.EmplID
                JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON p.EmplJobID = ej.EmplJobID
                LEFT JOIN dbo.SubevalAssignedEmplEmplJob sub ( NOLOCK ) ON sub.IsActive = 1
                                                              AND sub.IsDeleted = 0
                                                              AND sub.IsPrimary = 1
                                                              AND ej.EmplJobID = sub.EmplJobID
                LEFT JOIN dbo.SubEval s ( NOLOCK ) ON s.EvalActive = 1
                                                      AND sub.SubEvalID = s.EvalID
                JOIN dbo.Empl AS e ( NOLOCK ) ON ej.EmplID = e.EmplID
                LEFT OUTER JOIN dbo.Empl AS me ( NOLOCK ) ON ej.MgrID = me.EmplID
                JOIN dbo.CodeLookUp AS gt ( NOLOCK ) ON g.GoalTypeID = gt.CodeID
                JOIN dbo.CodeLookUp AS gl ( NOLOCK ) ON g.GoalLevelID = gl.CodeID
                JOIN dbo.CodeLookUp AS gs ( NOLOCK ) ON g.GoalStatusID = gs.CodeID
                LEFT OUTER JOIN dbo.GoalEvaluationProgress AS gep ( NOLOCK ) ON gep.EvalId = COALESCE(@EvalID,
                                                              gep.EvalId)
                                                              AND g.GoalID = gep.GoalID
                LEFT OUTER JOIN dbo.CodeLookUp AS gp ( NOLOCK ) ON gep.ProgressCodeID = gp.CodeID
                LEFT OUTER JOIN dbo.CodeLookUp AS oag ( NOLOCK ) ON p.GoalStatusID = oag.CodeID
                LEFT OUTER JOIN dbo.CodeLookUp AS oagnyr ( NOLOCK ) ON p.MultiYearGoalStatusID = oagnyr.CodeID
                LEFT OUTER JOIN dbo.Evaluation AS ev ( NOLOCK ) ON gep.EvalId = ev.EvalID
                LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
        ORDER BY g.CreatedByDt;		
    END;
GO
