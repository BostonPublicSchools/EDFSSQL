SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/23/2012
-- Description:	Get  Evidence count by EvidenceTypeID and ForeignID
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceCountByTypeIDandForeignID]
	@EvidenceTypeID AS int
	,@ForeignID as int
AS
BEGIN
	SET NOCOUNT ON;
	SELECT COUNT( distinct evidenceID) as EvidenceCount
	FROM EmplPlanEvidence
	WHERE EvidenceTypeID = @EvidenceTypeID
	AND ForeignID = @ForeignID

END

GO
