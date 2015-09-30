SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 11/06/2012
-- Description:	View for observation analyst
-- =============================================
CREATE VIEW [dbo].[ActiveEmployees]
AS
	SELECT 
		d.DeptID
		,d.DeptName
		,dc.CodeID AS DeptCatID
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
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN 1
			ELSE 0
			END) as EmplExceptionExists
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
		,ej.EmplID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  AS EmplName
		,j.JobCode
		,j.JobName
	FROM
		EmplEmplJob				AS ej (NOLOCK)
	JOIN Empl					AS e (NOLOCK)			ON ej.EmplID = e.EmplID
														AND e.EmplActive = 1
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
																	and ase.isActive = 1
																	and ase.isDeleted = 0
																	and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1
	JOIN EmplJob				AS j (NOLOCK)			ON ej.JobCode = j.JobCode
	LEFT JOIN EmplExceptions	AS emplEx(NOLOCK)		ON emplEx.EmplJobID = ej.EmplJobID
	JOIN Department				AS d (NOLOCK)			ON ej.DeptID = d.DeptID
	LEFT JOIN CodeLookUp		AS dc (NOLOCK)			ON d.DeptCategoryID = dc.CodeID
	where
		ej.IsActive = 1
GO
