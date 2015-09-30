SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[updObservationDefault]
	@ObsRubricID AS int
	,@EmplID as nchar(6)
	,@RubricID as int	
	,@IndicatorID AS int 
	,@IsActive as bit
	,@IsDeleted as bit = 0
	,@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE ObservationRubricDefault 
	SET EmplID  = @EmplID
		,RubricID = @RubricID
		,IndicatorID = @IndicatorID
		,IsActive = @IsActive
		,IsDeleted = @IsDeleted
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE  obsRubricID = @ObsRubricID
	
END
GO
