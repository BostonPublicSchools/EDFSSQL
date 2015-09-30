SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina
-- Create date: 01/16/2013
-- Description:	delete evaluation prescription 
-- =============================================
CREATE PROCEDURE [dbo].[delEvaluationPrescription]
	@PrescriptionID int
	,@IsDeleted as bit
	,@UserID as varchar(6) = null
	
AS
BEGIN
	SET NOCOUNT ON;
	
	
	UPDATE EvaluationPrescription
		SET IsDeleted = @IsDeleted
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
	WHERE PrescriptionId = @PrescriptionID
END


GO
