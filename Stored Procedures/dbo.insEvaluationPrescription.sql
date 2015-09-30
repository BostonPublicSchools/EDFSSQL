SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/04/2012
-- Description:	Inserts prescription into EvaluationStandardRating table
-- =============================================
CREATE PROCEDURE [dbo].[insEvaluationPrescription]
	@EvalID as int
	,@IndicatorID as int
	,@ProblemStmt as nvarchar(max) = null
	,@EvidenceStmt as nvarchar(max) = null
	,@PrescriptionStmt as nvarchar(max) = null
	,@UserID as varchar(6) = null
	,@PrescriptionID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
  SELECT @PrescriptionID = -1;
  if exists(select * from Evaluation where EvalID=@EvalID)
  begin
	insert EvaluationPrescription
			(	EvalID
				,IndicatorID
				,ProblemStmt
				,EvidenceStmt
				,PrscriptionStmt
				,CreatedByID
				,CreatedDt
				,LastUpdatedByID
				,LastUpdatedDt
			)
	values	(
				@EvalID
				,@IndicatorID
				,@ProblemStmt
				,@EvidenceStmt
				,@PrescriptionStmt
				,@UserID
				,GETDATE()
				,@UserID
				,GETDATE()
			)
	SELECT @PrescriptionID = SCOPE_IDENTITY();	
  end

	
END

GO
