SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/29/2013
-- Description:	Observation detail report
-- =============================================
CREATE VIEW [dbo].[ObservationDetails]
AS
	select 
		cast(oh.ObsvDt as date) as ObsrevationDate
		,c.NameLast + ', ' + c.NameFirst + ' ' + ISNULL(c.NameMiddle, '') AS CreatedByName
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmployeeName
		,m.NameLast + ', ' + m.NameFirst + ' ' + ISNULL(m.NameMiddle, '') AS ManagerName
		,(SELECT s.NameLast + ', ' + s.NameFirst + ' ' + ISNULL(s.NameMiddle, '') FROM Empl s where s.EmplID = (CASE WHEN se.EmplID IS NOT NULL THEN se.EmplID 
																									WHEN PrimaryEmplJobTable.managerID IS NOT NULL THEN PrimaryEmplJobTable.managerID
																									ELSE (case When (emplex.MgrID IS NOT NULL)
																										then emplex.MgrID
																									else ej.MgrID  
																									end) END)) AS SubevaluatorName
		,d.DeptName
		,dc.CodeText as DepartmentCategory
		,pt.CodeText as PlanType
		,ot.CodeText as ObservationType
		,oh.ObsvSubject		
		,DATEDIFF(N,oh.ObsvStartTime, oh.ObsvEndTime) as Duration
		,STUFF((SELECT
						CAST(ri.IndicatorText AS nvarchar(max))+','
					FROM
						RubricIndicator as ri						
					join ObservationDetailRubricIndicator as odr on odr.IndicatorID = ri.IndicatorID											
					join ObservationDetail od on od.ObsvDID = odr.ObsvDID
					Where 
						od.ObsvID = oh.ObsvID and odr.IsDeleted = 0 and od.IsDeleted = 0
					For XML PATH ('')), 1, 0,'')  AS Tags		
		,STUFF((SELECT
					CAST(ISNULL(od.ObsvDEvidence,'') AS nvarchar(max))+','
					FROM ObservationDetail as od
					Where 
						od.ObsvID = oh.ObsvID
					For XML PATH ('')), 1, 0,'')  AS ObservationEvidence
		,STUFF((SELECT
						CAST(ISNULL(od.ObsvDFeedBack,'') AS nvarchar(max))+','
					FROM ObservationDetail as od
					Where 
						od.ObsvID = oh.ObsvID
					For XML PATH ('')), 1, 0,'')  AS ObservationFeedBack					
		,oh.ObsvID									
	from
		ObservationHeader as oh	
	left join CodeLookUp as ot on oh.ObsvTypeID = ot.CodeID
	left join Empl as c on oh.CreatedByID = c.EmplID
	join EmplPlan as p on oh.PlanID = p.PlanID and p.IsInvalid = 0
	join CodeLookUp as pt on p.PlanTypeID = pt.CodeID
	join EmplEmplJob as ej on p.EmplJobID = ej.EmplJobID
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	left join Empl as m on m.EmplID = (case When (emplex.MgrID IS NOT NULL)
											then emplex.MgrID
											else ej.MgrID  
										end)
	left join SubevalAssignedEmplEmplJob as seaeej on ej.EmplJobID = seaeej.EmplJobID and seaeej.IsPrimary = 1 and seaeej.IsActive=1 and seaeej.IsDeleted = 0
	left join SubEval as se on seaeej.SubEvalID = se.EvalID and se.EvalActive = 1
	LEFT JOIN (SELECT (CASE WHEN ex.MgrID IS NOT NULL THEN ex.MgrID ELSE ej1.MgrID end)as managerID, ej1.EmplJobID,ej1.EmplID
                 FROM EmplEmplJob ej1
                 LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej1.EmplJobID 
                 WHERE ej1.EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej1.EmplID)) as PrimaryEmplJobTable on PrimaryEmplJobTable.EmplID = ej.EmplID	
	join Empl as e on ej.EmplID = e.EmplID	
	join Department as d on ej.DeptID = d.DeptID
	left join CodeLookUp as dc on d.DeptCategoryID = dc.CodeID
	where
		oh.IsDeleted = 0 AND oh.ObsvRelease = 1 
		

		
GO
