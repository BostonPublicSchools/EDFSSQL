SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/18/2012
-- Description:	Delete Observation Detail
-- =============================================
CREATE PROCEDURE [dbo].[delObservationDetailRubricIndicatorByObsvDID]
	@IsDeleted bit =1,
	@ObsvDID int,
	@UserID AS nchar(6)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE ObservationDetailRubricIndicator  SET
		isDeleted = @IsDeleted
		,LastUpdatedByID =@UserID
		,LastUpdatedDt = GETDATE()
	WHERE ObsvDID = @ObsvDID			
	
		
END
GO
