SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 04/27/2012
-- Description:	Goal status report
-- =============================================
CREATE VIEW [dbo].[GoalStatus]
AS
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
			ELSE (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = ej.MgrID)
		 END) AS ManagerName
		,CASE
			when s.EmplID IS NULL
			THEN CASE
						WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
						ELSE ej.MgrID
					END
			ELSE s.EmplID
		END SubEvalID			
		,(CASE 
			WHEN  s.EmplID IS NULL THEN CASE 
											WHEN (emplEx.MgrID IS NOT NULL)
											THEN (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = emplEx.MgrID) 
											ELSE (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = ej.MgrID)
										 END
			ELSE (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = s.EmplID) 
			END) AS SubEvalName		,e.NameFirst
		,e.NameMiddle
		,e.NameLast
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName
		,e.EmplActive
		,ej.EmplJobID
		,j.JobCode
		,j.JobName
		,e.NameLast + ' ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' ' + e.EmplID AS Search
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
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN 1
			ELSE 0
			END) AS EmplExceptionExists
	FROM
		Empl			AS e	(NOLOCK)
	JOIN EmplEmplJob	AS ej	(NOLOCK)	ON e.EmplID = ej.EmplID
											AND ej.IsActive = 1
											and ej.RubricID in (select RubricID from RubricHdr(NOLOCK) where Is5StepProcess = 1)
	JOIN department     AS d	(NOLOCK)    ON ej.DeptID = d.DeptID
	JOIN EmplJob		AS j	(NOLOCK)	ON ej.JobCode = j.JobCode	
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) ON emplEx.EmplJobID  = ej.EmplJobID
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1	
	LEFT OUTER JOIN EmplPlan	AS p (NOLOCK)	ON ej.EmplJobID = p.EmplJobID
												AND p.PlanActive = 1
	LEFT OUTER JOIN CodeLookUp	as pc (NOLOCK)	ON p.GoalStatusID =  pc.CodeID 
	WHERE
		e.EmplActive = 1
GO
