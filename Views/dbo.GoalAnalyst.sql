SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 11/13/2012
-- Description:	View for goal analyst
-- =============================================
CREATE VIEW [dbo].[GoalAnalyst]
AS
	with 
		cte (PlanID, EmplJobId, JobCode, EmplId)
	as
	(
		SELECT
			P.PlanID, ej.EmplJobID, ej.JobCode, ej.EmplId 
		FROM
				EmplEmplJob AS ej (NOLOCK)
			JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
			JOIN EmplPlan AS p (NOLOCK) ON ej.EmplJobID = p.EmplJobID
		WHERE
			ej.IsActive = 1
		AND p.PlanActive = 1
	)
	
	SELECT
		d.DeptID
		,d.DeptName
		,dc.CodeID AS DeptCatID
		,dc.CodeText AS DeptCat
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE ej.MgrID
			END) as MgrID
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') 
			FROM Empl e1 WHERE e1.EmplID  = CASE
												WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
												ELSE ej.MgrID
											END) AS ManagerName
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID + '@boston.k12.ma.us'
			ELSE ej.MgrID + '@boston.k12.ma.us'
			END) as  MgrEmailAddr
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN 1
			ELSE 0
			END) as EmplExceptionExists
		,CASE
			when s.EmplID IS NULL
			THEN CASE
						WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
						ELSE ej.MgrID
					END
			ELSE s.EmplID
		END SubEvalID
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') 
			FROM Empl e1 WHERE e1.EmplID  = CASE
												when s.EmplID IS NULL
												THEN CASE
															WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
															ELSE ej.MgrID
														END
												ELSE s.EmplID
												END) AS SubEvalName
		,(CASE
			when s.EmplID IS NULL
			THEN CASE
						WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
						ELSE ej.MgrID
					END
			ELSE s.EmplID
		END)  + '@boston.k12.ma.us' SubEvalEmailaddr
		,ej.EmplID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  AS EmplName
		,ej.EmplClass
		,CASE 
			WHEN ISNULL(pt.CodeText, '') = 'Developing' AND ej.EmplClass = 'U' THEN ISNULL(pt.CodeText, '') + ' (Prov 1)'
			WHEN ISNULL(pt.CodeText, '') = 'Developing' AND ej.EmplClass IN ('B','V','W','X') THEN ISNULL(pt.CodeText, '') + ' (Prov 2-4)'
			WHEN ISNULL(pt.CodeText, '') = 'Developing' AND NOT ej.EmplClass IN ('U','B','V','W','X') THEN ISNULL(pt.CodeText, '')
			WHEN ISNULL(pt.CodeText, '') = 'Improvement' AND DATEDIFF(d, p.PlanStartDt, p.PlanSchedEndDt) < 180 THEN ISNULL(pt.CodeText, '') + ' (duration <1 year)'
			WHEN ISNULL(pt.CodeText, '') = 'Improvement' AND DATEDIFF(d, p.PlanStartDt, p.PlanSchedEndDt) >= 180 THEN ISNULL(pt.CodeText, '') + ' (duration 1 year)'
			ELSE ISNULL(pt.CodeText, '')
		END AS PlanType
		,ISNULL(CONVERT(VARCHAR, p.PlanStartDt, 101), '') AS PlanStartDt
		,ISNULL(CONVERT(VARCHAR, p.PlanSchedEndDt, 101), '') AS PlanEndDt
		,CASE
			WHEN p.PlanStartDt IS NOT NULL THEN DATEDIFF(d, p.PlanStartDt, p.PlanSchedEndDt)
			WHEN p.PlanStartDt IS NULL THEN p.Duration
			ELSE 0
		END AS PlanDuration
		,pg.GoalTypeID
		,gt.CodeText AS GoalType
		,t.GoalTagID
		,gtd.CodeText AS GoalTag
	FROM
		EmplEmplJob				AS ej (NOLOCK)
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
																	and ase.isActive = 1
																	and ase.isDeleted = 0
																	and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1
	JOIN EmplJob				AS j (NOLOCK)			ON ej.JobCode = j.JobCode
	JOIN Department				AS d (NOLOCK)			ON ej.DeptID = d.DeptID
	LEFT JOIN CodeLookUp		AS dc (NOLOCK)			ON d.DeptCategoryID = dc.CodeID	
	JOIN Empl					AS e (NOLOCK)			ON ej.EmplID = e.EmplID
														AND e.EmplActive = 1
	LEFT JOIN EmplExceptions	AS emplEx(NOLOCK)		ON emplEx.EmplJobID = ej.EmplJobID
	LEFT JOIN (SELECT 
					EmplJobID
					,EmplId
					,JobCode
				FROM
					cte
				WHERE
					PlanID IS NOT NULL)	AS c			ON ej.EmplID = c.EmplId
	LEFT JOIN EmplPlan					AS p (NOLOCK)	ON c.EmplJobID = p.EmplJobId
														AND p.PlanActive = 1
	LEFT JOIN CodeLookUp				AS pt (NOLOCK)	ON p.PlanTypeID = pt.CodeID
	LEFT JOIN PlanGoal					AS pg (NOLOCK)	ON p.PlanID = pg.PlanID
	LEFT JOIN CodeLookUp				AS gt (NOLOCK)	ON pg.GoalTypeID = gt.CodeID
	LEFT JOIN GoalTag					AS t (NOLOCK)	ON pg.GoalID = t.GoalID
	LEFT JOIN CodeLookUp				AS gtd (NOLOCK) ON t.GoalTagID = gtd.CodeID
	where
		ej.IsActive = 1
	and not ej.RubricID in (select RubricID from RubricHdr (NOLOCK) where Is5StepProcess = 1)			
GO
