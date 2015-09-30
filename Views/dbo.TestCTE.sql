SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[TestCTE]
as
with 
	cte (PlanID, EmplJobId, JobCode, EmplId, EmplRcdNo, MgrId, SubEvalID, CreatedById, CreatedByDt, LastUpdatedByID, LastUpdatedDt, DeptID, PositionNo, EffectiveDt, EmplClass, IsActive)
as
(
select P.PlanID, ej.* 
FROM
		EmplEmplJob AS ej (NOLOCK)
	JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
								and j.UnionCode in ('BT3','HMP','BAS')
	JOIN Department AS d (NOLOCK) On ej.DeptID = d.DeptID								
	JOIN Empl AS e (NOLOCK) ON ej.EmplID = e.EmplID
							AND e.EmplActive = 1
	LEFT OUTER JOIN Empl AS de (NOLOCK) ON de.EmplID = ej.MgrID																						
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	LEFT OUTER JOIN Empl AS ee (NOLOCK) ON CASE ej.SubEvalID 
									WHEN '000000' THEN ej.MgrID
									ELSE ej.SubEvalID 
								END = ee.EmplID
	LEFT OUTER JOIN EmplPlan AS p (NOLOCK) ON ej.EmplJobID = p.EmplJobID
								  AND p.PlanActive = 1
	where ej.EmplID = '082204'
)
select case when PlanID is null then 9999 else PlanID end as PlanId, 
	   EmplJobId, JobCode, EmplId, EmplRcdNo, MgrId, SubEvalID, CreatedById, CreatedByDt, LastUpdatedByID, LastUpdatedDt, DeptID, PositionNo, EffectiveDt, EmplClass, IsActive 
from cte
GO
