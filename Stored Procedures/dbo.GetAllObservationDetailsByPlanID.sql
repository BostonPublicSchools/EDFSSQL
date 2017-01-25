SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 12/03/2012
-- Description:	Get all the observation detail by plan ID
-- =============================================
CREATE PROCEDURE [dbo].[GetAllObservationDetailsByPlanID] @PlanID INT
AS
    BEGIN
        SET NOCOUNT ON;
		
        WITH    allObsDetail
                  AS ( SELECT   od.ObsvDID ,
                                od.ObsvID ,
                                od.ObsvDEvidence ,
                                od.ObsvDFeedBack ,
                                od.IsDeleted ,
                                NULL AS parentIndicatorText ,
                                0 AS parentIndicatorID ,
                                0 AS IndicatorID ,
                                NULL AS IndicatorText ,
                                NULL AS IndicatorDesc ,
                                0 AS StandardID ,
                                NULL AS StandardText ,
                                Oh.ObsvDt ,
                                Oh.CreatedByDt ,
                                Oh.ObsvRelease
                       FROM     dbo.ObservationHeader Oh
                                JOIN dbo.ObservationDetail od ON od.ObsvID = Oh.ObsvID
                       WHERE    Oh.IsDeleted = 0
                                AND Oh.PlanID = @PlanID
                                AND Oh.ObsvRelease = 1
                                AND ( Oh.ObsvReleaseDt IS NOT NULL
                                      AND ( (CONVERT(DATE, Oh.ObsvReleaseDt) <= ( CONVERT(DATE, dbo.GetSchoolWorkingDate(Oh.ObsvDt)) )  ) )
                                    )
                       UNION
                       SELECT   od.ObsvDID ,
                                od.ObsvID ,
                                od.ObsvDEvidence ,
                                od.ObsvDFeedBack ,
                                od.IsDeleted ,
                                NULL AS parentIndicatorText ,
                                0 AS parentIndicatorID ,
                                0 AS IndicatorID ,
                                NULL AS IndicatorText ,
                                NULL AS IndicatorDesc ,
                                0 AS StandardID ,
                                NULL AS StandardText ,
                                Oh.ObsvDt ,
                                Oh.CreatedByDt ,
                                Oh.ObsvRelease
                       FROM     dbo.ObservationHeader Oh
                                JOIN dbo.ObservationDetail od ON od.ObsvID = Oh.ObsvID
                       WHERE    Oh.IsDeleted = 0
                                AND Oh.PlanID = @PlanID
                                AND Oh.ObsvRelease = 1
                                AND ( Oh.ObsvReleaseDt IS NOT NULL
                                      AND ( (CONVERT(DATE, Oh.ObsvReleaseDt) <= ( CONVERT(DATE, dbo.GetSchoolWorkingDate(Oh.ObsvDt)) )) )
                                    )
                     )
            SELECT  allObsDetail.ObsvDID ,
                    allObsDetail.ObsvID ,
                    allObsDetail.ObsvDEvidence ,
                    allObsDetail.ObsvDFeedBack ,
                    allObsDetail.IsDeleted ,
                    allObsDetail.parentIndicatorText ,
                    allObsDetail.parentIndicatorID ,
                    allObsDetail.IndicatorID ,
                    allObsDetail.IndicatorText ,
                    allObsDetail.IndicatorDesc ,
                    allObsDetail.StandardID ,
                    allObsDetail.StandardText ,
                    allObsDetail.ObsvDt ,
                    allObsDetail.CreatedByDt ,
                    allObsDetail.ObsvRelease
            FROM    allObsDetail
            WHERE   allObsDetail.IsDeleted = 0
            ORDER BY allObsDetail.CreatedByDt DESC;
	

    END;
GO
