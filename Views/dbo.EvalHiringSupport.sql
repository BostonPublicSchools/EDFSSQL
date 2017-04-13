SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







/* =============================================
 Author:		Newa,Matina
 Create date:   04/9/2013
 Description:	View for Evaluation as HR hiring Support
 =============================================*/
CREATE VIEW [dbo].[EvalHiringSupport]
AS
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
    SELECT  ecl.EmplID ,
            ecl.EmplName ,
            ecl.MgrID ,
            ecl.ManagerName ,
            ecl.SubEvalID ,
            ecl.SubEvalName ,
            ecl.DeptID ,
            ecl.DeptName
		--,'' [Primary program area] --ppc.ProgramArea
            ,
            SUBSTRING(( SELECT  '; ' + CAST(( c.CodeText ) AS VARCHAR) --[program area]
                        FROM    dbo.PositionProgram pp ( NOLOCK )
                                INNER JOIN dbo.CodeLookUp c ( NOLOCK ) ON pp.ProgramCodeID = c.CodeID
                        WHERE   c.CodeType = 'ProgTitle'
                                AND pp.IsPrimary = 1
                                AND pp.EmplID = ecl.EmplID
                      FOR
                        XML PATH('')
                      ), 2, 9999) [Primary program area] ,
            ecl.PlanType + ' -  '
            + ( ( CASE WHEN CAST(YEAR(DATEADD(DAY, ecl.PlanDuration, 0))
                            - 1900 AS VARCHAR) = '0' THEN ''
                       ELSE CAST(YEAR(DATEADD(DAY, ecl.PlanDuration, 0))
                            - 1900 AS VARCHAR) + ' Year(s) '
                  END )
                + ( CASE WHEN CAST(MONTH(DATEADD(DAY, ecl.PlanDuration, 0)) AS VARCHAR) = '0'
                         THEN ''
                         ELSE CAST(MONTH(DATEADD(DAY, ecl.PlanDuration, 0)) AS VARCHAR)
                              + ' Month(s) '
                    END )
                + ( CASE WHEN CAST(DAY(DATEADD(DAY, ecl.PlanDuration, 0)) AS VARCHAR) = '0'
                         THEN ''
                         ELSE CAST(DAY(DATEADD(DAY, ecl.PlanDuration, 0)) AS VARCHAR)
                              + ' Day(s)'
                    END ) ) [Current educator plan] ,
            ( CASE WHEN NOT ISNULL(gs.CodeText, '') = 'Approved' THEN 'Yes'
                   ELSE 'No'
              END ) [Current Goals approved?] ,
            ecl.sumOverAllRating [Overall Rating of most recent eval/assessment] ,
            ecl.sumReleaseDt [Release Date of most recent eval/assessment] ,
            ecl.EvalCount [Eval count for the year] ,
            ( CASE WHEN ( ( ecl.Overdue = 'Summative Evaluation'
                            OR ecl.Overdue = 'Formative Evaluation'
                            OR ecl.Overdue = 'Formative Evaluation'
                          )
                          AND ecl.sumReleaseDt IS NULL
                        ) THEN 'Yes'
                   ELSE 'No'
              END ) [Eval/Assessment started but not released] ,
            ( CASE WHEN cte.JobCode IN ( 'S85007', 'S85007', 'S85008',
                                         'S85010', 'S85011', 'S85012',
                                         'S85014', 'S85015' ) THEN 'Yes'
                   ELSE 'No'
              END ) [On leave] ,
            '' [Network Superintendent]
    FROM    dbo.EvaluatorCaseLoad ecl ( NOLOCK )
            INNER JOIN cte ON ecl.EmplID = cte.EmplId
            LEFT JOIN dbo.EmplPlan AS p ( NOLOCK ) ON p.PlanActive = 1
                                                      AND cte.EmplJobId = p.EmplJobID
            LEFT JOIN dbo.CodeLookUp AS gs ( NOLOCK ) ON p.GoalStatusID = gs.CodeID
            LEFT JOIN ( SELECT  PlanID ,
                                MAX(EvalID) AS EvalID
                        FROM    dbo.Evaluation (NOLOCK)
                        WHERE   IsSigned = 1
                                AND IsDeleted = 0
                        GROUP BY PlanID
                      ) AS ev ON cte.PlanID = ev.PlanID
            LEFT JOIN ( SELECT  ev.EvalID ,
                                c.CodeText
                        FROM    dbo.Evaluation AS ev ( NOLOCK )
                                JOIN dbo.CodeLookUp AS c ( NOLOCK ) ON ev.EvalTypeID = c.CodeID
                      ) AS ed ON ev.EvalID = ed.EvalID; 
GO
