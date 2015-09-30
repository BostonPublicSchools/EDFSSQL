SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Ganesan,Devi
-- Create date: 2/4/2013	
-- Description:	update the meeting status from admin screen
-- =========================================================
CREATE PROCEDURE [dbo].[updMeetingStatusAdmin]
	@MeetingStatusID as int
	,@IsMeetingReleased as bit
	,@IsMeetingReleaseChanged as bit
	,@UserID as nchar(6) = null
	,@MeetingID as int
AS
BEGIN
	SET NOCOUNT ON;
	update PlanMeeting
	set
	MeetingStatusID = @MeetingStatusID
	,IsMeetingReleased = (CASE WHEN @IsMeetingReleaseChanged = 1 THEN @IsMeetingReleased ELSE IsMeetingReleased END)
	, MeetingReleasedDt = (CASE WHEN @IsMeetingReleased != 0 THEN GETDATE() ELSE MeetingReleasedDt END)	
	,LastUpdatedByID = @UserID
	,LastUpdatedDt = GETDATE()
	where
	MeetingID =	@MeetingID					
	
END
GO
