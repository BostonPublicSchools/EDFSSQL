SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Newa,Matina
-- Create date: 09/18/2012
-- Description:	View self-assessment- strength and goal of Active Empl
-- SELECT top 50 * FROM SelfAssessmentDetail 
-- =============================================
CREATE VIEW [dbo].[SelfAssessmentDetail]
AS

SELECT	
		ej.EmplId [EmplID]
		,d.DeptID
		,d.DeptName
		,dc.CodeText AS DeptCat
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE ej.MgrID
			END) as MgrID
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') 
			FROM Empl e1 WHERE e1.EmplID  = CASE
												WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
												ELSE ej.MgrID
											END) AS ManagerName
		,CASE
			when s.EmplID IS NULL
			THEN CASE
						WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
						ELSE ej.MgrID
					END
			ELSE s.EmplID
		END SubEvalID
		,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') 
			FROM Empl e1 WHERE e1.EmplID  = CASE
												when s.EmplID IS NULL
												THEN CASE
															WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
															ELSE ej.MgrID
														END
												ELSE s.EmplID
												END) AS SubEvalName
														
		,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '')  AS EmplName
		,psCl.CodeText [Type]		
		,dbo.udf_StripHTML(ps.SelfAsmtText)  [Strength or Area of growth]
		,rs.StandardText as [Standard Tag]
		,pri.IndicatorText as [Indicator Tag]
		,ri.IndicatorText as [Element Tag]
		,Convert(varchar,p.DateSignedAsmt,101) [Signed on]
		
FROM
	EmplEmplJob AS ej (NOLOCK)
	JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
	JOIN EmplPlan AS p (NOLOCK) ON ej.EmplJobID = p.EmplJobID and p.IsInvalid=0
	JOIN Empl AS em (NOLOCK) ON ej.emplID=em.EmplID
	LEFT JOIN PlanSelfAsmt AS ps (NOLOCK) ON ps.PlanID=p.PlanID and ps.isDeleted=0
	LEFT JOIN CodeLookup AS psCl (NoLock) ON ps.SelfAsmtTypeID= psCl.CodeID and psCl.CodeType='SAsmtType' 
	
	JOIN Department AS d (NOLOCK) On ej.DeptID = d.DeptID		
		LEFT OUTER JOIN CodeLookUp As dc (NOLOCK) ON d.DeptCategoryID = dc.CodeID
	LEFT JOIN RubricStandard as rs (NOLOCK) on ps.StandardID = rs.StandardID
	LEFT JOIN RubricIndicator as ri (NOLOCK) on ps.IndicatorID = ri.IndicatorID
	LEFT JOIN RubricIndicator as pri (NOLOCK) on ri.ParentIndicatorID = pri.IndicatorID
	LEFT JOIN RubricHdr as rh (NOLOCK) ON rs.RubricID = rh.RubricID
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
		LEFT JOIN SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
																		and ase.isActive = 1
																		and ase.isDeleted = 0
																		and ase.isPrimary = 1
		LEFT JOIN SubEval s (nolock) on ase.SubEvalID = s.EvalID
										and s.EvalActive = 1
													
		
WHERE
	ej.IsActive = 1
AND p.PlanActive = 1
and ej.RubricID in (select RubricID from RubricHdr(NOLOCK) where Is5StepProcess = 1)

GO
