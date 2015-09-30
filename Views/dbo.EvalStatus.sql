SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 06/19/2012
-- Description:	Goal status report
-- =============================================
CREATE VIEW [dbo].[EvalStatus]
AS
	SELECT
		d.DeptID
		,d.DeptName
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE ej.MgrID
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
			END) AS SubEvalName
		,e.EmplID
		,e.NameFirst
		,e.NameMiddle
		,e.NameLast
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName
		,e.EmplActive
		,gs.CodeText As GoalStatus
		,ep.PlanSchedEndDt As PlanEndDt
		,(SELECT 
				COUNT(gep.GoalEvalID)
			FROM
				GoalEvaluationProgress as gep
			WHERE
				gep.EvalId = ev.EvalID) AS GoalProgressEntered
		,(SELECT 
				COUNT(esr.EvalStdRatingID)
			FROM
				EvaluationStandardRating as esr
			WHERE
				esr.EvalId = ev.EvalID) AS StandardRatingEntered
		,oar.CodeText
		,ev.EvaluatorSignedDt
		,ev.EmplSignedDt
		,evaltype.CodeText AS EvalType
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN 1
			ELSE 0
			END) as EmplExceptionExists
	FROM
		EmplEmplJob AS ej (NOLOCK)
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
																	and ase.isActive = 1
																	and ase.isDeleted = 0
																	and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1
	JOIN Department d (NOLOCK)  ON d.DeptID = ej.DeptID
	JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode	
	JOIN Empl AS e (NOLOCK) ON ej.EmplID = e.EmplID
								AND e.EmplActive = 1
	LEFT JOIN EmplPlan AS ep (NOLOCK) ON ej.EmplJobID = ep.EmplJobID
										AND ep.PlanActive = 1
	LEFT JOIN Evaluation AS ev (NOLOCK) ON ep.PlanID = ev.PlanID
										AND ev.IsDeleted = 0
	LEFT JOIN CodeLookUp AS gs (NOLOCK) ON ep.GoalStatusID = gs.CodeID
	LEFT JOIN CodeLookUp AS oar (NOLOCK) ON ev.OverallRatingID = oar.CodeID
	LEFT JOIN CodeLookUp AS evaltype (NOLOCK) ON ev.EvalTypeID = evaltype.CodeID
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	WHERE
		ej.IsActive = 1
	and ej.RubricID in (select RubricID from RubricHdr (NOLOCK) where Is5StepProcess = 1)
		
		
GO
