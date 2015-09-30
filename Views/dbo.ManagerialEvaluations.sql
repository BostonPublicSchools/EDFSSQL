SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Avery, Bryce
-- Create date: 06/04/2013
-- Description: Managerial Employee Evaluations
-- =============================================
CREATE VIEW [dbo].[ManagerialEvaluations]
AS
	SELECT distinct
		 d.DeptID
		 ,d.DeptName
		,(SELECT ISNULL(e1.NameLast,'') + ', ' + ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' ('+ e1.EmplID + ')'  FROM Empl e1 WHERE e1.EmplID = CASE
																																									when ISNULL(sub.SubEvalID, '') = '' or sub.SubEvalID = '0' or sub.SubEvalID = '000000'  THEN CASE
																																										when ase.SubEvalID IS NULL THEN CASE
																																												WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
																																												ELSE ej.MgrID
																																												END
																																										ELSE s.EmplID
																																										END
																																									ELSE sub.SubEvalID
																																								END) as SubEvalName
		,e.EmplID
	   ,ISNULL(e.NameLast,'') + ', ' + ISNULL(e.NameFirst, '')+ ' ' +ISNULL(e.NameMiddle,'') as EmplName
	   ,ej.EmplRcdNo
	   ,j.JobCode
	   ,j.JobName
	   ,j.UnionCode
	   ,ej.PositionNo
	   ,rh.RubricName
	   ,rh.Is5StepProcess
	   ,'' as PlanType	   
	   ,ed.IsSigned
	   ,(SELECT isnull(CodeText,'') from CodeLookUp where CodeID = ed.EvalTypeID) as EvalType
	   ,(SELECT isnull(CodeText,'') from CodeLookUp where CodeID = ed.OverallRatingID)as overallRating
	   ,ed.EvalDt	
	   ,ed.EditEndDt   
	   ,ed.EvaluatorsSignature
	   ,ed.EvaluatorSignedDt
	   ,ed.EvaluatorSignedDt as EvalRecdDate
		,ej.JobEntryDate as PeoplesoftEntryDate
		,ej.JobEntryDate as JobEffectiveDate
		,null JobReason
		,null JobAction
		,ej.Step as SalStep
		,ej.StepEntryDate as EffectiveDate
		,null Comments
		,ej.JobEntryDate as EntryDate
		,ej.SalaryAdministrationPlan as SalPlan
		,ej.SalaryGrade as Grade
		,ej.SalaryGrade as Tier
		,ej.StepEntryDate as TierDate
		,ej.Step as Step 
		,ej.StepEntryDate as StepEntryDate
		,null EvalMemo
		,null EvalMemoRecvd
	FROM Empl e (NOLOCK)
	JOIN EmplEmplJob AS ej	(NOLOCK) ON e.EmplID = ej.EmplID
									AND ej.IsActive = 1
	JOIN RubricHdr as rh (nolock) on ej.RubricID = rh.RubricID
	JOIN EmplJob as j (nolock) on ej.JobCode = j.JobCode
	join Department as d (nolock) on ej.DeptID = d.DeptID
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
														and ase.isDeleted = 0
														and ase.isPrimary = 1
														and ase.isActive = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
	LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on ej.EmplJobID = emplEx.EmplJobID 
	left JOIN (SELECT
					p.EmplJobID
					,MAX(e.EvalID) AS EvalID
				FROM 
					Evaluation as e (NOLOCK)
				JOIN EmplPlan as p (NOLOCK) on e.PlanID = p.PlanID
											and p.IsInvalid = 0
											and p.PlanSchedEndDt > '06/30/2013'
				WHERE
					e.IsDeleted = 0	
				AND e.IsSigned = 1								
				GROUP BY
					p.EmplJobID) AS  eval ON  ej.EmplJobID = eval.EmplJobID
	LEFT JOIN (Select 
					EmplJobID 
					,SubEvalID
				from 
					EmplPlan
				where
					IsInvalid = 0 and
					PlanSchedEndDt > '06/30/2013') as sub on sub.EmplJobID  = eval.EmplJobID 
	Left JOIN Evaluation AS ed (NOLOCK) ON  Eval.EvalID = ed.EvalID
										AND	ed.IsDeleted = 0
										AND ed.IsSigned = 1 
	WHERE 
		e.EmplActive = 1
	and e.IsContractor = 0
GO
