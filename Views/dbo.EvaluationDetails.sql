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
	WITH 
		cte (PlanID, EmplJobId, JobCode, EmplId, DeptID, UnionCode)
	AS
	(
		SELECT
			P.PlanID, ej.EmplJobID, ej.JobCode, ej.EmplId, ej.DeptID, j.UnionCode
		FROM
				EmplEmplJob AS ej (NOLOCK)
			JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
			JOIN EmplPlan AS p (NOLOCK) ON ej.EmplJobID = p.EmplJobID AND p.IsInvalid = 0 
	)
	
	SELECT 
		ev.EvalID
		,ev.EvaluatorSignedDt [EvaluationReleaseDate]
		,cd.CodeText [EvaluationType]
		,c.planid
		,C.EmplID		
		,(SELECT
				NameLast + ', ' + NameFirst + ' ' + ISNULL(NameMiddle, '') + ' (' + EmplID + ')'
			FROM
				Empl
			WHERE
				EmplID = c.EmplID) AS EmplName
		,ev.EvalManagerID AS MgrID
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') 
				FROM Empl e1 WHERE e1.EmplID = ev.EvalManagerID) AS ManagerName
		,ev.EvalSubEvalID AS SubEvalID
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'')
			 FROM Empl e1 WHERE e1.EmplID = ev.EvalSubEvalID ) AS SubEvalName
		,d.DeptName
		,cd_ep.CodeText [PlanType]
		,TBL_SL.Progress [PROGRESS_SL]	
		,TBL_PL.Progress [PROGRESS_PP]
		,esI.RatingText [StandardRatingI]
		,esII.RatingText [StandardRatingII]
		,esIII.RatingText [StandardRatingIII]
		,esIV.RatingText [StandardRatingIV]
		,cd_orate.CodeText [OverallRating]
		,(CASE 
			WHEN ep.PlanActive = 1 
			THEN 'Yes' ELSE 'No'
		END) [CurrentPlan]--yes/no - currentPlanEnd		
		,ISNULL(CONVERT(VARCHAR, ep.PlanSchedEndDt,101),'') [Schedule Plan End Date]
		,ISNULL(CONVERT(VARCHAR, ep.PlanActEndDt,101),'') [Actual Plan End Date]
		,ISNULL((SELECT TOP 1 CodeText FROM  CodeLookUp c WHERE ep.PlanEndReasonID=c.CodeID AND c.CodeType='PlanEndRsn'),'') [End Reason]
		,ev.EvaluatorsSignature
		,c.UnionCode
		,c.JobCode
		,c.DeptID
	FROM 
		Evaluation ev (NOLOCK)
	JOIN cte c	ON ev.PlanID = c.planid
	JOIN CodeLookUp cd (NOLOCK) ON  cd.CodeID = ev.EvalTypeID
	JOIN EmplEmplJob ej (NOLOCK) ON c.EmplJobID = ej.EmplJobID
	JOIN Department d (NOLOCK) ON ej.DeptID = d.DeptID
	LEFT JOIN EmplExceptions AS emplEx(NOLOCK) ON emplEx.EmplJobID = ej.EmplJobID
	JOIN EmplPlan ep (NOLOCK) ON c.PlanID = ep.PlanID AND ep.IsInvalid = 0 
	JOIN CodeLookUp cd_ep (NOLOCK) ON  cd_ep.CodeID = ep.PlanTypeID
	LEFT JOIN (SELECT
					EvalID
					,GoalTypeID
					,STUFF((SELECT 
								', ' + GoalTypeText + '-' + CAST(CodeText AS VARCHAR) 
							FROM 
								EvaluationGoals egl 
							LEFT JOIN CodeLookUp cdProg ON cdProg.CodeID = egl.ProgressCodeID
							WHERE 
								(EvalID=Results.EvalID AND GoalTypeID = Results.GoalTypeID) 
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
							LEFT JOIN CodeLookUp cdProg ON cdProg.CodeID = egl.ProgressCodeID
							WHERE 
								(EvalID=Results.EvalID AND GoalTypeID = Results.GoalTypeID) 
							FOR XML PATH ('')),1,2,'') AS Progress
				FROM
					EvaluationGoals Results
				WHERE 
					GoalTypeID = 5
				GROUP BY
					EvalID
					,GoalTypeID) TBL_SL ON TBL_SL.EvalID = EV.EvalID
	LEFT JOIN (SELECT 
					EvalID
					,StandardText
					,RatingText
				FROM 
					EvaluationStandards 
				WHERE 
					StandardText LIKE 'I.%') esI ON esI.EvalID=ev.EvalID
	LEFT JOIN (SELECT 
					EvalID
					,StandardText
					,RatingText
				FROM 
					EvaluationStandards 
				WHERE 
					StandardText LIKE 'II.%') esII ON esII.EvalID=ev.EvalID
	LEFT JOIN (SELECT 
					EvalID
					,StandardText
					,RatingText
				FROM 
					EvaluationStandards 
				WHERE 
					StandardText LIKE 'III.%') esIII ON esIII.EvalID=ev.EvalID
	LEFT JOIN (SELECT 
					EvalID
					,StandardText
					,RatingText
				FROM 
					EvaluationStandards 
				WHERE 
					StandardText LIKE 'IV.%') esIV ON esIV.EvalID=ev.EvalID															
	LEFT JOIN CodeLookUp cd_orate ON  cd_orate.CodeID = ev.OverallRatingID
	WHERE 
		ev.IsDeleted=0 AND ((ev.IsSigned !=0 AND ep.PlanActive = 0) OR (ep.PlanActive = 1))

GO
