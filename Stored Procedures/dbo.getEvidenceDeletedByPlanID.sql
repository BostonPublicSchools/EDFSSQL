SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa, Matina
-- Create date: 01/28/2014
-- Description:	Get deleted Evidence by PlanID
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceDeletedByPlanID]
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
			,e.IsDeleted
	FROM Evidence  e
	INNER JOIN Empl em (NOLOCK) on em.EmplID = e.CreatedByID
	INNER JOIN 	(select DISTINCT EvidenceID from EmplPlanEvidence where PlanID=@PlanID) ev on ev.EvidenceID= e.EvidenceID
	WHERE e.IsDeleted = 1
	order by
		e.CreatedByDt desc		
END



GO
