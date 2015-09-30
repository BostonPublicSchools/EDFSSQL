SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		khanpara,krunal	
-- Create date: 10/24/2012
-- Description:	 flag observation header deleted
-- =============================================
CREATE PROCEDURE [dbo].[delObservationHeader]
	@ObservationID	AS int 
	,@UserID as nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE ObservationHeader
	SET
		IsDeleted = 1
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		ObsvID = @ObservationID
			
END

GO
