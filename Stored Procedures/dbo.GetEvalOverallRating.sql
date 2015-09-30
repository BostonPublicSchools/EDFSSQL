SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi		
-- Create date: 04/16/2013
-- Description:	Get overall rating for all the employees
-- =============================================
CREATE PROCEDURE [dbo].[GetEvalOverallRating]
	 @ncUserId AS nchar(6) = NULL
	,@UserRoleID as int 
	,@RubricID as int = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF @RubricID IS NULL
	BEGIN
	SELECT e.EmplID
	   ,ISNULL(e.NameLast,'') + ', ' + ISNULL(e.NameFirst, '')+ ' ' +ISNULL(e.NameMiddle,'')+ ' ('+ e.EmplID + ')' as EmplName 
	   ,ej.EmplJobID
	   ,ISNULL(ep.PlanActive, 0) AS PlanActive
	   ,ISNULL(ep.PlanTypeID,0) as PlanTypeId	   
	   ,(CASE  
			WHEN ep.PlanStartDt is NULL THEN (cep.CodeText + ' ' + isnull(CONVERT(varchar, ep.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, ep.PlanSchedEndDt, 101),''))
			WHEN  ep.PlanStartDt is not NULL THEN cep.CodeText + ' ' + isnull(CONVERT(varchar, ep.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, ep.PlanSchedEndDt, 101),'')  
			else (cep.CodeText + ' ' + isnull(CONVERT(varchar, ep.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, ep.PlanSchedEndDt, 101),''))
		END) AS PlanLabel
	   ,ep.PlanID
	   , eval.PlanID as EvalPlanId
	   , (SELECT PlanSchedEndDt FROM EmplPlan Where PlanID = eval.PlanID) as EvalPlanEndDt
	   ,(SELECT isnull(CodeText,'') from CodeLookUp where CodeID = ep.PlanTypeID) as PlanType
	   , rh.Is5StepProcess
	   , rh.RubricID
	   , eval.EvalID
	   , et.CodeText as EvalType
	   , ed.EvalTypeID
	   , ed.IsSigned
	   , ed.OverallRatingID
	   , eor.CodeText as overallRating
	   , ed.EvalDt	
	   , ed.EditEndDt   
	   , ed.EvaluatorsSignature
	   , ed.EvaluatorSignedDt
	   , j.UnionCode
	   , dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) as MgrID	  
	   ,j.JobName
	   
	  -- , COALESCE((select top 1 s.EmplID
			--		from 
			--			SubevalAssignedEmplEmplJob as ase (nolock) 
			--		join SubEval s (nolock) on ase.SubEvalID = s.EvalID
			--		where
			--			ase.EmplJobID = ej.EmplJobID
			--		and ase.isActive = 1
			--		and ase.isDeleted = 0
			--		and ((ase.IsPrimary = 1 and @UserRoleID = 1) OR (@UserRoleID = 2 and s.EmplID = @ncUserId and ase.IsPrimary=1))) 
			--,dbo.funcGetPrimaryManagerByEmplID(e.EmplID)) as SubEvalID 
	FROM Empl e (NOLOCK)
	JOIN EmplEmplJob AS ej	(NOLOCK) ON e.EmplID = ej.EmplID
												AND ej.IsActive = 1	
	JOIN EmplJob as j (nolock) on ej.JobCode = j.JobCode
    --LEFT OUTER JOIN department     AS d	(NOLOCK)    ON ej.DeptID = d.DeptID
	LEFT OUTER JOIN EmplPlan AS ep(NOLOCK) ON ep.EmplJobID = ej.EmplJobID and ep.PlanActive = 1 and ep.IsInvalid = 0								
	JOIN RubricHdr as rh (nolock) on rh.RubricID = (CASE when (ep.RubricID is null or ep.RubricID != ej.RubricID) then ej.RubricID else ep.RubricID end) and rh.Is5StepProcess = 0
	LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	LEFT OUTER JOIN CodeLookUp AS cep(NOLOCK) ON cep.CodeID = ep.PlanTypeID	
	LEFT OUTER JOIN (SELECT
						PlanID
						,MAX(EvalID) AS EvalID
					FROM 
						Evaluation (NOLOCK)				
					GROUP BY
						PlanID) AS  eval ON  eval.PlanID = (CASE WHEN ep.PlanID is not null and ep.PlanID != 0 
																THEN ep.PlanID 
																ELSE (SELECT top 1 (PlanID) 
																	  FROM EmplPlan
																	  WHERE EmplJobID = ej.EmplJobID and PlanActive = 0 and IsInvalid = 0 
																	  and RubricID = (Select RubricID from emplempljob where empljobID = dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID))
																	  ORDER BY PlanSchedEndDt desc) 
																END)
	LEFT OUTER JOIN (SELECT
						EvalID
						,OverallRatingID
						,EvalDt
						,IsSigned
						,EditEndDt
						,EvalTypeID
						,EvalRubricID
						,EvaluatorsSignature
						,EvaluatorSignedDt
					FROM 
						Evaluation (NOLOCK)
					WHERE
						IsDeleted = 0) AS  ed ON  eval.EvalID = ed.EvalID
	LEFT OUTER JOIN CodeLookUp	AS eor (NOLOCK) ON ed.OverallRatingID = eor.CodeID
	LEFT OUTER JOIN CodeLookUp	AS et (NOLOCK) ON ed.EvalTypeID = et.CodeID					
	WHERE 
		e.EmplActive = 1
		AND (   ((CASE 
						WHEN (emplEx.MgrID IS NOT NULL)
						THEN emplEx.MgrID
						ELSE ej.MgrID
					END = @ncUserId) AND @UserRoleID = 1)
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
			and rh.Is5StepProcess = 0				
		ORDER BY 
			e.NameLast
			,e.NameFirst
	END	
	ELSE IF @RubricID IS NOT NULL
	BEGIN 
		SELECT e.EmplID
	   ,ISNULL(e.NameLast,'') + ', ' + ISNULL(e.NameFirst, '')+ ' ' +ISNULL(e.NameMiddle,'')+ ' ('+ e.EmplID + ')' as EmplName 
	   ,ej.EmplJobID
	   ,ISNULL(ep.PlanActive, 0) AS PlanActive
	   ,ISNULL(ep.PlanTypeID,0) as PlanTypeId	   
	   ,(CASE  
			WHEN ep.PlanStartDt is NULL THEN (cep.CodeText + ' ' + isnull(CONVERT(varchar, ep.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, ep.PlanSchedEndDt, 101),''))
			WHEN  ep.PlanStartDt is not NULL THEN cep.CodeText + ' ' + isnull(CONVERT(varchar, ep.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, ep.PlanSchedEndDt, 101),'')  
			else (cep.CodeText + ' ' + isnull(CONVERT(varchar, ep.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, ep.PlanSchedEndDt, 101),''))
		END) AS PlanLabel
	   ,ep.PlanID
	   , eval.PlanID as EvalPlanId
	   , (SELECT PlanSchedEndDt FROM EmplPlan Where PlanID = eval.PlanID) as EvalPlanEndDt
	   ,(SELECT isnull(CodeText,'') from CodeLookUp where CodeID = ep.PlanTypeID) as PlanType
	   , rh.Is5StepProcess
	   , rh.RubricID
	   , eval.EvalID
	   , et.CodeText as EvalType
	   , ed.EvalTypeID
	   , ed.IsSigned
	   , ed.OverallRatingID
	   , eor.CodeText as overallRating
	   , ed.EvalDt	
	   , ed.EditEndDt   
	   , ed.EvaluatorsSignature
	   , ed.EvaluatorSignedDt
	   , j.UnionCode
	   , dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) as MgrID	   	
		FROM Empl e (NOLOCK)
		JOIN EmplEmplJob AS ej	(NOLOCK) ON e.EmplID = ej.EmplID
													AND ej.IsActive = 1	
		JOIN EmplJob as j (nolock) on ej.JobCode = j.JobCode
		--LEFT OUTER JOIN department     AS d	(NOLOCK)    ON ej.DeptID = d.DeptID
		LEFT OUTER JOIN EmplPlan AS ep(NOLOCK) ON ep.EmplJobID = ej.EmplJobID and ep.PlanActive = 1 and ep.IsInvalid = 0								
		JOIN RubricHdr as rh (nolock) on rh.RubricID = (CASE when ep.RubricID is null then ej.RubricID else ep.RubricID end) and rh.Is5StepProcess = 0
		LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
		LEFT OUTER JOIN CodeLookUp AS cep(NOLOCK) ON cep.CodeID = ep.PlanTypeID
		LEFT OUTER JOIN (SELECT
							PlanID
							,MAX(EvalID) AS EvalID
						FROM 
							Evaluation (NOLOCK)				
						GROUP BY
							PlanID) AS  eval ON  eval.PlanID = (CASE WHEN ep.PlanID is not null and ep.PlanID != 0 
																	THEN ep.PlanID 
																	ELSE (SELECT top 1 (PlanID) 
																		  FROM EmplPlan
																		  WHERE EmplJobID = ej.EmplJobID and PlanActive = 0 and IsInvalid = 0
																		  ORDER BY PlanSchedEndDt desc) 
																	END)
		LEFT OUTER JOIN (SELECT
							EvalID
							,OverallRatingID
							,EvalDt
							,IsSigned
							,EditEndDt
							,EvalTypeID
							,EvalRubricID
							,EvaluatorsSignature
							,EvaluatorSignedDt
						FROM 
							Evaluation (NOLOCK)
						WHERE
							IsDeleted = 0) AS  ed ON  eval.EvalID = ed.EvalID
		LEFT OUTER JOIN CodeLookUp	AS eor (NOLOCK) ON ed.OverallRatingID = eor.CodeID
		LEFT OUTER JOIN CodeLookUp	AS et (NOLOCK) ON ed.EvalTypeID = et.CodeID					
		WHERE 
			e.EmplActive = 1
			AND (   ((CASE 
							WHEN (emplEx.MgrID IS NOT NULL)
							THEN emplEx.MgrID
							ELSE ej.MgrID
						END = @ncUserId) AND @UserRoleID = 1)
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
				and rh.Is5StepProcess = 0 and rh.RubricID = @RubricID				
			ORDER BY 
				e.NameLast
				,e.NameFirst
	END
	
END
GO
