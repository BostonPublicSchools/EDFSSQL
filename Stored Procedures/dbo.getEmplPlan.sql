SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/17/2012
-- Description:	List of plan info for an individual employee. PLAN DO NOT INCLUDE INVALID PLAN
-- =============================================
CREATE PROCEDURE [dbo].[getEmplPlan]
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
		,(SELECT ISNULL(e1.NameLast, '')+ ', ' +ISNULL(e1.NameFirst,'')+ ' '+ISNULL(e1.NameMiddle,'') FROM Empl e1 WHERE e1.EmplID = p.SubEvalID) as SubEvalName
		,ISNULL(gs.CodeText, 'None') AS GoalStatus
		,p.GoalStatusID
		,p.GoalStatusDt
		,pt.CodeText AS PlanType
		,CASE  
			WHEN p.PlanStartDt is NULL THEN (pt.CodeText + ' ' + isnull(CONVERT(varchar, p.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, p.PlanSchedEndDt, 101),''))
			WHEN  p.PlanStartDt is not NULL THEN pt.CodeText + ' ' + isnull(CONVERT(varchar, p.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, p.PlanSchedEndDt, 101),'')   --+ ' (' + CAST(DATEDIFF(day,  p.PlanStartDt, (CASE WHEN p.PlanActive = 0 and p.PlanEndDate IS NOT NULL and p.PlanEndDate != p.PlanEndDt THEN  p.PlanEndDate ELSE  p.PlanEndDt END)) as varchar(10))  + ' Days)' 
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
		--,NULL AS PlanCreatedName
		,(SELECT ec.NameFirst + ' ' + ISNULL(ec.NameMiddle,'') + ' ' + ec.NameLast FROM Empl ec WHERE ec.EmplID = p.CreatedByID) AS PlanCreatedName
		,p.CreatedByID AS PlanCreatedByID
		,(SELECT ISNULL(e1.NameLast, '')+ ', ' +ISNULL(e1.NameFirst,'')+ ' '+ISNULL(e1.NameMiddle,'') FROM Empl e1 WHERE e1.EmplID = p.SubEvalID) as PlanSubEvalName
		,ISNULL(acs.CodeText, 'None') AS ActnStepStatus
		,e.EvalID
		,ed.EvalDt
		,Coalesce(ed.EvalPlanYear,1) As EvalPlanYear
		,ed.OverallRatingID AS OverallRatingID		
		,eor.CodeText AS OverallRating
		,et.CodeText AS EvalType
		,ed.IsSigned AS IsEvalSigned
		,ed.EditEndDt AS EvalEditEndDt
		,cast(ed.EvaluatorSignedDt as date) as EvaluatorSignedDt
		,p.HasPrescript
		,p.PrescriptEvalID
		,p.PrevPlanPrescptEvalID 
		,ej.IsActive
		,ed.EvalRubricID AS EvalRubricID
		--,ej.RubricID
		,j.UnionCode
		,(SELECT EvalRubricID From Evaluation where EvalID = p.PrevPlanPrescptEvalID) as PrescriptRubricID
		,rh.RubricID
		,rh.RubricName
		,rh.Is5StepProcess
		,p.PlanStartEvalDate
		,p.AnticipatedEvalWeek
		,p.IsMultiYearPlan		
		,gm.CodeText [MultiYearGoalStatus]
		,p.MultiYearGoalStatusID
		,p.MultiYearGoalStatusDt
		,acsm.CodeText [MultiYearActnStepStatus]
		,p.MultiYearActnStepStatusID
		,p.MultiYearActnStepDt
		,dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) as PrimaryEvalID
		,ej.IsActive
		,p.IsInvalid
		,ISNULL(p.InvalidNote,'') InvalidNote	
	FROM
		EmplEmplJob AS ej (NOLOCK)
	JOIN EmplPlan AS p (NOLOCK)	ON ej.EmplJobID = p.EmplJobID and p.IsInvalid=0
	join RubricHdr as rh (nolock) on rh.RubricID =(CASE when p.RubricID is not null then p.RubricID else ej.RubricID end)			
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1	
	JOIN CodeLookUp	AS pt (NOLOCK) ON p.PlanTypeID = pt.CodeID	
	LEFT JOIN CodeLookUp AS gs (NOLOCK) ON p.GoalStatusID = gs.CodeID
	LEFT JOIN CodeLookUp AS acs (NOLOCK) ON p.ActnStepStatusID = acs.CodeID
	LEFT JOIN (SELECT
					PlanID
					,MAX(EvalID) AS EvalID
				FROM 
					Evaluation (NOLOCK)
				WHERE
					IsSigned = 1 And IsDeleted=0
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
					,EvaluatorSignedDt
				FROM 
					Evaluation (NOLOCK)
				WHERE
					IsDeleted = 0) AS  ed ON  e.EvalID = ed.EvalID
	LEFT JOIN CodeLookUp	AS eor (NOLOCK) ON ed.OverallRatingID = eor.CodeID
	LEFT JOIN CodeLookUp	AS et (NOLOCK) ON ed.EvalTypeID = et.CodeID
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) ON emplEx.EmplJobID = ej.EmplJobID
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
		--p.PlanActive desc,p.PlanEndDate desc,  p.PlanEndDt desc
END
GO
