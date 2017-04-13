SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa, Matina
-- Create date: 01/28/2014
-- Description:	Get deleted Evidence by PlanID
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceDeletedByPlanID] @PlanID AS INT
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
                -1 SortOrder
                ,
                e.LastCommentViewDt ,
                ( SELECT    COUNT(CommentID)
                  FROM      dbo.Comment ( NOLOCK )
                  WHERE     PlanID = @PlanID
                            AND OtherID = e.EvidenceID
                            AND IsDeleted = 0
                ) AS EviCommentCount ,
                e.IsDeleted
        FROM    dbo.Evidence e ( NOLOCK )
                INNER JOIN dbo.Empl em ( NOLOCK ) ON em.EmplID = e.CreatedByID
                INNER JOIN ( SELECT DISTINCT
                                    EvidenceID
                             FROM   dbo.EmplPlanEvidence ( NOLOCK )
                             WHERE  PlanID = @PlanID
                           ) ev ON ev.EvidenceID = e.EvidenceID
        WHERE   e.IsDeleted = 1
        ORDER BY e.CreatedByDt DESC;		
    END;
GO
