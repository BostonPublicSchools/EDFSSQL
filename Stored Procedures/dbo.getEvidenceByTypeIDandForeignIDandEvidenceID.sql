SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/25/2012
-- Description:	Get  Evidence List by EvidenceTypeID and ForeignID and EvidenceID
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceByTypeIDandForeignIDandEvidenceID]
    @EvidenceTypeID AS INT ,
    @ForeignID AS INT ,
    @EvidenceID AS INT
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @EvidenceTypeID1 INT;
        DECLARE @ForeignID1 INT;
        DECLARE @EvidenceID1 INT;
	
        SET @EvidenceTypeID1 = @EvidenceTypeID;
        SET @ForeignID1 = @ForeignID;
        SET @EvidenceID1 = @EvidenceID;
		
        SELECT  epe.PlanEvidenceID ,
                epe.EvidenceID ,
                epe.PlanID ,
                epe.EvidenceTypeID ,
                epe.ForeignID ,
                e.FileName ,
                e.FileExt ,
                e.FileSize ,
                e.CreatedByID ,
                e.Description ,
                e.Rationale
        FROM    dbo.EmplPlanEvidence epe ( NOLOCK )
                LEFT JOIN dbo.Evidence e ( NOLOCK ) ON epe.EvidenceID = e.EvidenceID
        WHERE   epe.EvidenceTypeID = @EvidenceTypeID1
                AND epe.ForeignID = @ForeignID1
                AND epe.EvidenceID = @EvidenceID1
                AND epe.IsDeleted = 0;

    END;

GO
