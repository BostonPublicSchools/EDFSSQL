SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Avery, Bryce
-- Create date: 10/17/2012
-- Description: Goal Detail Report
-- =============================================
CREATE VIEW [dbo].[GoalDetail]
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
		AND p.PlanActive = 1
	)

SELECT 
		d.DeptID
		,d.DeptName
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
		,see.EmplID as SubEvalID
		,(ISNULL(see.NameFirst, '')+ ' ' +ISNULL(see.NameMiddle,'')+ ' '+ISNULL(see.NameLast,'')) AS SubEvalName
		,ej.EmplID as EmplID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  AS EmplName		
		,(case when p.IsMultiYearPlan ='true' and p.PlanTypeID=1 then 'Two Year '
			when  (p.IsMultiYearPlan is null or p.IsMultiYearPlan ='false') and p.PlanTypeID=1 then 'One Year '
			else ''
			end ) + (select isnull(pt.CodeText,'') from CodeLookUp where CodeID = p.PlanTypeID) 
		 as PlanType
		,gt.CodeText AS GoalType
		,pl.CodeText AS GoalLevel
		,SUBSTRING((SELECT
						 ', ' + CAST(c.CodeText AS varchar(50))
					FROM
						GoalTag AS gt
					JOIN CodeLookUp AS c ON gt.GoalTagID = c.CodeID
					Where 
						GT.GoalID = g.GoalID
					For XML PATH ('')), 2, 9999)  AS GoalTagTexts
		
		,g.GoalText as GoalText
		,(Case When g.GoalYear=1 and p.IsMultiYearPlan ='true' and p.PlanTypeID=1 
				Then 'Year I' 
			   When g.GoalYear=2 and p.IsMultiYearPlan ='true' and p.PlanTypeID=1  
				Then 'Year II' 
			Else '' End) AS [Goal Year]
		, gs.CodeText as GoalStatus
		, p.GoalFirstSubmitDt as GoalSubmittedDate
		, Convert(Varchar, g.GoalApprovedDt,101) AS [Goal Approved Date]
FROM
		EmplEmplJob AS ej (NOLOCK)								
	JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
	JOIN Department AS d (NOLOCK) On ej.DeptID = d.DeptID
	LEFT OUTER JOIN CodeLookUp As dc (NOLOCK) ON d.DeptCategoryID = dc.CodeID	
	JOIN Empl AS e (NOLOCK) ON ej.EmplID = e.EmplID
							AND e.EmplActive = 1
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	JOIN (SELECT 
				EmplJobID
				,EmplId
				,JobCode
			FROM
				cte
			WHERE
				PlanID IS NOT NULL) AS c ON ej.EmplID = c.EmplId
	JOIN EmplPlan AS p (NOLOCK) ON c.EmplJobID = p.EmplJobId
								AND p.PlanActive = 1
	JOIN CodeLookUp As pt (NOLOCK) ON p.PlanTypeID = pt.CodeID
	JOIN PlanGoal AS g (NOLOCK) ON p.PlanID = g.PlanID
								AND g.GoalStatusID IN (SELECT CodeID from CodeLookUp (NOLOCK) where CodeText in ('Approved', 'Returned','Awaiting Approval') and CodeType = 'GoalStatus')
								AND g.IsDeleted = 0
	JOIN CodeLookUp As pl (NOLOCK) ON g.GoalLevelID = pl.CodeID
	JOIN CodeLookUp as gt (NOLOCK) ON g.GoalTypeID = gt.CodeID
	JOIN CodeLookUp AS gs (NOLOCK) ON gs.CodeID = g.GoalStatusID
	LEFT JOIN SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
																	and ase.isActive = 1
																	and ase.isDeleted = 0
																	and ase.isPrimary = 1
	LEFT JOIN SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1
	LEFT JOIN (SELECT (CASE WHEN ex.MgrID IS NOT NULL THEN ex.MgrID ELSE ej1.MgrID end)as managerID, ej1.EmplJobID,ej1.EmplID
                 FROM EmplEmplJob ej1
                 LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej1.EmplJobID 
                 WHERE ej1.EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej1.EmplID)) as PrimaryEmplJobTable on PrimaryEmplJobTable.EmplJobID = ej.EmplJobID	
	LEFT JOIN Empl see on see.EmplID = (CASE WHEN s.EmplID IS NOT NULL THEN s.EmplID 
					 WHEN PrimaryEmplJobTable.managerID IS NOT NULL THEN PrimaryEmplJobTable.managerID
					 ELSE (case When (emplex.MgrID IS NOT NULL)
									then emplex.MgrID
								else ej.MgrID  
								end) END)
WHERE
	e.EmplActive = 1 and ej.IsActive=1
and ej.RubricID in (select RubricID from RubricHdr (NOLOCK) where Is5StepProcess = 1)

GO
