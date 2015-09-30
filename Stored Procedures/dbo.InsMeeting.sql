SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Avery, Bryce
-- Create date: 12/21/2012	
-- Description:	insert a new meeting
-- =========================================================
CREATE PROCEDURE [dbo].[InsMeeting]
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
	,@IsMeetingReleased as bit
	,@MeetingID int OUTPUT
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
	
	INSERT INTO PlanMeeting(PlanID, MeetingTypeID, MeetingDate, MeetingStartTime, MeetingEndTime, MeetingLocation, 
							MeetingDescription, MeetingStatusID, EvaluatorComment, EmployeeComment, 
							CreatedByID,CreatedByDt, LastUpdatedByID, LastUpdatedDt, IsMeetingReleased,MeetingReleasedDt)
					VALUES(@PlanID, @MeetingTypeID, @MeetingDate, @MeetingStartTime, @MeetingEndTime, 
								@MeetingLocation, @MeetingDescription, @MeetingStatusID, @EvaluatorComment, 
								@EmployeeComment, @UserID , GETDATE(), @UserID, GETDATE(), @IsMeetingReleased, (CASE WHEN @IsMeetingReleased = 1 THEN GETDATE() ELSE NULL END))

	SELECT @MeetingID = SCOPE_IDENTITY();					
	
END
GO
