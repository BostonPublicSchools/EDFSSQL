SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 06/17/2013
-- Description: Generate report on latest evaluation 
-- =============================================

CREATE VIEW [dbo].[ViewEvaluationReportText]
AS
SELECT  
	(SELECT NameLast + ', ' + NameFirst + ' ' + ISNULL(NameMiddle, '') FROM Empl WHERE EmplID = (CASE WHEN ex.MgrID IS NULL THEN ej.MgrID ELSE ex.MgrID END)) as ManagerName
	,ej.MgrID  as ManagerID
	,s.EmplID as EvaluatorID
	,(SELECT NameLast + ', ' + NameFirst + ' ' + ISNULL(NameMiddle, '') FROM Empl WHERE EmplID = s.EmplID) as EvaluatorName
	,e.EmplID as EmplId	
	,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '')  AS EmplName	
	,dept.DeptName AS Department
	,ej.EmplJobID
	,ep.PlanID
	,cdPlanType.CodeText AS CurrentPlan
	,ep.PlanActive
	,eval.EvalID
	,cdEval.CodeText as EvaluationType	
	,eval.EvaluatorSignedDt AS EvaluationReleaseDate	
	,STUFF((SELECT
						CAST(('GoalText:'+pg1.GoalText+' ProgressCode:'+(select codeText from codeLookUp where CodeID = gep.ProgressCodeID)+' Rationale:'+gep.Rationale)as nvarchar(max))+'||'
					FROM PlanGoal pg1 
					LEFT OUTER JOIN GoalEvaluationProgress gep on gep.GoalID = pg1.GoalID and gep.EvalId = FilteredEval.EvalID			
					Where 
						pg1.PlanID = FilteredEval.PlanID and pg1.IsDeleted = 0
						and pg1.GoalTypeID = (SELECT CodeId FROM CodeLookUp WHERE CodeType='GoalType' and CodeText='Student Learning' and CodeSubText = rh.RubricName)
					For XML PATH ('')), 1, 0,'')  AS StudentGoalText	
	,STUFF((SELECT
						CAST(('GoalText:'+pg1.GoalText+' ProgressCode:'+(select codeText from codeLookUp where CodeID = gep.ProgressCodeID)+' Rationale:'+gep.Rationale)as nvarchar(max))+'||'
					FROM PlanGoal pg1 
					LEFT OUTER JOIN GoalEvaluationProgress gep on gep.GoalID = pg1.GoalID  and gep.EvalId = FilteredEval.EvalID		
					Where 
						pg1.PlanID = FilteredEval.PlanID and pg1.IsDeleted = 0
						and pg1.GoalTypeID = (SELECT CodeId FROM CodeLookUp WHERE CodeType='GoalType' and CodeText='Professional Practice' and CodeSubText = rh.RubricName)
					For XML PATH ('')), 1, 0,'')  AS ProfessionalText	
						
	,(SELECT cdlStdRating.CodeText FROM EvaluationStandardRating esr 
	  JOIN RubricStandard rs on rs.StandardID = esr.StandardID and rs.SortOrder = 1
	  JOIN CodeLookUp cdlStdRating on cdlStdRating.CodeID = esr.RatingID
	  WHERE esr.EvalID = eval.EvalID and rs.RubricID = ep.RubricID)  as StandardIRating  
	,STUFF((SELECT CAST(ISNULL(esr.Rationale,'') AS nvarchar(max))+',' FROM EvaluationStandardRating esr 
	  JOIN RubricStandard rs on rs.StandardID = esr.StandardID and rs.SortOrder = 1
	  JOIN CodeLookUp cdlStdRating on cdlStdRating.CodeID = esr.RatingID
	  WHERE esr.EvalID = eval.EvalID and rs.RubricID = ep.RubricID For XML PATH ('')), 1, 0,'')  as Standard1Rationale 	  	
	,STUFF((SELECT CAST(('Prescription: '+epsr.PrscriptionStmt + ' Evidence: '+ epsr.EvidenceStmt +' Problem:'+ epsr.ProblemStmt)  AS nvarchar(max))+'||'
			 FROM EvaluationPrescription epsr 
			JOIN RubricIndicator ri on ri.IndicatorID = epsr.IndicatorID 
			JOIN RubricStandard rs on rs.StandardID = ri.StandardID and rs.RubricID = rh.RubricID		
			WHERE epsr.EvalID =eval.EvalID and rs.SortOrder = 1 and epsr.IsDeleted = 0
		   For XML PATH ('')), 1, 0, '') as Standard1Prescription  	
		   
	,(SELECT cdlStdRating.CodeText FROM EvaluationStandardRating esr 
	  JOIN RubricStandard rs on rs.StandardID = esr.StandardID and rs.SortOrder = 2
	  JOIN CodeLookUp cdlStdRating on cdlStdRating.CodeID = esr.RatingID
	  WHERE esr.EvalID = eval.EvalID and rs.RubricID = ep.RubricID)  as Standard2Rating  
	,STUFF((SELECT CAST(ISNULL(esr.Rationale,'') AS nvarchar(max))+',' FROM EvaluationStandardRating esr 
	  JOIN RubricStandard rs on rs.StandardID = esr.StandardID and rs.SortOrder = 2
	  JOIN CodeLookUp cdlStdRating on cdlStdRating.CodeID = esr.RatingID
	  WHERE esr.EvalID = eval.EvalID and rs.RubricID = ep.RubricID For XML PATH ('')), 1, 0,'')  as Standard2Rationale 	  	
	,STUFF((SELECT CAST(('Prescription: '+epsr.PrscriptionStmt + ' Evidence: '+ epsr.EvidenceStmt +' Problem:'+ epsr.ProblemStmt)  AS nvarchar(max))+'||'
			 FROM EvaluationPrescription epsr 
			JOIN RubricIndicator ri on ri.IndicatorID = epsr.IndicatorID 
			JOIN RubricStandard rs on rs.StandardID = ri.StandardID and rs.RubricID = rh.RubricID		
			WHERE epsr.EvalID =eval.EvalID and rs.SortOrder = 2 and epsr.IsDeleted = 0
		   For XML PATH ('')), 1, 0, '') as Standard2Prescription	
	
	,(SELECT cdlStdRating.CodeText FROM EvaluationStandardRating esr 
	  JOIN RubricStandard rs on rs.StandardID = esr.StandardID and rs.SortOrder = 3
	  JOIN CodeLookUp cdlStdRating on cdlStdRating.CodeID = esr.RatingID
	  WHERE esr.EvalID = eval.EvalID and rs.RubricID = ep.RubricID)  as Standard3Rating  
	,STUFF((SELECT CAST(ISNULL(esr.Rationale,'') AS nvarchar(max))+',' FROM EvaluationStandardRating esr 
	  JOIN RubricStandard rs on rs.StandardID = esr.StandardID and rs.SortOrder = 3
	  JOIN CodeLookUp cdlStdRating on cdlStdRating.CodeID = esr.RatingID
	  WHERE esr.EvalID = eval.EvalID and rs.RubricID = ep.RubricID For XML PATH ('')), 1, 0,'')  as Standard3Rationale 	  	
	,STUFF((SELECT CAST(('Prescription: '+epsr.PrscriptionStmt + ' Evidence: '+ epsr.EvidenceStmt +' Problem:'+ epsr.ProblemStmt)  AS nvarchar(max))+'||'
			 FROM EvaluationPrescription epsr 
			JOIN RubricIndicator ri on ri.IndicatorID = epsr.IndicatorID 
			JOIN RubricStandard rs on rs.StandardID = ri.StandardID and rs.RubricID = rh.RubricID		
			WHERE epsr.EvalID =eval.EvalID and rs.SortOrder = 3 and epsr.IsDeleted = 0
		   For XML PATH ('')), 1, 0, '') as Standard3Prescription	

	,(SELECT cdlStdRating.CodeText FROM EvaluationStandardRating esr 
	  JOIN RubricStandard rs on rs.StandardID = esr.StandardID and rs.SortOrder = 4
	  JOIN CodeLookUp cdlStdRating on cdlStdRating.CodeID = esr.RatingID
	  WHERE esr.EvalID = eval.EvalID and rs.RubricID = ep.RubricID)  as Standard4Rating  
	,STUFF((SELECT CAST(ISNULL(esr.Rationale,'') AS nvarchar(max))+',' FROM EvaluationStandardRating esr 
	  JOIN RubricStandard rs on rs.StandardID = esr.StandardID and rs.SortOrder =4
	  JOIN CodeLookUp cdlStdRating on cdlStdRating.CodeID = esr.RatingID
	  WHERE esr.EvalID = eval.EvalID and rs.RubricID = ep.RubricID For XML PATH ('')), 1, 0,'')  as Standard4Rationale 	  	
	,STUFF((SELECT CAST(('Prescription: '+epsr.PrscriptionStmt + ' Evidence: '+ epsr.EvidenceStmt +' Problem:'+ epsr.ProblemStmt)  AS nvarchar(max))+'||'
			 FROM EvaluationPrescription epsr 
			JOIN RubricIndicator ri on ri.IndicatorID = epsr.IndicatorID 
			JOIN RubricStandard rs on rs.StandardID = ri.StandardID and rs.RubricID = rh.RubricID		
			WHERE epsr.EvalID =eval.EvalID and rs.SortOrder =4 and epsr.IsDeleted = 0
		   For XML PATH ('')), 1, 0, '') as Standard4Prescription		   			   	   	   									
FROM Evaluation eval (NOLOCK)
JOIN (SELECT MAX(evl.EvalID) AS EvalID, ep1.PlanID
				FROM Evaluation evl (NOLOCK)
				JOIN EmplPlan ep1 on evl.PlanID =ep1.PlanID and ep1.IsInvalid = 0
				JOIN EmplEmplJob ej1 on ej1.EmplJobID = ep1.EmplJobID
				JOIn CodeLookUp cdl on cdl.CodeType = 'EvalType' and cdl.CodeText = 'Formative Assessment'
				WHERE evl.IsDeleted = 0 
				GROUP BY evl.EvalID, ep1.PlanID
		Union
		SELECT MAX(evl.EvalID) AS EvalID, ep1.PlanID
				FROM Evaluation evl (NOLOCK)
				JOIN EmplPlan ep1 on evl.PlanID =ep1.PlanID and ep1.IsInvalid = 0
				JOIN EmplEmplJob ej1 on ej1.EmplJobID = ep1.EmplJobID
				JOIn CodeLookUp cdl on cdl.CodeType = 'EvalType' and cdl.CodeText = 'Formative Evaluation'
				WHERE evl.IsDeleted = 0 
				GROUP BY evl.EvalID, ep1.PlanID
		Union
		SELECT MAX(evl.EvalID) AS EvalID, ep1.PlanID
				FROM Evaluation evl (NOLOCK)
				JOIN EmplPlan ep1 on evl.PlanID =ep1.PlanID and ep1.IsInvalid = 0
				JOIN EmplEmplJob ej1 on ej1.EmplJobID = ep1.EmplJobID
				JOIn CodeLookUp cdl on cdl.CodeType = 'EvalType' and cdl.CodeText = 'Summative Evaluation'
				WHERE evl.IsDeleted = 0 
				GROUP BY evl.EvalID, ep1.PlanID) as FilteredEval on FilteredEval.EvalID = eval.EvalID
JOIN CodeLookUp AS cdEval (NOLOCK) on cdEval.CodeID = eval.EvalTypeID	 
JOIN EmplPlan AS ep (NOLOCK) on ep.PlanID = eval.PlanID and ep.IsInvalid = 0 
LEFT JOIN RubricHdr AS rh(NOLOCK) on rh.RubricID = ep.RubricID
JOIN EmplEmplJob AS ej (NOLOCK) on ej.EmplJobID = ep.EmplJobID
LEFT JOIN EmplExceptions AS ex(NOLOCK) on ex.EmplJobID = ej.EmplJobID 
LEFT JOIN Department AS dept(NOLOCK) on dept.DeptID = ej.DeptID
JOIN Empl AS e (NOLOCK) on e.EmplID = ej.EmplID
JOIN CodeLookUp AS cdPlanType (NOLOCK) on cdPlanType.CodeID = ep.PlanTypeID
LEFT JOIN SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
LEFT JOIN SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1									

WHERE e.EmplActive = 1						

GO
