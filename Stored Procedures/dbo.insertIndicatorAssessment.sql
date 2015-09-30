SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/10/2012
-- Description:	Returns indicator assessmnet for each 
-- code and indicator by ID
-- =============================================
Create PROCEDURE [dbo].[insertIndicatorAssessment]
	@CodeID AS int,
	@IndicatorID as int,
	@AssessmentText as nvarchar(max),
	@CreatedById as nchar(6),
	@LastUpdateById as nchar(6)
	
AS
BEGIN
	SET NOCOUNT ON;

INSERT INTO RubricIndicatorAssmt(CodeID, IndicatorID, AssmtText, CreatedByID, CreatedDt, LastUpdatedByID, LastUpdatedDt)
VALUES(@CodeID, @IndicatorID, @AssessmentText, @CreatedById, GETDATE(), @LastUpdateById, GETDATE())

	
END

GO
