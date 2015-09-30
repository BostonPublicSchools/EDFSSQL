SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 11/06/2012
-- Description:	View for observation analyst
-- =============================================
CREATE VIEW [dbo].[ObservationAnalyst]
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
--		AND j.UnionCode in ('BT3','HMP','BAS')
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
			THEN emplEx.MgrID
			ELSE ej.MgrID
			END) + '@boston.k12.ma.us' as MgrEmailAddr
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
		,ISNULL(CONVERT(VARCHAR, (SELECT TOP 1
										ObsvDt 
									FROM
										ObservationHeader (NOLOCK)
									WHERE
										PlanID = p.PlanID
									AND IsDeleted = 0 
									And ObsvRelease=1
								--for cuurent plan year	And ObsvDt >(Select '09/01/'+ SUBSTRING(SchYearValue,1,4) from dbo.PlanYearChangeTable where SchYearType='First')
									ORDER BY
										ObsvDt), 101), '') AS FirstObsvDt
		,(SELECT 
				COUNT(*) 
			FROM
				ObservationHeader (NOLOCK)
			WHERE
				PlanID = p.PlanID
			AND IsDeleted = 0				
			AND ObsvTypeID IN (SELECT
									CodeID
								FROM
									CodeLookUp (NOLOCK)
								WHERE
									CodeType = 'ObsvType'
								AND CodeText = 'Unannounced')) AS UnAnnouncedObsvCnt
		,ISNULL((SELECT 
				MaxLimit
			FROM
				PlanTypeMaxObservation (NOLOCK) 
			WHERE
				PlanTypeID = p.PlanTypeID
			AND CASE 
					WHEN EmplClass IS NULL THEN ej.EmplClass
					WHEN EmplClass = '' THEN ej.EmplClass
					ELSE EmplClass
				END = ej.EmplClass
			AND ObservationTypeID IN (SELECT
									CodeID
								FROM
									CodeLookUp (NOLOCK)
								WHERE
									CodeType = 'ObsvType'
								AND CodeText = 'Unannounced')), 0) AS UnAnnouncedMax
		,(SELECT
				COUNT(*) 
			FROM
				ObservationHeader (NOLOCK)
			WHERE
				PlanID = p.PlanID
			AND IsDeleted = 0				
			AND ObsvTypeID IN (SELECT
									CodeID
								FROM
									CodeLookUp (NOLOCK)
								WHERE
									CodeType = 'ObsvType'
								AND CodeText = 'Announced')) AS AnnouncedObsvCnt
		,ISNULL((SELECT 
						MaxLimit
					FROM
						PlanTypeMaxObservation (NOLOCK) 
					WHERE
						PlanTypeID = p.PlanTypeID 
					AND CASE 
							WHEN EmplClass IS NULL THEN ej.EmplClass
							WHEN EmplClass = '' THEN ej.EmplClass
							ELSE EmplClass
						END = ej.EmplClass
					AND ObservationTypeID IN (SELECT
											CodeID
										FROM
											CodeLookUp (NOLOCK)
										WHERE
											CodeType = 'ObsvType'
										AND CodeText = 'Announced')), 0) AS AnnouncedMax
		,(SELECT
				COUNT(*) 
			FROM
				ObservationHeader (NOLOCK)
			WHERE
				PlanID = p.PlanID
			AND IsDeleted = 0				
			AND DATEDIFF(n, ObsvStartTime, ObsvEndTime) >= 30) AS GreaterThan30ObsvCnt
		,(SELECT
				COUNT(*) 
			FROM
				ObservationHeader (NOLOCK)
			WHERE
				PlanID = p.PlanID
			AND IsDeleted = 0				
			AND DATEDIFF(n, ObsvStartTime, ObsvEndTime) < 30) AS LessThan30ObsvCnt
		,ISNULL((SELECT
						SUM(DATEDIFF(n, ObsvStartTime, ObsvEndTime)) 
					FROM
						ObservationHeader (NOLOCK)
					WHERE
						PlanID = p.PlanID
					AND IsDeleted = 0), 0) AS TotalTimeObsv
		,(SELECT 
				COUNT(*)
			FROM
				ObservationHeader AS oh (NOLOCK)
				JOIN ObservationDetail AS od (NOLOCK)	ON oh.ObsvID = od.ObsvID
														AND od.IsDeleted = 0
														AND NOT (ISNULL(od.ObsvDEvidence, '') = ''
														AND ISNULL(od.ObsvDFeedBack, '') = '')
				JOIN RubricIndicator AS ri (NOLOCK)		ON od.IndicatorID = ri.IndicatorID
				JOIN RubricStandard AS s (NOLOCK)		ON ri.StandardID = s.StandardID
														AND s.StandardText like 'I.%'
			WHERE
				 oh.IsDeleted = 0
			AND oh.PlanID = p.PlanID) AS ObsvStdI
		,(SELECT 
				COUNT(*)
			FROM
				ObservationHeader AS oh (NOLOCK)
				JOIN ObservationDetail AS od (NOLOCK)	ON oh.ObsvID = od.ObsvID
														AND od.IsDeleted = 0
														AND NOT (ISNULL(od.ObsvDEvidence, '') = ''
														AND ISNULL(od.ObsvDFeedBack, '') = '')
				JOIN RubricIndicator AS ri (NOLOCK)		ON od.IndicatorID = ri.IndicatorID
				JOIN RubricStandard AS s (NOLOCK)		ON ri.StandardID = s.StandardID
														AND s.StandardText like 'II.%'
			WHERE
				 oh.IsDeleted = 0
			AND oh.PlanID = p.PlanID) AS ObsvStdII
		,(SELECT 
				COUNT(*)
			FROM
				ObservationHeader AS oh (NOLOCK)
				JOIN ObservationDetail AS od (NOLOCK)	ON oh.ObsvID = od.ObsvID
														AND od.IsDeleted = 0
														AND NOT (ISNULL(od.ObsvDEvidence, '') = ''
														AND ISNULL(od.ObsvDFeedBack, '') = '')
				JOIN RubricIndicator AS ri (NOLOCK)		ON od.IndicatorID = ri.IndicatorID
				JOIN RubricStandard AS s (NOLOCK)		ON ri.StandardID = s.StandardID
														AND s.StandardText like 'III.%'
			WHERE
				 oh.IsDeleted = 0
			AND oh.PlanID = p.PlanID) AS ObsvStdIII
		,(SELECT 
				COUNT(*)
			FROM
				ObservationHeader AS oh (NOLOCK)
				JOIN ObservationDetail AS od (NOLOCK)	ON oh.ObsvID = od.ObsvID
														AND od.IsDeleted = 0
														AND NOT (ISNULL(od.ObsvDEvidence, '') = ''
														AND ISNULL(od.ObsvDFeedBack, '') = '')
				JOIN RubricIndicator AS ri (NOLOCK)		ON od.IndicatorID = ri.IndicatorID
				JOIN RubricStandard AS s (NOLOCK)		ON ri.StandardID = s.StandardID
														AND s.StandardText like 'IV.%'
			WHERE
				 oh.IsDeleted = 0
			AND oh.PlanID = p.PlanID) AS ObsvStdIV
		,ISNULL(CONVERT(VARCHAR, ev.EvalDt, 101), '') AS FormAsmtEvalDt
		,CASE 
			WHEN ISNULL(RxCnt, 0) > 0 THEN 'Yes'
			ELSE 'No'
		END AS StdRateBelow
		,ISNULL(CONVERT(VARCHAR, DATEADD(d,30, ev.EvaluatorSignedDt), 101), '') AS FollowUpDt
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
	JOIN RptUnionCode			AS ruc (NOLOCK)			ON j.JobCode = ruc.JobCode
														AND ruc.IsActive = 1
	JOIN Empl					AS e (NOLOCK)			ON ej.EmplID = e.EmplID
														AND e.EmplActive = 1
	LEFT JOIN Empl				AS de (NOLOCK)			ON de.EmplID = ej.MgrID																						
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
	LEFT JOIN (SELECT
					PlanID
					,EvalDt
					,EvaluatorSignedDt
					,MAX(EvalID) AS EvalID
				FROM 
					Evaluation (NOLOCK)
				WHERE
					IsSigned = 1
				AND EvalTypeID IN (SELECT
										CodeID
									FROM
										CodeLookUp (NOLOCK)
									WHERE
										CodeType = 'EvalType'
									AND CodeText = 'Formative Assessment')
				GROUP BY
					PlanID, EvalDt, EvaluatorSignedDt) AS  ev ON  p.PlanID = ev.PlanID
	LEFT JOIN (SELECT
					EvalID
					,COUNT(*) AS RxCnt
				FROM
					EvaluationPrescription (NOLOCK)
				GROUP BY
					EvalID) AS ep ON ev.EvalID = ep.EvalID
												
	where
		ej.IsActive = 1	


GO
