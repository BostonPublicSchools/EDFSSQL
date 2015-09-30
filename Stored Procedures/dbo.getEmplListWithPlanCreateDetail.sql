SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 10/20/2013
-- Description: Based on getEmplList, get all the empls to whom @ncUserId is Primary-Edvaluator and who need new plan to create
--				@UserRoleID : 1(MANAGER) AND 2 ( EVALUATOR )
--				EXEC getEmplListWithPlanCreateDetail '076036',1
-- =============================================
CREATE PROCEDURE [dbo].[getEmplListWithPlanCreateDetail]		
	@ncUserId  nchar(6) 
	,@UserRoleID  int 	
AS
BEGIN
	SET NOCOUNT ON;
--Declare @ncUserId  nchar(6) = '076036'
--Declare @UserRoleID  int = 1	 
IF OBJECT_ID('tempdb..##TMPMYTABLE') IS NOT NULL DROP TABLE #TMPMYTABLE
	;with 
		cte (PlanID, EmplJobId, JobCode, EmplId)
	as
	(
		SELECT
			P.PlanID, ej.EmplJobID, ej.JobCode, ej.EmplId			
		FROM
				EmplEmplJob AS ej (NOLOCK)
			JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
			JOIN EmplPlan AS p (NOLOCK) ON ej.EmplJobID = p.EmplJobID
			JOIN RubricHdr as r (NOLOCK)  ON ej.RubricID = r.RubricID
		WHERE
			ej.IsActive = 1
		AND p.PlanActive = 1
		AND r.Is5StepProcess = 0		
	)

	
	SELECT distinct
		e.EmplID
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE d.MgrID
			END) as MgrID
		,COALESCE( 
					(select top 1 s.EmplID
					from 
						SubevalAssignedEmplEmplJob as ase (nolock) 
					join SubEval s (nolock) on ase.SubEvalID = s.EvalID
					where
						ase.EmplJobID = ej.EmplJobID
					and ase.isActive = 1
					and ase.isDeleted = 0
					and ((ase.IsPrimary = 1 and @UserRoleID = 1) OR (@UserRoleID = 2 and s.EmplID = @ncUserId and ase.IsPrimary=1))) 
			,dbo.funcGetPrimaryManagerByEmplID(e.EmplID) )SubEvalID  --if its manager , then get the primary subeval or if its subeval, then get the matching subeval id.
	
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmplName
		,e.EmplActive
		,ej.EmplJobID
		,ej.RubricID JobRubricID
		,ISNULL(p.PlanActive, 0) AS PlanActive
		,ISNULL(p.PlanTypeID,0) as PlanTypeId
		,(select isnull(CodeText,'') from CodeLookUp where CodeID = p.PlanTypeID) as PlanType
		, p.PlanYear as PlanYear
		,p.IsMultiYearPlan as IsMultiYearPlan				
		,ej.EmplClass
		,j.UnionCode
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN 1
			ELSE 0
			END) as EmplExceptionExists
		,rh.Is5StepProcess
		, (case when @UserRoleID = 1 and @ncUserId =  dbo.funcGetPrimaryManagerByEmplID(e.EmplID)  then 1
				when @UserRoleID = 2 and @ncUserId in(select --top 1
											s.EmplID
										from 
											SubevalAssignedEmplEmplJob as ase (nolock) 
										join SubEval s (nolock) on ase.SubEvalID = s.EvalID
										where
											--ase.EmplJobID = ej.EmplJobID
											ase.EmplJobID in(select EmplJobID from EmplEmplJob where IsActive=1 and EmplID=e.EmplID)
										and ase.isActive = 1
										and ase.isDeleted = 0
										and ase.IsPrimary = 1) 
					then 1 					
				when @UserRoleID = 3
					then 0
				else 0
			 end ) IsPrimaryEvaluator
			,plInActive.MaxPlanID			
			,plInActiveEndRsn.PlanEndReasonText		
			 
	INTO #TMPMYTABLE
	FROM
		Empl			AS e	(NOLOCK)
	JOIN EmplEmplJob	AS ej	(NOLOCK)	ON e.EmplID = ej.EmplID
											AND ej.IsActive = 1
	LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	
	join RubricHdr as rh (nolock) on ej.RubricID = rh.RubricID
	JOIN department     AS d	(NOLOCK)    ON ej.DeptID = d.DeptID
	JOIN EmplJob		AS j	(NOLOCK)	ON ej.JobCode = j.JobCode
	LEFT JOIN (SELECT 
				EmplJobID
				,EmplId
				,JobCode
			FROM
				cte
			WHERE
				PlanID IS NOT NULL) AS c ON ej.EmplID = c.EmplID
	LEFT JOIN EmplPlan AS p (NOLOCK) ON c.EmplJobID = p.EmplJobId 
									 AND p.PlanActive = 1
	LEFT JOIN 
		(
			select max(planid) MaxPlanID,EmplJobID 
			from EmplPlan p 
			where p.PlanActive=0 and p.IsInvalid=0 and p.PlanTypeID in(select CodeID from CodeLookUp where CodeType ='plantype' and CodeActive=1) 
			group by EmplJobID  
		) plInActive on plInActive.EmplJobID = ej.EmplJobID 
	LEFT JOIN (
				select p.PlanID , CodeText [PlanEndReasonText]
				from EmplPlan p 
				inner join CodeLookUp cl on 
							p.PlanEndReasonID= cl.CodeID and 
							CodeType ='PlanEndRsn' and 
							CodeActive =1 and 
							CodeText !='Plan Re-activated' and
							p.IsInvalid = 0
			 )plInActiveEndRsn on plInActiveEndRsn.PlanID = plInActive.MaxPlanID
	
	WHERE
		e.EmplActive = 1 
		And rh.Is5StepProcess=0
	AND (   ((CASE 
					WHEN (emplEx.MgrID IS NOT NULL)
					THEN emplEx.MgrID
					ELSE ej.MgrID
				END = @ncUserId) AND @UserRoleID = 1  )
			OR
			(@ncUserId in (select 
					s.EmplID
				from 
					SubevalAssignedEmplEmplJob as ase (nolock) 
				join SubEval s (nolock) on ase.SubEvalID = s.EvalID
				where
					ase.EmplJobID = ej.EmplJobID					
				and ase.isActive = 1
				and ase.isDeleted = 0) and @UserRoleID = 2)
			OR
			(ej.EmplID = @ncUserId and @UserRoleID = 3)
		)


	SELECT tb.* , ev.EvalID, ev.EvalTypeID, ev.OverallRatingID
		--,(case when ev.OverallRatingID is null then 'NewJob' else 'OldJob' end) NewPlanType
		, (case when ev.OverallRatingID is null then 'NewJob' else 'OldJob' end) NewPlanType
		--, ( CASE 
		--		WHEN tb.MaxPlanID IS NULL OR ev.OverallRatingID IS NULL --New Job
		--			THEN 
		--		WHEN tb.MaxPlanID IS NOT NULL AND TB.PlanEndReasonText='PeopleSoft' -- New Job
		--			THEN		
		--		WHEN tb.MaxPlanID IS NOT NULL AND TB.PlanEndReasonText='Formative Assessment'
		--			THEN
		--		WHEN tb.MaxPlanID IS NOT NULL AND TB.PlanEndReasonText='Formative Evaluation'
		--			THEN					
		--		WHEN tb.MaxPlanID IS NOT NULL AND TB.PlanEndReasonText='Summative Evaluation'
		--			THEN								
		--		WHEN tb.MaxPlanID IS NOT NULL AND TB.PlanEndReasonText='Admin'
		--			THEN							
			
		--	END	)
		,(Case 
				When (SELECT Top 1 Code FROM CODELOOKUP WHERE CodeType ='PlanEndRsn' And CODETEXT = PlanEndReasonText)='EvalEnd'
					then 'EvalEnd'
				When (SELECT Top 1 Code FROM CODELOOKUP WHERE CodeType ='PlanEndRsn' And CODETEXT = PlanEndReasonText)='AdminEnd'
					then 'AdminEnd'
				When (SELECT Top 1 Code FROM CODELOOKUP WHERE CodeType ='PlanEndRsn' And CODETEXT = PlanEndReasonText)='PplSoftEnd'
					then 'PplSoftEnd'										
				Else 'New'
			End) EndType
		
	FROM #TMPMYTABLE tb
		LEFT JOIN Evaluation ev on tb.MaxPlanID = ev.PlanID and ev.IsSigned =1
	WHERE IsPrimaryEvaluator=1 and PlanType is null
	ORDER BY EmplName
	
	
	
IF OBJECT_ID('tempdb..##TMPMYTABLE') IS NOT NULL DROP TABLE #TMPMYTABLE

END
GO
