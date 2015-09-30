SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 08/09/2012
-- Description:	get goal by goalID
-- =============================================
CREATE PROCEDURE [dbo].[getGoalByID]
	@GoalID as int
	
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @GoalTagIDList AS nvarchar(max)
	
	SELECT
		g.GoalID
		,p.PlanID
		,g.GoalYear
		,g.GoalTypeID
		,gt.CodeText AS GoalType
		,g.GoalLevelID
		,gl.CodeText AS GoalLevel
		,g.GoalStatusID
		,gs.CodeText AS GoalStatus
    	,g.GoalText
    	,g.IsDeleted
    	,gep.GoalEvalID
    	,gep.EvalID
    	,gep.ProgressCodeID
    	,gp.CodeText AS ProgressCode
    	,gep.Rationale 
		,SUBSTRING((SELECT
						',' + CAST(gt.GoalTagID AS nvarchar)
					FROM
						GoalTag AS gt
					Where 
						GT.GoalID = g.GoalID
					For XML PATH ('')), 2, 9999)  AS GoalTagIDs
		,SUBSTRING((SELECT
						 ', ' + CAST(c.CodeText AS varchar(50))
					FROM
						GoalTag AS gt
					JOIN CodeLookUp AS c ON gt.GoalTagID = c.CodeID
					Where 
						GT.GoalID = g.GoalID
					For XML PATH ('')), 2, 9999)  AS GoalTagTexts
		,e.EmplID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE ej.MgrID
			END) as MgrID
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') 
			FROM Empl e1 WHERE e1.EmplID  = CASE
												WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
												ELSE ej.MgrID
											END) AS MgrName
		,CASE
			when s.EmplID IS NULL
			THEN CASE
						WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
						ELSE ej.MgrID
					END
			ELSE s.EmplID
		END SubEvalID			
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') 
			FROM Empl e1 WHERE e1.EmplID  = CASE
												when s.EmplID IS NULL
												THEN CASE
															WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
															ELSE ej.MgrID
														END
												ELSE s.EmplID
												END) AS SubEvalName
		,g.CreatedByID
		,ce.NameLast + ', ' + ce.NameFirst + ' ' + ISNULL(ce.NameMiddle, '') AS CreatedBy
	FROM
		EmplPlan AS p (NOLOCK)
	JOIN PlanGoal AS g (NOLOCK)ON p.PlanID = g.PlanID
	JOIN Empl as ce (NOLOCK) ON g.CreatedByID = ce.EmplID
	JOIN EmplEmplJob as ej (NOLOCK) on p.EmplJobID = ej.EmplJobID
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1	
	LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	JOIN Empl as e (NOLOCK) ON ej.EmplID = e.EmplID
	JOIN CodeLookUp as gt (NOLOCK) ON g.GoalTypeID = gt.CodeID
	JOIN CodeLookUp as gl (NOLOCK) ON g.GoalLevelID = gl.CodeID
	JOIN CodeLookUp as gs (NOLOCK) ON g.GoalStatusID = gs.CodeID
	LEFT OUTER JOIN GoalEvaluationProgress as gep (NOLOCK) ON g.GoalID = gep.GoalID
	LEFT OUTER JOIN CodeLookUp as gp (NOLOCK) ON gep.ProgressCodeID = gp.CodeID
	WHERE
		g.IsDeleted = 0
		AND g.GoalID = @GoalID
				
END
GO
