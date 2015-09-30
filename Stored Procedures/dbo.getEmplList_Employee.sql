SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/17/2012
-- Description:	Get employee record
-- =============================================
CREATE PROCEDURE [dbo].[getEmplList_Employee]
	@ncUserId AS nchar(6) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		e.EmplID
		--,d.MgrID
		--,de.NameLast + ', ' + de.NameFirst + ' ' + ISNULL(de.NameMiddle, '') AS ManagerName
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE d.MgrID
			END) as MgrID
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = emplEx.MgrID) 
			ELSE (de.NameLast + ', ' + de.NameFirst + ' ' + ISNULL(de.NameMiddle, ''))
		  END) as ManagerName
		,(CASE ej.SubEvalID 
			WHEN '000000' THEN (CASE 
								WHEN (emplEx.MgrID IS NOT NULL)
								THEN emplEx.MgrID
								ELSE d.MgrID
								END)
			ELSE ej.SubEvalID 
			END) AS SubEvalID 
		,s.NameLast + ', ' + s.NameFirst + ' ' + ISNULL(s.NameMiddle, '') AS SubEvalName
		,e.NameFirst
		,e.NameMiddle
		,e.NameLast
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')' AS EmplName
		,e.EmplActive
		,ej.EmplJobID
		,j.JobCode
		,j.JobName
		,(SELECT
				COUNT(p.PlanID)
			FROM
				EmplPlan AS p (NOLOCK)
			WHERE
				p.EmplJobID = ej.EmplJobID) AS PlanCount
	FROM
		Empl AS e	 (NOLOCK)
	JOIN EmplEmplJob AS ej	 (NOLOCK)	ON e.EmplID = ej.EmplID
										AND ej.EmplRcdNo <= 20
	JOIN department     AS d	(NOLOCK)    ON ej.DeptID = d.DeptID
	JOIN EmplJob AS j	 (NOLOCK)		ON ej.JobCode = j.JobCode
	JOIN Empl AS s (NOLOCK) ON CASE ej.SubEvalID 
									WHEN '000000' THEN d.MgrID
									ELSE ej.SubEvalID 
								END	 = s.EmplID
	JOIN Empl           AS de    (NOLOCK)   ON de.EmplID = d.MgrID	
	LEFT OUTER JOIN EmplExceptions AS emplEx(NOLOCK) ON emplEx.EmplJobID = ej.EmplJobID
	WHERE
		e.EmplActive = 1
	AND e.EmplID = @ncUserId 
END
GO
