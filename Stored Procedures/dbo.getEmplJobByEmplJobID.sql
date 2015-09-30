SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/17/2012
-- Description:	List employees assigned to a supervisor
-- =============================================
CREATE PROCEDURE [dbo].[getEmplJobByEmplJobID]
	@EmplJobID as int
AS	
BEGIN
		SET NOCOUNT ON;
		
	SELECT distinct
		e.EmplID
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
		,dbo.funcGetPrimaryManagerByEmplID(e.EmplID)as subevalID --if its manager , then get the primary subeval
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmplName
		,ej.EmplJobID
		,ej.RubricID
		,j.JobCode
		,j.JobName						
		,j.UnionCode
		,d.DeptID
		,d.DeptName
		,ej.FTE
		,rh.RubricName
		,(case when (ej.IsActive=1 and rh.IsActive =1) then 1 else 0 end) IsEmpJobActive
		, ej.EmplClass
	FROM
		Empl			AS e	(NOLOCK)
	JOIN EmplEmplJob	AS ej	(NOLOCK)	ON e.EmplID = ej.EmplID
											--AND ej.IsActive = 1
	LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	
	join RubricHdr as rh (nolock) on ej.RubricID = rh.RubricID
	JOIN department     AS d	(NOLOCK)    ON ej.DeptID = d.DeptID
	JOIN EmplJob		AS j	(NOLOCK)	ON ej.JobCode = j.JobCode	
	WHERE
		e.EmplActive = 1 
		and ej.EmplJobID = @EmplJobID
END


GO
