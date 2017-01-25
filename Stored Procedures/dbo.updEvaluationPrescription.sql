SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/04/2012
-- Description:	update evaluation prescription 
-- =============================================
CREATE PROCEDURE [dbo].[updEvaluationPrescription]
    @PrescriptionID INT ,
    @IndicatorID AS INT ,
    @ProblemStmt AS NVARCHAR(MAX) = NULL ,
    @EvidenceStmt AS NVARCHAR(MAX) = NULL ,
    @IsDeleted AS BIT ,
    @PrescriptionStmt AS NVARCHAR(MAX) = NULL ,
    @UserID AS VARCHAR(6) = NULL
AS
    BEGIN
        SET NOCOUNT ON;
	
	
	
        IF @IsDeleted IS NULL
            BEGIN
                SELECT  @IsDeleted = IsDeleted
                FROM    dbo.EvaluationPrescription
                WHERE   PrescriptionId = @PrescriptionID;
            END;
	
        UPDATE  dbo.EvaluationPrescription
        SET     IndicatorID = @IndicatorID ,
                ProblemStmt = @ProblemStmt ,
                EvidenceStmt = @EvidenceStmt ,
                PrscriptionStmt = @PrescriptionStmt ,
                IsDeleted = @IsDeleted ,
                LastUpdatedByID = @UserID ,
                LastUpdatedDt = GETDATE()
        WHERE   PrescriptionId = @PrescriptionID;
	
	--WHEN all the prescription of evalid mentioned is deleted , change the status of hasprescript in the emplPlan table if the prescript evalId is the same.
        DECLARE @EvalID AS INT;
        SELECT  @EvalID = EvalID
        FROM    dbo.EvaluationPrescription
        WHERE   PrescriptionId = @PrescriptionID;
        IF NOT EXISTS ( SELECT  evprs.PrescriptionId
                        FROM    dbo.EvaluationPrescription evprs
                                JOIN dbo.Evaluation ev ON ev.EvalID = evprs.EvalID
                                JOIN dbo.EmplPlan ep ON ep.PlanID = ev.PlanID
                                                    AND ep.PrescriptEvalID = ev.EvalID
                                                    AND evprs.IsDeleted = 0
                                                    AND evprs.EvalID = @EvalID )
            BEGIN
                UPDATE  dbo.EmplPlan
                SET     HasPrescript = 0 ,
                        PrescriptEvalID = NULL ,
                        LastUpdatedByID = @UserID ,
                        LastUpdatedDt = GETDATE()
                WHERE   PlanID IN (
                        SELECT  ep.PlanID
                        FROM    dbo.EmplPlan ep
                        WHERE   ep.PrescriptEvalID = ( SELECT  epsr.EvalID
                                                    FROM    dbo.EvaluationPrescription epsr
                                                    WHERE   epsr.PrescriptionId = @PrescriptionID
                                                  )
                                AND ep.HasPrescript = 1 );
		
            END;					
    END;

GO
