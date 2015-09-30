SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 12/27/2012
-- Description:	Update evidence when viewed by eval
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEvidenceViewed]
	@PlanID int,
	@EvidenceID int,	
	@UserID nchar(6)

AS
BEGIN
	SET NOCOUNT ON;
	UPDATE Evidence
	SET IsEvidenceViewed = 1, 
		EvidenceViewedDt = GETDATE(),
		EvidenceViewedBy = @UserID,
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE()
	WHERE EvidenceID = @evidenceID 
END
GO
