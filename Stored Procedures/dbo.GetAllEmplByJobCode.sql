SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 11/20/2012
-- Description:	get all the empl details by the jobcode
-- =============================================
CREATE PROCEDURE [dbo].[GetAllEmplByJobCode]
  @ncJobCode AS nchar(6)
AS
BEGIN 
SET NOCOUNT ON;
SELECT ej.EmplJobID
		,j.JobName
	   ,ej.emplID
	   ,ej.MgrID
	   ,ej.subevalID
	   ,ej.DeptID
	   ,j.UnionCode
	   ,d.DeptName
	   ,ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') AS EmplName
	   ,ISNULL(e2.NameFirst, '')+ ' ' +ISNULL(e2.NameMiddle,'')+ ' '+ISNULL(e2.NameLast,'') AS ManagerName
	   ,ISNULL(e3.NameFirst, '')+ ' ' +ISNULL(e3.NameMiddle,'')+ ' '+ISNULL(e3.NameLast,'') AS SubEvalName
FROM EmplEmplJob ej	   
JOIN EmplJob j on ej.JobCode = j.JobCode
LEFT JOIN Department d ON ej.DeptID = d.DeptID
LEFT JOIN Empl e1 ON e1.EmplID = ej.EmplID
LEFT JOIN Empl e2 ON e2.EmplID = ej.MgrID
LEFT JOIN Empl e3 ON e3.EmplID = ej.SubEvalID

WHERE ej.JobCode = @ncJobCode
ORDER BY EmplName

END
GO
