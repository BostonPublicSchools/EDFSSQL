SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 09/10/2012
-- Description:	Review self assesssment data
-- =============================================
CREATE VIEW [dbo].[SelfAssmt]
AS
	SELECT
		d.DeptID
		,d.DeptName
		,ej.MgrID
		--,de.NameLast + ', ' + de.NameFirst + ' ' + ISNULL(de.NameMiddle, '') AS ManagerName
		,CASE
			when ase.SubEvalID IS NULL
			THEN CASE
						WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
						ELSE ej.MgrID
					END
		ELSE s.EmplID
		end	AS SubEvalID 
		,sub.NameLast + ', ' + sub.NameFirst + ' ' + ISNULL(sub.NameMiddle, '') AS SubEvalName
		,e.EmplID
		,e.NameFirst
		,e.NameMiddle
		,e.NameLast
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName
		,e.EmplActive
	FROM
		Department d (NOLOCK)
	JOIN EmplEmplJob AS ej (NOLOCK) ON d.DeptID = ej.DeptID
									AND ej.IsActive = 1
	LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
								and s.EvalActive = 1	
	--JOIN Empl AS de (NOLOCK) ON de.EmplID = CASE
	--											WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
	--											ELSE ej.MgrID
	--										END
	JOIN Empl AS sub (NOLOCK)	ON CASE
										when ase.SubEvalID IS NULL
										THEN CASE
													WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
													ELSE ej.MgrID
												END
										ELSE s.EmplID
										END = sub.EmplID
	JOIN Empl AS e (NOLOCK) ON ej.EmplID = e.EmplID
								AND e.EmplActive = 1
	LEFT JOIN EmplPlan AS ep (NOLOCK) ON ej.EmplJobID = ep.EmplJobID
										and ep.PlanActive = 1
GO
