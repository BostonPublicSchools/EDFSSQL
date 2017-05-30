SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi		
-- Create date: 04/16/2013
-- Description:	Get overall rating for all the employees
-- =============================================
CREATE PROCEDURE [dbo].[GetEvalOverallRating]
    @ncUserId AS NCHAR(6) = NULL ,
    @UserRoleID AS INT ,
    @RubricID AS INT = NULL
AS
    BEGIN
        SET NOCOUNT ON;
        IF @RubricID IS NULL
            BEGIN
                SELECT  e.EmplID ,
                        ISNULL(e.NameLast, '') + ', ' + ISNULL(e.NameFirst, '')
                        + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID
                        + ')' AS EmplName ,
                        ej.EmplJobID ,
                        ISNULL(ep.PlanActive, 0) AS PlanActive ,
                        ISNULL(ep.PlanTypeID, 0) AS PlanTypeId ,
                        ( CASE WHEN ep.PlanStartDt IS NULL
                               THEN ( cep.CodeText + ' '
                                      + ISNULL(CONVERT(VARCHAR, ep.PlanStartDt, 101),
                                               '') + ' - '
                                      + ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101),
                                               '') )
                               WHEN ep.PlanStartDt IS NOT NULL
                               THEN cep.CodeText + ' '
                                    + ISNULL(CONVERT(VARCHAR, ep.PlanStartDt, 101),
                                             '') + ' - '
                                    + ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101),
                                             '')
                               ELSE ( cep.CodeText + ' '
                                      + ISNULL(CONVERT(VARCHAR, ep.PlanStartDt, 101),
                                               '') + ' - '
                                      + ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101),
                                               '') )
                          END ) AS PlanLabel ,
                        ep.PlanID ,
                        eval.PlanID AS EvalPlanId ,
                        ( SELECT    PlanSchedEndDt
                          FROM      dbo.EmplPlan ( NOLOCK )
                          WHERE     PlanID = eval.PlanID
                        ) AS EvalPlanEndDt ,
                        ( SELECT    ISNULL(CodeText, '')
                          FROM      dbo.CodeLookUp ( NOLOCK )
                          WHERE     CodeID = ep.PlanTypeID
                        ) AS PlanType ,
                        rh.Is5StepProcess ,
                        rh.RubricID ,
                        eval.EvalID ,
                        et.CodeText AS EvalType ,
                        ed.EvalTypeID ,
                        ed.IsSigned ,
                        ed.OverallRatingID ,
                        eor.CodeText AS overallRating ,
                        ed.EvalDt ,
                        ed.EditEndDt ,
                        ed.EvaluatorsSignature ,
                        ed.EvaluatorSignedDt ,
                        j.UnionCode ,
                        dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) AS MgrID ,
                        j.JobName
                FROM    dbo.Empl e ( NOLOCK )
                        JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON ej.IsActive = 1
                                                             AND e.EmplID = ej.EmplID
                        JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                        LEFT OUTER JOIN dbo.EmplPlan AS ep ( NOLOCK ) ON ep.PlanActive = 1
                                                              AND ep.IsInvalid = 0
															  AND ep.EmplJobID = ej.EmplJobID
                        JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON  rh.Is5StepProcess = 0
															AND rh.RubricID = ( CASE
                                                              WHEN ( ep.RubricID IS NULL
                                                              OR ep.RubricID != ej.RubricID
                                                              )
                                                              THEN ej.RubricID
                                                              ELSE ep.RubricID
                                                              END )
                        LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
                        LEFT OUTER JOIN dbo.CodeLookUp AS cep ( NOLOCK ) ON cep.CodeID = ep.PlanTypeID
                        LEFT OUTER JOIN ( SELECT    PlanID ,
                                                    MAX(EvalID) AS EvalID
                                          FROM      dbo.Evaluation (NOLOCK)
                                          GROUP BY  PlanID
                                        ) AS eval ON eval.PlanID = ( CASE
                                                              WHEN ep.PlanID IS NOT NULL
                                                              AND ep.PlanID != 0
                                                              THEN ep.PlanID
                                                              ELSE ( SELECT TOP 1
                                                              ( PlanID )
                                                              FROM
                                                              dbo.EmplPlan ( NOLOCK )
                                                              WHERE
                                                              EmplJobID = ej.EmplJobID
                                                              AND PlanActive = 0
                                                              AND IsInvalid = 0
                                                              AND RubricID = ( SELECT
                                                              RubricID
                                                              FROM
                                                              dbo.EmplEmplJob ( NOLOCK )
                                                              WHERE
                                                              EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID)
                                                              )
                                                              ORDER BY PlanSchedEndDt DESC
                                                              )
                                                              END )
                        LEFT OUTER JOIN ( SELECT    EvalID ,
                                                    OverallRatingID ,
                                                    EvalDt ,
                                                    IsSigned ,
                                                    EditEndDt ,
                                                    EvalTypeID ,
                                                    EvalRubricID ,
                                                    EvaluatorsSignature ,
                                                    EvaluatorSignedDt
                                          FROM      dbo.Evaluation (NOLOCK)
                                          WHERE     IsDeleted = 0
                                        ) AS ed ON eval.EvalID = ed.EvalID
                        LEFT OUTER JOIN dbo.CodeLookUp AS eor ( NOLOCK ) ON ed.OverallRatingID = eor.CodeID
                        LEFT OUTER JOIN dbo.CodeLookUp AS et ( NOLOCK ) ON ed.EvalTypeID = et.CodeID
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
                                            JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                   WHERE    ase.EmplJobID = ej.EmplJobID
                                            AND ase.IsActive = 1
                                            AND ase.IsDeleted = 0 )
                                   AND @UserRoleID = 2
                                 )
                              OR ( ej.EmplID = @ncUserId
                                   AND @UserRoleID = 3
                                 )
                            )
                ORDER BY e.NameLast ,
                        e.NameFirst;
            END;	
        ELSE
            IF @RubricID IS NOT NULL
                BEGIN 
                    SELECT  e.EmplID ,
                            ISNULL(e.NameLast, '') + ', ' + ISNULL(e.NameFirst,
                                                              '') + ' '
                            + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmplName ,
                            ej.EmplJobID ,
                            ISNULL(ep.PlanActive, 0) AS PlanActive ,
                            ISNULL(ep.PlanTypeID, 0) AS PlanTypeId ,
                            ( CASE WHEN ep.PlanStartDt IS NULL
                                   THEN ( cep.CodeText + ' '
                                          + ISNULL(CONVERT(VARCHAR, ep.PlanStartDt, 101),
                                                   '') + ' - '
                                          + ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101),
                                                   '') )
                                   WHEN ep.PlanStartDt IS NOT NULL
                                   THEN cep.CodeText + ' '
                                        + ISNULL(CONVERT(VARCHAR, ep.PlanStartDt, 101),
                                                 '') + ' - '
                                        + ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101),
                                                 '')
                                   ELSE ( cep.CodeText + ' '
                                          + ISNULL(CONVERT(VARCHAR, ep.PlanStartDt, 101),
                                                   '') + ' - '
                                          + ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101),
                                                   '') )
                              END ) AS PlanLabel ,
                            ep.PlanID ,
                            eval.PlanID AS EvalPlanId ,
                            ( SELECT    PlanSchedEndDt
                              FROM      dbo.EmplPlan (NOLOCK)
                              WHERE     PlanID = eval.PlanID
                            ) AS EvalPlanEndDt ,
                            ( SELECT    ISNULL(CodeText, '')
                              FROM      dbo.CodeLookUp (NOLOCK)
                              WHERE     CodeID = ep.PlanTypeID
                            ) AS PlanType ,
                            rh.Is5StepProcess ,
                            rh.RubricID ,
                            eval.EvalID ,
                            et.CodeText AS EvalType ,
                            ed.EvalTypeID ,
                            ed.IsSigned ,
                            ed.OverallRatingID ,
                            eor.CodeText AS overallRating ,
                            ed.EvalDt ,
                            ed.EditEndDt ,
                            ed.EvaluatorsSignature ,
                            ed.EvaluatorSignedDt ,
                            j.UnionCode ,
                            dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) AS MgrID
                    FROM    dbo.Empl e ( NOLOCK )
                            JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON e.EmplID = ej.EmplID
                                                              AND ej.IsActive = 1
                            JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
                            LEFT OUTER JOIN dbo.EmplPlan AS ep ( NOLOCK ) ON ep.PlanActive = 1
                                                              AND ep.IsInvalid = 0
															  AND ep.EmplJobID = ej.EmplJobID
                            JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON rh.Is5StepProcess = 0
																AND rh.RubricID = @RubricID
																AND rh.RubricID = ( CASE
                                                              WHEN ep.RubricID IS NULL
                                                              THEN ej.RubricID
                                                              ELSE ep.RubricID
                                                              END )
                            LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
                            LEFT OUTER JOIN dbo.CodeLookUp AS cep ( NOLOCK ) ON cep.CodeID = ep.PlanTypeID
                            LEFT OUTER JOIN ( SELECT    PlanID ,
                                                        MAX(EvalID) AS EvalID
                                              FROM      dbo.Evaluation (NOLOCK)
                                              GROUP BY  PlanID
                                            ) AS eval ON eval.PlanID = ( CASE
                                                              WHEN ep.PlanID IS NOT NULL
                                                              AND ep.PlanID != 0
                                                              THEN ep.PlanID
                                                              ELSE ( SELECT TOP 1
                                                              ( PlanID )
                                                              FROM
                                                              dbo.EmplPlan
                                                              WHERE
                                                              EmplJobID = ej.EmplJobID
                                                              AND PlanActive = 0
                                                              AND IsInvalid = 0
                                                              ORDER BY PlanSchedEndDt DESC
                                                              )
                                                              END )
                            LEFT OUTER JOIN ( SELECT    EvalID ,
                                                        OverallRatingID ,
                                                        EvalDt ,
                                                        IsSigned ,
                                                        EditEndDt ,
                                                        EvalTypeID ,
                                                        EvalRubricID ,
                                                        EvaluatorsSignature ,
                                                        EvaluatorSignedDt
                                              FROM      dbo.Evaluation (NOLOCK)
                                              WHERE     IsDeleted = 0
                                            ) AS ed ON eval.EvalID = ed.EvalID
                            LEFT OUTER JOIN dbo.CodeLookUp AS eor ( NOLOCK ) ON ed.OverallRatingID = eor.CodeID
                            LEFT OUTER JOIN dbo.CodeLookUp AS et ( NOLOCK ) ON ed.EvalTypeID = et.CodeID
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
                                                JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                       WHERE    ase.EmplJobID = ej.EmplJobID
                                                AND ase.IsActive = 1
                                                AND ase.IsDeleted = 0 )
                                       AND @UserRoleID = 2
                                     )
                                  OR ( ej.EmplID = @ncUserId
                                       AND @UserRoleID = 3
                                     )
                                )
                    ORDER BY e.NameLast ,
                            e.NameFirst;
                END;
	
    END;
GO
