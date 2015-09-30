SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/25/2012
-- Description:	Get  Evidence List by EvidenceTypeID and ForeignID
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceByTypeIDandForeignID]
	@EvidenceTypeID AS int
	,@ForeignID as int
AS
BEGIN
	SET NOCOUNT ON;
	SELECT	epe.PlanEvidenceID
			,epe.EvidenceID
			,epe.PlanID
			,epe.EvidenceTypeID
			,epe.ForeignID
			,e.FileName
			,e.FileExt
			,e.FileSize
			,e.CreatedByID
			,e.[Description]
			,e.Rationale
	FROM EmplPlanEvidence epe
	LEFT JOIN Evidence e (NOLOCK) ON epe.EvidenceID = e.EvidenceID
	WHERE EvidenceTypeID = @EvidenceTypeID
	AND ForeignID = @ForeignID
	AND epe.IsDeleted = 0

END

GO
