SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Avery, Bryce
-- Create date: 09/14/2012
-- Description:	Get meeting by PlanID
-- =============================================
CREATE PROCEDURE [dbo].[getMeetingByPlanID]
	@PlanID int

AS
BEGIN
	SET NOCOUNT ON;
	SELECT	
		pm.PlanID
		,pm.MeetingID
		,pm.MeetingTypeID
		,cl.CodeText as MeetingType
		,pm.MeetingDate
		,pm.MeetingStartTime
		,pm.MeetingEndTime
		,pm.MeetingLocation
		,pm.MeetingDescription
		,pm.EvaluatorComment
		,pm.EmployeeComment
		,pm.MeetingStatusID
		,pm.IsMeetingReleased
		,pm.MeetingReleasedDt
		,cl2.CodeText as MeetingStatus
		,pm.CreatedByID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS CreatedBy
	FROM 
		PlanMeeting as pm
	join CodeLookUp cl on cl.CodeID = pm.MeetingTypeID
	join CodeLookUp cl2 on cl2.CodeID = pm.MeetingStatusID
	join Empl e on e.EmplID = pm.CreatedByID
	WHERE 
		pm.PlanID = @PlanID	
END

GO
