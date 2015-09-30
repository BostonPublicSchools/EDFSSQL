SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 16/12/2013
-- Description:	Returns indicator assessmnet for each 
-- code and indicator by standard Id
-- =============================================
Create PROCEDURE [dbo].[getRubricIndicatorAssessmentByStandardID]
	@StandardID int
	
AS
BEGIN
	SET NOCOUNT ON;
	
SELECT ra.AssmtID, ra.CodeID, ra.IndicatorID, ra.AssmtText, ra.CreatedByID, ra.CreatedDt, ra.LastUpdatedByID, 
	   ra.LastUpdatedDt, ri.IndicatorText AS IndicatorText, clp.CodeText AS CodeText, ri.IsActive AS IsActive, ri.IsDeleted as IsDeleted
FROM RubricIndicatorAssmt ra
JOIN RubricIndicator ri ON ri.IndicatorID = ra.IndicatorID AND ri.StandardID = @StandardID and ParentIndicatorID  != 0					 
JOIN CodeLookUp clp ON clp.CodeID = ra.CodeID 
Order By ri.IndicatorID
	
END

GO
