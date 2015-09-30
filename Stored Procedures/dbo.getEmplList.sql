SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/17/2012
-- Description:	List employees assigned to a supervisor
-- =============================================
CREATE PROCEDURE [dbo].[getEmplList]
	@ncUserId AS nchar(6) = NULL
	,@UserRoleID as int
	--,@IsNonLic as bit = 0 	
AS	
BEGIN
		SET NOCOUNT ON;
	
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
			JOIN RubricHdr as r (NOLOCK)  ON r.RubricID = (CASE WHEN p.RubricID is not null then p.RubricID else ej.RubricID end)
		WHERE
			ej.IsActive = 1
		AND p.PlanActive = 1
		--AND r.Is5StepProcess = @IsNonLic	
	)
	
	SELECT distinct
		e.EmplID
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE d.MgrID
			END) as MgrID
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = emplEx.MgrID) 
			ELSE (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = ej.MgrID)
		 END) AS ManagerName
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
		,e.NameFirst
		,e.NameMiddle
		,e.NameLast
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmplName
		,e.EmplActive
		,ej.EmplJobID
		,rh.RubricID
		,rh.RubricName
		,CASE 
				WHEN ej.MgrID= '000000' OR emplEx.MgrID IS NOT NULL  or e.EmplID in (select MgrID from Department) THEN 'Manager'
				WHEN (SELECT TOP 1
							EmplID
						FROM
							SubEval
						WHERE
							EmplID = e.EmplID and EvalActive =1) IS NOT NULL 
							THEN 'Subevaluator'
				ELSE 'Employee'
			END  AS EmplRoleDesc
		,ej.DeptID
		,d.DeptName
		,j.JobCode
		,j.JobName
		,e.NameLast + ' ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' ' + e.EmplID AS Search
		,1 AS PlanCount
		,ISNULL(p.PlanActive, 0) AS PlanActive
		,ISNULL(p.PlanTypeID,0) as PlanTypeId
		,(select isnull(CodeText,'') from CodeLookUp where CodeID = p.PlanTypeID) as PlanType
		, p.PlanYear as PlanYear
		,p.IsMultiYearPlan as IsMultiYearPlan
		,p.IsSignedAsmt
		,p.DateSignedAsmt
		,(CASE WHEN p.PlanStartDt IS not null then DATEDIFF(day, p.PlanStartDt, p.PlanSchedEndDt) 
		 ELSE 0 END)as Duration
		,ISNULL(pc.CodeText, 'None') AS GoalStatus
		,ISNULL(ac.CodeText, 'None') AS ActionStepStatus
		,(SELECT COUNT(*) FROM PlanGoal WHERE PlanID = p.PlanID and GoalYear=1 and IsDeleted = 0) AS GoalCount
		,(SELECT COUNT(*) FROM ObservationHeader WHERE PlanID = p.PlanID and IsDeleted = 0) AS ObservationCount
		,(SELECT COUNT(*) FROM ObservationHeader WHERE PlanID = p.PlanID and IsDeleted = 0 and CreatedByID=@ncUserId and ObsvRelease=0) AS ObservationUnReleasedCountByEval
		,(SELECT COUNT(*) FROM ObservationHeader WHERE PlanID = p.PlanID and IsDeleted = 0 and ObsvRelease=0) AS ObservationUnReleasedTotalCount
		,(SELECT COUNT(*) FROM ObservationHeader WHERE PlanID = p.PlanID and IsDeleted = 0 and CreatedByID=@ncUserId and ObsvRelease=1) AS ObservationReleasedCountByEval
		,(SELECT COUNT(*) FROM ObservationHeader WHERE PlanID = p.PlanID and IsDeleted = 0 and ObsvRelease=1) AS ObservationReleasedTotalCount
		,(SELECT COUNT(*) FROM EmplPlanEvidence WHERE PlanID = p.PlanID and IsDeleted = 0) AS ArtifactCount
		,e.Sex AS EmplImage
		,(SELECT TOP 1
				eval.EvaluatorSignedDt
			FROM
				Evaluation as eval
			JOIN EmplPlan as p on eval.PlanID = p.PlanID
			JOIN EmplEmplJob as sej on p.EmplJobID = sej.EmplJobID
			WHERE
				sej.EmplID = ej.EmplID
			and eval.IsDeleted = 0
			ORDER BY
				eval.EvalDt DESC) AS EvaluatorSignedDt
		,(SELECT TOP 1 eval.EvaluatorSignedDt from Evaluation as Eval
					JOIN EmplPlan as p on eval.PlanID = p.PlanID
										AND p.PlanActive = 1
					JOIN EmplEmplJob as sej on p.EmplJobID = sej.EmplJobID
					where sej.EmplID = ej.EmplID
					and eval.IsDeleted = 0 and eval.EvalTypeID in (83, 84) and eval.EvaluatorSignedDt is not null
					order by eval.EvaluatorSignedDt desc) as FormativeDate
		,(SELECT TOP 1 eval.EvaluatorSignedDt from Evaluation as Eval
					JOIN EmplPlan as p on eval.PlanID = p.PlanID
										AND p.PlanActive = 1
					JOIN EmplEmplJob as sej on p.EmplJobID = sej.EmplJobID
					where sej.EmplID = ej.EmplID
					and eval.IsDeleted = 0 and eval.EvalTypeID = 85 and eval.EvaluatorSignedDt is not null
					order by eval.EvaluatorSignedDt desc) 
					as SummativeDate
		,p.HasPrescript
		,p.PlanID
		,ej.EmplClass
		,j.UnionCode
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN 1
			ELSE 0
			END) as EmplExceptionExists
		,rh.Is5StepProcess as Is5StepProcess
		--,case when ISNULL(p.PlanActive, 0) = 1 
		--	then ISNULL(rh.Is5StepProcess, 0)
		--	else ISNULL(ejrh.Is5StepProcess, 0)
		--	end Is5StepProcess
		,rh.IsDESELic
		, (case when @UserRoleID = 1 and @ncUserId =  dbo.funcGetPrimaryManagerByEmplID(e.EmplID)  then 1
				when @UserRoleID = 2 and @ncUserId in(select 
											s.EmplID
										from 
											SubevalAssignedEmplEmplJob as ase (nolock) 
										join SubEval s (nolock) on ase.SubEvalID = s.EvalID
										where											
											ase.EmplJobID in(select EmplJobID from EmplEmplJob where IsActive=1 and EmplID=e.EmplID)
										and ase.isActive = 1
										and ase.isDeleted = 0
										and ase.IsPrimary = 1) 
					then 1 					
				when @UserRoleID = 3
					then 0
				else 0
			 end ) IsPrimaryEvaluator		
		,ISNULL(pcmulti.CodeText, 'None') AS MultiGoalStatus
		,(SELECT COUNT(*) FROM PlanGoal WHERE PlanID = p.PlanID and GoalYear=2 and IsDeleted =0 ) AS SecondYearGoalCount
		,ISNULL(acmulti.CodeText, 'None') AS MultiActionStepStatus
	FROM
		Empl			AS e	(NOLOCK)
	JOIN EmplEmplJob	AS ej	(NOLOCK)	ON e.EmplID = ej.EmplID
											AND ej.IsActive = 1
	LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
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
									AND p.PlanActive = 1 and p.IsInvalid = 0
	left join RubricHdr as rh (nolock) on rh.RubricID = (case when p.RubricID is null then ej.RubricID else p.RubricID end)									
	--left join RubricHdr as rh (nolock) on rh.RubricID = p.RubricID
	LEFT OUTER JOIN CodeLookUp	as pc (NOLOCK)	ON p.GoalStatusID =  pc.CodeID 
	LEFT OUTER JOIN CodeLookUp	as ac (NOLOCK)	ON p.ActnStepStatusID =  ac.CodeID 
	LEFT OUTER JOIN CodeLookUp	as pcmulti (NOLOCK)	ON p.MultiYearGoalStatusID =  pcmulti.CodeID 
	LEFT OUTER JOIN CodeLookUp	as acmulti (NOLOCK)	ON p.MultiYearActnStepStatusID =  acmulti.CodeID 
	WHERE
		e.EmplActive = 1 
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
				and s.EvalActive = 1
				where
					ase.EmplJobID = ej.EmplJobID					
				and ase.isActive = 1
				and ase.isDeleted = 0) and @UserRoleID = 2)
			OR
			(ej.EmplID = @ncUserId and @UserRoleID = 3)
		)		
	ORDER BY
		rh.Is5StepProcess
		,e.NameLast
		,e.NameFirst
END


GO
