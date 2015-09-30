SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
Create PROCEDURE [dbo].[delStandard]
	@StandardID	AS int = null
	,@UserID AS nchar(6) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE RubricStandard
	SET
		IsDeleted = 1
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		StandardID = @StandardID
			
END



GO
