SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 08/01/2012
-- Description:	View for self-assessment goal report report
-- =============================================
CREATE VIEW [dbo].[SubEvaluators]
AS
SELECT 
		d.DeptID
		,d.DeptName
		,d.MgrID as MgrID
		,(me.NameLast + ', ' + me.NameFirst + ' ' + ISNULL(me.NameMiddle, '')) as ManagerName
		,s.EmplID as EmplID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  AS EmplName
		,j.UnionCode
		,j.JobCode
		,j.JobName
FROM
		Department AS d (NOLOCK)
	JOIN Empl AS me (NOLOCK) ON d.MgrID = me.EmplID
								AND me.EmplActive = 1
	JOIN SubEval AS s (NOLOCK) ON me.EmplID = s.MgrID
	JOIN Empl AS e (NOLOCK) ON s.EmplID = e.EmplID
							AND e.EmplActive = 1
	JOIN EmplEmplJob as ej (NOLOCK) ON e.EmplID = ej.EmplID
									AND ej.IsActive = 1
	JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
UNION
SELECT 
		d.DeptID
		,d.DeptName
		,d.MgrID as MgrID
		,(me.NameLast + ', ' + me.NameFirst + ' ' + ISNULL(me.NameMiddle, '')) as ManagerName
		,e.EmplID as EmplID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  AS EmplName
		,j.UnionCode
		,j.JobCode
		,j.JobName
FROM
		Department AS d (NOLOCK)
	JOIN Empl AS me (NOLOCK) ON d.MgrID = me.EmplID
								AND me.EmplActive = 1
--	JOIN SubEval AS s (NOLOCK) ON me.EmplID = s.MgrID
	JOIN Empl AS e (NOLOCK) ON d.MgrID = e.EmplID
							AND e.EmplActive = 1
	JOIN EmplEmplJob as ej (NOLOCK) ON e.EmplID = ej.EmplID
									AND ej.IsActive = 1
	JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
	
GO
