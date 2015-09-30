SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/24/2012
-- Description:	edit the observation release date,
-- isdeleted, iseditenddate
-- =============================================
CREATE PROCEDURE [dbo].[editObservationHeader]
	@ObsvID AS int,	
	@ObservationRelease AS bit,
	@IsDeleted AS bit,	
	@ObsvReleaseDate AS DateTime = null,
	@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE ObservationHeader SET 
			ObsvRelease = @ObservationRelease,
			IsDeleted = @IsDeleted,			
			LastUpdatedByID = @UserID,
			LastUpdatedDt = GETDATE(),			
			ObsvReleaseDt = (CASE WHEN @ObservationRelease = 1
								  THEN @ObsvReleaseDate
								  ELSE ObsvReleaseDt
								  END)								
	WHERE ObsvID = @ObsvID
END
GO
