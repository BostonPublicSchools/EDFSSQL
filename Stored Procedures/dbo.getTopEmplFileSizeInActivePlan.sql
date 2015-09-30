SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa, Matina
-- Create date: 01/22/2014
-- Description:	Top 10 empl based on size of artifacts in InActive Plan
-- =============================================
CREATE PROCEDURE [dbo].[getTopEmplFileSizeInActivePlan]

AS
BEGIN

	SELECT TOP 10 ISNULL(e1.NameFirst, '') + ' ' + ISNULL(e1.NameMiddle, '') + ' ' + ISNULL(e1.NameLast, '') AS EmplName
		,e1.EmplID
		,Max(ep.PlanID) AS PlanID
		,EmplList.TotalSize
	FROM (
		SELECT eej.EmplID
			,sum(TEMP.FileSize) AS TotalSize
		FROM (
			SELECT DISTINCT evi.EvidenceID
				,evi.FileSize
				,ep.EmplJobID
			FROM Evidence evi
			LEFT JOIN EmplPlanEvidence epe ON epe.EvidenceID = evi.EvidenceID
			LEFT JOIN EmplPlan ep ON ep.PlanID = epe.PlanID
			WHERE ep.PlanActive = 0 and ep.IsInvalid = 0
				AND evi.IsDeleted = 0 and epe.IsDeleted = 0
			) AS TEMP
		LEFT JOIN EmplEmplJob eej ON eej.EmplJobID = TEMP.EmplJobID
		LEFT JOIN Empl e ON eej.EmplID = e.EmplID
		GROUP BY eej.EmplID
		) AS EmplList
	LEFT JOIN Empl e1 ON e1.EmplID = EmplList.EmplID
	LEFT JOIN EmplEmplJob eej ON eej.EmplID = e1.EmplID --and eej.IsActive = 0
	LEFT JOIN EmplPlan ep ON ep.EmplJobID = eej.EmplJobID
	GROUP BY e1.NameFirst
		,e1.NameMiddle
		,e1.NameLast
		,e1.EmplID
		,empllist.TotalSize
	ORDER BY EmplList.TotalSize DESC
				
		
END


GO
