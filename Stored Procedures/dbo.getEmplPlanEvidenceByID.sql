SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/12/2012
-- Description:	Get  Evidence by EvidenceID
-- =============================================
CREATE PROCEDURE [dbo].[getEmplPlanEvidenceByID]
	@PlanEvidenceID AS nchar(6) 

AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT  epv.PlanEvidenceID
			,epv.EvidenceID
			,epv.PlanID
			,epv.EvidenceTypeID
			,epv.ForeignID
			,epv.IsEvalViewed
			,epv.EvalViewedDate
	FROM EmplPlanEvidence epv
	WHERE epv.IsDeleted = 0
	AND epv.PlanEvidenceID = @PlanEvidenceID
END

GO
