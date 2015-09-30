SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 04/24/2012
-- Description:	Goal status report
-- =============================================
CREATE PROCEDURE [dbo].[Report_GoalStatus]
	@ncUserId AS nchar(6) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		e.EmplID
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE d.MgrID
			END) as MgrID
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = emplEx.MgrID) 
			ELSE (de.NameLast + ', ' + de.NameFirst + ' ' + ISNULL(de.NameMiddle, ''))
		  END) as ManagerName
		,CASE
			when p.SubEvalID = '000000'
			THEN CASE
					when ase.SubEvalID IS NULL
					THEN CASE
								WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
								ELSE ej.MgrID
							END
					ELSE s.EmplID
			END
			ELSE p.SubEvalID
		END AS SubEvalID
		,sub.NameLast + ', ' + sub.NameFirst + ' ' + ISNULL(sub.NameMiddle, '') AS SubEvalName
		,e.NameFirst
		,e.NameMiddle
		,e.NameLast
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName
		,e.EmplActive
		,ej.EmplJobID
		,j.JobCode
		,j.JobName
		,e.NameLast + ' ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' ' + e.EmplID + ' ' + sub.NameLast + ' ' + sub.NameFirst AS Search
		,1 AS PlanCount
		,ISNULL(p.PlanActive, 0) AS PlanActive
		,ISNULL(p.PlanTypeID,0) as PlanTypeId
		,(select isnull(CodeText,'') from CodeLookUp where CodeID = p.PlanTypeID) as PlanType
		,p.PlanStartDt
		,p.PlanSchedEndDt As PlanEndDt
		,p.IsSignedAsmt
		,p.DateSignedAsmt
		,ISNULL(pc.CodeText, 'None') AS GoalStatus
		,(SELECT COUNT(*) FROM PlanGoal WHERE GoalTypeID in (select CodeID from CodeLookUp where Code = 'pp') and PlanID = p.PlanID) AS ppGoalCount
		,(SELECT COUNT(*) FROM PlanGoal WHERE GoalTypeID in (select CodeID from CodeLookUp where Code = 'sl') and PlanID = p.PlanID) AS slGoalCount
	FROM
		Empl			AS e	(NOLOCK)
	JOIN EmplEmplJob	AS ej	(NOLOCK)	ON e.EmplID = ej.EmplID
	JOIN department     AS d	(NOLOCK)    ON ej.DeptID = d.DeptID
	JOIN EmplJob		AS j	(NOLOCK)	ON ej.JobCode = j.JobCode
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
																	and ase.isActive = 1
																	and ase.isDeleted = 0
																	and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1
	JOIN Empl			AS sub	(NOLOCK)	ON CASE
									when ase.SubEvalID IS NULL
									THEN CASE
												WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
												ELSE ej.MgrID
											END
									ELSE s.EmplID
								end = sub.EmplID
	JOIN Empl           AS de    (NOLOCK)   ON de.EmplID = d.MgrID																						
	LEFT OUTER JOIN EmplPlan	AS p (NOLOCK)	ON ej.EmplJobID = p.EmplJobID
												AND p.PlanActive = 1
	LEFT OUTER JOIN CodeLookUp	as pc (NOLOCK)	ON p.GoalStatusID =  pc.CodeID 
	WHERE
		e.EmplActive = 1
	AND ej.MgrID = @ncUserId 
		
END
GO
