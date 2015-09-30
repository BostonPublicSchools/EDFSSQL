SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Newa,Matina
-- Create date: 03/27/2013
-- Description:	View all to list active plans on inactive jobs 
--				select * from [AllActivePlansInactiveJob]
-- =============================================
CREATE VIEW [dbo].[AllActivePlansInactiveJob]
AS
	SELECT  --ejc.IsEmailSent,
		e.EmplID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  AS EmplName
		,e.EmplID + '@boston.k12.ma.us' as  EmplEmailAddr
		,m.EmplID as MgrID
		,m.NameLast + ', ' + m.NameFirst + ' ' + ISNULL(m.NameMiddle, '') + ' (' + m.EmplID + ')'  AS MgrName
		,m.EmplID + '@boston.k12.ma.us' as  MgrEmailAddr
--		,e.EmplID + '@boston.k12.ma.us; ' + m.EmplID + '@boston.k12.ma.us' as  CombinedEmailAddr
		,'114600@boston.k12.ma.us; x02414@boston.k12.ma.us' as  CombinedEmailAddr
		,d.DeptID as CurrentActiveDeptID
		,d.DeptName + ' (' + d.DeptID  + ')' as CurrentActiveDept
		,j.JobName + ' (' + j.JobCode  + ')' as CurrentActiveJob
		,j2.JobName + ' (' + j2.JobCode  + ')' as PreviousJob
		,ejc.NewEmplEmplJoBCreatedDt
		,ejc.NewJobEnttryDate		
	FROM
		EmplJobChange as ejc (NOLOCK)
	JOIN Empl as e (NOLOCK) ON ejc.EmplID = e.EmplID
	LEFT JOIN Empl as m (NOLOCK) ON ejc.MgrID = m.EmplID
	LEFT JOIN Department as d (NOLOCK) ON m.EmplID = d.MgrID
	JOIN EmplJob as j (NOLOCK) ON ejc.NewJobCode = j.JobCode
	JOIN EmplJob as j2 (NOLOCK) ON ejc.PreviousJobCode = j2.JobCode
GO
