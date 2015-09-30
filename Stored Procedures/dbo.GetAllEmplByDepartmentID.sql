SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Newa, Matina
-- Create date: 12/30/2013
-- Description:	get all the active empl details by the department Id
--				exec GetAllEmplByDepartmentID @ncDeptID='101346'
-- =============================================
CREATE PROCEDURE [dbo].[GetAllEmplByDepartmentID]
  @ncDeptID AS nchar(6) = NULL
AS
BEGIN 
SET NOCOUNT ON;

WITH [AllEmplJobTable] AS 
(

	  SELECT  
			ej.emplID
			,ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') AS EmplName
			,ej.EmplJobID
			,j.JobName	   
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
			,CASE
				when s.EmplID IS NULL
				THEN CASE
							WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
							ELSE ej.MgrID
						END
				ELSE s.EmplID
			END SubEvalID
			,(CASE 
				WHEN  s.EmplID IS NULL THEN CASE 
												WHEN (emplEx.MgrID IS NOT NULL)
												THEN (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = emplEx.MgrID) 
												ELSE (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = ej.MgrID)
											 END
				ELSE (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = s.EmplID) 
				END) AS SubEvalName
		   ,ej.DeptID		   
		   ,d.DeptName
		   ,cdl.CodeText [DeptCategory]
		   ,j.UnionCode
		   ,ej.FTE
		   ,r.RubricID
		   ,r.RubricName
		   ,r.Is5StepProcess
	FROM EmplEmplJob ej	   
	JOIN EmplJob j on ej.JobCode = j.JobCode
	join RubricHdr r on ej.RubricID = r.RubricID
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1	
	LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	LEFT JOIN Department d ON ej.DeptID = d.DeptID
	LEFT JOIN Empl e1 ON e1.EmplID = ej.EmplID
	LEFT JOIN Empl e2 ON e2.EmplID = ej.MgrID
	LEFT OUTER JOIN CodeLookUp cdl on d.DeptCategoryID = cdl.CodeID and CodeType = 'DeptCat'
	WHERE ej.IsActive=1 and ej.DeptID=@ncDeptID	 and e1.EmplActive=1
)
	
	SELECT distinct * FROM AllEmplJobTable	
	ORDER BY DeptID,EmplName
	


END




GO
