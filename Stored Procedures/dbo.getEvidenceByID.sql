SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/10/2012
-- Description:	Get  Evidence by EvidenceID
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceByID] @EvidenceID AS NCHAR(6)
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT  e.EvidenceID ,
                e.FileName ,
                e.FileExt ,
                e.FileSize ,
                e.Description ,
                e.Rationale ,
                e.CreatedByID ,
                em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle,
                                                              '') + ' ('
                + em.EmplID + ')' AS CreatedBy ,
                CONVERT(VARCHAR, e.CreatedByDt, 101) AS CreatedByDt ,
                e.IsEvidenceViewed ,
                e.EvidenceViewedDt ,
                e.EvidenceViewedBy
        FROM    dbo.Evidence e ( NOLOCK )
                LEFT OUTER JOIN dbo.EmplPlanEvidence epv ( NOLOCK ) ON epv.EvidenceID = e.EvidenceID
                JOIN dbo.Empl em ( NOLOCK ) ON em.EmplID = e.CreatedByID
        WHERE   e.IsDeleted = 0
                AND e.EvidenceID = @EvidenceID;
    END;

GO
