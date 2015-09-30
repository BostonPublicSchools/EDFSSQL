SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 --=============================================
 --Author:		Avery, Bryce
 --Create date: 05/29/2014
 --Description:	Data for demographics pie chart report
 --=============================================
CREATE VIEW [dbo].[EducatorDemographics]
AS
	with 
		cte (EmplID, EvalID)
	as
	(
		SELECT
			ej.EmplID, max(e.EvalID)
		FROM
				EmplEmplJob AS ej
			LEFT OUTER JOIN EmplPlan AS p ON ej.EmplJobID = p.EmplJobID
										and p.IsInvalid = 0
										--and (p.PlanEnddt between '07/01/2012' and '06/30/2013'
										--	or p.PlanStartDt between '09/01/2012' and '06/30/2013')
			LEFT OUTER join Evaluation as e on p.PlanID = e.PlanID
									--and e.EvalTypeID in (select
										--						CodeID
										--					from
										--						CodeLookUp
										--					where
										--						CodeType = 'EvalType'
										--					--and CodeText in ('Formative Evaluation','Summative Evaluation')
										--					)
										and e.IsSigned = 1
		--where 
		--	ej.RubricID in (select 
		--							RubricID
		--						from 
		--							RubricHdr 
		--						where 
		--							Is5StepProcess = 1)
		group by
			ej.EmplID
			
	)
	select
		case 
			when d.DeptID is null then (select distinct top 1 DeptID from EmplEmplJob where EmplRcdNo = (select min(EmplRcdNo) from EmplEmplJob where EmplID = e.EmplID group by  EmplID) and EmplID = e.EmplID)
			else d.DeptID 
		end as DeptID
		,case 
			when d.DeptName is null then (select DeptName from Department where DeptID in (select distinct top 1 DeptID from EmplEmplJob where EmplRcdNo = (select min(EmplRcdNo) from EmplEmplJob where EmplID = e.EmplID group by  EmplID) and EmplID = e.EmplID))
			else d.DeptName 
		end as DeptName
		,c.EmplID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName
		,cast(e.BirthDt as date) as BirthDt
		,e.Race
		,e.Sex
		,e.OriginalHireDate
		,cast(ev.EvaluatorSignedDt as date) as EvaluatorSignedDt
		,(SELECT isnull(CodeText,'') from CodeLookUp where CodeID = ev.OverallRatingID)as OverallRating
	from
		Empl as e
	left outer join (SELECT 
				EmplID
				,EvalID
			FROM
				cte) as c on e.EmplID = c.EmplID
	LEFT OUTER join Evaluation as ev on c.EvalID = ev.EvalID
	LEFT OUTER join EmplPlan as p on ev.PlanID = p.PlanID and p.IsInvalid=0
	LEFT OUTER join EmplEmplJob as ej on p.EmplJobID = ej.EmplJobID
	LEFT OUTER join Department as d on ej.DeptID = d.DeptID
	where
		e.IsContractor = 0
	and e.EmplID in (select EmplID from EmplEmplJob)
	and (select distinct top 1 DeptID from EmplEmplJob where EmplRcdNo = (select min(EmplRcdNo) from EmplEmplJob where EmplID = e.EmplID group by  EmplID) and EmplID = e.EmplID) is not null
	
GO
