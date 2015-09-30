SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 01/17/2013
-- Description: 
-- =============================================
CREATE View [dbo].[ViewUnderPerformerCaseLoad] 
AS 
SELECT (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = (CASE WHEN emplEx.MgrID IS NOT NULL THEN emplEx.MgrID ELSE ej.MgrID END)) AS ManagerName
                   ,(CASE WHEN emplEx.MgrID IS NOT NULL THEN emplEx.MgrID ELSE ej.MgrID END) AS ManagerID
                   ,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = ej.EmplID) AS EmployeeName
                   ,ej.EmplID AS EmployeeID       
                   ,s.EmplId AS SubEvalID
                   ,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = s.EmplID) AS Evaluator    
                   ,dept.DeptName AS DepartmentName
                   ,dept.DeptID AS DepartmentID                   
                   ,ep.PlanID                   
				   ,(case when ep.IsMultiYearPlan ='true' and ep.PlanTypeID=1 then 'Two Year '
						  when  (ep.IsMultiYearPlan is null or ep.IsMultiYearPlan ='false') and ep.PlanTypeID=1 then 'One Year '
						  else ''
					 end ) + (select isnull(cdl.CodeText,'') from CodeLookUp where CodeID = ep.PlanTypeID) 
					as PlanType		 
                   ,ep.PlanTypeID    
                   ,dbo.funPlanCurrentStatus(ep.PlanID, PlanEval.EvalID) AS CurrentStepStatus
                   ,dbo.funGetExpectedApproach(eval.EvalTypeID, eval.EditEndDt) AS ExpectedApproach                   
                   , ep.AnticipatedEvalWeek AS FormativeTargetWeek                   
                   ,(SELECT top 1(FormativeActualDt) FROM dbo.vwFormativeEvalDt(ep.PlanID) Order by FormativeEvalID desc) AS FormativeActualDate
                   ,ep.PlanStartDt
                   ,ep.PlanSchedEndDt                   
                   ,(select top 1 EvalDt from Evaluation evalSumm where evalSumm.PlanID=ep.PlanID and evalSumm.EvalTypeID in(select CodeID from CodeLookUp where CodeType='EvalType  ' and CodeText='Summative Evaluation') ) SummativeDate
                   --,(select top 1 OverallRatingID from Evaluation evalSumm where evalSumm.PlanID=ep.PlanID and evalSumm.EvalTypeID in(select CodeID from CodeLookUp where CodeType='EvalType  ' and CodeText='Summative Evaluation') ) SummativeRating                   
                   ,(CASE WHEN ep.PlanStartDt IS NULL THEN 0 ELSE DATEDIFF(day, ep.PlanStartDt, ep.PlanSchedEndDt) END) AS PlanDuration                                    
				   --, cdEval.CodeText AS OverallRating
                   , (case when eval.EvalTypeID in(select CodeID from CodeLookUp where CodeType='EvalType' and CodeText like 'Formative%') then cdEval.CodeText else NULL end) AS OverallRating --[FormativeRating]
                   , (case when eval.EvalTypeID in(select CodeID from CodeLookUp where CodeType='EvalType' and CodeText like 'Summative%') then cdEval.CodeText else NULL end) AS SummativeRating --[SummativeRating]
                   
                   ,(SELECT COUNT(ep.PlanID) FROM EmplPlan ep JOIN EmplEmplJob ej1 ON ej1.EmplJobID = ep.EmplJobID AND ej1.EmplID = ej.EmplID and ep.IsInvalid = 0) AS PlanCount
                   , (CASE WHEN PlanEval.EvalCount IS NULL THEN 0 ELSE PlanEval.EvalCount END)AS EvalCount                     
                   ,(SELECT COUNT(obs.ObsvID) FROM ObservationHeader obs WHERE obs.PlanID = ep.PlanID and obs.IsDeleted = 0 and obs.ObsvTypeID = (SELECT CodeID FROM CodeLookUp WHERE CodeText ='Unannounced' AND CodeType = 'ObsvType')) AS AnnouncedObsCount
                   ,(SELECT COUNT(obs.ObsvID) FROM ObservationHeader obs WHERE obs.PlanID = ep.PlanID and obs.IsDeleted = 0 and obs.ObsvTypeID = (SELECT CodeID FROM CodeLookUp WHERE CodeText ='Announced' AND CodeType = 'ObsvType')) AS UnAnnouncedObsCount    
                   ,(SELECT COUNT(*) FROM vwObservationByPlan WHERE PlanID = ep.PlanID AND sortOrder = 1) AS StandardI
                   ,(SELECT COUNT(*) FROM vwObservationByPlan WHERE PlanID = ep.PlanID AND sortOrder = 2) AS StandardII
                   ,(SELECT COUNT(*) FROM vwObservationByPlan WHERE PlanID = ep.PlanID AND sortOrder = 3) AS StandardIII
                   ,(SELECT COUNT(*) FROM vwObservationByPlan WHERE PlanID = ep.PlanID AND sortOrder = 4) AS StandardIV            
                   ,0 AS GoalCount
                   ,ISNULL((SELECT Sum(EvidenceCount) FROM vwArtifactsByEviType WHERE PlanID = ep.PlanID AND sortOrder = 1 AND EvidenceTypeID='109'),0) AS StandardI2
                   ,ISNULL((SELECT Sum(EvidenceCount) FROM vwArtifactsByEviType WHERE PlanID = ep.PlanID AND sortOrder = 2 AND EvidenceTypeID='109'),0) AS StandardII3
                   ,ISNULL((SELECT Sum(EvidenceCount) FROM vwArtifactsByEviType WHERE PlanID = ep.PlanID AND sortOrder = 3 AND EvidenceTypeID='109'),0) AS StandardIII4
                   ,ISNULL((SELECT Sum(EvidenceCount) FROM vwArtifactsByEviType WHERE PlanID = ep.PlanID AND sortOrder = 4 AND EvidenceTypeID='109'),0) AS StandardIV5
                   ,ISNULL((SELECT Sum(EvidenceCount) FROM vwArtifactsByEviType WHERE PlanID = ep.PlanID AND EvidenceTypeID='108'),0) AS Goals3
                   ,((SELECT COUNT(*) FROM vwObservationByPlan WHERE PlanID = ep.PlanID AND sortOrder = 1) + ISNULL((SELECT Sum(EvidenceCount)  FROM vwArtifactsByEviType WHERE PlanID = ep.PlanID AND sortOrder = 1 AND EvidenceTypeID='109'),0)) AS StandardI7
                   ,((SELECT COUNT(*) FROM vwObservationByPlan WHERE PlanID = ep.PlanID AND sortOrder = 2) + ISNULL((SELECT Sum(EvidenceCount)  FROM vwArtifactsByEviType WHERE PlanID = ep.PlanID AND sortOrder = 2 AND EvidenceTypeID='109'),0)) AS StandardI8
                   ,((SELECT COUNT(*) FROM vwObservationByPlan WHERE PlanID = ep.PlanID AND sortOrder = 3) + ISNULL((SELECT Sum(EvidenceCount)  FROM vwArtifactsByEviType WHERE PlanID = ep.PlanID AND sortOrder = 3 AND EvidenceTypeID='109'),0)) AS StandardI9
                   ,((SELECT COUNT(*) FROM vwObservationByPlan WHERE PlanID = ep.PlanID AND sortOrder = 4) + ISNULL((SELECT Sum(EvidenceCount)  FROM vwArtifactsByEviType WHERE PlanID = ep.PlanID AND sortOrder = 4 AND EvidenceTypeID='109'),0)) AS StandardI10
                   ,ISNULL((SELECT SUM(EvidenceCount) FROM vwArtifactsByEviType WHERE PlanID = ep.PlanID AND EvidenceTypeID='108'),0) AS Goals2      
                   ,eval.EvaluatorSignedDt AS ReleasedDt
                   ,(select 	
						--c.PlanID,
						 STUFF(
						 ( Select ', '+' Commented On ' + Convert(varchar,CommentDt,101) + ': ' + dbo.udf_StripHTML( CommentText )
						  from Comment cin where cin.PlanID=c.PlanID
						  for xml path(''))
						 ,1,2,'') as comm
					From Comment c
					where c.CommentTypeID=(select top 1 CodeID from CodeLookUp where CodeType ='ComType' And Code='AdminCom')
					and c.PlanID=ep.PlanID 
					Group by c.PlanID) AS AdminComment
                
FROM EmplPlan ep
JOIN CodeLookUp cdl (NOLOCK) ON cdl.CodeID = ep.PlanTypeID AND (cdl.CodeText = 'Improvement' OR cdl.CodeText ='Directed Growth' or cdl.CodeText='Self-Directed')
JOIN EmplEmplJob ej (NOLOCK) ON ej.EmplJobID = ep.EmplJobID AND ej.IsActive = 1
JOIN Empl e (NOLOCK) ON e.EmplID=ej.EmplID and e.EmplActive=1
LEFT JOIN SubevalAssignedEmplEmplJob AS ase (nolock) ON ej.EmplJobID = ase.EmplJobID
                                                        AND ase.isActive = 1
                                                        AND ase.isDeleted = 0
                                                        AND ase.isPrimary = 1
LEFT JOIN SubEval s (nolock) ON ase.SubEvalID = s.EvalID
                                                      AND s.EvalActive = 1   

LEFT OUTER JOIN EmplExceptions emplEx (NOLOCK) ON emplEx.EmplJobID = ej.EmplJobID
LEFT OUTER JOIN Department dept (NOLOCK) ON dept.DeptID = ej.DeptID                                                                                                                                                   
LEFT OUTER JOIN(SELECT PlanID
                       ,MAX(EvalID) AS EvalID
                       ,COUNT(EvalID) AS EvalCount
                       FROM 
                       Evaluation (NOLOCK)                                  
                       GROUP BY
                       PlanID) AS PlanEval ON PlanEval.PlanID = ep.PlanID                                                                  
LEFT OUTER JOIN Evaluation eval ON eval.EvalID = PlanEval.EvalID  
LEFT OUTER JOIN CodeLookUp cdEval (NOLOCK) ON cdEval.CodeID =  eval.OverallRatingID     
WHERE ep.PlanActive = 1
GO
