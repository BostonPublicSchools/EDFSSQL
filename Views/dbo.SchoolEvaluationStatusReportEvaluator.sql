SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[SchoolEvaluationStatusReportEvaluator]
AS
with T(PlanID,EmplID,EvaluatorID,PlanTypeID,IsMultiYearPlan,PlanActive,DateSignedAsmt,GoalStatusID,PlanStartDt,PlanEndDt)
as
(
select ep.PlanID,eej.EmplID,s.EmplID,ep.PlanTypeID,ep.IsMultiYearPlan,ep.PlanActive,ep.DateSignedAsmt,ep.GoalStatusID,ep.PlanStartDt,ep.PlanSchedEndDt 
from SubevalAssignedEmplEmplJob sae 
join SubEval s on s.EvalID= sae.SubEvalID and s.EvalActive=1 and sae.IsPrimary =1 
join EmplEmplJob eej on eej.EmplJobID = sae.EmplJobID and eej.IsActive=1 
join RubricHdr rh on rh.RubricID = eej.RubricID and rh.Is5StepProcess=1
join EmplPlan ep on ep.EmplJobID = sae.EmplJobID 
)

SELECT	(SELECT top 1 eej.DeptID from EmplEmplJob eej where eej.EmplID = s.EmplID and eej.IsActive=1) as DeptID
		,(SELECT top 1 d.DeptName from Department d join EmplEmplJob eej on eej.DeptID = d.DeptID and eej.EmplID = s.EmplID and eej.IsActive=1) as DeptName 
		, (SELECT 	e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') from Empl e where e.EmplID = (SELECT Top 1 d.MgrID from Department d join EmplEmplJob eej on d.DeptID = eej.DeptID and eej.EmplID = s.EmplID)) as PricipalName
		,(SELECT 	e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') from Empl e where e.EmplID = (SELECT Top 1 d.ImplSpecialistID from Department d join EmplEmplJob eej on d.DeptID = eej.DeptID and eej.EmplID = s.EmplID)) as ImplSpecialist
		,(SELECT 	e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') from Empl e where e.EmplID = s.EmplID)  AS EvaluatorName
		,s.EmplID as EvaluatorID 
		,count(eej.EmplID) as NumberOfEmpl
		,(SELECT COUNT( T.PlanID) from T where T.PlanTypeID =1 and T.EvaluatorID= s.EmplID and T.IsMultiYearPlan =0 and T.PlanActive=1 ) as [Self-Directed 1 year]
		,(SELECT COUNT(T.PlanID) from T where T.PlanTypeID =1 and T.EvaluatorID= s.EmplID and T.IsMultiYearPlan =1 and T.PlanActive=1 ) as [Self-Directed 2 year]
		,(select COUNT(T.PlanID) from T where T.PlanTypeID = 2 and T.EvaluatorID = s.EmplID and T.PlanActive=1 ) as Developing
		,(select COUNT(T.PlanID) from T where T.PlanTypeID = 3 and T.EvaluatorID = s.EmplID and T.PlanActive=1 ) as [Directed Growth]
		,(select COUNT(T.PlanID) from T where T.PlanTypeID = 4 and T.EvaluatorID = s.EmplID and T.PlanActive=1 )as [Improvement]		
		,(SELECT COUNT(tmp1.PlanID) from (SELECT Max(T.PlanID) as PlanID,MAx(CAST(T.PlanActive as int)) as PlanActive,T.EmplID from T where (T.PlanTypeID =1 or T.PlanTypeID=2) and T.EvaluatorID = s.EmplID  group by T.EmplID) as tmp1 where tmp1.PlanActive=0 ) as NeedPlan
		,(SELECT COUNT(T.PlanID) from T where (T.PlanTypeID=1or T.PlanTypeID=2)  and T.EvaluatorID=s.EmplID and T.PlanActive =1 and T.DateSignedAsmt=null ) as NeedToSubmitSelfAssessment
		,(SELECT COUNT(T.PlanID) from T where (T.PlanTypeID=1 or T.PlanTypeID=2)  and T.EvaluatorID=s.EmplID and T.PlanActive =1 and T.GoalStatusID=11 ) as NeedToSubmitGoalsActionSteps
		,(SELECT COUNT(T.PlanID) from T where (T.PlanTypeID=1 or T.PlanTypeID=2)  and T.EvaluatorID=s.EmplID and T.PlanActive =1 and T.GoalStatusID=12 ) as NeedGoalsActionStepsApproved
		--,(SELECT COUNT(T.PlanID) from T where (T.PlanTypeID=1 or T.PlanTypeID=2)  and T.EvaluatorID=s.EmplID and T.PlanActive =1 and T.ActnStepStatusID=112 ) as NeedToSubmitActionSteps
		--,(SELECT COUNT(T.PlanID) from T where (T.PlanTypeID=1 or T.PlanTypeID=2)  and T.EvaluatorID=s.EmplID and T.PlanActive =1 and T.ActnStepStatusID=113 ) as NeedActionStepsApproved
		,(SELECT COUNT(T.PlanID) from T Left join ObservationHeader oh on oh.PlanID = T.PlanID where (T.PlanTypeID=1 or T.PlanTypeID=2)  and T.EvaluatorID=s.EmplID and T.PlanActive =1 and oh.ObsvID =null) as NeedObservation
		,(SELECT COUNT(T.PlanID) from T left join Evaluation eval on eval.PlanID = T.PlanID where (T.PlanTypeID=1 or T.PlanTypeID=2) and T.EvaluatorID=s.EmplID and T.PlanActive =1 and eval.EvalID = null and  T.PlanStartDt <> null and T.GoalStatusID=13) as FormativeCollectEvidence
		,(SELECT COUNT(T.PlanID) from T left join Evaluation eval on eval.PlanID = T.PlanID where (T.PlanTypeID=1 or T.PlanTypeID=2) and T.EvaluatorID=s.EmplID and T.PlanActive =1 and eval.EvalID = null and ( T.PlanStartDt <> null and dbo.GetSchoolWorkingDays('2012-2013', ISNULL(CONVERT(VARCHAR, DATEADD(d, DATEDIFF(d, T.PlanStartDt, T.PlanEndDt) / 2, T.PlanStartDt), 101), ''),GETDATE()) < 10 ) ) as FormativeTargetApproching
		,(SELECT COUNT(T.PlanID) from T left join Evaluation eval on eval.PlanID = T.PlanID where (T.PlanTypeID=1 or T.PlanTypeID=2) and T.EvaluatorID=s.EmplID and T.PlanActive =1 and eval.EvalID = null and ( T.PlanStartDt <> null and ISNULL(CONVERT(VARCHAR, DATEADD(d, DATEDIFF(d, T.PlanStartDt, T.PlanEndDt) / 2, T.PlanStartDt), 101), '') < GETDATE() ) ) as FormativeTargetPassed
		,(SELECT COUNT(T.PlanID) from T left join Evaluation eval on eval.PlanID = T.PlanID where (T.PlanTypeID=1 or T.PlanTypeID=2) and T.EvaluatorID=s.EmplID and T.PlanActive =1 and eval.EvalID <> 85 and eval.EvalID <> null and T.GoalStatusID=13) as SummativeCollectEvidence
		,(SELECT COUNT(T.PlanID) from T left join Evaluation eval on eval.PlanID = T.PlanID where (T.PlanTypeID=1 or T.PlanTypeID=2) and T.EvaluatorID=s.EmplID and T.PlanActive =1 and eval.EvalID <> 85 and dbo.GetSchoolWorkingDays('2012-2013',ISNULL(CONVERT(VARCHAR, T.PlanEndDt, 101), '') , GETDATE()) <10 ) as SummativeTargetApproching
		,(SELECT COUNT(T.PlanID) from T left join Evaluation eval on eval.PlanID = T.PlanID where (T.PlanTypeID=1 or T.PlanTypeID=2) and T.EvaluatorID=s.EmplID and T.PlanActive =1 and eval.EvalID <> 85 and ISNULL(CONVERT(VARCHAR, T.PlanEndDt, 101), '') < GETDATE()) as SummativeTargetPassed
		,(SELECT COUNT(T.PlanID) from T left join Evaluation eval on eval.PlanID = T.PlanID where (T.PlanTypeID=1 or T.PlanTypeID=2) and T.EvaluatorID=s.EmplID and T.PlanActive =1 and eval.EvalID = 85 and dbo.GetSchoolWorkingDays('2012-2013',ISNULL(CONVERT(VARCHAR, eval.EvaluatorSignedDt, 101), '') , GETDATE()) <50) as RestartCycle
		,(SELECT COUNT(oh.ObsvID) from T left join ObservationHeader oh on oh.PlanID = T.PlanID where  T.EvaluatorID = s.EmplID and oh.CreatedByID= s.EmplID and t.PlanActive =1   )  as TotalObservations
		,(SELECT COUNT(eval.EvalID) from T left join Evaluation eval on eval.PlanID = T.PlanID where  T.EvaluatorID=s.EmplID and T.PlanActive =1 and eval.IsDeleted=0 and eval.EvalID <> 85 ) as TotalFormative
		,(SELECT COUNT(eval.EvalID) from T left join Evaluation eval on eval.PlanID = T.PlanID where  T.EvaluatorID=s.EmplID and  eval.IsDeleted=0 and eval.EvalID = 85 ) as TotalSummative

FROM SubevalAssignedEmplEmplJob sae 
join SubEval s (NOLOCK) ON sae.SubEvalID = s.EvalID and  s.EvalActive =1 and s.Is5StepProcess = 1 and sae.IsPrimary = 1
join EmplEmplJob eej (nolock) on eej.EmplJobID = sae.EmplJobID and eej.IsActive=1
join RubricHdr rh (nolock) on rh.RubricID= eej.RubricID and rh.Is5StepProcess=1

group by s.EmplID,sae.IsPrimary




GO
