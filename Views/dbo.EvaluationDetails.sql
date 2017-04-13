SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





/* =============================================
 Author:		Newa,Matina
 Create date: 03/25/2013
 Description:	View for Evaluation Detail 
				SELECT top 100 * FROM [EvaluationDetails] WHERE EMPLID='103342'
 =============================================*/
CREATE VIEW [dbo].[EvaluationDetails]
AS
    WITH    cte ( PlanID, EmplJobId, JobCode, EmplId, DeptID, UnionCode )
              AS ( SELECT   p.PlanID ,
                            ej.EmplJobID ,
                            ej.JobCode ,
                            ej.EmplID ,
                            ej.DeptID ,
                            j.UnionCode
                   FROM     dbo.EmplEmplJob AS ej ( NOLOCK )
                            JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                            JOIN dbo.EmplPlan AS p ( NOLOCK ) ON ej.EmplJobID = p.EmplJobID
                                                             AND p.IsInvalid = 0
                 )
    SELECT  ev.EvalID ,
            ev.EvaluatorSignedDt EvaluationReleaseDate ,
            cd.CodeText EvaluationType ,
            c.PlanID ,
            c.EmplId ,
            ( SELECT    NameLast + ', ' + NameFirst + ' ' + ISNULL(NameMiddle,
                                                              '') + ' ('
                        + EmplID + ')'
              FROM      dbo.Empl ( NOLOCK )
              WHERE     EmplID = c.EmplId
            ) AS EmplName ,
            ev.EvalManagerID AS MgrID ,
            ( SELECT    ISNULL(e1.NameFirst, '') + ' ' + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                        + ISNULL(e1.NameLast, '')
              FROM      dbo.Empl e1 ( NOLOCK )
              WHERE     e1.EmplID = ev.EvalManagerID
            ) AS ManagerName ,
            ev.EvalSubEvalID AS SubEvalID ,
            ( SELECT    ISNULL(e1.NameFirst, '') + ' ' + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                        + ISNULL(e1.NameLast, '')
              FROM      dbo.Empl e1 ( NOLOCK )
              WHERE     e1.EmplID = ev.EvalSubEvalID
            ) AS SubEvalName ,
            d.DeptName ,
            cd_ep.CodeText PlanType ,
            TBL_SL.Progress PROGRESS_SL ,
            TBL_PL.Progress PROGRESS_PP ,
            esI.RatingText StandardRatingI ,
            esII.RatingText StandardRatingII ,
            esIII.RatingText StandardRatingIII ,
            esIV.RatingText StandardRatingIV ,
            cd_orate.CodeText OverallRating ,
            ( CASE WHEN ep.PlanActive = 1 THEN 'Yes'
                   ELSE 'No'
              END ) CurrentPlan--yes/no - currentPlanEnd		
            ,
            ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101), '') [Schedule Plan End Date] ,
            ISNULL(CONVERT(VARCHAR, ep.PlanActEndDt, 101), '') [Actual Plan End Date] ,
            ISNULL(( SELECT TOP 1
                            c.CodeText
                     FROM   dbo.CodeLookUp c ( NOLOCK )
                     WHERE  ep.PlanEndReasonID = c.CodeID
                            AND c.CodeType = 'PlanEndRsn'
                   ), '') [End Reason] ,
            ev.EvaluatorsSignature ,
            c.UnionCode ,
            c.JobCode ,
            c.DeptID
    FROM    dbo.Evaluation ev ( NOLOCK )
            JOIN cte c ON ev.PlanID = c.PlanID
            JOIN dbo.CodeLookUp cd ( NOLOCK ) ON cd.CodeID = ev.EvalTypeID
            JOIN dbo.EmplEmplJob ej ( NOLOCK ) ON c.EmplJobId = ej.EmplJobID
            JOIN dbo.Department d ( NOLOCK ) ON ej.DeptID = d.DeptID
            LEFT JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
            JOIN dbo.EmplPlan ep ( NOLOCK ) ON ep.IsInvalid = 0
                                           AND c.PlanID = ep.PlanID
            JOIN dbo.CodeLookUp cd_ep ( NOLOCK ) ON cd_ep.CodeID = ep.PlanTypeID
            LEFT JOIN ( SELECT  Results.EvalID ,
                                Results.GoalTypeID ,
                                STUFF(( SELECT  ', ' + egl.GoalTypeText + '-'
                                                + CAST(cdProg.CodeText AS VARCHAR)
                                        FROM    dbo.EvaluationGoals egl ( NOLOCK )
                                                LEFT JOIN dbo.CodeLookUp cdProg ( NOLOCK ) ON cdProg.CodeID = egl.ProgressCodeID
                                        WHERE   ( egl.EvalID = Results.EvalID
                                                  AND egl.GoalTypeID = Results.GoalTypeID
                                                )
                                      FOR
                                        XML PATH('')
                                      ), 1, 2, '') AS Progress
                        FROM    dbo.EvaluationGoals Results ( NOLOCK )
                        WHERE   Results.GoalTypeID = 7
                        GROUP BY Results.EvalID ,
                                Results.GoalTypeID
                      ) TBL_PL ON TBL_PL.EvalID = ev.EvalID
            LEFT JOIN ( SELECT  Results.EvalID ,
                                Results.GoalTypeID ,
                                STUFF(( SELECT  ', ' + egl.GoalTypeText + '-'
                                                + CAST(cdProg.CodeText AS VARCHAR)
                                        FROM    dbo.EvaluationGoals egl
                                                LEFT JOIN dbo.CodeLookUp cdProg ON cdProg.CodeID = egl.ProgressCodeID
                                        WHERE   ( egl.EvalID = Results.EvalID
                                                  AND egl.GoalTypeID = Results.GoalTypeID
                                                )
                                      FOR
                                        XML PATH('')
                                      ), 1, 2, '') AS Progress
                        FROM    dbo.EvaluationGoals Results ( NOLOCK )
                        WHERE   Results.GoalTypeID = 5
                        GROUP BY Results.EvalID ,
                                Results.GoalTypeID
                      ) TBL_SL ON TBL_SL.EvalID = ev.EvalID
            LEFT JOIN ( SELECT  EvalID ,
                                StandardText ,
                                RatingText
                        FROM    dbo.EvaluationStandards ( NOLOCK )
                        WHERE   StandardText LIKE 'I.%'
                      ) esI ON esI.EvalID = ev.EvalID
            LEFT JOIN ( SELECT  EvalID ,
                                StandardText ,
                                RatingText
                        FROM    dbo.EvaluationStandards ( NOLOCK )
                        WHERE   StandardText LIKE 'II.%'
                      ) esII ON esII.EvalID = ev.EvalID
            LEFT JOIN ( SELECT  EvalID ,
                                StandardText ,
                                RatingText
                        FROM    dbo.EvaluationStandards ( NOLOCK )
                        WHERE   StandardText LIKE 'III.%'
                      ) esIII ON esIII.EvalID = ev.EvalID
            LEFT JOIN ( SELECT  EvalID ,
                                StandardText ,
                                RatingText
                        FROM    dbo.EvaluationStandards ( NOLOCK )
                        WHERE   StandardText LIKE 'IV.%'
                      ) esIV ON esIV.EvalID = ev.EvalID
            LEFT JOIN dbo.CodeLookUp cd_orate ON cd_orate.CodeID = ev.OverallRatingID
    WHERE   ev.IsDeleted = 0
            AND ( ( ev.IsSigned != 0
                    AND ep.PlanActive = 0
                  )
                  OR ( ep.PlanActive = 1 )
                );


GO
