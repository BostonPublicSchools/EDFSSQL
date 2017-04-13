SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 08/20/2012
-- Description:	delete EmplPlanEvidence
-- =============================================
CREATE PROCEDURE [dbo].[delEmplPlanEvidence]
    @EvidenceTypeID INT ,
    @ForeignId INT ,
    @EvidenceID INT ,
    @UserID AS VARCHAR(6) = NULL
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @EvidenceTypeID1 INT;
        DECLARE @ForeignId1 INT;
        DECLARE @EvidenceID1 INT;
        DECLARE @UserID1 AS VARCHAR(6); 
	
        SET @EvidenceTypeID1 = @EvidenceTypeID;
        SET @ForeignId1 = @ForeignId;
        SET @EvidenceID1 = @EvidenceID;
        SET @UserID1 = @UserID;
	
        UPDATE  dbo.EmplPlanEvidence
        SET     IsDeleted = 1 ,
                LastUpdatedByID = @UserID1 ,
                LastUpdatedDt = GETDATE()
        WHERE   EvidenceTypeID = @EvidenceTypeID1
                AND ForeignID = @ForeignId1
                AND EvidenceID = @EvidenceID1;
	
    END;
GO
