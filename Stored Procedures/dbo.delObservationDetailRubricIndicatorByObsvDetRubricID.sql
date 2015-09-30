SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa, Matina
-- Create date: 12/21/2013
-- Description:	Delete Observation Detail rubric tags by ObsvDetRubricID
-- =============================================
CREATE PROCEDURE [dbo].[delObservationDetailRubricIndicatorByObsvDetRubricID]	
	@ObsvDetRubricID int =null,
	@UserID AS nchar(6),
	@IsDeleted bit = 1
	
AS
BEGIN
	SET NOCOUNT ON;
		UPDATE ObservationDetailRubricIndicator  
		SET
			 isDeleted = @IsDeleted
			,LastUpdatedByID =@UserID
			,LastUpdatedDt = GETDATE()
		WHERE ObsvDetRubricID = @ObsvDetRubricID
END
GO
