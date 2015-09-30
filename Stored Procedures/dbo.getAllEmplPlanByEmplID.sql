SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/24/2012
-- Description:	List of plan info for an individual employee. Plan also include Invalid Plan
-- =============================================
CREATE PROCEDURE [dbo].[getAllEmplPlanByEmplID]
	@ncEmplID AS nchar(6) = NULL
AS
BEGIN
	SET NOCOUNT ON;
SELECT 
		ej.EmplID
		,p.PlanActive
		,p.PlanActEndDt
		,cl.CodeText as PlanEndReason
		,p.PlanEndReasonID
		,p.PlanEditLock
		,p.PlanID
		,p.PlanTypeID
		,p.PlanStartDt
		,p.PlanSchedEndDt
		,p.PlanYear
		,p.SubEvalID
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE ej.MgrID
			END) as MgrID
		,ej.EmplJobID
		,empl.NameLast + ', ' + empl.NameFirst + ' '  + ISNULL(empl.NameMiddle,'') + ' (' + empl.EmplID + ')' as EmplName 
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = p.SubEvalID) AS SubEvalName
		,ISNULL(gs.CodeText, 'None') AS GoalStatus
		,p.GoalStatusID
		,p.GoalStatusDt
		,pt.CodeText AS PlanType
		,CASE  
			WHEN p.PlanStartDt is NULL THEN (pt.CodeText + ' ' + isnull(CONVERT(varchar, p.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, p.PlanSchedEndDt, 101),''))
			WHEN p.PlanStartDt IS NOT NULL THEN pt.CodeText + ' ' + isnull(CONVERT(varchar, p.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, p.PlanSchedEndDt, 101),'') 
			else (pt.CodeText + ' ' + isnull(CONVERT(varchar, p.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, p.PlanSchedEndDt, 101),''))
		 END AS PlanLabel
		,j.JobCode
		,j.JobName
		,d.DeptID
		,d.DeptName
		,p.IsSignedAsmt
		,p.SignatureAsmt
		,p.DateSignedAsmt
		,p.IsSignedActnStep
		,p.SignatureActnStep
		,p.DateSignedActnStep
		,p.ActnStepStatusID
		,p.ActnStepDt
		,(CASE WHEN p.PlanStartDt IS NOT NULL THEN DATEDIFF(day,  p.PlanStartDt, p.PlanSchedEndDt) ELSE 0 END) as Duration
		,(CASE WHEN p.PlanActive = 0 and p.PlanActEndDt IS NOT NULL and p.PlanStartDt IS NOT NULL THEN DATEDIFF(day,  p.PlanStartDt, p.PlanActEndDt) ELSE 0 END) as ActualDuration
		,p.SubEvalID AS PlanSubEvalID
		,p.CreatedByDt AS PlanCreatedDt
		,(SELECT ec.NameFirst + ' ' + ISNULL(ec.NameMiddle,'') + ' ' + ec.NameLast FROM Empl ec WHERE ec.EmplID = p.CreatedByID) AS PlanCreatedName
		,p.CreatedByID AS PlanCreatedByID
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = p.SubEvalID) as PlanSubEvalName
		,ISNULL(acs.CodeText, 'None') AS ActnStepStatus
		,e.EvalID
		,ed.EvalDt
		,coalesce(ed.EvalPlanYear,1) As EvalPlanYear
		,ed.OverallRatingID AS OverallRatingID
		,eor.CodeText AS OverallRating
		,et.CodeText AS EvalType
		,ed.IsSigned AS IsEvalSigned
		,ed.EditEndDt AS EvalEditEndDt				
		,cast(ed.EvaluatorSignedDt as date) as EvaluatorSignedDt
		,p.HasPrescript
		,p.PrescriptEvalID
		,p.PrevPlanPrescptEvalID 
		,ed.EvalRubricID AS EvalRubricID
		--,j.RubricID
		,(SELECT EvalRubricID From Evaluation where EvalID = p.PrescriptEvalID) as PrescriptRubricID
		,rh.Is5StepProcess
		,rh.RubricID
		,rh.RubricName
		,p.PlanStartEvalDate
		,p.AnticipatedEvalWeek
		,p.IsMultiYearPlan
		,(case when p.planyear=2 then ISNULL(gm.CodeText, 'None') else '' end) [MultiYearGoalStatus]
		,p.MultiYearGoalStatusID
		,p.MultiYearGoalStatusDt
		,(case when p.PlanYear=2 then ISNULL(acsm.CodeText, 'None') else '' end)  [MultiYearActnStepStatus]
		,p.MultiYearActnStepStatusID
		,p.MultiYearActnStepDt
		,dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) as PrimaryEvalID
		,ej.IsActive
		,p.IsInvalid
		,ISNULL(p.InvalidNote,'') InvalidNote
	FROM
		EmplEmplJob AS ej (NOLOCK) 
	JOIN EmplPlan AS p (NOLOCK)	ON ej.EmplJobID = p.EmplJobID
	join RubricHdr as rh (nolock) on rh.RubricID = (CASE when p.RubricID is not null then p.RubricID else ej.RubricID end)					
	JOIN CodeLookUp	AS pt (NOLOCK) ON p.PlanTypeID = pt.CodeID		
	LEFT OUTER JOIN EmplExceptions as emplEx(NOLOCK) ON emplEx.EmplJobID = ej.EmplJobID AND emplEx.EmplID = @ncEmplID
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1	
	LEFT JOIN CodeLookUp AS gs (NOLOCK) ON p.GoalStatusID = gs.CodeID
	LEFT JOIN CodeLookUp AS acs (NOLOCK) ON p.ActnStepStatusID = acs.CodeID
	LEFT JOIN (SELECT
					PlanID
					,MAX(EvalID) AS EvalID
					FROM 
					Evaluation (NOLOCK)
				--WHERE - show even the eval is not signed
				--	IsSigned = 1
				GROUP BY
					PlanID) AS  e ON  p.PlanID = e.PlanID
	LEFT JOIN (SELECT
					EvalID
					,OverallRatingID
					,EvalDt
					,IsSigned
					,EditEndDt
					,EvalTypeID
					,EvalRubricID
					,EvalPlanYear
					,EmplSignedDt
					,EvaluatorSignedDt
				FROM 
					Evaluation (NOLOCK)
				WHERE
					IsDeleted = 0) AS  ed ON  e.EvalID = ed.EvalID
	LEFT JOIN CodeLookUp	AS eor (NOLOCK) ON ed.OverallRatingID = eor.CodeID
	LEFT JOIN CodeLookUp	AS et (NOLOCK) ON ed.EvalTypeID = et.CodeID
	LEFT JOIN Empl AS sub  (NOLOCK) on CASE
										when p.SubEvalID = '000000'
										THEN CASE
												when s.EmplID IS NULL
												THEN CASE
															WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
															ELSE ej.MgrID
														END
												ELSE s.EmplID
										END
										ELSE p.SubEvalID
										END = sub.emplid
	JOIN Empl as empl (NOLOCK) on ej.EmplID =  empl.EmplID
	LEFT JOIN EmplJob AS j (NOLOCK) on j.JobCode = ej.JobCode
	LEFT JOIN Department AS d (NOLOCK) ON ej.DeptID = d.DeptID
	left join CodeLookUp as cl (NOLOCK) on cl.CodeID = p.PlanEndReasonID
	LEFT JOIN CodeLookUp AS gm (NOLOCK) ON p.MultiYearGoalStatusID = gm.CodeID	
	LEFT JOIN CodeLookUp AS acsm (NOLOCK) ON p.MultiYearActnStepStatusID = acsm.CodeID
	WHERE
		ej.EmplID = @ncEmplID
	ORDER by
		CASE p.PlanActive when 1 then p.CreatedByDt END desc
		, Case p.PlanActive when 0 then (p.PlanSchedEndDt) END desc
		--p.PlanActive desc, p.PlanStartDt desc 
END
GO
