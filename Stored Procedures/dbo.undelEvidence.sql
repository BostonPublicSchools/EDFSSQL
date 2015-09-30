SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa, Matina
-- Create date: 01/28/2014
-- Description:	Reset delete Evidence back to undelete from Evidence and EmplPlanEvidence tables
-- =============================================
CREATE PROCEDURE [dbo].[undelEvidence]
	@EvidenceID	AS int = null
	,@UserID AS nchar(6) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Evidence
	SET
		IsDeleted = 0
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		EvidenceID= @EvidenceID
			
	update EmplPlanEvidence
	SET 
		IsDeleted = 0
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		EvidenceID= @EvidenceID
END
GO
