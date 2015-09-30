SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 01/17/2013
-- Description: 
-- =============================================


Create View [dbo].[vwArtifactsByEviType] 
AS 
	(SELECT COUNT(evidenceID) AS EvidenceCount, epv.PlanID, epv.EvidenceTypeID, rs.StandardID AS ForeignID, rs.SortOrder FROM EmplPlanEvidence epv
	JOIN CodeLookUp cdl ON cdl.CodeID = epv.EvidenceTypeID AND cdl.CodeType = 'eviType' AND cdl.CodeText = 'Standard Evidence'
	JOIN RubricStandard rs ON rs.StandardID = epv.ForeignID
	GROUP BY epv.PlanID, rs.StandardID, rs.SortOrder, epv.EvidenceTypeID
	UNION
	SELECT COUNT(evidenceID) as EvidenceCount, epv.PlanID, epv.EvidenceTypeID, pg.GoalID AS ForeignID, 0 FROM EmplPlanEvidence epv
	JOIN CodeLookUp cdl ON cdl.CodeID = epv.EvidenceTypeID AND cdl.CodeType = 'eviType' AND cdl.Code = 'eviG'
	JOIN PlanGoal pg ON pg.GoalID = epv.ForeignID 
	GROUP BY  epv.PlanID, pg.GoalID, epv.EvidenceTypeID)

GO
