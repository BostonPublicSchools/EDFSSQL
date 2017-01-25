SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 02/12/2013
-- Description:	Copy the new 
-- =============================================
CREATE PROCEDURE [dbo].[UpdNewFileEvidence]
    @EvidenceID INT ,
    @Description AS NVARCHAR(250) = NULL ,
    @Rationale AS NVARCHAR(MAX) = NULL ,
    @FileName AS VARCHAR(32) = NULL ,
    @FileExt AS VARCHAR(5) = NULL ,
    @FileSize INT = NULL ,
    @UserID AS VARCHAR(6) = NULL ,
    @NewEvidenceID AS INT OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT  EvidenceID ,
                FileName ,
                FileExt ,
                FileSize ,
                IsDeleted ,
                CreatedByID ,
                CreatedByDt ,
                LastUpdatedByID ,
                LastUpdatedDt ,
                Description ,
                Rationale ,
                IsEvidenceViewed ,
                EvidenceViewedDt ,
                EvidenceViewedBy ,
                LastCommentViewDt
        FROM    dbo.Evidence;
	

    END;
GO
