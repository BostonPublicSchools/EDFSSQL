SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE View [dbo].[SchoolEvaluationStatusReport-Principal]
AS 
with T(deptID,DeptName,MgrID,ImplSpecialistID,DeptCategoryID,IsSchool,ExceptionMgrID)
as
(
select d.deptID,d.DeptName,d.MgrID,d.ImplSpecialistID ,d.DeptCategoryID,d.IsSchool, null as ExceptionMgrID
from Department d
union
select distinct 0 as deptID,'' as DeptName,'' as MgrID,'' as ImplSpecialistID, 0 as DeptCategoryID,null as IsSchool, ee.MgrID as ExceptionMgrID
from EmplExceptions ee
)

select	tmt.deptID
		,tmt.DeptName as schoolName
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '')  AS PrincipalName
		,(CASE WHEn tmt.ExceptionMgrID is not null --or tmt.ExceptionMgrID <>''
				THEN tmt.ExceptionMgrID
				else tmt.MgrID
				END
		)as MgrID
		,tmt.ImplSpecialistID
		,e1.NameLast + ', ' + e1.NameFirst + ' ' + ISNULL(e1.NameMiddle, '')  AS ImplSpecialist
		,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ee.EmplID) from EmplExceptions ee join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID join RubricHdr rh on rh.RubricID= eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and rh.Is5StepProcess=1 	)
			ELSE (select COUNT(EmplID) from EmplEmplJob eej join RubricHdr rh on rh.RubricID= eej.RubricID  where DeptID = tmt.deptID and rh.Is5StepProcess=1)
			END
		 )as NumberOfEmpl
		 ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and ep.PlanTypeID=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and ISNULL(IsMultiYearPlan,0) =0 )
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID where eej.DeptID = tmt.deptID and ep.PlanTypeID= 1 and eej.IsActive=1 and ep.PlanActive =1 and  rh.Is5StepProcess=1 and ISNULL(IsMultiYearPlan,0) =0)
			END
		 ) as [Self-Directed 1 year]
		,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and ep.PlanTypeID=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and IsMultiYearPlan=1)
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID where eej.DeptID = tmt.deptID and ep.PlanTypeID= 1 and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and IsMultiYearPlan=1)
			END
		 ) as [Self-Directed 2 year]
		 ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and ep.PlanTypeID=2 and ep.PlanActive =1 and rh.Is5StepProcess=1)
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID  left join RubricHdr rh on rh.RubricID = eej.RubricID where eej.DeptID = tmt.deptID and ep.PlanTypeID= 2 and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1)
			END
		 ) as [Developing]
		 ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and ep.PlanTypeID=3 and ep.PlanActive =1 and rh.Is5StepProcess=1)
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID where eej.DeptID = tmt.deptID and ep.PlanTypeID= 3 and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1)
			END
		 ) as [Directed Growth]
		 ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and ep.PlanTypeID=4 and ep.PlanActive =1 and rh.Is5StepProcess=1)
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID where eej.DeptID = tmt.deptID and ep.PlanTypeID= 4 and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1)
			END
		 ) as [Improvement]
		 ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(eej.EmplID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 )  and ep.PlanActive =0 and rh.Is5StepProcess=1)
			ELSE (select COUNT(eej.EmplID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID where eej.DeptID = tmt.deptID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and eej.IsActive=1 and ep.PlanActive =0 and rh.Is5StepProcess=1)
			END
		 ) as NeedPlan
		  ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 )  and ep.PlanActive =1  and rh.Is5StepProcess=1 and ep.DateSignedAsmt = null)
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID where eej.DeptID = tmt.deptID and (ep.PlanTypeID=1 or ep.PlanTypeID=2) and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and ep.DateSignedAsmt = null)
			END
		 ) as NeedToSubmitSelfAssessment
		   ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 )  and ep.PlanActive =1  and rh.Is5StepProcess=1 and ep.GoalStatusID = 11)
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID where eej.DeptID = tmt.deptID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and ep.GoalStatusID = 11)
			END
		 ) as NeedToSubmitGoalsActionSteps
		 ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 )  and ep.PlanActive =1  and rh.Is5StepProcess=1 and ep.GoalStatusID = 12)
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID where eej.DeptID = tmt.deptID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and ep.GoalStatusID = 12)
			END
		 ) as NeedGoalsActionStepsApproved
		 --,(CASE WHEN tmt.DeptID =0
			--THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 )  and ep.PlanActive =1  and rh.Is5StepProcess=1 )
			--ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID where eej.DeptID = tmt.deptID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and ep.ActnStepStatusID = 112)
			--END
		 --) as NeedToSubmitActionSteps
		 --,(CASE WHEN tmt.DeptID =0
			--THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID where ee.MgrID = tmt.ExceptionMgrID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 )  and ep.PlanActive =1  and rh.Is5StepProcess=1 and ep.ActnStepStatusID = 113)
			--ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID where eej.DeptID = tmt.deptID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and ep.ActnStepStatusID = 113)
			--END
		 --) as NeedActionStepsApproved
		,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join ObservationHeader oh on oh.PlanID = ep.PlanID where ee.MgrID = tmt.ExceptionMgrID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 )  and ep.PlanActive =1  and rh.Is5StepProcess=1  and oh.ObsvID = null)
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join ObservationHeader oh on oh.PlanID = ep.PlanID where eej.DeptID = tmt.deptID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and oh.ObsvID = null)
			END
		 ) as NeedAnObservation		
		   ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID  where ee.MgrID = tmt.ExceptionMgrID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and ep.GoalStatusID=13  and ep.PlanActive =1  and rh.Is5StepProcess=1  and e.EvalID = null and  ( ep.PlanStartDt IS NOT NULL ))
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID where eej.DeptID = tmt.deptID  and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and ep.GoalStatusID=13 and e.EvalID = null and ( ep.PlanStartDt IS NOT NULL ))
			END
		 ) as FormativeCollectEvidence	
		  ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID  where ee.MgrID = tmt.ExceptionMgrID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 )  and ep.PlanActive =1  and rh.Is5StepProcess=1  and e.EvalID = null and  ( ep.PlanStartDt IS NOT NULL and dbo.GetSchoolWorkingDays('2012-2013', ISNULL(CONVERT(VARCHAR, DATEADD(d, DATEDIFF(d, ep.PlanStartDt, ep.PlanSchedEndDt) / 2, ep.PlanStartDt), 101), ''),GETDATE()) < 10 ))
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID where eej.DeptID = tmt.deptID  and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and e.EvalID = null and ( ep.PlanStartDt IS NOT NULL and dbo.GetSchoolWorkingDays('2012-2013', ISNULL(CONVERT(VARCHAR, DATEADD(d, DATEDIFF(d, ep.PlanStartDt, ep.PlanSchedEndDt) / 2, ep.PlanStartDt), 101), ''),GETDATE()) < 10 ))
			END
		 ) as FormativeTargetApproching			
		 ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID  where ee.MgrID = tmt.ExceptionMgrID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 )  and ep.PlanActive =1  and rh.Is5StepProcess=1  and e.EvalID = null and  ( ep.PlanStartDt IS NOT NULL and ISNULL(CONVERT(VARCHAR, DATEADD(d, DATEDIFF(d, ep.PlanStartDt, ep.PlanSchedEndDt) / 2, ep.PlanStartDt), 101), '') < GETDATE() ) )
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID where eej.DeptID = tmt.deptID  and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and e.EvalID = null and ( ep.PlanStartDt IS NOT NULL and ISNULL(CONVERT(VARCHAR, DATEADD(d, DATEDIFF(d, ep.PlanStartDt, ep.PlanSchedEndDt) / 2, ep.PlanStartDt), 101), '') < GETDATE() ))
			END
		 ) as FormativeTargetPassed		
		  ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID  where ee.MgrID = tmt.ExceptionMgrID   and ep.PlanActive =1 and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and ep.GoalStatusID=13 and rh.Is5StepProcess=1 and  e.EvalTypeID <> 85  and e.EvalID <> null )
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID where eej.DeptID = tmt.deptID  and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1  and  (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and ep.GoalStatusID=13 and e.EvalTypeID <> 85 and e.EvalID <> null)
			END
		 ) as SummativeCollectEvidence
		 ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID  where ee.MgrID = tmt.ExceptionMgrID   and ep.PlanActive =1 and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and rh.Is5StepProcess=1 and  e.EvalTypeID <> 85 and dbo.GetSchoolWorkingDays('2012-2013',ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101), '') , GETDATE()) <10 )
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID where eej.DeptID = tmt.deptID  and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1  and  (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and e.EvalTypeID <> 85  and e.EvalID <> null and dbo.GetSchoolWorkingDays('2012-2013',ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101), '') , GETDATE()) <10  )
			END
		 ) as SummativeTargetApproching
		 ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID  where ee.MgrID = tmt.ExceptionMgrID and (ep.PlanTypeID=1 or ep.PlanTypeID=2 )  and ep.PlanActive =1  and rh.Is5StepProcess=1 and  e.EvalTypeID <> 85 and ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101), '') < GETDATE() )
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID where eej.DeptID = tmt.deptID  and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1 and (ep.PlanTypeID=1 or ep.PlanTypeID=2 ) and  e.EvalTypeID <> 85  and e.EvalID <> null and ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt, 101), '') < GETDATE() )
			END
		 ) as SummativeTargetPassed	
		 ,(CASE WHEN tmt.DeptID =0
			THEN (select COUNT(ep.PlanID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID  where ee.MgrID = tmt.ExceptionMgrID   and ep.PlanActive =1  and rh.Is5StepProcess=1 and  e.EvalTypeID = 85 and dbo.GetSchoolWorkingDays('2012-2013',ISNULL(CONVERT(VARCHAR, e.EvaluatorSignedDt, 101), '') , GETDATE()) <50 )
			ELSE (select COUNT(ep.PlanID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID where eej.DeptID = tmt.deptID  and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1  and  e.EvalTypeID = 85 and dbo.GetSchoolWorkingDays('2012-2013',ISNULL(CONVERT(VARCHAR, e.EvaluatorSignedDt, 101), '') , GETDATE()) <50 )
			END
		 ) as RestartCycle
		 ,(CASE WHEN tmt.deptID =0
			THEN (select COUNT(oh.ObsvID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join ObservationHeader oh on oh.PlanID = ep.PlanID  where ee.MgrID = tmt.ExceptionMgrID   and ep.PlanActive =1  and rh.Is5StepProcess=1 and oh.CreatedByID =tmt.ExceptionMgrID and oh.IsDeleted=0   )
			ELSE (select COUNT(oh.ObsvID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join ObservationHeader oh on oh.PlanID = ep.PlanID where eej.DeptID = tmt.deptID  and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1  and oh.CreatedByID =tmt.ExceptionMgrID and oh.IsDeleted=0  )
			END
		 ) as TotalObservations
		 ,(CASE WHEN tmt.deptID =0
			THEN (SELECT AVG(temp.ObsvNum) from  (select COUNT(oh.ObsvID) as ObsvNum,ep.PlanID,oh.CreatedByID from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join ObservationHeader oh on oh.PlanID = ep.PlanID  where ee.MgrID = tmt.ExceptionMgrID   and ep.PlanActive =1  and rh.Is5StepProcess=1 and oh.CreatedByID =tmt.ExceptionMgrID and oh.IsDeleted=0 GROUP by ep.PlanID,oh.CreatedByID  ) as temp)
			ELSE (SELECT AVG(temp.obsvNum) from (select COUNT(oh.ObsvID) as ObsvNum,ep.PlanID,oh.CreatedByID from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join ObservationHeader oh on oh.PlanID = ep.PlanID where eej.DeptID = tmt.deptID  and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1  and oh.CreatedByID =tmt.ExceptionMgrID and oh.IsDeleted=0 GROUP by ep.PlanID,oh.CreatedByID ) as temp)
			END 
		 ) as AvgObservations
		 ,(CASE WHEN tmt.deptID =0
			THEN (select COUNT(e.EvalID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID  where ee.MgrID = tmt.ExceptionMgrID   and ep.PlanActive =1  and rh.Is5StepProcess=1 and  e.EvalTypeID <> 85  and e.IsDeleted =0 )
			ELSE (select COUNT(e.EvalID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID where eej.DeptID = tmt.deptID  and eej.IsActive=1 and ep.PlanActive =1 and rh.Is5StepProcess=1  and  e.EvalTypeID <> 85 and e.IsDeleted =0 )
			END
		  )as TotalFormatives
		 ,(CASE WHEN tmt.deptID =0
			THEN (select COUNT(e.EvalID) from EmplPlan ep left join EmplExceptions ee on ee.EmplJobID = ep.EmplJobID LEFT join EmplEmplJob eej on eej.EmplJobID = ee.EmplJobID LEFT join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID  where ee.MgrID = tmt.ExceptionMgrID     and rh.Is5StepProcess=1 and  e.EvalTypeID = 85  and e.IsDeleted =0 )
			ELSE (select COUNT(e.EvalID) from EmplPlan ep left join EmplEmplJob eej on eej.EmplJobID = ep.EmplJobID left join RubricHdr rh on rh.RubricID = eej.RubricID LEFT join Evaluation e on e.PlanID = ep.PlanID where eej.DeptID = tmt.deptID  and eej.IsActive=1 and   rh.Is5StepProcess=1  and  e.EvalTypeID = 85 and e.IsDeleted =0 and e.IsDeleted=0 )
			END
		  )as TotalSummatives
from T tmt
left join  Empl e WITH (NOLOCK) on (CASE when tmt.ExceptionMgrID is not null --or tmt.ExceptionMgrID<>''
						THEN tmt.ExceptionMgrID
						ELSE tmt.MgrID
						END) = e.EmplID
left join Empl e1 WITH (NOLOCK) on e1.EmplID = tmt.ImplSpecialistID					








GO
