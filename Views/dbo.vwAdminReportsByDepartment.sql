SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 01/06/2014	
-- Description: View to generate administrative reports
-- on departments 
-- =============================================
CREATE VIEW [dbo].[vwAdminReportsByDepartment]
AS

SELECT  
(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'')+' ('+e1.EmplID+')' FROM Empl e1 WHERE e1.EmplID = ej.EmplID) as EmplName, 
(j.JobName+' ('+j.jobCode+')') as JobName ,
(d.DeptName +' ('+d.DeptID+')') as DepartmentName,
cd.CodeText as DepartmentCategory,
(SELECT ISNULL(e2.NameFirst, '')+ ' ' +ISNULL(e2.NameMiddle,'')+ ' '+ISNULL(e2.NameLast,'')+' ('+e2.EmplID+')' FROM Empl e2 WHERE e2.EmplID = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)) as PrimaryEvaluator, 
(SELECT ISNULL(e2.NameFirst, '')+ ' ' +ISNULL(e2.NameMiddle,'')+ ' '+ISNULL(e2.NameLast,'') +' ('+e2.EmplID+')' FROM Empl e2 WHERE e2.EmplID = (CASE WHEN ex.MgrID is null then ej.MgrID else ex.MgrID end)) as Manager, 
(SELECT ISNULL(e2.NameFirst, '')+ ' ' +ISNULL(e2.NameMiddle,'')+ ' '+ISNULL(e2.NameLast,'')+' ('+e2.EmplID+')' FROM Empl e2 WHERE e2.EmplID = (CASE WHEN d.DeptRptEmplID IS NOt NULL THEN d.DeptRptEmplID 
																															WHEN (CASE WHEN ex1.MgrID is null then ej1.MgrID else ex1.MgrID end) IS NOT NULL then (CASE WHEN ex1.MgrID is null then ej1.MgrID else ex1.MgrID end)
																															ELSE dbo.funcGetPrimaryManagerByEmplID(CASE WHEN ex.MgrID is null then ej.MgrID else ex.MgrID end) END )) as ReportTo
,d.IsSchool																															
FROM EmplEmplJob ej 
JOIN Department d on d.DeptID = ej.DeptID
LEFT OUTER JOIN CodeLookUp cd on cd.CodeID = d.DeptCategoryID
LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID
LEFT OUTER JOIN EmplEmplJob ej1 on ej1.DeptID = d.DeptID and ej1.IsActive = 1 and ej1.EmplID = (CASE WHEN ex.MgrID is null then ej.MgrID else ex.MgrID end)
LEFT OUTER JOIN EmplExceptions ex1 on ex1.EmplJobID = ej1.EmplJobID
JOIN EmplJob j on ej.JobCode = j.JobCode
WHERE ej.IsActive = 1 

GO
