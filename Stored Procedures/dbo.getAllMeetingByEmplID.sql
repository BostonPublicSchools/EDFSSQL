SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/24/2012
-- Description:	get all the meeting of all 
-- employees for a manager and own meeting
-- =============================================
CREATE PROCEDURE [dbo].[getAllMeetingByEmplID]
	@EmplID AS nchar(6)	
AS
BEGIN
	SET NOCOUNT ON;

SELECT 
	pm.MeetingID,
	pm.PlanID, 
	cdl.CodeText AS PlanType, 
	eplan.PlanTypeID, 
	eplan.IsInvalid as PlanIsInValid,
	pm.MeetingTypeID,  
	cd2.CodeText AS MeetingType,
	pm.MeetingStatusID,
	cd3.CodeText AS MeetingStatus,
	pm.MeetingLocation,
	pm.MeetingDescription,
	pm.EmployeeComment,
	pm.EvaluatorComment,
	pm.MeetingDate,
	pm.MeetingStartTime,
	pm.MeetingEndTime,
	pm.IsMeetingReleased,
	pm.MeetingReleasedDt,
	ISNULL(empl.NameFirst, '')+ ' ' +ISNULL(empl.NameMiddle,'')+ ' '+ISNULL(empl.NameLast,'') AS EmplName,
	ejob.EmplID as EmplID,
	ISNULL(empl1.NameFirst, '')+ ' ' +ISNULL(empl1.NameMiddle,'')+ ' '+ISNULL(empl1.NameLast,'') AS CreatedBy,	
	pm.CreatedByID
FROM PlanMeeting pm(NOLOCK) 
	JOIN EmplPlan eplan (NOLOCK) ON eplan.PlanID = pm.PlanID
	JOIN EmplEmplJob ejob (NOLOCK) ON ejob.EmplJobID = eplan.EmplJobID 
	LEFT OUTER JOIN EmplExceptions emplEx ON emplEx.EmplJobID = eplan.EmplJobID
	LEFT OUTER JOIN CodeLookUp cdl (NOLOCK) ON cdl.CodeID = eplan.PlanTypeID AND cdl.CodeType = 'PlanType' 
	LEFT OUTER JOIN CodeLookUp cd2 (NOLOCK) ON cd2.CodeID = pm.MeetingTypeID AND cd2.CodeType = 'MtgWhy' 
	LEFT OUTER JOIN CodeLookUp cd3 (NOLOCK) ON cd3.CodeID = pm.MeetingStatusID AND cd3.CodeType = 'MtgStat' 
	LEFT OUTER JOIN Empl empl (NOLOCK) ON empl.EmplID = ejob.EmplID
	LEFT OUTER JOIN Empl empl1 (NOLOCK) ON empl1.EmplID = pm.CreatedByID
WHERE ejob.MgrID = @EmplId OR emplEx.MgrID = @EmplId OR ejob.EmplID = @EmplID	
END

GO
