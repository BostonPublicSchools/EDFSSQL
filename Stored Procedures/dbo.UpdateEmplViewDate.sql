SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 12/26/2012
-- Description:	Update EmplView when viewed by employee
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEmplViewDate]
	@ObsvID int,
	@UserID nchar(6)

AS
BEGIN
	SET NOCOUNT ON;
	UPDATE ObservationHeader
	SET IsEmplViewed = 1, 
		EmplViewedDate = GETDATE(),
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE()
	WHERE ObsvID = @ObsvID 
END
GO
