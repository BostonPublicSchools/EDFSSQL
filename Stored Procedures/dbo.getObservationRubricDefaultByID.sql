SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[getObservationRubricDefaultByID]
@ObsRubricID int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ObsRubricID1 int
	SET @ObsRubricID1 = @ObsRubricID
SELECT 
			ord.ObsRubricID
			,ord.EmplID
			,ord.RubricID
			,rh.RubricName
			,ord.IndicatorID
			,ri.StandardID
			,ri.IndicatorText
			,ord.IsActive
	FROM ObservationRubricDefault ord
	LEFT JOIN RubricHdr rh (nolock) on rh.RubricID = ord.RubricID
	LEFT JOIN RubricIndicator ri (nolock) on ri.IndicatorID = ord.IndicatorID
	WHERE ord.IsDeleted = 0 and ord.ObsRubricID = @ObsRubricID1
	
	
	
END
GO
