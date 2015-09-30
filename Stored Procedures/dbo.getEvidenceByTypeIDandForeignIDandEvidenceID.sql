SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/25/2012
-- Description:	Get  Evidence List by EvidenceTypeID and ForeignID and EvidenceID
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceByTypeIDandForeignIDandEvidenceID]
	@EvidenceTypeID AS int
	,@ForeignID as int
	,@EvidenceID as int
AS
BEGIN
	DECLARE @EvidenceTypeID1 int
	DECLARE @ForeignID1 int
	DECLARE @EvidenceID1 int
	
	set @EvidenceTypeID1 = @EvidenceTypeID
	set @ForeignID1 = @ForeignID
	set @EvidenceID1 = @EvidenceID
		
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
	WHERE EvidenceTypeID =@EvidenceTypeID1
	AND ForeignID =@ForeignID1
	and epe.EvidenceID = @EvidenceID1
	AND epe.IsDeleted = 0

END

GO
