SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/31/2012
-- Description:	List of all department with Manager
-- =============================================
CREATE PROCEDURE [dbo].[getAllDepartments]
	
AS
BEGIN
	SET NOCOUNT ON;

	--SELECT
	--	dept.DeptID,
	--	dept.DeptName,
	--	dept.MgrID,
	--	dept.CreatedByID,
	--	dept.CreatedByDt,
	--	dept.LastUpdatedByID,
	--	dept.LastUpdatedDt,
	--	dept.IsSchool,
	--	ISNULL(em.NameFirst,'') + ' '+ ISNULL(em.NameMiddle,'')+ ' ' + ISNULL(em.NameLast,'') as DeptMgrName,
	--	ISNULL(em2.NameFirst,'') + ' '+ ISNULL(em2.NameMiddle,'')+ ' ' + ISNULL(em2.NameLast,'') as DeptUpdatedByName,
	--	dept.DeptCategoryID,
	--	cdl.CodeText as DeptCategoryName		
	--FROM
	--	Department dept
	--LEFT OUTER JOIN Empl em on em.EmplID = dept.MgrID
	--LEFT OUTER JOIN Empl em2 on em2.EmplID = dept.LastUpdatedByID
	--LEFT OUTER JOIN CodeLookUp cdl on dept.DeptCategoryID = cdl.CodeID and CodeType = 'DeptCat'
	--ORDER BY dept.DeptName
	
	SELECT
		dept.DeptID,
		dept.DeptName,
		dept.MgrID,
		dept.CreatedByID,
		dept.CreatedByDt,
		dept.LastUpdatedByID,
		dept.LastUpdatedDt,
		dept.IsSchool,
		dept.ImplSpecialistID,
		dept.DeptRptEmplID,
		em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + em.EmplID + ')' as DeptMgrName,
		em2.NameLast + ', ' + em2.NameFirst + ' ' + ISNULL(em2.NameMiddle, '') + ' (' + em2.EmplID + ')' as DeptUpdatedByName,
		em3.NameLast + ', ' + em3.NameFirst + ' ' + ISNULL(em3.NameMiddle, '') + ' (' + em3.EmplID + ')' as ImplSpecialist,
		em4.NameLast + ', ' + em4.NameFirst + ' ' + ISNULL(em4.NameMiddle, '') + ' (' + em4.EmplID + ')' as DeptRptEmpl,
		dept.DeptCategoryID,
		cdl.CodeText as DeptCategoryName
		,((SELECT COUNT(emplJobID) FROM EmplEmplJob ej WHERE ej.DeptID = dept.DeptID) - 
				(SELECT COUNT(emplJobID) FROM EmplEmplJob ej WHERE ej.DeptID = dept.DeptID AND ej.IsActive=0)) AS emplActiveJobCount		
	FROM
		Department dept
	LEFT OUTER JOIN Empl em on em.EmplID = dept.MgrID
	LEFT OUTER JOIN Empl em2 on em2.EmplID = dept.LastUpdatedByID
	LEFT OUTER JOIN Empl em3 on em3.EmplID = dept.ImplSpecialistID
	LEFT OUTER JOIN Empl em4 on em4.EmplID = dept.DeptRptEmplID
	LEFT OUTER JOIN CodeLookUp cdl on dept.DeptCategoryID = cdl.CodeID and CodeType = 'DeptCat'
	ORDER BY dept.DeptName

END

GO
