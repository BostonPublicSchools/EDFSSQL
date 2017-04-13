SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/23/2012
-- Description:	Get  Evidence by PlanID
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceByPlanID] @PlanID AS INT
AS
    BEGIN
        SET NOCOUNT ON;
	
        SELECT  e.EvidenceID ,
                e.FileName ,
                e.FileExt ,
                e.FileSize ,
                e.CreatedByID ,
                e.CreatedByDt ,
                @PlanID PlanID ,
                e.Description ,
                e.Rationale ,
                em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle,
                                                              '') + ' ('
                + e.CreatedByID + ')' AS CreatedBy ,
                CONVERT(VARCHAR, e.CreatedByDt, 101) AS CreatedByDt ,
                e.IsEvidenceViewed ,
                e.EvidenceViewedDt ,
                e.EvidenceViewedBy ,
                -1 SortOrder--[s.SortOrder]
                ,
                e.LastCommentViewDt ,
                ( SELECT    COUNT(CommentID)
                  FROM      dbo.Comment ( NOLOCK )
                  WHERE     PlanID = @PlanID
                            AND OtherID = e.EvidenceID
                            AND IsDeleted = 0
                ) AS EviCommentCount
        FROM    dbo.Evidence e ( NOLOCK )
                JOIN dbo.Empl em ( NOLOCK ) ON em.EmplID = e.CreatedByID
                INNER JOIN ( SELECT DISTINCT
                                    EvidenceID
                             FROM   dbo.EmplPlanEvidence ( NOLOCK )
                             WHERE  PlanID = @PlanID
                           ) ev ON ev.EvidenceID = e.EvidenceID
        WHERE   e.IsDeleted = 0
        ORDER BY e.CreatedByDt DESC;		
    END;



GO
