SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Avery, Bryce
-- Create date: 1/7/2013	
-- Description:	changes status to deleted for meeting
-- =========================================================
CREATE PROCEDURE [dbo].[delMeeting]
	@UserID as nchar(6) = null
	,@MeetingStatus as varchar(50) = null
	,@MeetingID as int = 0
AS
BEGIN
	SET NOCOUNT ON;
	declare @MeetingStatusID as int
	
	select 
		@MeetingStatusID = CodeID
	from
		CodeLookUp
	where
		CodeType = 'MtgStat'
	and CodeText = @MeetingStatus
	
	update PlanMeeting
	set
	MeetingStatusID = @MeetingStatusID
	,CreatedByID = @UserID
	,CreatedByDt = GETDATE()
	,LastUpdatedByID = @UserID
	,LastUpdatedDt = GETDATE()
	where
	MeetingID =	@MeetingID					
	
END
GO
