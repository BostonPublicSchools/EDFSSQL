SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 02/19/2013
-- Description:	Demographic report
-- =============================================
CREATE VIEW [dbo].[Demographic]
AS
	SELECT
		e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmplName
		,e.Sex
		,e.Race
		,e.BirthDt
		,j.JobCode
		,j.JobName
		,j.UnionCode
		,d.DeptName
		,isnull((SELECT e1.NameLast + ', ' + e1.NameFirst + ' ' + ISNULL(e1.NameMiddle, '') FROM Empl e1 WHERE e1.EmplID = (CASE 
																																WHEN emplEx.MgrID IS NOT NULL theN emplEx.MgrID 
																																ELSE ej.MgrID
																															 END)), '') AS ManagerName
		,isnull(SUBSTRING((SELECT
								', (' + e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ')'
							FROM
								SubevalAssignedEmplEmplJob as ase (nolock)
							join SubEval s (nolock) on ase.SubEvalID = s.EvalID
							join Empl as e (nolock) on s.EmplID = e.EmplID	
							Where 
								ase.EmplJobID = ej.EmplJobID
							For XML PATH ('')), 2, 9999),'')  as SubEvalName
		,isnull(c.CodeText, '') as PlanType

	FROM
		Empl			AS e	(NOLOCK)
	JOIN EmplEmplJob	AS ej	(NOLOCK)	ON e.EmplID = ej.EmplID
											AND ej.IsActive = 1
	join EmplJob as j (NOLOCK) on ej.JobCode = j.JobCode
	join Department as d (NOLOCK) on ej.DeptID = d.DeptID
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) ON emplEx.EmplJobID  = ej.EmplJobID
	--left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
	--												and ase.isActive = 1
	--												and ase.isDeleted = 0
	--left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
	--								and s.EvalActive = 1	
	LEFT OUTER JOIN EmplPlan	AS p (NOLOCK)	ON ej.EmplJobID = p.EmplJobID
												AND p.PlanActive = 1
	left outer join CodeLookUp as c (nolock) on p.PlanTypeID = c.CodeID												
	WHERE
		e.EmplActive = 1
GO
