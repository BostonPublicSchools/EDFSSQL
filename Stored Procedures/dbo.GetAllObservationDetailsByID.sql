SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 11/27/2012
-- Description:	Get all the observation detail by ID
-- =============================================
CREATE PROCEDURE [dbo].[GetAllObservationDetailsByID]
	@ObsvID int
AS
BEGIN
	SET NOCOUNT ON;
		SELECT	
			od.ObsvDID
			,od.ObsvID
			,ord.ObsvDetRubricID [ObservationDetailRubricID]
			,ord.IndicatorID
			,od.ObsvDEvidence
			,od.ObsvDFeedBack				
			,ord.IsDeleted  [IsDeleted]
			,od.IsDeleted [IsDeletedDetail]
			,ri.IndicatorText
			,ri.IndicatorDesc
			,ri.StandardID
			,rs.StandardText			
			,(case 
				when od.IsDeleted=1 then 1
				when (od.IsDeleted=0 and (Select COUNT(ObsvDID) from ObservationDetailRubricIndicator where ObsvDID = od.ObsvDID and IsDeleted=0)>0) then 1 else 0 end )	 AnyTagNotExists
	FROM ObservationDetail od
	LEFT JOIN ObservationDetailRubricIndicator ord ON od.ObsvDID= ord.ObsvDID
	LEFt join RubricIndicator ri (NOLOCK)  on ri.IndicatorID = ord.IndicatorID
	Left join RubricStandard rs (NOLOCK)  on rs.StandardID = ri.StandardID
	WHERE od.ObsvID = @ObsvID
	ORDER BY rs.SortOrder, ri.SortOrder, od.CreatedByDt desc
	
END
GO
