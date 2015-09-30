SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 11/29/2012
-- Description:	View for to list active plans on inactive jobs
-- =============================================
CREATE VIEW [dbo].[ActivePlansInactiveJob]
AS
	SELECT
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
		,j.JobCode as CurrentActiveJobCode
		,j2.JobName + ' (' + j2.JobCode  + ')' as PreviousJob
		,j2.JobCode as PreviousJobCode
		,se.[Message]
		,ejc.NewEmplEmplJoBCreatedDt
		,ejc.NewJobEnttryDate
	FROM
		EmplJobChange as ejc (NOLOCK)
	JOIN EmplEmplJob as ej (NOLOCK) on ejc.NewEmplJobID = ej.EmplJobID
	JOIN Empl as e (NOLOCK) ON ej.EmplID = e.EmplID
	LEFT JOIN Empl as m (NOLOCK) ON ej.MgrID = m.EmplID
	LEFT JOIN Department as d (NOLOCK) ON ej.DeptID = d.DeptID
	JOIN EmplJob as j (NOLOCK) ON ej.JobCode = j.JobCode
	JOIN EmplEmplJob as ej2 (NOLOCK) on ejc.PreviousEmplJobID = ej2.EmplJobID
	JOIN EmplJob as j2 (NOLOCK) ON ej2.JobCode = j2.JobCode
	CROSS JOIN StdEmail as se (NOLOCK)
	WHERE
		ejc.IsEmailSent = 0
	AND se.FuncCall = 'JobChange'
GO
