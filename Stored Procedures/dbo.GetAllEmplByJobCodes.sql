SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 11/20/2012
-- Description:	get all the empl details by the jobcode
-- =============================================
CREATE PROCEDURE [dbo].[GetAllEmplByJobCodes]
  @ncJobCode AS nchar(6)
  --@pageIndex as int = 1,
  --@pageSize as int = 300
AS
BEGIN 
SET NOCOUNT ON;

WITH [AllEmplJobTable] AS (
  SELECT -- ROW_NUMBER() OVER(ORDER BY ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'')) AS RowNumber
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
	   ,j.UnionCode
	   ,d.DeptName
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

WHERE ej.JobCode = @ncJobCode and ej.IsActive=1 and e1.EmplActive=1
)

SELECT * FROM AllEmplJobTable
ORDER BY EmplName

END

GO
