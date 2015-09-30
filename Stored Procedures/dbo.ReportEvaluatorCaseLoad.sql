SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[ReportEvaluatorCaseLoad]
	@ncUserId AS nchar(6) = NULL
	,@UserRoleID as int
AS
BEGIN
SET NOCOUNT ON; 
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
		MainTable.* 
			--,( CASE 
			--	WHEN (MainTable.PlanType = 'Self-Directed' AND MainTable.CurrentPlanEvalCount= 0 AND MainTable.[Self-Directed]!='2 Year(s)') 
			--		THEN 'Formative Assessment'  	-- self directed 
			--	WHEN (MainTable.PlanType = 'Self-Directed' AND MainTable.CurrentPlanEvalCount= 0 AND MainTable.[Self-Directed]='2 Year(s)') 
			--		THEN 'Formative Evaluation' 
										
			--	WHEN (MainTable.PlanType = 'Self-Directed' AND MainTable.[Self-Directed]='1 Year(s)' AND MainTable.CurrentPlanEvalCount> 0 AND forReleaseDtActvPlan='') 
			--		THEN 'Formative Assessment'  	-- self directed - 1yr
			--	WHEN (MainTable.PlanType = 'Self-Directed' AND MainTable.[Self-Directed]='1 Year(s)' AND MainTable.CurrentPlanEvalCount> 0 AND forReleaseDtActvPlan!='' ) 
			--		THEN 'Summative Evaluation'  	-- self directed - 1yr
					
			--	WHEN (MainTable.PlanType = 'Self-Directed' AND MainTable.[Self-Directed]='2 Year(s)' AND MainTable.CurrentPlanEvalCount=1 AND forEvalReleaseDtActvPlan ='') 
			--		THEN 'Formative Evaluation' 
			--	WHEN (MainTable.PlanType = 'Self-Directed' AND MainTable.[Self-Directed]='2 Year(s)' AND MainTable.CurrentPlanEvalCount> 1 AND forEvalReleaseDtActvPlan !='') 
			--		THEN 'Summative Evaluation' 	-- self directed
					  
			--	WHEN (MainTable.CurrentPlanEvalCount =0	AND forReleaseDtActvPlan='')			
			--		THEN 'Formative Assessment' 
					
			--	WHEN (MainTable.CurrentPlanEvalCount>0 AND forReleaseDtActvPlan!='') 
			--		THEN 'Summative Evaluation'    	
 
			--	ELSE 'Formative Assessment' 
			--END)  as NextEvaluation

	FROM
	(SELECT 
		e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  AS EducatorName
		,(SELECT e1.NameLast + ', ' + e1.NameFirst + ' ' + ISNULL(e1.NameMiddle, '') + ' (' + e1.EmplID + ')' FROM Empl e1 WHERE e1.EmplID = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)) as PrimaryEval	
		--,ISNULL(pt.CodeText, '') AS PlanType
		,(CASE
			WHEN p.PlanTypeID = 1 AND p.IsMultiYearPlan = 'true'  THEN '2 Years '+ pt.CodeText
			WHEN p.PlanTypeID = 1 AND ( p.IsMultiYearPlan = 'false' OR p.IsMultiYearPlan IS NULL) THEN '1 Year '+pt.CodeText
			ELSE pt.CodeText 
		END) AS PlanType		
		,ISNULL(CONVERT(VARCHAR, p.PlanSchedEndDt, 101), '') AS PlanEnd
		,(SELECT TOP 1 CodeText+' ('+ rtrim(clEmpCl.Code)+')' FROM CodeLookUp WHERE CodeType = 'EmplClass' and Code = ej.EmplClass) as EmplClass		
		,CASE
			WHEN p.PlanID IS NULL THEN 'Plan'
			WHEN p.IsSignedAsmt = 0 THEN 'Self-Assessment'
			WHEN ISNULL(gs.CodeText, '') = 'Awaiting Approval' AND p.planyear=1  THEN 'Approve Goals & Action Steps'
			WHEN ISNULL(gs.CodeText, '') = 'Returned' AND p.planyear=1 THEN 'Goal & Action Steps Returned'
			WHEN NOT ISNULL(gs.CodeText, '') = 'Approved' AND p.planyear=1 THEN 'Goals & Action Steps'
			
			WHEN gs.CodeText = 'Approved' And (gsMulti.CodeText = 'Awaiting Approval') AND ( p.IsMultiYearPlan = 'true' And p.PlanYear=2)  
				THEN 'Approve Next Year Goals & Action Steps'
			WHEN gs.CodeText = 'Approved' And (gsMulti.CodeText = 'Returned') AND ( p.IsMultiYearPlan = 'true' And p.PlanYear=2)  
				THEN 'Next Year Goals & Action Steps Returned'				
			WHEN gs.CodeText = 'Approved' And NOT ISNULL(gsMulti.CodeText, '') = 'Approved'  AND ( p.IsMultiYearPlan = 'true' And p.PlanYear=2)  
				THEN 'Next Year Goals & Action Steps'
			ELSE 'Collect Evidence'			
		END AS CurrentStep	
		,ISNULL((select top 1
					CONVERT(VARCHAR, sev.EvaluatorSignedDt, 101)
				from
					EmplEmplJob as sej
				join EmplPlan as sp on sej.EmplJobID = sp.EmplJobID and sp.IsInvalid = 0
				join Evaluation as sev on sp.PlanID = sev.PlanID
				join CodeLookUp as st on sev.EvalTypeID = st.CodeID
									and st.CodeText = 'Summative Evaluation'
				join CodeLookUp as ser on sev.OverallRatingID = ser.CodeID
				where
					sev.IsSigned = 1
				and sev.IsDeleted = 0
				and sej.EmplID = e.EmplID				
				order by
				sev.EvalDt desc), '') as SummativeDate
		,ISNULL((select top 1
					ser.CodeText as OverAllRating
				from
					EmplEmplJob as sej
				join EmplPlan as sp on sej.EmplJobID = sp.EmplJobID and sp.IsInvalid = 0
				join Evaluation as sev on sp.PlanID = sev.PlanID
				join CodeLookUp as st on sev.EvalTypeID = st.CodeID
									and st.CodeText = 'Summative Evaluation'
				join CodeLookUp as ser on sev.OverallRatingID = ser.CodeID
				where
					sev.IsSigned = 1
				and sev.IsDeleted = 0
				and sej.EmplID = e.EmplID				
				order by
				sev.EvalDt desc), '')	as SummativeRating		
		,ISNULL((select top 1
					CONVERT(VARCHAR, sev.EvaluatorSignedDt, 101)
				from
					EmplEmplJob as sej
				join EmplPlan as sp on sej.EmplJobID = sp.EmplJobID and sp.IsInvalid = 0
				join Evaluation as sev on sp.PlanID = sev.PlanID
				join CodeLookUp as st on sev.EvalTypeID = st.CodeID
									and st.CodeText like 'Formative%'
				join CodeLookUp as ser on sev.OverallRatingID = ser.CodeID
				where
					sev.IsSigned = 1
				and sev.IsDeleted = 0
				and sej.EmplID = e.EmplID	
				order by
				sev.EvalDt desc), '') as FormativeDate
		,ISNULL((select top 1
					ser.CodeText as OverAllRating
				from
					EmplEmplJob as sej
				join EmplPlan as sp on sej.EmplJobID = sp.EmplJobID and sp.IsInvalid = 0
				join Evaluation as sev on sp.PlanID = sev.PlanID
				join CodeLookUp as st on sev.EvalTypeID = st.CodeID
									and st.CodeText like 'Formative%'
				join CodeLookUp as ser on sev.OverallRatingID = ser.CodeID
				where
					sev.IsSigned = 1
				and sev.IsDeleted = 0
				and sej.EmplID = e.EmplID				
				order by
				sev.EvalDt desc), '')	as FormativeRating				
		,(SELECT COUNT(ev.EvidenceID) from Evidence ev where ev.EvidenceID in
			(select distinct(EvidenceID) from EmplPlanEvidence epe where epe.PlanID=p.PlanID and epe.IsDeleted=0)
			and ev.IsDeleted=0
			) AS Artifacts
		,(select 
				count(ObsvID)
			from 
				ObservationHeader
			where
				ObsvRelease = 1
			and PlanID  = p.PlanID)  AS Observations
	    ,rh.RubricID
	    ,(case when @ncUserId =  dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)  then 1 else 0 end) as IsPrimaryEvaluator
	    ,CASE
			WHEN p.AnticipatedEvalWeek is not null Then p.AnticipatedEvalWeek
			ELSE ''
		END AS FormativeTargetedWeek
			
--not req				
		--,ISNULL(CONVERT(VARCHAR, p.PlanStartDt, 101), '') AS PlanStartDt		
		--,d.DeptID
		--,d.DeptName
		--,dc.CodeID AS DeptCatID
		--,dc.CodeText AS DeptCat		
		--,(CASE 
		--	WHEN (emplEx.MgrID IS NOT NULL)
		--	THEN 'Yes'
		--	ELSE 'No'
		--	END) as EmplExceptionExists		
		--,CASE
		--	WHEN p.PlanStartDt IS NOT NULL THEN DATEDIFF(d, p.PlanStartDt, p.PlanEndDt)
		--	WHEN p.PlanStartDt IS NULL THEN DATEDIFF(d, GETDATE(), p.PlanEndDt)
		--	ELSE 0
		--END AS PlanDuration
		--,CASE
		--	WHEN p.PlanTypeID = 1 AND p.IsMultiYearPlan = 'true'  THEN '2 Year(s)'
		--	WHEN p.PlanTypeID = 1 AND ( p.IsMultiYearPlan = 'false' OR p.IsMultiYearPlan IS NULL) THEN '1 Year(s)'			
		--	ELSE null 
		--END AS [Self-Directed] --self directed plan year		
		--,CASE
		--	WHEN p.AnticipatedEvalWeek is not null Then p.AnticipatedEvalWeek
		--	ELSE ''
		--END AS FormativeTargetDt
		--,ISNULL(CONVERT(VARCHAR, p.PlanEndDt, 101), '') AS SummativeTargetDt
		
		--,'' AS Approaching
		
--		,(select
--				ISNULL(SUM(ISNULL(evid.EvidenceCount, 0) + isnull(obsv.ObservationCount, 0)), 0)
--			from
--				(SELECT
--						epe.PlanID 
--						,COUNT(epe.EvidenceID) as EvidenceCount
--					FROM
--						EmplPlanEvidence AS epe (NOLOCK)
--						JOIN CodeLookUp AS et (NOLOCK) ON epe.EvidenceTypeID = et.CodeID
--														AND et.CodeText IN ('Standard Evidence')
--						JOIN RubricStandard as s (NOLOCK) ON epe.ForeignID = s.StandardID
--																		AND s.StandardText like 'I.%'
--					WHERE
--						 epe.IsDeleted = 0
--					group by
--						epe.PlanID) as evid
--			LEFT JOIN (SELECT
--						oh.PlanID 
--						,COUNT(od.ObsvDID) as ObservationCount
--					FROM
--						ObservationHeader as oh (nolock)
--						join ObservationDetail as od (nolock) on oh.ObsvID = od.ObsvID
--															and od.IsDeleted = 0
--						join RubricIndicator as ri (nolock) on od.IndicatorID = ri.IndicatorID
--						JOIN RubricStandard as s (NOLOCK) ON ri.StandardID = s.StandardID
--															AND s.StandardText like 'I.%'
--					WHERE
--						 oh.IsDeleted = 0
--					group by
--						oh.PlanID) as obsv on evid.PlanID = obsv.PlanID
--			WHERE
--				evid.PlanID = p.PlanID) AS ArtifactStdI
--		,(select
--				ISNULL(SUM(ISNULL(evid.EvidenceCount, 0) + isnull(obsv.ObservationCount, 0)), 0)
--			from
--				(SELECT
--						epe.PlanID 
--						,COUNT(epe.EvidenceID) as EvidenceCount
--					FROM
--						EmplPlanEvidence AS epe (NOLOCK)
--						JOIN CodeLookUp AS et (NOLOCK) ON epe.EvidenceTypeID = et.CodeID
--														AND et.CodeText IN ('Standard Evidence')
--						JOIN RubricStandard as s (NOLOCK) ON epe.ForeignID = s.StandardID
--																		AND s.StandardText like 'II.%'
--					WHERE
--						 epe.IsDeleted = 0
--					group by
--						epe.PlanID) as evid
--			LEFT JOIN (SELECT
--						oh.PlanID 
--						,COUNT(od.ObsvDID) as ObservationCount
--					FROM
--						ObservationHeader as oh (nolock)
--						join ObservationDetail as od (nolock) on oh.ObsvID = od.ObsvID
--															and od.IsDeleted = 0
--						join RubricIndicator as ri (nolock) on od.IndicatorID = ri.IndicatorID
--						JOIN RubricStandard as s (NOLOCK) ON ri.StandardID = s.StandardID
--															AND s.StandardText like 'II.%'
--					WHERE
--						 oh.IsDeleted = 0
--					group by
--						oh.PlanID) as obsv on evid.PlanID = obsv.PlanID
--			WHERE
--				evid.PlanID = p.PlanID) AS ArtifactStdII
--		,(select
--				ISNULL(SUM(ISNULL(evid.EvidenceCount, 0) + isnull(obsv.ObservationCount, 0)), 0)
--			from
--				(SELECT
--						epe.PlanID 
--						,COUNT(epe.EvidenceID) as EvidenceCount
--					FROM
--						EmplPlanEvidence AS epe (NOLOCK)
--						JOIN CodeLookUp AS et (NOLOCK) ON epe.EvidenceTypeID = et.CodeID
--														AND et.CodeText IN ('Standard Evidence')
--						JOIN RubricStandard as s (NOLOCK) ON epe.ForeignID = s.StandardID
--																		AND s.StandardText like 'III.%'
--					WHERE
--						 epe.IsDeleted = 0
--					group by
--						epe.PlanID) as evid
--			LEFT JOIN (SELECT
--						oh.PlanID 
--						,COUNT(od.ObsvDID) as ObservationCount
--					FROM
--						ObservationHeader as oh (nolock)
--						join ObservationDetail as od (nolock) on oh.ObsvID = od.ObsvID
--															and od.IsDeleted = 0
--						join RubricIndicator as ri (nolock) on od.IndicatorID = ri.IndicatorID
--						JOIN RubricStandard as s (NOLOCK) ON ri.StandardID = s.StandardID
--															AND s.StandardText like 'III.%'
--					WHERE
--						 oh.IsDeleted = 0
--					group by
--						oh.PlanID) as obsv on evid.PlanID = obsv.PlanID
--			WHERE
--				evid.PlanID = p.PlanID) AS ArtifactStdIII
--		,(select
--				ISNULL(SUM(ISNULL(evid.EvidenceCount, 0) + isnull(obsv.ObservationCount, 0)), 0)
--			from
--				(SELECT
--						epe.PlanID 
--						,COUNT(epe.EvidenceID) as EvidenceCount
--					FROM
--						EmplPlanEvidence AS epe (NOLOCK)
--						JOIN CodeLookUp AS et (NOLOCK) ON epe.EvidenceTypeID = et.CodeID
--														AND et.CodeText IN ('Standard Evidence')
--						JOIN RubricStandard as s (NOLOCK) ON epe.ForeignID = s.StandardID
--																		AND s.StandardText like 'IV.%'
--					WHERE
--						 epe.IsDeleted = 0
--					group by
--						epe.PlanID) as evid
--			LEFT JOIN (SELECT
--						oh.PlanID 
--						,COUNT(od.ObsvDID) as ObservationCount
--					FROM
--						ObservationHeader as oh (nolock)
--						join ObservationDetail as od (nolock) on oh.ObsvID = od.ObsvID
--															and od.IsDeleted = 0
--						join RubricIndicator as ri (nolock) on od.IndicatorID = ri.IndicatorID
--						JOIN RubricStandard as s (NOLOCK) ON ri.StandardID = s.StandardID
--															AND s.StandardText like 'IV.%'
--					WHERE
--						 oh.IsDeleted = 0
--					group by
--						oh.PlanID) as obsv on evid.PlanID = obsv.PlanID
--			WHERE
--				evid.PlanID = p.PlanID) AS ArtifactStdIV
		
--		,(SELECT 
--				COUNT(*)
--			FROM
--				EmplPlanEvidence AS epe (NOLOCK)
--				JOIN CodeLookUp AS et (NOLOCK) ON epe.EvidenceTypeID = et.CodeID
--												AND et.CodeText IN ('Goal Evidence')
--			WHERE
--				 epe.IsDeleted = 0
--			AND epe.PlanID = p.PlanID) AS ArtifactGoal
--		,(select
--				count(PlanID)
--			from
--				EmplPlan 
--			where
--				PlanStartDt >= '2012-07-01'
--				and IsInvalid = 0
--				and EmplJobID in (select
--									EmplJobID
--								from
--									EmplEmplJob 
--								where 
--									EmplID = e.EmplID)) as PlanCount
--		,(select
--				COUNT(EvalID)
--			from
--				Evaluation
--			where
--				EvaluatorSignedDt > '2012-07-01'
--			and PlanID in (select
--								PlanID
--							from
--								EmplPlan 
--							where
--								IsInvalid = 0 								
--								And EmplJobID in (select
--													EmplJobID
--												from
--													EmplEmplJob 
--												where 
--													EmplID = e.EmplID))) as EvalCount
--		,(select
--				COUNT(EvalID)
--			from
--				Evaluation
--			where
--				isDeleted = 0
--			and	PlanID = p.PlanID) as CurrentPlanEvalCount
		
--		,ISNULL((select top 1
--					CONVERT(VARCHAR, sev.EvaluatorSignedDt, 101)
--				from
--					EmplEmplJob as sej
--				join EmplPlan as sp on sej.EmplJobID = sp.EmplJobID and sp.IsInvalid = 0
--				join Evaluation as sev on sp.PlanID = sev.PlanID
--				join CodeLookUp as st on sev.EvalTypeID = st.CodeID
--									and st.CodeText = 'Formative Evaluation'
--				join CodeLookUp as ser on sev.OverallRatingID = ser.CodeID
--				where
--					sev.IsSigned = 1
--				and sev.IsDeleted = 0
--				and sej.EmplID = e.EmplID	
--				order by
--				sev.EvalDt desc), '') as forEvalReleaseDt	
--		,clEmpCl.CodeText +' ('+ rtrim(clEmpCl.Code)+')' as EmplClass
--		,ISNULL(Convert(VARCHAR, p.GoalFirstSubmitDt,101), '') GoalFirstSubmitDate
		
-----current current active plan evals: used in NextEvaluation
--		,ISNULL((select top 1
--					CONVERT(VARCHAR, sev.EvaluatorSignedDt, 101)
--				from
--					EmplEmplJob as sej
--				join EmplPlan as sp on sej.EmplJobID = sp.EmplJobID and sp.IsInvalid = 0
--				join Evaluation as sev on sp.PlanID = sev.PlanID
--				join CodeLookUp as st on sev.EvalTypeID = st.CodeID
--									and st.CodeText like 'Formative%'
--				join CodeLookUp as ser on sev.OverallRatingID = ser.CodeID
--				where
--					sev.IsSigned = 1
--				and sev.IsDeleted = 0
--				and sej.EmplID = e.EmplID	and sp.planID=	p.planID 			
--				order by
--				sev.EvalDt desc), '') as forReleaseDtActvPlan
--		,ISNULL((select top 1
--					CONVERT(VARCHAR, sev.EvaluatorSignedDt, 101)
--				from
--					EmplEmplJob as sej
--				join EmplPlan as sp on sej.EmplJobID = sp.EmplJobID and sp.IsInvalid = 0
--				join Evaluation as sev on sp.PlanID = sev.PlanID
--				join CodeLookUp as st on sev.EvalTypeID = st.CodeID
--									and st.CodeText = 'Formative Evaluation'
--				join CodeLookUp as ser on sev.OverallRatingID = ser.CodeID
--				where
--					sev.IsSigned = 1
--				and sev.IsDeleted = 0
--				and sej.EmplID = e.EmplID	and sp.planID=	p.planID 		
--				order by
--				sev.EvalDt desc), '') as forEvalReleaseDtActvPlan
---	
	FROM
		Empl AS e (NOLOCK) 
	JOIN EmplEmplJob AS ej (NOLOCK) ON e.EmplID = eJ.EmplID
									AND ej.IsActive = 1
									and not ej.RubricID in (select RubricID from RubricHdr where Is5StepProcess = 0)
	JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
	JOIN Department AS d (NOLOCK) On ej.DeptID = d.DeptID
	LEFT OUTER JOIN CodeLookUp As dc (NOLOCK) ON d.DeptCategoryID = dc.CodeID
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	left join SubevalAssignedEmplEmplJob ase on ase.EmplJobID = ej.EmplJobID
						and ase.isActive = 1
						and ase.isDeleted = 0
						and ase.isPrimary = 1
	left join SubEval s on s.EvalID = ase.SubEvalID and s.EvalActive = 1
	LEFT JOIN (SELECT (CASE WHEN ex.MgrID IS NOT NULL THEN ex.MgrID ELSE ej1.MgrID end)as managerID, ej1.EmplJobID,ej1.EmplID
					 FROM EmplEmplJob ej1
					 LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej1.EmplJobID 
					 WHERE ej1.EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej1.EmplID)) as PrimaryEmplJobTable on PrimaryEmplJobTable.EmplJobID = ej.EmplJobID

	left join Empl see on see.EmplID = (CASE WHEN s.EmplID IS NOT NULL THEN s.EmplID 
						 WHEN PrimaryEmplJobTable.managerID IS NOT NULL THEN PrimaryEmplJobTable.managerID
						 ELSE (case When (emplex.MgrID IS Not null)
							then emplex.MgrID
							else ej.MgrID  
							end) END)
	LEFT JOIN (SELECT 
				EmplJobID
				,EmplId
				,JobCode
			FROM
				cte
			WHERE
				PlanID IS NOT NULL) AS c ON ej.EmplID = c.EmplId
	LEFT JOIN EmplPlan AS p (NOLOCK) ON c.EmplJobID = p.EmplJobId
								AND p.PlanActive = 1
	LEFT JOIN CodeLookUp AS pt (NOLOCK) ON p.PlanTypeID = pt.CodeID
	LEFT JOIN CodeLookUp AS gs (NOLOCK) ON p.GoalStatusID = gs.CodeID	
	LEFT JOIN CodeLookUp AS gsMulti (NOLOCK) ON p.MultiYearGoalStatusID = gsMulti.CodeID	
	LEFT JOIN CodeLookUp As clEmpCl (NOLOCK) ON clEmpCl.Code= ej.EmplClass and clEmpCl.CodeType='emplclass'	
	LEFT JOIN RubricHdr as rh (nolock) on rh.RubricID = (case when p.RubricID is null then ej.RubricID else p.RubricID end)	
	where
		e.EmplActive = 1 and ej.EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID)
		and (((CASE 
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
	) as MainTable

END

GO
