SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 --=============================================
 --Author:		Avery, Bryce
 --Create date: 06/13/2013
 --Description:	EDFS data for EPIMS 
 --=============================================
CREATE VIEW [dbo].[EPIMS]
AS
	with 
		cte (EmplID, EvalID)
	as
	(
		SELECT
			ej.EmplID, max(e.EvalID)
		FROM
				EmplEmplJob AS ej (NOLOCK)
			JOIN EmplPlan AS p (NOLOCK) ON ej.EmplJobID = p.EmplJobID
										and p.IsInvalid = 0
			join Evaluation as e (NOLOCK) on p.PlanID = e.PlanID
										and e.EvalTypeID in (select
																CodeID
															from
																CodeLookUp
															where
																CodeType = 'EvalType'
															and CodeText in ('Formative Evaluation','Summative Evaluation', 'Formative Assessment'))
										and e.IsSigned = 1
		where 
			ej.RubricID in (select 
									RubricID
								from 
									RubricHdr 
								where 
									IsDESELic = 1)
		group by
			ej.EmplID
			
	)
	select
		d.DeptID
		,d.DeptName
		,c.EmplID
		,CONVERT(date,p.PlanStartDt) [PlanStartDate]
		,CONVERT(date,p.PlanSchedEndDt) [PlanScheduled_EndDate]	
		,[SR29 – Summative Eval or Formative Eval Rating] = 
			dbo.funGetStandardCode( 
					clEvalType.CodeText, rh.RubricName, 
					(SELECT isnull(CodeText,'') from CodeLookUp where CodeID = e.OverallRatingID))
		
		,[SR30 – Standard 1 Eval Rating] = 
			dbo.funGetStandardCode(
				clEvalType.CodeText, rh.RubricName,
				(select 
				(SELECT isnull(CodeText,'') from CodeLookUp where CodeID = r.RatingID)
			from
				EvaluationStandardRating as r
			where
				r.StandardID in (select 
										StandardID
									from 
										RubricStandard
									where 
										StandardText like 'I.%' and RubricID = rh.RubricID )
			and	r.EvalID = e.EvalID))  
		,[SR31 – Standard 2 Eval Rating]=
			dbo.funGetStandardCode(
				clEvalType.CodeText, rh.RubricName,
				(select 
				(SELECT isnull(CodeText,'') from CodeLookUp where CodeID = r.RatingID)
			from
				EvaluationStandardRating as r
			where
				r.StandardID in (select 
										StandardID
									from 
										RubricStandard
									where 
										StandardText like 'II.%'  and RubricID = rh.RubricID )
			and	r.EvalID = e.EvalID)) 
		,[SR32 – Standard 3 Eval Rating] = 
			dbo.funGetStandardCode(
				clEvalType.CodeText, rh.RubricName,
				(select 
				(SELECT isnull(CodeText,'') from CodeLookUp where CodeID = r.RatingID)
			from
				EvaluationStandardRating as r
			where
				r.StandardID in (select 
										StandardID
									from 
										RubricStandard
									where 
										StandardText like 'III.%' and RubricID = rh.RubricID)
			and	r.EvalID = e.EvalID))
		,[SR33 – Standard 4 Eval Rating]=
			dbo.funGetStandardCode(
			clEvalType.CodeText, rh.RubricName,
			(select 
				(SELECT isnull(CodeText,'') from CodeLookUp where CodeID = r.RatingID)
			from
				EvaluationStandardRating as r
			where
				r.StandardID in (select 
										StandardID
									from 
										RubricStandard
									where 
										StandardText like 'IV.%' and RubricID = rh.RubricID)
			and	r.EvalID = e.EvalID)) 
		,[SR34 – Impact on Student Learning Growth and Achievement Rating]='99' --Not Applicable
		,[SR35 - Educator Evaluation Plan]= 
			(CASE 
				WHEN clPlanType.CodeText='Developing'
				THEN '01'
				WHEN clPlanType.CodeText='Self-Directed' And (p.IsMultiYearPlan='false' Or p.IsMultiYearPlan IS NULL )
				THEN '02'				
				WHEN clPlanType.CodeText='Self-Directed' And p.IsMultiYearPlan='true' 
				THEN '03'
				WHEN clPlanType.CodeText='Directed Growth'
				THEN '04'
				WHEN clPlanType.CodeText='Improvement'
				THEN '05'
				ELSE '99'
			END)
		,CONVERT(date,e.EvaluatorSignedDt) [Evalutor Signed On]
		--,e.EvalID,clEvalType.CodeText, rh.RubricName
	from
		(SELECT 
			EmplID
			,EvalID
		FROM
			cte) as c
	join Evaluation as e on c.EvalID = e.EvalID
	join EmplPlan as p on e.PlanID = p.PlanID and p.IsInvalid=0
	join EmplEmplJob as ej on p.EmplJobID = ej.EmplJobID
	join Department as d on ej.DeptID = d.DeptID
	join RubricHdr as rh on rh.RubricID =(case when p.RubricID IS not null then p.RubricID else ej.RubricID end )and rh.IsDESELic=1
	join CodeLookUp as clEvalType on e.EvalTypeID = clEvalType.CodeID and clEvalType.CodeType ='EvalType'
	join CodeLookUp as clPlanType on p.PlanTypeID = clPlanType.CodeID and clPlanType.CodeType ='PlanType'
	
	
GO
