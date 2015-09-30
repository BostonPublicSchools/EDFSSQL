SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/26/2013
-- Description:	Get  ObservationDetailRubricIndicator by ObservationDetailID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationDetailRubricIndicatorByObsvDID]
@ObsvDID int
	
	
AS
BEGIN
	SET NOCOUNT ON;
	
	
	SELECT 	odri.ObsvDetRubricID
			,odri.ObsvDID
			,odri.IndicatorID
			,ri.IndicatorText
			,rs.StandardID
FROM ObservationDetailRubricIndicator odri
JOIN RubricIndicator ri ON ri.IndicatorID = odri.IndicatorID
JOIN RubricStandard rs ON rs.StandardID = ri.StandardID
WHERE odri.ObsvDID = @ObsvDID and odri.IsDeleted =0
	
END


GO
