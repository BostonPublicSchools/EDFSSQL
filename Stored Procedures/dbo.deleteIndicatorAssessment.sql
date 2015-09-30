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
Create PROCEDURE [dbo].[deleteIndicatorAssessment]
	@CodeID AS int,
	@IndicatorID as int,
	@AssessmentID as int
	
AS
BEGIN
	SET NOCOUNT ON;
	
DELETE FROM RubricIndicatorAssmt 
WHERE CodeID = @CodeID and IndicatorID = @IndicatorID and AssmtID = @AssessmentID

	
END

GO
