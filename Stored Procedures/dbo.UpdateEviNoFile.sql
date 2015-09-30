SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 01/14/2012
-- Description:	Remove the fileName for the evidence
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEviNoFile]
		@EvidenceID AS int,
		@UserID AS nchar(6)
		
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Evidence SET
		FileName = 'NoFile',
		FileExt = 'None',
		FileSize = 0,
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE()
	WHERE EvidenceID = @EvidenceID
	
END	
GO
