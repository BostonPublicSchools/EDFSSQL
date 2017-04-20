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
    @EvidenceTypeID AS INT ,
    @ForeignID AS INT
AS
    BEGIN
        SET NOCOUNT ON;

        SELECT  COUNT(DISTINCT EvidenceID) AS EvidenceCount
        FROM    dbo.EmplPlanEvidence (NOLOCK)
        WHERE   EvidenceTypeID = @EvidenceTypeID
                AND ForeignID = @ForeignID;

    END;

GO
