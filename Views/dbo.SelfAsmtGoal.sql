SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 08/01/2012
-- Description:	View for self-assessment goal report report
-- =============================================
CREATE VIEW [dbo].[SelfAsmtGoal]
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

SELECT DISTINCT
		d.DeptID
		,d.DeptName + ' (' + d.DeptID + ')' AS DeptName
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
		,ej.EmplID as EmplID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  AS EmplName
		,j.UnionCode
		,j.JobCode
		,j.JobName
		,pp.PositionProgramID
		,ISNULL(ssa.StandardText, '') as StrengthStandardText
		,ISNULL(ssa.Indicator, '') as StrengthIndicatorText
		,ISNULL(ssa.Element, '') as StrengthElementText
		,ssa.SelfAsmtText AS StrengthSelfAsmtText
		,ISNULL(gsa.StandardText, '') as GrowthStandardText
		,ISNULL(gsa.Indicator, '') as GrowthIndicatorText
		,ISNULL(gsa.Element, '') as GrowthElementText
		,gsa.SelfAsmtText AS GrowthSelfAsmtText
		,gt.CodeText as GoalType
		,gl.CodeText as GoalLevel
		,SUBSTRING((SELECT
						 ', ' + CAST(c.CodeText AS varchar(50))
					FROM
						GoalTag AS gt
					JOIN CodeLookUp AS c ON gt.GoalTagID = c.CodeID
					Where 
						GT.GoalID = g.GoalID
					For XML PATH ('')), 2, 9999)  AS GoalTagTexts
		,g.GoalText
		,gce.NameLast + ', ' + gce.NameFirst + ' ' + ISNULL(gce.NameMiddle, '') + ' (' + gce.EmplID + ')'  AS GoalCreatedByName
		,gs.CodeText as GoalStatus
		,pgs.CodeText as ApprovalStatus
FROM
		EmplEmplJob AS ej (NOLOCK)
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1	
	JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
	JOIN Department AS d (NOLOCK) On ej.DeptID = d.DeptID
	LEFT OUTER JOIN CodeLookUp As dc (NOLOCK) ON d.DeptCategoryID = dc.CodeID
	
	JOIN Empl AS e (NOLOCK) ON ej.EmplID = e.EmplID
							AND e.EmplActive = 1
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	LEFT JOIN PositionProgram as pp (NOLOCK) on ej.EmplID = pp.EmplID
	LEFT JOIN (SELECT 
				EmplJobID
				,EmplId
				,JobCode
			FROM
				cte
			WHERE
				PlanID IS NOT NULL) AS c ON ej.EmplID = c.EmplId
	LEFT JOIN EmplPlan AS p (NOLOCK) ON c.EmplJobID = p.EmplJobId
								AND p.PlanActive = 1
	LEFT JOIN (SELECT
					sa.PlanID	
					,rs.StandardText
					,pri.IndicatorText as Indicator
					,ri.IndicatorText as Element
					,sa.SelfAsmtText
				FROM
					PlanSelfAsmt as sa (NOLOCK) 
					JOIN CodeLookUp As sat (NOLOCK) ON sa.SelfAsmtTypeID = sat.CodeID
					JOIN RubricStandard as rs (NOLOCK) on sa.StandardID = rs.StandardID
					JOIN RubricIndicator as ri (NOLOCK) on sa.IndicatorID = ri.IndicatorID
					JOIN RubricIndicator as pri (NOLOCK) on ri.ParentIndicatorID = pri.IndicatorID
					JOIN RubricHdr as rh (NOLOCK) ON rs.RubricID = rh.RubricID
				WHERE
					sa.SelfAsmtTypeID = (SELECT CodeID FROM CodeLookUp (NOLOCK) WHERE CodeText = 'Strength' AND CodeType = 'SAsmtType')) as ssa ON p.PlanID = ssa.PlanID
	LEFT JOIN (SELECT
					sa.PlanID	
					,rs.StandardText
					,pri.IndicatorText as Indicator
					,ri.IndicatorText as Element
					,sa.SelfAsmtText
				FROM
					PlanSelfAsmt as sa (NOLOCK) 
					JOIN CodeLookUp As sat (NOLOCK) ON sa.SelfAsmtTypeID = sat.CodeID
					JOIN RubricStandard as rs (NOLOCK) on sa.StandardID = rs.StandardID
					JOIN RubricIndicator as ri (NOLOCK) on sa.IndicatorID = ri.IndicatorID
					JOIN RubricIndicator as pri (NOLOCK) on ri.ParentIndicatorID = pri.IndicatorID
					JOIN RubricHdr as rh (NOLOCK) ON rs.RubricID = rh.RubricID
				WHERE
					sa.SelfAsmtTypeID = (SELECT CodeID FROM CodeLookUp (NOLOCK) WHERE CodeText = 'Area of Growth' AND CodeType = 'SAsmtType')) as gsa ON p.PlanID = gsa.PlanID
	LEFT JOIN PlanGoal as g (NOLOCK) on p.PlanID = g.PlanID
										and g.IsDeleted = 0
	LEFT JOIN CodeLookUp as gt (NOLOCK) on g.GoalTypeID = gt.CodeID
	LEFT JOIN CodeLookUp as gl (NOLOCK) on g.GoalLevelID = gl.CodeID	
	LEFT JOIN CodeLookUp as gs (NOLOCK) on g.GoalStatusID = gs.CodeID
	LEFT JOIN CodeLookUp as pgs (NOLOCK) on p.GoalStatusID = pgs.CodeID
	LEFT JOIN Empl as gce (NOLOCK) on g.CreatedByID = gce.EmplID
where
	ej.IsActive = 1	
and not ej.RubricID in (select RubricID from RubricHdr(NOLOCK) where Is5StepProcess = 1)
GO
