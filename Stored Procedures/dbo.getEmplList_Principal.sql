SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/17/2012
-- Description:	List employees assigned to a supervisor
-- =============================================
CREATE PROCEDURE [dbo].[getEmplList_Principal]
	@ncUserId AS nchar(6) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		e.EmplID
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE ej.MgrID
			END) as MgrID
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = emplEx.MgrID) 
			ELSE (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = ej.MgrID)
		 END) AS ManagerName
		,CASE
			when s.EmplID IS NULL
			THEN CASE
						WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
						ELSE ej.MgrID
					END
			ELSE s.EmplID
		END SubEvalID			
		,(CASE 
			WHEN  s.EmplID IS NULL THEN CASE 
											WHEN (emplEx.MgrID IS NOT NULL)
											THEN (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = emplEx.MgrID) 
											ELSE (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = ej.MgrID)
										 END
			ELSE (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = s.EmplID) 
			END) AS SubEvalName
		,e.NameFirst
		,e.NameMiddle
		,e.NameLast
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmplName
		,e.EmplActive
		,ej.EmplJobID
		,j.JobCode
		,j.JobName
		,e.NameLast + ' ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' ' + e.EmplID AS Search
		,1 AS PlanCount
		,ISNULL(p.PlanActive, 0) AS PlanActive
		,ISNULL(p.PlanTypeID,0) as PlanTypeId
		,(select isnull(CodeText,'') from CodeLookUp where CodeID = p.PlanTypeID) as PlanType
				,p.IsSignedAsmt
		,p.DateSignedAsmt
		,ISNULL(pc.CodeText, 'None') AS GoalStatus
		,(SELECT COUNT(*) FROM PlanGoal WHERE PlanID = p.PlanID) AS GoalCount
		,e.Sex + e.Race AS EmplImage
	FROM
		Empl			AS e	(NOLOCK)
	JOIN EmplEmplJob	AS ej	(NOLOCK)	ON e.EmplID = ej.EmplID
											and not ej.RubricID in (select RubricID from RubricHdr(NOLOCK) where Is5StepProcess = 0)
											and	e.EmplActive = 1
	JOIN department     AS d	(NOLOCK)    ON ej.DeptID = d.DeptID
	JOIN EmplJob		AS j	(NOLOCK)	ON ej.JobCode = j.JobCode
	--JOIN RptUnionCode	AS ruc	(NOLOCK)		ON j.JobCode = ruc.JobCode
	--										AND ruc.IsActive = 1
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1	
	LEFT OUTER JOIN EmplPlan	AS p (NOLOCK)	ON ej.EmplJobID = p.EmplJobID
												AND p.PlanActive = 1
	LEFT OUTER JOIN CodeLookUp	as pc (NOLOCK)	ON p.GoalStatusID =  pc.CodeID 
	LEFT OUTER JOIN EmplExceptions AS emplEx (NOLOCK) ON emplEx.EmplJobID  = ej.EmplJobID
	WHERE
		(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE ej.MgrID
		END = @ncUserId)
		
END
GO
