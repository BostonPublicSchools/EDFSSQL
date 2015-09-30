SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/07/2012
-- Description:	Get  evaluation by EvalID
-- =============================================
Create PROCEDURE [dbo].[getEvaluationByEval]
	@EvalID AS nchar(6) 

AS
BEGIN
	SET NOCOUNT ON;
	
select	e.EvalID
		,e.PlanID
		,e.EvalTypeID
		,(select CodeText from CodeLookUp where CodeID = e.EvalTypeID)as EvalType
		,CONVERT(varchar, e.EvalDt, 101) as EvalDt		
		,e.EvaluatorsCmnt
		,e.EmplCmnt
		,e.OverallRatingID
		,(select CodeText from CodeLookUp where CodeID = e.OverallRatingID) as OverallRating
		,e.Rationale
		,e.EvaluatorsSignature
		,e.EvaluatorSignedDt
		,e.EmplSignature
		,e.EmplSignedDt
		,e.WitnessSignature
		,e.WitnessSignDt
		,e.IsSigned
		,e.EmplSignedDt
		,e.EditEndDt
		,e.EvalRubricID
		,ep.PlanActive
		,ep.EmplJobID
		,j.JobName
		,j.JobCode
		,ej.RubricID
		,RTRIM(clEjCls.Code) EmplClass	
		,(CASE WHEN ep.SubEvalID IS NULL
			THEN
				CASE
					when s.EmplID IS NULL
					THEN CASE
						WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
						ELSE ej.MgrID
						END
					ELSE s.EmplID
				END 
			ELSE
				ep.SubEvalID
		 END) AS SubEvalID
		,(select  empl.NameLast + ', ' + empl.NameFirst + ' ' + ISNULL(empl.NameMiddle, '')  from Empl where EmplID= 
																										CASE WHEN ep.SubEvalID IS NULL
																										THEN CASE
																											when s.EmplID IS NULL
																											THEN CASE
																														WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
																														ELSE ej.MgrID
																													END
																											ELSE s.EmplID END
																										ELSE
																											ep.SubEvalID
																										END) AS SubEvalName	
		,(CASE WHEN (emplEx.MgrID IS NOT NULL)
			   THEN emplEx.MgrID
			   ELSE ej.MgrID
			   END) AS MgrID
		,(CASE WHEN (emplEx.MgrID IS NOT NULL)
			   THEN (select  empl.NameLast + ', ' + empl.NameFirst + ' ' + ISNULL(empl.NameMiddle, '')  from Empl where EmplID= emplEx.MgrID)
			   ELSE (select  empl.NameLast + ', ' + empl.NameFirst + ' ' + ISNULL(empl.NameMiddle, '')  from Empl where EmplID= ej.MgrID) 
			   END) AS MgrName		
		,ej.EmplID
		,(select  empl.NameLast + ', ' + empl.NameFirst + ' ' + ISNULL(empl.NameMiddle, '') + ' (' + empl.EmplID + ')' from Empl where EmplID= ej.emplID) AS EmplName
		,minc.CodeID as minCodeID
		,minc.CodeText as minCodeText
		,ISNULL(m.MinCodeSortOrder, 1) as MinCodeSortOrder
		,ISNULL(m.MaxCodeSortOrder, 4) as MaxCodeSortOrder
		,EvalSignOffCount
		,Coalesce(e.EvalPlanYear,1) As EvalPlanYear
		,EvalManagerID
		,(select  empl.NameLast + ', ' + empl.NameFirst + ' ' + ISNULL(empl.NameMiddle, '') from Empl where EmplID= EvalManagerID) AS EvalManagerName
		,EvalSubEvalID
		,(select  empl.NameLast + ', ' + empl.NameFirst + ' ' + ISNULL(empl.NameMiddle, '') from Empl where EmplID= EvalSubEvalID) AS EvalSubEvalName
		,(CASE WHEN (SELECT COUNT(*) FROM EvaluationStandardRating 
					WHERE RatingID IN (SELECT CodeID FROM CodeLookUp 
										WHERE CodeType = 'StdRating' 
										AND CodeText IN('Needs Improvement','Unsatisfactory') 
									  )
					AND EvalID = e.EvalID) > 0  THEN 1 ELSE 0 END) AS HasEvalPrescript
from Evaluation e
left join EmplPlan ep (NOLOCK) on ep.PlanID = e.PlanID
left join EmplEmplJob ej (NOLOCK) on ej.EmplJobID = ep.EmplJobID
						AND ej.EmplRcdNo <= 20	
left join CodeLookUp clEjCls (NOLOCK) on clEjCls.Code = ej.EmplClass and clEjCls.CodeType='emplclass'
JOIN EmplJob AS j	 (NOLOCK)		ON ej.JobCode = j.JobCode
LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
												and ase.isActive = 1
												and ase.isDeleted = 0
												and ase.isPrimary = 1
left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
								and s.EvalActive = 1	
left join (SELECT
				esr.EvalID
				,MAX(c.CodeSortOrder) as MaxCodeSortOrder
				,MIN(c.CodeSortOrder) as MinCodeSortOrder
			FROM
				CodeLookUp as c
			JOIN EvaluationStandardRating as esr  on c.CodeID = esr.RatingID 	
			WHERE 
				c.CodeType = 'stdRating'
			GROUP BY
				esr.EvalID) as m on m.EvalID = e.EvalID
left join CodeLookUp as maxc on m.MaxCodeSortOrder = maxc.CodeSortOrder
							and maxc.CodeType ='stdRating'
left join CodeLookUp as minc on m.MinCodeSortOrder = minc.CodeSortOrder
							and minc.CodeType ='stdRating'
		where e.EvalID =@EvalID
				AND e.IsDeleted = 0
	order by e.EvalDt desc	
END


GO
