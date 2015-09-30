SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Get  ObservationDetail by ID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationDetailByID]
	@ObsvDID int

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ObsvDID1 int
	SET @ObsvDID1 = @ObsvDID
	
	SELECT	od.ObsvDID
			,od.ObsvID
			,ord.IndicatorID
			,od.ObsvDEvidence
			,od.ObsvDFeedBack
			,ri.IndicatorText		
			,rs.StandardText
			
	FROM ObservationDetail od
	LEFT JOIN ObservationDetailRubricIndicator ord ON od.ObsvDID= ord.ObsvDID
	LEFt join RubricIndicator ri (NOLOCK)  on ri.IndicatorID = ord.IndicatorID
	Left join RubricStandard rs (NOLOCK)  on rs.StandardID = ri.StandardID
	WHERE od.ObsvDID = @ObsvDID1	
END
GO
