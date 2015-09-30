SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/10/2012
-- Description:	Returns indicator assessmnet for each 
-- code and indicator by rubric ID
-- =============================================
Create PROCEDURE [dbo].[getRubricIndicatorAssessmentByRubricID]
	@RubricID int
	
AS
BEGIN
	SET NOCOUNT ON;
	
SELECT ra.AssmtID, ra.CodeID, ra.IndicatorID, ra.AssmtText, ra.CreatedByID, ra.CreatedDt, ra.LastUpdatedByID, 
	   ra.LastUpdatedDt, ri.IndicatorText AS IndicatorText, clp.CodeText AS CodeText, ri.IsActive AS IsActive, ri.IsDeleted as IsDeleted
FROM RubricIndicatorAssmt ra
JOIN RubricIndicator ri ON ri.IndicatorID = ra.IndicatorID AND ri.StandardID IN (SELECT StandardID FROM RubricStandard WHERE RubricID = @RubricID)						
JOIN CodeLookUp clp ON clp.CodeID = ra.CodeID
Order By ri.IndicatorID
	
END

GO
