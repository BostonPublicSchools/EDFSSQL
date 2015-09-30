SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/10/2012
-- Description:	Get  Evidence by EvidenceID
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceByID]
	@EvidenceID AS nchar(6) 

AS
BEGIN
	SET NOCOUNT ON;
	SELECT  e.EvidenceID
			,e.[FileName]
			,e.FileExt
			,e.FileSize
			,e.[Description]
			,e.Rationale
			,e.CreatedByID
			,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + em.EmplID + ')' AS CreatedBy
			,CONVERT(varchar, e.CreatedByDt, 101) as CreatedByDt
			,e.IsEvidenceViewed
			,e.EvidenceViewedDt
			,e.EvidenceViewedBy
	FROM Evidence e
	LEFT OUTER JOIN EmplPlanEvidence epv on epv.EvidenceID = e.EvidenceID
	JOIN Empl em (NOLOCK) on em.EmplID = e.CreatedByID
	WHERE e.IsDeleted = 0
	AND e.EvidenceID = @EvidenceID
END

GO
