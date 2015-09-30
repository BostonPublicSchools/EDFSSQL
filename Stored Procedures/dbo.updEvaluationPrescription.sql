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
	@PrescriptionID int
	,@IndicatorID as int
	,@ProblemStmt as nvarchar(max) = null
	,@EvidenceStmt as nvarchar(max) = null
	,@IsDeleted as bit
	,@PrescriptionStmt as nvarchar(max) = null
	,@UserID as varchar(6) = null
	
AS
BEGIN
	SET NOCOUNT ON;
	
	
	
	IF @IsDeleted is null
	BEGIN
		SELECT @IsDeleted = IsDeleted
		FROM EvaluationPrescription 
		WHERE PrescriptionId = @PrescriptionID
	END
	
	UPDATE EvaluationPrescription
		SET IndicatorID = @IndicatorID
			,ProblemStmt = @ProblemStmt
			,EvidenceStmt = @EvidenceStmt
			,PrscriptionStmt = @PrescriptionStmt
			,IsDeleted = @IsDeleted
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
	WHERE PrescriptionId = @PrescriptionID
	
	--WHEN all the prescription of evalid mentioned is deleted , change the status of hasprescript in the emplPlan table if the prescript evalId is the same.
	DECLARE @EvalID as int
	SELECT @EvalID = EvalID FROM EvaluationPrescription WHERE PrescriptionId = @PrescriptionID
	IF NOT EXISTS(SELECT * FROM EvaluationPrescription evprs
					JOIN Evaluation ev on ev.EvalID = evprs.EvalID
					JOIN EmplPlan ep on ep.PlanID = ev.PlanID and ep.PrescriptEvalID = ev.EvalID
					AND evprs.IsDeleted = 0 and evprs.EvalID = @EvalID)
	BEGIN
		UPDATE EmplPlan
		SET HasPrescript = 0,
		PrescriptEvalID = NULL,
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE()
		WHERE PlanID in (SELECT ep.PlanID FROM EmplPlan ep 
						 WHERE PrescriptEvalID = (SELECT evalID FROM EvaluationPrescription epsr 
												 WHERE epsr.PrescriptionId = @PrescriptionID)
												 AND HasPrescript = 1)
		
	END					
END

GO
