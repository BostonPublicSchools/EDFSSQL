SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/24/2012
-- Description:	List of goals associated with a plan
-- =============================================
CREATE PROCEDURE [dbo].[getGoals]
    @PlanID AS INT = NULL ,
    @EvalID AS INT = NULL
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
                            FROM    GoalTag AS gt
                                    LEFT OUTER JOIN CodeLookUp cdElementTag ON cdElementTag.CodeID = gt.GoalTagID
                                                              AND cdElementTag.CodeType = 'GoalTag'
                                    JOIN CodeLookUp cd ON cd.CodeType = 'GoalType'
                                                          AND cdElementTag.CodeSubText LIKE ( cd.CodeSubText )
                                                          + CAST(cd.CodeID AS CHAR(250))
                            WHERE   gt.GoalID = g.GoalID
                          FOR
                            XML PATH('')
                          ), 2, 9999) AS GoalTagIDs ,
                SUBSTRING(( SELECT  ', ' + CAST(c.CodeText AS VARCHAR(50))
                            FROM    GoalTag AS gt
                                    JOIN CodeLookUp AS c ON gt.GoalTagID = c.CodeID
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
                  FROM      Empl e1
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
                  FROM      Empl e1
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
		--,oag.CodeText as OveralGoalStatus
                ,
                ( CASE WHEN g.GoalYear = 1 THEN oag.CodeText
                       ELSE oagnyr.CodeText
                  END ) AS OveralGoalStatus ,
                ( SELECT    COUNT(CodeID)
                  FROM      CodeLookUp
                  WHERE     CodeType = 'GoalType'
                            AND CodeSubText = ( SELECT  r.RubricName
                                                FROM    RubricHdr AS r ( NOLOCK )
                                                        JOIN EmplJob AS j ( NOLOCK ) ON r.RubricID = j.RubricID
                                                WHERE   j.JobCode = ej.JobCode
                                              )
                ) AS TotalGoalTypeCount ,
                CASE WHEN ( SELECT  COUNT(IsAllGoalTypesIncluded)
                            FROM    ( SELECT DISTINCT
                                                CASE WHEN TypeTotal < 0
                                                     THEN 'FALSE'
                                                     ELSE 'TRUE'
                                                END IsAllGoalTypesIncluded
                                      FROM      ( SELECT    PlanID ,
                                                            GoalTypeID ,
                                                            COUNT(GoalTypeID) AS TypeTotal
                                                  FROM      PlanGoal (NOLOCK)
                                                  WHERE     PlanID = COALESCE(@PlanID,
                                                              PlanID)
                                                            AND NOT GoalStatusID = ( SELECT
                                                              CodeID
                                                              FROM
                                                              CodeLookUp (NOLOCK)
                                                              WHERE
                                                              CodeText = 'Not Applicable'
                                                              AND CodeType = 'GoalStatus'
                                                              ) 
				--AND IsDeleted = 0
                                                  GROUP BY  PlanID ,
                                                            GoalTypeID
                                                  HAVING    COUNT(GoalTypeID) > 0
                                                ) AS a
                                    ) AS b
                          ) = 1
                     THEN ( SELECT  COUNT(CodeID)
                            FROM    CodeLookUp
                            WHERE   CodeType = 'GoalType'
                                    AND CodeSubText = ( SELECT
                                                              r.RubricName
                                                        FROM  RubricHdr AS r ( NOLOCK )
                                                              JOIN EmplJob AS j ( NOLOCK ) ON r.RubricID = j.RubricID
                                                        WHERE j.JobCode = ej.JobCode
                                                      )
                          )
                     ELSE 0
                END AS SelectGoalTypesCount ,
                oagnyr.CodeID AS MultiYearGoalStatusID ,
                oagnyr.CodeText AS MultiYearGoalStatus ,
                ( gt.CodeText + '  |  ' + gl.CodeText + '  |  ' + g.GoalText ) AS DisplayText ,
                ( SELECT    COUNT(GoalID)
                  FROM      GoalActionStep
                  WHERE     GoalID = g.GoalID
                ) AS GoalActionStepCount
        FROM    EmplPlan AS p ( NOLOCK )
                JOIN PlanGoal AS g ( NOLOCK ) ON p.PlanID = g.PlanID
                JOIN Empl AS ce ( NOLOCK ) ON g.CreatedByID = ce.EmplID
                JOIN EmplEmplJob AS ej ( NOLOCK ) ON p.EmplJobID = ej.EmplJobID
                LEFT JOIN SubevalAssignedEmplEmplJob sub ON sub.IsActive = 1
                                                            AND sub.IsDeleted = 0
                                                            AND sub.IsPrimary = 1
                                                            AND ej.EmplJobID = sub.EmplJobID
                LEFT JOIN SubEval s ( NOLOCK ) ON s.EvalActive = 1
                                                  AND sub.SubEvalID = s.EvalID
                JOIN Empl AS e ( NOLOCK ) ON ej.EmplID = e.EmplID
                LEFT OUTER JOIN Empl AS me ( NOLOCK ) ON ej.MgrID = me.EmplID
                JOIN CodeLookUp AS gt ( NOLOCK ) ON g.GoalTypeID = gt.CodeID
                JOIN CodeLookUp AS gl ( NOLOCK ) ON g.GoalLevelID = gl.CodeID
                JOIN CodeLookUp AS gs ( NOLOCK ) ON g.GoalStatusID = gs.CodeID
                LEFT OUTER JOIN GoalEvaluationProgress AS gep ( NOLOCK ) ON gep.EvalId = COALESCE(@EvalID,
                                                              gep.EvalId)
                                                              AND g.GoalID = gep.GoalID
                LEFT OUTER JOIN CodeLookUp AS gp ( NOLOCK ) ON gep.ProgressCodeID = gp.CodeID
                LEFT OUTER JOIN CodeLookUp AS oag ( NOLOCK ) ON p.GoalStatusID = oag.CodeID
                LEFT OUTER JOIN CodeLookUp AS oagnyr ( NOLOCK ) ON p.MultiYearGoalStatusID = oagnyr.CodeID
                LEFT OUTER JOIN Evaluation AS ev ( NOLOCK ) ON gep.EvalId = ev.EvalID
                LEFT OUTER JOIN EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
        WHERE   p.PlanID = COALESCE(@PlanID, p.PlanID)
        ORDER BY g.CreatedByDt;		
    END;
GO
