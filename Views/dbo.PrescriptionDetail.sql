SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 12/12/2012
-- Description: prescription text report
-- =============================================
CREATE VIEW [dbo].[PrescriptionDetail]
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
		,pt.CodeText AS PlanType
		,rs.StandardText
		,psr.CodeText as StandardRating
		,evalp.PrscriptionStmt
FROM
		EmplEmplJob AS ej (NOLOCK)
	JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1	
	JOIN Department AS d (NOLOCK) On ej.DeptID = d.DeptID
	LEFT OUTER JOIN CodeLookUp As dc (NOLOCK) ON d.DeptCategoryID = dc.CodeID
	JOIN RptUnionCode	AS ruc	(NOLOCK)		ON j.JobCode = ruc.JobCode
											AND ruc.IsActive = 1
	JOIN Empl AS e (NOLOCK) ON ej.EmplID = e.EmplID
							AND e.EmplActive = 1
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	JOIN (SELECT 
				EmplJobID
				,EmplId
				,JobCode
			FROM
				cte
			WHERE
				PlanID IS NOT NULL) AS c ON ej.EmplID = c.EmplId
	JOIN EmplPlan AS p (NOLOCK) ON c.EmplJobID = p.EmplJobId
								AND p.IsInvalid = 0
	JOIN CodeLookUp As pt (NOLOCK) ON p.PlanTypeID = pt.CodeID
	join Evaluation as eval (NOLOCK) on p.PlanID = eval.PlanID
	join EvaluationPrescription as evalp (nolock) on eval.EvalID = evalp.EvalID
													and evalp.IsDeleted = 0
	join RubricIndicator as ri (nolock) on evalp.IndicatorID = ri.IndicatorID
	join RubricStandard as rs (nolock) on ri.StandardID = rs.StandardID
	join EvaluationStandardRating as evalsr on rs.StandardID = evalsr.StandardID
											and evalp.EvalID = evalsr.EvalID
	join CodeLookUp as psr (nolock) on evalsr.RatingID = psr.CodeID
GO
