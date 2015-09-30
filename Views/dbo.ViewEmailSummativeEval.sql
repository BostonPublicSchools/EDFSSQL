SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[ViewEmailSummativeEval]
AS
SELECT 
	e.EmplID
	,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  AS EmplName
	,e.EmplID + '@boston.k12.ma.us' as  EmplEmailAddr
	,m.EmplID as MgrID
	,m.NameLast + ', ' + m.NameFirst + ' ' + ISNULL(m.NameMiddle, '') + ' (' + m.EmplID + ')'  AS MgrName
	,m.EmplID + '@boston.k12.ma.us' as  MgrEmailAddr
	,eval.EmplID as SubEvalID
	,eval.NameLast + ', ' + eval.NameFirst + ' ' + ISNULL(eval.NameMiddle, '') + ' (' + eval.EmplID + ')'  AS SubEvalName
	,eval.EmplID + '@boston.k12.ma.us' as  SubEvalMailAddr
	,d.DeptName As SchoolName
	,ep.PlanID
	,ep.PlanStartDt
	,ep.PlanSchedEndDt 
	,REPLACE(cast(se.Message as nvarchar(max)), '[date stamp]', Convert(date, ep.PlanSchedEndDt)) as Message
FROM EmplPlan ep
JOIN EmplEmplJob ej On ej.EmplJobID = ep.EmplJobID
LEFT JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID
LEFT JOIN SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
LEFT JOIN SubEval s (nolock) on ase.SubEvalID = s.EvalID
LEFT JOIN Department d on d.DeptID = ej.DeptID
LEFT JOIN Empl as e (NOLOCK) ON ej.EmplID = e.EmplID
LEFT JOIN Empl as m (NOLOCK) ON m.EmplID = (CASE WHEN ex.MgrID IS NULL 
												 THEN ej.MgrID
												 ELSE ex.MgrID END)												  	 
LEFT JOIN Empl as eval (NOLOCK) ON eval.EmplID = s.EmplID											 
CROSS JOIN StdEmail as se (NOLOCK)
WHERE ep.PlanActive = 1 
AND Convert(date,ep.PlanSchedEndDt) = Convert(date,DATEADD(week,6,GETDATE()))
AND se.FuncCall = 'sumatvRprt'











GO
