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
    @EvalID AS INT ,
    @IndicatorID AS INT ,
    @ProblemStmt AS NVARCHAR(MAX) = NULL ,
    @EvidenceStmt AS NVARCHAR(MAX) = NULL ,
    @PrescriptionStmt AS NVARCHAR(MAX) = NULL ,
    @UserID AS VARCHAR(6) = NULL ,
    @PrescriptionID INT OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;
	
        SELECT  @PrescriptionID = -1;
        IF EXISTS ( SELECT  EvalID 
                    FROM    dbo.Evaluation
                    WHERE   EvalID = @EvalID )
            BEGIN
                INSERT  dbo.EvaluationPrescription
                        ( EvalID ,
                          IndicatorID ,
                          ProblemStmt ,
                          EvidenceStmt ,
                          PrscriptionStmt ,
                          CreatedByID ,
                          CreatedDt ,
                          LastUpdatedByID ,
                          LastUpdatedDt
			            )
                VALUES  ( @EvalID ,
                          @IndicatorID ,
                          @ProblemStmt ,
                          @EvidenceStmt ,
                          @PrescriptionStmt ,
                          @UserID ,
                          GETDATE() ,
                          @UserID ,
                          GETDATE()
                        );
                SELECT  @PrescriptionID = SCOPE_IDENTITY();	
            END;

	
    END;

GO
