SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 10/22/2012
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[getObservationRubricDefaultByEmplID]
@EmplID char(6)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @EmplID1 char(6)
	SET @EmplID1 = @EmplID
	SELECT 
			ord.ObsRubricID
			,ord.EmplID
			,ord.RubricID
			,rh.RubricName
			,ord.IndicatorID
			,ri.IndicatorText
			,ord.IsActive
	FROM ObservationRubricDefault ord
	LEFT JOIN RubricHdr rh (nolock) on rh.RubricID = ord.RubricID
	LEFT JOIN RubricIndicator ri (nolock) on ri.IndicatorID = ord.IndicatorID
	WHERE ord.IsDeleted = 0 and ord.EmplID = @EmplID1
	
	
	
END


GO
