SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/28/2013
-- Description:	Arifact detail report
-- =============================================
CREATE VIEW [dbo].[ArtifactDetails]
AS
	select distinct
		ev.EvidenceID
		,cast(ev.CreatedByDt as date) as UploadDate
		,c.NameLast + ', ' + c.NameFirst + ' ' + ISNULL(c.NameMiddle, '') AS CreatedByName
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmployeeName
		,m.NameLast + ', ' + m.NameFirst + ' ' + ISNULL(m.NameMiddle, '') AS ManagerName
		,s.NameLast + ', ' + s.NameFirst + ' ' + ISNULL(s.NameMiddle, '') AS SubevaluatorName
		,d.DeptName
		,dc.CodeText as DepartmentCategory
		,pt.CodeText as PlanType
		,SUBSTRING((SELECT
						',' + CAST(rs.StandardText AS nvarchar)
					FROM
						RubricStandard as rs
					join EmplPlanEvidence as sepe on sepe.ForeignID = rs.StandardID
													and sepe.EvidenceTypeID = (select CodeID from CodeLookUp where CodeText = 'Standard Evidence')
					Where 
						sepe.EvidenceID = epe.EvidenceID
					For XML PATH ('')), 2, 9999)  AS StandardTagged
		,SUBSTRING((SELECT
						',' + CAST(ri.IndicatorText AS nvarchar)
					FROM
						RubricIndicator  as ri
					join EmplPlanEvidence as sepe on sepe.ForeignID = ri.IndicatorID
													and sepe.EvidenceTypeID = (select CodeID from CodeLookUp where CodeText = 'Indicator Evidence')
					Where 
						sepe.EvidenceID = epe.EvidenceID
					For XML PATH ('')), 2, 9999)  AS IndicatorTagged
		,SUBSTRING((SELECT
						',' + CAST(gt.CodeText AS nvarchar)
					FROM
						CodeLookUp gt
					left join PlanGoal as pg on pg.GoalTypeID = gt.CodeID
					join EmplPlanEvidence as sepe on sepe.ForeignID = pg.GoalID
													and sepe.EvidenceTypeID = (select CodeID from CodeLookUp where CodeText = 'Goal Evidence')
					Where 
						sepe.EvidenceID = epe.EvidenceID
					For XML PATH ('')), 2, 9999)  AS GoalTagged		
		,ev.Description [Description]				
	from
		Evidence as ev
	join Empl as c on ev.CreatedByID = c.EmplID
	join EmplPlanEvidence as epe on ev.EvidenceID = epe.EvidenceID
	join EmplPlan as p on epe.PlanID = p.PlanID and p.IsInvalid = 0 
	join CodeLookUp as pt on p.PlanTypeID = pt.CodeID
	join EmplEmplJob as ej on p.EmplJobID = ej.EmplJobID
	left join SubevalAssignedEmplEmplJob as seaeej on ej.EmplJobID = seaeej.EmplJobID
	left join SubEval as se on seaeej.SubEvalID = se.EvalID
	left join Empl as s on se.EmplID = s.EmplID
	join Empl as e on ej.EmplID = e.EmplID
	left join Empl as m on ej.MgrID = m.EmplID
	join Department as d on ej.DeptID = d.DeptID
	left join CodeLookUp as dc on d.DeptCategoryID = dc.CodeID
	where
		ev.IsDeleted = 0
		

		
GO
