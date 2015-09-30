SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 04/17/2012
-- Description:	Returns individual plan info
-- =============================================
CREATE PROCEDURE [dbo].[getPlan]
	@PlanID AS int = NULL
AS
BEGIN
SET NOCOUNT ON;
	SELECT 
		ej.EmplID
		,ej.JobCode
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName
		,p.PlanActive
		,p.PlanEditLock
		,p.PlanID
		,p.PlanStartDt
		,p.PlanSchedEndDt
		,p.PlanYear
		,p.CreatedByDt
		,ISNULL(gs.CodeText, 'None') AS GoalStatus
		,p.GoalStatusDt
		,pt.CodeText AS PlanType
		,p.PlanTypeID
		,CASE  
			WHEN p.PlanStartDt is NULL THEN (pt.CodeText + ' ' + isnull(CONVERT(varchar, p.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, p.PlanSchedEndDt, 101),''))
			WHEN p.PlanStartDt IS NOT NULL THEN pt.CodeText + ' ' + isnull(CONVERT(varchar, p.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, p.PlanSchedEndDt, 101),'') + ' (' + CAST(DATEDIFF(day, PlanStartDt, PlanSchedEndDt) as varchar(10))   + ' Days)' 
			END as PlanLabel
		--,pt.CodeText + ' ' + isnull(CONVERT(varchar, p.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, p.PlanEndDt, 101),'')  AS PlanLabel
		,p.IsSignedAsmt
		,p.SignatureAsmt
		,p.DateSignedAsmt
		,p.IsSignedActnStep
		,p.SignatureActnStep
		,p.DateSignedActnStep
		,p.ActnStepStatusID
		,p.ActnStepDt
		,ISNULL(acs.CodeText, 'None') AS ActnStepStatus
			,p.HasPrescript
		,p.PrescriptEvalID
		,p.NeedToEnd
		,(CASE WHEN PlanStartDt IS NOT NULL THEN DATEDIFF(day, PlanStartDt, PlanSchedEndDt) ELSE 0 END) as Duration
		,ej.RubricID
		,p.RubricID [PlanRubricID]
		--,p.SelfAsmtStrength
		--,p.SelfAsmtWeakness
		,p.PlanStartEvalDate
		,p.AnticipatedEvalWeek
		,p.IsMultiYearPlan
		,gm.CodeText [MultiYearGoalStatus]
		,p.MultiYearGoalStatusID
		,p.MultiYearGoalStatusDt
		,acsm.CodeText [MultiYearActnStepStatus]
		,p.MultiYearActnStepStatusID
		,p.MultiYearActnStepDt
		,eval.EvalID
		,et.CodeText AS EvalType
		,ed.IsSigned AS IsEvalSigned
		,Coalesce(ed.EvalPlanYear,1) As EvalPlanYear
		,ed.EditEndDt EvalEditEndDt
		,p.PrevPlanPrescptEvalID
		,p.EmplJobID
		,d.DeptName
	FROM
		EmplEmplJob AS ej (NOLOCK) 
	JOIN Empl as e (NOLOCK) on ej.EmplID = e.EmplID
	JOIN EmplPlan AS p (NOLOCK)	ON ej.EmplJobID = p.EmplJobID
	JOIN CodeLookUp	AS pt (NOLOCK) ON p.PlanTypeID = pt.CodeID
	LEFT OUTER JOIN EmplJob AS j(NOLOCK) ON j.JobCode = ej.JobCode
	LEFT OUTER JOIN CodeLookUp	AS gs (NOLOCK) ON p.GoalStatusID = gs.CodeID
	LEFT OUTER JOIN CodeLookUp AS acs (NOLOCK) ON p.ActnStepStatusID = acs.CodeID
	LEFT JOIN CodeLookUp AS gm (NOLOCK) ON p.MultiYearGoalStatusID = gm.CodeID
	LEFT JOIN CodeLookUp AS acsm (NOLOCK) ON p.MultiYearActnStepStatusID = acsm.CodeID
	LEFT JOIN Department as d (NOLOCK) ON d.DeptID = ej.DeptID
	LEFT JOIN (SELECT
				PlanID
				,MAX(EvalID) AS EvalID
			FROM 
				Evaluation (NOLOCK)
			WHERE
				IsSigned = 1
			GROUP BY
				PlanID) AS  eval ON  p.PlanID = eval.PlanID
	LEFT JOIN (SELECT
				EvalID
				,OverallRatingID
				,EvalDt
				,IsSigned
				,EditEndDt
				,EvalTypeID
				,EvalRubricID
				,EvalPlanYear
			FROM 
				Evaluation (NOLOCK)
			WHERE
				IsDeleted = 0) AS  ed ON  eval.EvalID = ed.EvalID
	LEFT JOIN CodeLookUp	AS et (NOLOCK) ON ed.EvalTypeID = et.CodeID
	WHERE
		p.PlanID =@PlanID
	AND ej.EmplRcdNo <= 20
END
GO
