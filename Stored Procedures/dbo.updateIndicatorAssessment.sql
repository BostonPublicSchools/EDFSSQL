SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/10/2012
-- Description:	update indicator assessmnet for each 
-- code and indicator by ID
-- =============================================
Create PROCEDURE [dbo].[updateIndicatorAssessment]
	@CodeID AS int,
	@IndicatorID as int,
	@AssessmentText as nvarchar(max),
	@LastUpdateById as nchar(6),
	@AssessmentID as int
	
AS
BEGIN
	SET NOCOUNT ON;
	
UPDATE RubricIndicatorAssmt 
SET CodeID = @CodeID, 
	IndicatorID = @IndicatorID, 
	AssmtText = @AssessmentText,
	LastUpdatedByID = @LastUpdateById,
	LastUpdatedDt = GETDATE()
WHERE AssmtID = @AssessmentID
	
END

GO
