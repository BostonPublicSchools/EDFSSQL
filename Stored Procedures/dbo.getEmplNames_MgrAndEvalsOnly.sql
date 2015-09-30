SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa, Matina
-- Create date: 03/24/2014
-- Description:	list of Managers and Evaluators and allow id for search
-- =============================================
Create PROCEDURE [dbo].[getEmplNames_MgrAndEvalsOnly]
 @searchText AS nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

SELECT * FROM 
(	
	--Get Managers 
		SELECT
			 em.NameFirst
			,em.NameLast
			,em.NameMiddle
			,em.EmplID
			,em.EmplActive
			--,d.DeptID
		FROM
			Empl AS em
		JOIN Department d on em.EmplID= d.MgrID
		WHERE em.EmplActive=1 	
	UNION 	
	-- Get Evaluators
		SELECT
			 em.NameFirst
			,em.NameLast
			,em.NameMiddle
			,em.EmplID
			,em.EmplActive		
		FROM
			Empl AS em
		JOIN (		
				SELECT distinct s.EmplID					
				FROM
					SubevalAssignedEmplEmplJob as subass
				JOIN SubEval s (nolock) on subass.SubEvalID = s.EvalID
				WHERE						
					 subass.isActive = 1
					 AND subass.isDeleted = 0
				) tbEvaluator
		ON em.EmplID = tbEvaluator.EmplID
		WHERE em.EmplActive=1
) AS tblMgrAndEvals
WHERE 
	ISNULL(tblMgrAndEvals.NameFirst,'') + ISNULL(tblMgrAndEvals.NameMiddle,'') + ISNULL(tblMgrAndEvals.NameLast,'') like '%'+@searchText+'%'

END;
	
GO
