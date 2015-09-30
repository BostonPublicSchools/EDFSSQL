SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/24/2012
-- Description:	Delete Initative from Initative table
-- =============================================
CREATE PROCEDURE [dbo].[delInitative]
	@InitativeID	AS int = null
	,@UserID AS nchar(6) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Initiative
	SET
		IsDeleted = 1
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		InitiativeID = @InitativeID
			
END
GO
