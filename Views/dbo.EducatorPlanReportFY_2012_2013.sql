SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[EducatorPlanReportFY_2012_2013]
AS
select	e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EducatorName
		,e.EmplID
		,d.DeptName
		,(select NameLast+ ', '+ NameFirst + ' ' + ISNULL(NameMiddle, '') + ' (' + EmplID + ')' from empl where emplid = ep.PlanManagerID) as ManagerName
		,ISNULL(see.NameLast + ', ' + see.NameFirst + ' ' + ISNULL(see.NameMiddle, '') + ' (' + see.EmplID + ')', '') AS SubEvalName
		,ep.PlanID as PlanID
		,cl.CodeText as PlanType
		,ISNULL(CONVERT(VARCHAR, ep.PlanStartDt, 101), '') as PlanStartDt
		,ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101), '') as PlanEnddt
		,ISNULL(CONVERT(VARCHAR, ep.PlanActEndDt, 101), '') as ActualPlanEnddt
		,CASE
			WHEN ep.PlanTypeID = 1 AND ep.IsMultiYearPlan = 'true'  THEN '2 Year(s)'
			WHEN ep.PlanTypeID = 1 AND ( ep.IsMultiYearPlan = 'false' OR ep.IsMultiYearPlan IS NULL) THEN '1 Year(s)'			
			ELSE null 
		END AS IsMultiYearPlan
 from EmplPlan as ep (NOLOCK)
join CodeLookUp as cl (NOLOCK) on cl.CodeID = ep.PlanTypeID 
join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID
left outer join EmplExceptions as emplEx (nolock) on eej.EmplJobID = emplex.EmplJobID 
Join Empl e on e.EmplID = eej.EmplID
join Department d on d.DeptID = eej.DeptID
join RubricHdr r on eej.RubricID = r.RubricID
				and r.Is5StepProcess = 1
left join Empl see on see.EmplID = ep.SubEvalID

where 
	ep.IsInvalid = 0 AND
	(ep.PlanSchedEndDt between '07/01/2012' and '06/30/2013'
				or ep.PlanStartDt between '07/01/2012' and '06/30/2013')

GO
