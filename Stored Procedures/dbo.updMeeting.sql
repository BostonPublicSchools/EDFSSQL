SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Avery, Bryce
-- Create date: 1/7/2013	
-- Description:	Updates a meeting
-- =========================================================
CREATE PROCEDURE [dbo].[updMeeting]
	@UserID as nchar(6) = null
	,@PlanID as int = 0
	,@MeetingTypeID as int = 0
	,@MeetingDate as date = null
	,@MeetingStartTime as varchar(100) = null
	,@MeetingEndTime as varchar(100) = null
	,@MeetingLocation as varchar(100) = null
	,@MeetingDescription as varchar(max) = null
	,@EvaluatorComment as varchar(max) = null
	,@EmployeeComment as varchar(max) = null
	,@MeetingStatusID as int = 0
	,@MeetingID as int = 0
	,@IsMeetingReleased as bit
AS
BEGIN
	SET NOCOUNT ON;
	
	if @MeetingStatusID = 0
	begin
		select
			@MeetingStatusID = CodeID
		from
			CodeLookUp
		where
			CodeType = 'MtgStat'
		and CodeText = 'Scheduled'
	end
	
	update PlanMeeting
	set
	PlanID = @PlanID
	,MeetingTypeID = @MeetingTypeID
	,MeetingDate = @MeetingDate
	,MeetingStartTime = @MeetingStartTime
	,MeetingEndTime = @MeetingEndTime
	,MeetingLocation = @MeetingLocation
	,MeetingDescription = @MeetingDescription
	,EvaluatorComment = @EvaluatorComment
	,EmployeeComment = @EmployeeComment
	,MeetingStatusID = @MeetingStatusID
	,LastUpdatedByID = @UserID
	,LastUpdatedDt = GETDATE()
	,IsMeetingReleased = @IsMeetingReleased
	,MeetingReleasedDt = (CASE WHEN @IsMeetingReleased = 1 THEN GETDATE() ELSE NULL END)
	where
	MeetingID =	@MeetingID					
	
END
GO
