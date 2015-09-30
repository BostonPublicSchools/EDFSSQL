SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Get  ObservationDetail by ObservationID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationDetailByObsvIDNew]
@ObsvID int
	
	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ObsvID1 int
	
	
	SET @ObsvID1 = @ObsvID
	
	
	SELECT	od.ObsvDID
			,od.ObsvID
			--,od.IndicatorID
			,od.ObsvDEvidence
			,od.ObsvDFeedBack
			--,ri.IndicatorText
			--,ri.IndicatorDesc
			--,ri.StandardID
			--,rs.StandardText 
	FROM ObservationDetail od
	--LEFT JOIN ObservationDetailRubricIndicator  as odi on odi.ObsvDID = od.ObsvDID
	--Left join RubricIndicator ri on ri.IndicatorID = odi.IndicatorID
	--left join RubricStandard rs on rs.StandardID = ri.StandardID
	where od.ObsvID = @ObsvID1
	and od.IsDeleted = 0
	order by CreatedByDt asc
END


GO
