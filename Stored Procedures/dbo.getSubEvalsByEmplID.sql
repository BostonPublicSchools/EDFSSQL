SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 10/12/2012
-- Description:	Get sub evals by emplID
-- =============================================
CREATE PROCEDURE [dbo].[getSubEvalsByEmplID]
	@EmplID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
(SELECT ej.MgrID AS PlanSubEvalID
		,empl.NameLast + ', ' + empl.NameFirst + ' '  + ISNULL(empl.NameMiddle,'') AS PlanSubEvalName ,
		dept.DeptID,
		dept.IsSchool
		FROM EmplEmplJob AS ej(NOLOCK) 
		LEFT OUTER JOIN Empl AS empl(NOLOCK) ON empl.EmplID = ej.MgrID
		LEFT OUTER JOIN Department AS dept(NOLOCK) ON dept.DeptID = ej.DeptID
		WHERE ej.EmplID = @EmplID AND ej.isActive = 1
	 UNION
	 SELECT 
	 CASE
				when ase.SubEvalID IS NULL
				THEN CASE
							WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
							ELSE ej.MgrID
						END
				ELSE s.EmplID
		END AS PlanSubEvalID
		,empl.NameLast + ', ' + empl.NameFirst + ' '  + ISNULL(empl.NameMiddle,'') AS PlanSubEvalName ,
		dept.DeptID,
		dept.IsSchool
		FROM 
				EmplEmplJob AS ej(NOLOCK)
		LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
		left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
														and ase.isActive = 1
														and ase.isDeleted = 0
														and ase.isPrimary = 1
		left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
										and s.EvalActive = 1
		LEFT OUTER JOIN Empl AS empl(NOLOCK) ON empl.EmplID = s.EmplID
		LEFT OUTER JOIN Department AS dept(NOLOCK) ON dept.DeptID = ej.DeptID
		WHERE ej.EmplID = @EmplID AND ej.isActive = 1
	 UNION
	 SELECT sub.EmplID AS PlanSubEvalID 
			,empl.NameLast + ', ' + empl.NameFirst + ' '  + ISNULL(empl.NameMiddle,'') AS PlanSubEvalName  ,
			dept.DeptID,
			dept.IsSchool
			FROM SubEval AS sub(NOLOCK)
			LEFT OUTER JOIN Empl AS empl(NOLOCK) ON empl.EmplID = sub.EmplID
			JOIN EmplEmplJob AS ej(NOLOCK) ON ej.MgrID = sub.MgrID
			LEFT OUTER JOIN Department AS dept(NOLOCK) ON dept.DeptID = ej.DeptID			
      WHERE ej.EmplID = @EmplID and IsActive = 1
      UNION
      SELECT ex.MgrID AS PlanSubEvalID
		,empl.NameLast + ', ' + empl.NameFirst + ' '  + ISNULL(empl.NameMiddle,'') AS PlanSubEvalName ,
		dept.DeptID,
		dept.IsSchool
		FROM EmplEmplJob AS ej(NOLOCK) 
		JOIN EmplExceptions AS ex(NOLOCK) ON ex.EmplJobID = ej.EmplJobID
		LEFT OUTER JOIN Empl AS empl(NOLOCK) ON empl.EmplID = ex.MgrID
		LEFT OUTER JOIN Department AS dept(NOLOCK) ON dept.DeptID = ej.DeptID
		WHERE ej.EmplID = @EmplID AND ej.isActive = 1)
END
GO
