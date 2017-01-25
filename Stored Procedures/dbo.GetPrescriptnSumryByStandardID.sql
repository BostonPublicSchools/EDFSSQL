SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 01/09/2014	
-- Description:	Get the prescription and previous prescription by standardID
-- =============================================
CREATE PROCEDURE [dbo].[GetPrescriptnSumryByStandardID]
    @EvalID AS INT ,
    @PlanID AS INT ,
    @StandardID AS INT
AS
    BEGIN
        SET NOCOUNT ON;
	
        DECLARE @PrevPrescriptionEvalID AS INT = 0;
        SELECT  @PrevPrescriptionEvalID = ( CASE WHEN HasPrescript = 1
                                                      AND ( PrescriptEvalID IS NULL
                                                            OR PrescriptEvalID = @EvalID
                                                          )
                                                 THEN PrevPlanPrescptEvalID
                                                 ELSE PrescriptEvalID
                                            END )
        FROM    dbo.EmplPlan
        WHERE   PlanID = @PlanID;
	
        WITH    cte
                  AS ( SELECT   ep.PrescriptionId ,
                                ep.EvalID ,
                                ev.PlanID ,
                                ep.ProblemStmt ,
                                ep.EvidenceStmt ,
                                ep.PrscriptionStmt ,
                                ri.IndicatorText ,
                                ri.IndicatorID ,
                                rs.StandardText ,
                                rs.StandardID ,
                                PrevPescriptionTable.PrevPrescriptionID ,
                                PrevPescriptionTable.PrevEvalID ,
                                PrevPescriptionTable.PrevPlanID ,
                                PrevPescriptionTable.PrevProblemStmnt ,
                                PrevPescriptionTable.PrevEvidenceStmt ,
                                PrevPescriptionTable.PrevPrescStmnt ,
                                PrevPescriptionTable.PrevIndicatorText ,
                                PrevPescriptionTable.PrevIndicatorID ,
                                PrevPescriptionTable.PrevStandardText ,
                                PrevPescriptionTable.PrevStandID
                       FROM     dbo.EvaluationPrescription ep
                                JOIN dbo.Evaluation ev ON ev.EvalID = ep.EvalID
                                JOIN dbo.RubricIndicator ri ON ri.IndicatorID = ep.IndicatorID
                                                           AND ri.IsDeleted = 0
                                JOIN dbo.RubricStandard rs ON rs.StandardID = ri.StandardID
                                                          AND rs.IsDeleted = 0
                                LEFT OUTER JOIN ( SELECT    ep.PrescriptionId AS PrevPrescriptionID ,
                                                            ep.EvalID AS PrevEvalID ,
                                                            ev.PlanID AS PrevPlanID ,
                                                            ep.ProblemStmt AS PrevProblemStmnt ,
                                                            ep.EvidenceStmt AS PrevEvidenceStmt ,
                                                            ep.PrscriptionStmt AS PrevPrescStmnt ,
                                                            ri.IndicatorText AS PrevIndicatorText ,
                                                            ri.IndicatorID AS PrevIndicatorID ,
                                                            rs.StandardText AS PrevStandardText ,
                                                            rs.StandardID AS PrevStandID
                                                  FROM      dbo.EvaluationPrescription ep
                                                            JOIN dbo.Evaluation ev ON ev.EvalID = ep.EvalID
                                                            JOIN dbo.RubricIndicator ri ON ri.IndicatorID = ep.IndicatorID
                                                              AND ri.IsDeleted = 0
                                                            JOIN dbo.RubricStandard rs ON rs.StandardID = ri.StandardID
                                                              AND rs.IsDeleted = 0
                                                  WHERE     rs.StandardID = @StandardID
                                                            AND ep.EvalID = @PrevPrescriptionEvalID
                                                            AND ep.IsDeleted = 0
                                                ) AS PrevPescriptionTable ON PrevPescriptionTable.PrevIndicatorID = ri.IndicatorID
                       WHERE    rs.StandardID = @StandardID
                                AND ep.EvalID = @EvalID
                                AND ep.IsDeleted = 0
                       UNION
                       SELECT   CurrentPrescription.PrescriptionId ,
                                CurrentPrescription.EvalID ,
                                CurrentPrescription.PlanID ,
                                CurrentPrescription.ProblemStmt ,
                                CurrentPrescription.EvidenceStmt ,
                                CurrentPrescription.PrscriptionStmt ,
                                CurrentPrescription.IndicatorText ,
                                CurrentPrescription.IndicatorID ,
                                CurrentPrescription.StandardText ,
                                CurrentPrescription.StandardID ,
                                ep.PrescriptionId AS PrevPrescriptionID ,
                                ep.EvalID AS PrevEvalID ,
                                ev.PlanID AS PrevPlanID ,
                                ep.ProblemStmt AS PrevProblemStmnt ,
                                ep.EvidenceStmt AS PrevEvidenceStmt ,
                                ep.PrscriptionStmt AS PrevPrescStmnt ,
                                ri.IndicatorText AS PrevIndicatorText ,
                                ri.IndicatorID AS PrevIndicatorID ,
                                rs.StandardText AS PrevStandardText ,
                                rs.StandardID AS PrevStandID
                       FROM     dbo.EvaluationPrescription ep
                                JOIN dbo.Evaluation ev ON ev.EvalID = ep.EvalID
                                JOIN dbo.RubricIndicator ri ON ri.IndicatorID = ep.IndicatorID
                                                           AND ri.IsDeleted = 0
                                JOIN dbo.RubricStandard rs ON rs.StandardID = ri.StandardID
                                                          AND rs.IsDeleted = 0
                                LEFT OUTER JOIN ( SELECT    ep.PrescriptionId ,
                                                            ep.EvalID ,
                                                            ev.PlanID ,
                                                            ep.ProblemStmt ,
                                                            ep.EvidenceStmt ,
                                                            ep.PrscriptionStmt ,
                                                            ri.IndicatorText ,
                                                            ri.IndicatorID ,
                                                            rs.StandardText ,
                                                            rs.StandardID
                                                  FROM      dbo.EvaluationPrescription ep
                                                            JOIN dbo.Evaluation ev ON ev.EvalID = ep.EvalID
                                                            JOIN dbo.RubricIndicator ri ON ri.IndicatorID = ep.IndicatorID
                                                              AND ri.IsDeleted = 0
                                                            JOIN dbo.RubricStandard rs ON rs.StandardID = ri.StandardID
                                                              AND rs.IsDeleted = 0
                                                  WHERE     rs.StandardID = @StandardID
                                                            AND ep.EvalID = @EvalID
                                                            AND ep.IsDeleted = 0
                                                ) AS CurrentPrescription ON CurrentPrescription.IndicatorID = ri.IndicatorID
                       WHERE    rs.StandardID = @StandardID
                                AND ep.EvalID = @PrevPrescriptionEvalID
                                AND ep.IsDeleted = 0
                     )
            SELECT  cte.PrescriptionId ,
                    cte.EvalID ,
                    cte.PlanID ,
                    cte.ProblemStmt ,
                    cte.EvidenceStmt ,
                    cte.PrscriptionStmt ,
                    cte.IndicatorText ,
                    cte.IndicatorID ,
                    cte.StandardText ,
                    cte.StandardID ,
                    cte.PrevStandID ,
                    cte.PrevStandardText ,
                    cte.PrevIndicatorID ,
                    cte.PrevIndicatorText ,
                    cte.PrevPrescStmnt ,
                    cte.PrevEvidenceStmt ,
                    cte.PrevProblemStmnt ,
                    cte.PrevPlanID ,
                    cte.PrevEvalID ,
                    cte.PrevPrescriptionID
            FROM    cte
            ORDER BY cte.IndicatorText ,
                    cte.IndicatorID ASC;
		
    END;
GO
