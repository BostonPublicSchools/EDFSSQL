SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 04/04/2012
-- Description:	Get list of evaluations by PlanID AND isdelete=0 (by default) 
-- 				If isdeleted=1 then retrived both deleted and non-deleted records [Updated by Newa, Matina on 03/15/2013]
-- =============================================
CREATE PROCEDURE [dbo].[getEvaluationByPlan]
	@PlanID AS nchar(6) 
	,@IsDeleted bit = 0
AS
BEGIN
	SET NOCOUNT ON;
print @IsDeleted
SELECT
	e.EvalID
	,e.PlanID
	,e.EvalTypeID
	,etc.CodeText AS EvalType
	,CONVERT(varchar, e.EvalDt, 101) as EvalDt
	,e.EvaluatorsCmnt
	,e.EmplCmnt
	,e.OverallRatingID
	,orc.CodeText AS OverallRating
	,e.Rationale
	,e.EvaluatorsSignature
	,e.EvaluatorSignedDt
	,e.EmplSignature
	,e.EmplSignedDt
	,e.WitnessSignature
	,e.WitnessSignDt
	,e.EditEndDt
	,j.JobName
	,j.JobCode
	,e.IsSigned
	,ep.EmplJobID
	,ep.HasPrescript
	,ep.PrescriptEvalID
	,(CASE WHEN (SELECT COUNT(*) FROM EvaluationStandardRating 
					WHERE RatingID IN (SELECT CodeID FROM CodeLookUp 
										WHERE CodeType = 'StdRating' 
										AND CodeText IN('Needs Improvement','Unsatisfactory') 
									  )
					AND EvalID = e.EvalID) > 0  THEN 1 ELSE 0 END) AS HasEvalPrescript
	,CASE
		when s.EmplID IS NULL
		THEN CASE
					WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
					ELSE ej.MgrID
				END
		ELSE s.EmplID
	END SubEvalID
	,sub.NameLast + ', ' + sub.NameFirst + ' ' + ISNULL(sub.NameMiddle, '') AS SubEvalName
	,(CASE 
		WHEN (emplEx.MgrID IS NOT NULL)
		THEN emplEx.MgrID
		ELSE ej.MgrID
		END)as MgrID
	,(CASE 
		WHEN (emplEx.MgrID IS NOT NULL)
		THEN (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = emplEx.MgrID) 
		ELSE mgr.NameLast + ', ' + mgr.NameFirst + ' ' + ISNULL(mgr.NameMiddle, '') 
		END)as MgrName	
	,epl.EmplID
	,epl.NameLast + ', ' + epl.NameFirst + ' ' + ISNULL(epl.NameMiddle, '') + ' (' + epl.EmplID + ')' AS EmplName
	,evlr.EmplID AS EvaluatorID
	,evlr.NameLast + ', ' + evlr.NameFirst + ' ' + ISNULL(evlr.NameMiddle, '') AS EvaluatorName
	,e.IsDeleted
	,Coalesce(e.EvalPlanYear,1) As EvalPlanYear
	,EvalManagerID
	,(select  empl.NameLast + ', ' + empl.NameFirst + ' ' + ISNULL(empl.NameMiddle, '') from Empl where EmplID= EvalManagerID) AS EvalManagerName
	,EvalSubEvalID
	,(select  empl.NameLast + ', ' + empl.NameFirst + ' ' + ISNULL(empl.NameMiddle, '') from Empl where EmplID= EvalSubEvalID) AS EvalSubEvalName
FROM
	Evaluation AS e (NOLOCK)
JOIN CodeLookUp AS etc ON e.EvalTypeID = etc.CodeID
LEFT JOIN CodeLookUp AS orc ON e.OverallRatingID = orc.CodeID
JOIN EmplPlan AS ep (NOLOCK) ON ep.PlanID = e.PlanID
JOIN EmplEmplJob AS ej (NOLOCK) ON ej.EmplJobID = ep.EmplJobID
LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
												and ase.isActive = 1
												and ase.isDeleted = 0
												and ase.isPrimary = 1
left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
								and s.EvalActive = 1	
JOIN Empl AS epl (NOLOCK) ON ej.EmplID = epl.EmplID
LEFT OUTER JOIN Empl AS mgr (NOLOCK) ON ej.MgrID = mgr.EmplID
LEFT JOIN Empl as sub (NOLOCK)	on CASE
									when s.EmplID IS NULL
									THEN CASE
												WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
												ELSE ej.MgrID
											END
									ELSE s.EmplID
									END = sub.EmplID
LEFT OUTER JOIN Empl AS evlr (NOLOCK) ON ep.SubEvalID = evlr.EmplID								
JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
WHERE 
	e.PlanID = @PlanID
AND ( e.IsDeleted = 0 or e.IsDeleted = @IsDeleted )
ORDER BY
	e.EvalDt desc				
		
END

GO
