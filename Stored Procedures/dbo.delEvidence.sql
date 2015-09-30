SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 05/24/2012
-- Description:	Delete Evidence from Evidence table  and EmplPlanEvide
-- =============================================
CREATE PROCEDURE [dbo].[delEvidence]
	@EvidenceID	AS int = null
	,@UserID AS nchar(6) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Evidence
	SET
		IsDeleted = 1
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		EvidenceID= @EvidenceID
			
	--deleting completely those that are already deleted to maintain consistency with last update
	Delete From EmplPlanEvidence where EvidenceID= @EvidenceID And IsDeleted=1
	
	update EmplPlanEvidence
	SET 
		IsDeleted = 1
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		EvidenceID= @EvidenceID
		And IsDeleted=0
END
GO
