SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 01/02/2013
-- Description:	Get  Evidence and FileSize by PlanID
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceSizeByPlanID]
	@PlanID AS int

AS
BEGIN
	SET NOCOUNT ON;
	select	EvidenceID
			,[FileName]
			,FileExt
			,FileSize 
	from Evidence 
	where EvidenceID in (select distinct EvidenceID from EmplPlanEvidence where PlanID = @PlanID and IsDeleted = 0) and IsDeleted =0

END

GO
