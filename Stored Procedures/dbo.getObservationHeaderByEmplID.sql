SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/24/2012
-- Description:	get all the observations of all 
-- employees for a manager and his own observation
-- =============================================
CREATE PROCEDURE [dbo].[getObservationHeaderByEmplID]
	@EmplID AS nchar(6)	
	,@ExcludeInValidPlan as bit = 0
AS
BEGIN
		SET NOCOUNT ON;

	DECLARE @EmplID1 as nchar(6)
	SET @EmplID1 = @EmplID
SELECT 
	Obs.ObsvID,
	Obs.PlanID, 
	cdl.CodeText AS PlanType, 
	eplan.PlanTypeID, 
	eplan.PlanActive,
	eplan.IsInvalid as PlanIsInValid,
	Obs.ObsvTypeID,  
	cd2.CodeText AS ObsvType,
	Obs.ObsvRelease,
	Obs.ObsvReleaseDt,
	Obs.IsDeleted,
	Obs.IsEditEndDt,	
	ISNULL(empl.NameFirst, '')+ ' ' +ISNULL(empl.NameMiddle,'')+ ' '+ISNULL(empl.NameLast,'') + ' (' + empl.EmplID + ')' AS EmplName,
	ejob.EmplID as EmplID,
	obs.EmplIsEditEndDt,	 	
	obs.ObsvDt,
	obs.ObsvEndTime,
	obs.ObsvStartTime,
	obs.ObsvSubject,
	obs.Comment,
	obs.EmplComment,
	obs.CreatedByID,
	ISNULL(empl1.NameFirst, '')+ ' ' +ISNULL(empl1.NameMiddle,'')+ ' '+ISNULL(empl1.NameLast,'') + ' (' + empl1.EmplID + ')' AS CreatedBy
	,Obs.IsEmplViewed
	,Obs.EmplViewedDate
	,obs.IsFromIpad
FROM ObservationHeader Obs (NOLOCK) 
	JOIN EmplPlan eplan (NOLOCK) ON eplan.PlanID = obs.PlanID 
								And eplan.IsInvalid = (case when @ExcludeInValidPlan = 1 then 0 else eplan.IsInvalid end)
	JOIN EmplEmplJob ejob (NOLOCK) ON ejob.EmplJobID = eplan.EmplJobID 
	LEFT OUTER JOIN EmplExceptions emplEx (NOLOCK)  ON emplEx.EmplJobID = eplan.EmplJobID
	LEFT OUTER JOIN CodeLookUp cdl (NOLOCK) ON cdl.CodeID = eplan.PlanTypeID AND cdl.CodeType = 'PlanType' 
	LEFT OUTER JOIN CodeLookUp cd2 (NOLOCK) ON cd2.CodeID = Obs.ObsvTypeID AND cd2.CodeType = 'ObsvType' 
	LEFT OUTER JOIN Empl empl (NOLOCK) ON empl.EmplID = ejob.EmplID
	LEFT OUTER JOIN Empl empl1 (NOLOCK) ON empl1.EmplID = obs.CreatedByID
WHERE 
		(case when (emplEx.MgrID is not null)
				THEN emplEx.MgrID 
				ELSE ejob.MgrID
				END) =@EmplID1
OR ejob.EmplID =@EmplID1
ORDER BY obs.ObsvDt desc
END
GO
