SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/19/2012
-- Description:	Get  Evidence by PlanID
-- =============================================
CREATE PROCEDURE [dbo].[getEmplPlanEvidenceByPlanID]
	@PlanID AS int

AS
BEGIN
	SET NOCOUNT ON;
	
SELECT	epe.PlanEvidenceID
		,epe.EvidenceID
		,epe.PlanID
		,epe.EvidenceTypeID
		,c.CodeText as EvidenceType
		,epe.ForeignID
		,e.[FileName]
		,e.FileExt
		,e.FileSize
		,e.CreatedByID
		,e.[Description]
		,e.Rationale
		,e.IsEvidenceViewed
		,e.EvidenceViewedDt
		,e.EvidenceViewedBy
FROM EmplPlanEvidence epe
LEFT JOIN Evidence e ON e.EvidenceID = epe.EvidenceID
JOIN CodeLookUp c (nolock) on c.CodeID = epe.EvidenceTypeID
WHERE epe.PlanID = @PlanID

END
GO
