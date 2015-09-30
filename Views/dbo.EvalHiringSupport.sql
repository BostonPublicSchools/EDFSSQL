SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





/* =============================================
 Author:		Newa,Matina
 Create date:   04/9/2013
 Description:	View for Evaluation as HR hiring Support
				SELECT * FROM [EvalHiringSupport] 
 =============================================*/
CREATE VIEW [dbo].[EvalHiringSupport]
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
		 ecl.EmplID
		,EmplName
		,MgrID
		,ManagerName
		,ecl.SubEvalID
		,SubEvalName
		,DeptID
		,DeptName
		--,'' [Primary program area] --ppc.ProgramArea
		,SUBSTRING((SELECT
						'; ' + CAST(( c.CodeText) AS VARCHAR) --[program area]
					FROM PositionProgram pp INNER JOIN CodeLookUp c on pp.ProgramCodeID =c.CodeID 
						where c.CodeType='ProgTitle'
						and pp.IsPrimary = 1
					AND 
						pp.EmplID=ecl.EmplID
					For XML PATH ('')), 2, 9999)  [Primary program area]
					
		,PlanType +' -  '+ ( ( CASE WHEN cast(year(dateadd(day,PlanDuration,0))-1900 as varchar)='0' THEN '' ELSE  cast(year(dateadd(day,PlanDuration,0))-1900 as varchar)+' Year(s) ' END)
			+ ( CASE WHEN cast(month(dateadd(day,PlanDuration,0)) as varchar)='0' THEN '' ELSE cast(month(dateadd(day,PlanDuration,0)) as varchar) + ' Month(s) ' END)
			+ ( CASE WHEN cast(day(dateadd(day,PlanDuration,0)) as varchar)='0' THEN '' ELSE cast(day(dateadd(day,PlanDuration,0)) as varchar) + ' Day(s)' END)
		)[Current educator plan]		
		, (CASE WHEN NOT ISNULL(gs.CodeText,'') = 'Approved' THEN 'Yes' else 'No' end)	[Current Goals approved?]
		,sumOverAllRating [Overall Rating of most recent eval/assessment]
		,sumReleaseDt [Release Date of most recent eval/assessment]  
		,EvalCount [Eval count for the year] 
		,(CASE WHEN ((Overdue='Summative Evaluation' OR Overdue='Formative Evaluation' OR Overdue='Formative Evaluation' ) AND  sumReleaseDt IS NULL )  then 'Yes' else 'No' end) 
			[Eval/Assessment started but not released]
		,(case when CTE.JobCode IN ('S85007','S85007','S85008','S85010','S85011','S85012','S85014','S85015') then 'Yes' else 'No' end) [On leave]
		,'' [Network Superintendent]
	FROM 
		dbo.EvaluatorCaseLoad ecl
		INNER JOIN cte on ecl.EmplID = cte.EmplId
		LEFT JOIN EmplPlan AS p (NOLOCK) ON cte.EmplJobID = p.EmplJobId
								AND p.PlanActive = 1	
		LEFT JOIN CodeLookUp AS gs (NOLOCK) ON p.GoalStatusID = gs.CodeID
		LEFT JOIN (SELECT
					PlanID
					,MAX(EvalID) AS EvalID
				FROM 
					Evaluation (NOLOCK)
				WHERE
					IsSigned = 1
				and IsDeleted = 0
				GROUP BY 
					PlanID) AS  ev ON  cte.PlanID = ev.PlanID					
		LEFT JOIN (SELECT
					ev.EvalID
					,c.CodeText
				FROM 
					Evaluation AS ev (NOLOCK)
				JOIN CodeLookUp AS c (NOLOCK) ON ev.EvalTypeID = c.CodeID) AS  ed ON  ev.EvalID = ed.EvalID 
		--LEFT JOIN ( SELECT pp.EmplID, ( RTRIM(c.code) + ':    ' +c.CodeText) [ProgramArea] 
		--			from  PositionProgram pp INNER JOIN CodeLookUp c on pp.ProgramCodeID =c.CodeID 
		--			where c.CodeType='ProgTitle'
		--		  ) AS ppc ON ppc.EmplID=ecl.EmplID
		 




GO
