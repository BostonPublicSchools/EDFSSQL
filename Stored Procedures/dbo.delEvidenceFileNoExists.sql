SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:			
-- Create date: 12/20/2012
-- Description:	Delete EmplPlanEvide WHEN FILE DONOT EXISTS
-- =============================================
CREATE PROCEDURE [dbo].[delEvidenceFileNoExists]
	@EvidenceID	AS int = null
	,@UserID AS nchar(6) = null
AS
BEGIN
	SET NOCOUNT ON;
		
	UPDATE Evidence
	SET
		[Description]='MISSING FILE '+[Description]
		,IsDeleted = 1
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		EvidenceID= @EvidenceID
			
	update EmplPlanEvidence
	SET 
		 IsDeleted = 1
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		EvidenceID= @EvidenceID
END
 
GO
