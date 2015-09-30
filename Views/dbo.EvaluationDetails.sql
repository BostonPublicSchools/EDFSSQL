SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/* =============================================
 Author:		Newa,Matina
 Create date: 03/25/2013
 Description:	View for Evaluation Detail 
				SELECT top 100 * FROM [EvaluationDetails] WHERE EMPLID='103342'
 =============================================*/
CREATE VIEW [dbo].[EvaluationDetails]
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
			JOIN EmplPlan AS p (NOLOCK) ON ej.EmplJobID = p.EmplJobID and p.IsInvalid = 0 
	)
	
	select 
		ev.EvalID
		,ev.EvaluatorSignedDt [EvaluationReleaseDate]
		,cd.CodeText [EvaluationType]
		,c.planid
		,C.EmplID		
		,(SELECT
				NameLast + ', ' + NameFirst + ' ' + ISNULL(NameMiddle, '') + ' (' + EmplID + ')'
			from
				Empl
			where
				EmplID = c.EmplID) as EmplName
		,ev.EvalManagerID as MgrID
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') 
				FROM Empl e1 WHERE e1.EmplID = ev.EvalManagerID) as ManagerName
		,ev.EvalSubEvalID AS SubEvalID
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'')
			 FROM Empl e1 WHERE e1.EmplID = ev.EvalSubEvalID ) as SubEvalName
		,d.DeptName
		,cd_ep.CodeText [PlanType]
		,TBL_SL.Progress [PROGRESS_SL]	
		,TBL_PL.Progress [PROGRESS_PP]
		,esI.RatingText [StandardRatingI]
		,esII.RatingText [StandardRatingII]
		,esIII.RatingText [StandardRatingIII]
		,esIV.RatingText [StandardRatingIV]
		,cd_orate.CodeText [OverallRating]
		,(case 
			when ep.PlanActive = 1 
			then 'Yes' else 'No'
		end) [CurrentPlan]--yes/no - currentPlanEnd		
		,Isnull(CONVERT(varchar, ep.PlanSchedEndDt,101),'') [Schedule Plan End Date]
		,Isnull(CONVERT(varchar, ep.PlanActEndDt,101),'') [Actual Plan End Date]
		,Isnull((select top 1 CodeText from  CodeLookUp c where ep.PlanEndReasonID=c.CodeID and c.CodeType='PlanEndRsn'),'') [End Reason]
		,ev.EvaluatorsSignature
	FROM 
		Evaluation ev (NOLOCK)
	JOIN cte c	on ev.PlanID = c.planid
	JOIN CodeLookUp cd (NOLOCK) ON  cd.CodeID = ev.EvalTypeID
	join EmplEmplJob ej (NOLOCK) on c.EmplJobID = ej.EmplJobID
	join Department d (NOLOCK) on ej.DeptID = d.DeptID
	LEFT JOIN EmplExceptions AS emplEx(NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	JOIN EmplPlan ep (NOLOCK) ON c.PlanID = ep.PlanID and ep.IsInvalid = 0 
	JOIN CodeLookUp cd_ep (NOLOCK) ON  cd_ep.CodeID = ep.PlanTypeID
	LEFT JOIN (SELECT
					EvalID
					,GoalTypeID
					,STUFF((SELECT 
								', ' + GoalTypeText + '-' + CAST(CodeText AS VARCHAR) 
							FROM 
								EvaluationGoals egl 
							LEFT JOIN CodeLookUp cdProg on cdProg.CodeID = egl.ProgressCodeID
							WHERE 
								(EvalID=Results.EvalID and GoalTypeID = Results.GoalTypeID) 
							FOR XML PATH ('')),1,2,'') AS Progress
				FROM
					EvaluationGoals Results
				WHERE 
					GoalTypeID = 7
				GROUP BY
					EvalID
					,GoalTypeID) TBL_PL ON TBL_PL.EvalID = EV.EvalID 
	LEFT JOIN (SELECT
					EvalID
					,GoalTypeID
					,STUFF((SELECT 
								', ' + GoalTypeText + '-' + CAST(CodeText AS VARCHAR) 
							FROM 
								EvaluationGoals egl 
							LEFT JOIN CodeLookUp cdProg on cdProg.CodeID = egl.ProgressCodeID
							WHERE 
								(EvalID=Results.EvalID and GoalTypeID = Results.GoalTypeID) 
							FOR XML PATH ('')),1,2,'') AS Progress
				FROM
					EvaluationGoals Results
				WHERE 
					GoalTypeID = 5
				GROUP BY
					EvalID
					,GoalTypeID) TBL_SL ON TBL_SL.EvalID = EV.EvalID
	LEFT JOIN (select 
					EvalID
					,StandardText
					,RatingText
				from 
					EvaluationStandards 
				where 
					StandardText like 'I.%') esI ON esI.EvalID=ev.EvalID
	LEFT JOIN (select 
					EvalID
					,StandardText
					,RatingText
				from 
					EvaluationStandards 
				where 
					StandardText like 'II.%') esII ON esII.EvalID=ev.EvalID
	LEFT JOIN (select 
					EvalID
					,StandardText
					,RatingText
				from 
					EvaluationStandards 
				where 
					StandardText like 'III.%') esIII ON esIII.EvalID=ev.EvalID
	LEFT JOIN (select 
					EvalID
					,StandardText
					,RatingText
				from 
					EvaluationStandards 
				where 
					StandardText like 'IV.%') esIV ON esIV.EvalID=ev.EvalID															
	LEFT JOIN CodeLookUp cd_orate ON  cd_orate.CodeID = ev.OverallRatingID
	where 
		ev.IsDeleted=0 and ((ev.IsSigned !=0 and ep.PlanActive = 0) OR (ep.PlanActive = 1))
GO
