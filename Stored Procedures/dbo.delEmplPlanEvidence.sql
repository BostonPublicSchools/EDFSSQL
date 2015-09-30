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
	@EvidenceTypeID int 
	,@ForeignId int
	,@EvidenceID int
	,@UserID as varchar(6) = null
	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @EvidenceTypeID1 int
	DECLARE @ForeignId1 int
	DECLARE @EvidenceID1 int
	DECLARE @UserID1 as varchar(6) 
	
	SET @EvidenceTypeID1 = @EvidenceTypeID
	SET @ForeignId1 = @ForeignId
	SET @EvidenceID1 = @EvidenceID
	SET @UserID1 = @UserID
	
	--select * from EmplPlanEvidence
	UPDATE  EmplPlanEvidence SET IsDeleted = 1 ,LastUpdatedByID= @UserID1,LastUpdatedDt= GETDATE()
	WHERE EvidenceTypeID = @EvidenceTypeID1
	AND ForeignID = @ForeignId1 AND EvidenceID = @EvidenceID1
	
END
GO
