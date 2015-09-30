SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Get  ObservationHeader by ID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationHeaderByID]
	@ObsvID int

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ObsvID1 int
	SET @ObsvID1 = @ObsvID
	
	SELECT	oh.ObsvID
			,oh.PlanID
			,oh.ObsvTypeID
			,cl.CodeText as ObsvType
			,CONVERT(varchar, oh.ObsvDt, 101) as obsvDt
			,oh.ObsvRelease
			,oh.ObsvReleaseDt
			,oh.ObsvStartTime
			,oh.ObsvEndTime
			,oh.IsDeleted
			,oh.IsEditEndDt
			,oh.Comment
			,oh.EmplComment
			,oh.EmplIsEditEndDt
			,oh.ObsvSubject
			,oh.IsEmplViewed
			,oh.EmplViewedDate
	FROM ObservationHeader oh
	LEFT Join CodeLookUp cl on cl.CodeID = oh.ObsvTypeID
	WHERE oh.ObsvID = @ObsvID1	
END
GO
