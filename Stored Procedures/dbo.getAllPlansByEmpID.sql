SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 08/22/2012
-- Description:	get all plan for an employee by id
-- =============================================
CREATE PROCEDURE [dbo].[getAllPlansByEmpID]
	@emplID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		ej.EmplID
		,j.JobCode
		,j.JobName
		,p.PlanActive
		,p.PlanEditLock
		,p.PlanID
		,p.PlanStartDt
		,p.PlanSchedEndDt
		,ISNULL(gs.CodeText, 'None') AS GoalStatus
		,p.GoalStatusDt
		,pt.CodeText AS PlanType
		,CASE  
			WHEN p.PlanStartDt is NULL THEN (pt.CodeText + ' ' + isnull(CONVERT(varchar, p.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, p.PlanSchedEndDt, 101),''))
			WHEN p.PlanStartDt IS NOT NULL THEN pt.CodeText + ' ' + isnull(CONVERT(varchar, p.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, p.PlanSchedEndDt, 101),'') + ' (' + CAST(DATEDIFF(day, PlanStartDt, PlanSchedEndDt) as varchar(10)) + ' Days)' 
			else (pt.CodeText + ' ' + isnull(CONVERT(varchar, p.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, p.PlanSchedEndDt, 101),''))
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
		--,p.SelfAsmtStrength
		--,p.SelfAsmtWeakness
	FROM
		EmplEmplJob AS ej (NOLOCK) 
	JOIN EmplJob AS j ON j.JobCode = ej.JobCode
	JOIN EmplPlan AS p (NOLOCK)	ON ej.EmplJobID = p.EmplJobID
	JOIN CodeLookUp	AS pt (NOLOCK) ON p.PlanTypeID = pt.CodeID
	LEFT OUTER JOIN CodeLookUp	AS gs (NOLOCK) ON p.GoalStatusID = gs.CodeID
	LEFT OUTER JOIN CodeLookUp AS acs (NOLOCK) ON p.ActnStepStatusID = acs.CodeID
	WHERE
	ej.EmplID = @emplID AND 
	ej.EmplRcdNo <= 20	
END
GO
