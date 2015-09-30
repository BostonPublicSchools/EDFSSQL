SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/23/2012
-- Description:	Get  Evidence by PlanID
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceByPlanID]
	@PlanID AS int 

AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
			e.EvidenceID
			,e.FileName
			,e.FileExt
			,e.FileSize
			,e.CreatedByID
			,e.CreatedByDt
			,@PlanID PlanID
			,e.[Description]
			,e.Rationale
			,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID + ')' AS CreatedBy
			,CONVERT(varchar, e.CreatedByDt, 101) as CreatedByDt
			,e.IsEvidenceViewed
			,e.EvidenceViewedDt
			,e.EvidenceViewedBy
			,-1 [SortOrder]--[s.SortOrder]
			,e.LastCommentViewDt
			,(SELECT COUNT(*) FROM Comment WHERE PlanID = @PlanID and OtherID = e.EvidenceID and IsDeleted = 0) as EviCommentCount
	FROM Evidence  e
	JOIN Empl em (NOLOCK) on em.EmplID = e.CreatedByID	
	INNER JOIN 	(select DISTINCT EvidenceID from EmplPlanEvidence where PlanID=@PlanID) ev on ev.EvidenceID= e.EvidenceID
	WHERE e.IsDeleted = 0
	order by
		e.CreatedByDt desc		
END



GO
