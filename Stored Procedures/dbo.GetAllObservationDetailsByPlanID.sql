SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 12/03/2012
-- Description:	Get all the observation detail by plan ID
-- =============================================
CREATE PROCEDURE [dbo].[GetAllObservationDetailsByPlanID]
	@PlanID int
AS
BEGIN
	SET NOCOUNT ON;
		
	WITH [allObsDetail] AS(
	
	SELECT	
			od.ObsvDID
			,od.ObsvID 
			,od.ObsvDEvidence
			,od.ObsvDFeedBack
			,od.IsDeleted 
			,null AS parentIndicatorText
			,0 AS parentIndicatorID
			,0 as IndicatorID
			,null as IndicatorText
			,null as IndicatorDesc
			,0 as StandardID
			,null as StandardText			
			,oh.ObsvDt
			,oh.CreatedByDt
			,oh.ObsvRelease
	FROM ObservationHeader Oh
	JOIN ObservationDetail od ON od.ObsvID = oh.ObsvID	
	WHERE 
	oh.IsDeleted = 0 AND
	oh.PlanID =@PlanID 
	AND oh.ObsvRelease = 1 AND (oh.ObsvReleaseDt IS NOT NULL 
							AND ((CONVERT(date, oh.ObsvReleaseDt) <= (Convert(date, dbo.GetSchoolWorkingDate(oh.ObsvDt) ))  )))
	
	UNION
	
	SELECT	
			od.ObsvDID
			,od.ObsvID 
			,od.ObsvDEvidence
			,od.ObsvDFeedBack
			,od.IsDeleted 
			,null AS parentIndicatorText
			,0 AS parentIndicatorID
			,0  as IndicatorID
			,null as IndicatorText
			,null as IndicatorDesc
			,0 as StandardID
			,null as StandardText			
			,oh.ObsvDt
			,oh.CreatedByDt
			,oh.ObsvRelease
	FROM ObservationHeader Oh
	JOIN ObservationDetail od ON od.ObsvID = oh.ObsvID	
	WHERE 
		oh.IsDeleted = 0 AND
		oh.PlanID =@PlanID 
		AND oh.ObsvRelease = 1 AND (oh.ObsvReleaseDt IS NOT NULL 
					AND ((CONVERT(date, oh.ObsvReleaseDt) <= (Convert(date, dbo.GetSchoolWorkingDate(oh.ObsvDt)))))))
	
	SELECT * FROM allObsDetail
	WHERE IsDeleted = 0
	ORDER BY 
	CreatedByDt desc
	

END
GO
