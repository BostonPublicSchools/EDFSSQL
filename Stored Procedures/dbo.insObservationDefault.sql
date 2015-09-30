SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[insObservationDefault]
	
	@EmplID as nchar(6)
	,@RubricID as int	
	,@IndicatorID AS int 
	,@IsActive as bit
	,@UserID AS nchar(6)
	,@ObsRubricID int OUTPUT 
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO ObservationRubricDefault(EmplID,RubricID,IndicatorID,IsActive,CreatedByID,CreatedByDt,LastUpdatedByID,LastUpdatedDt)
	VALUES (@EmplID,@RubricID,@IndicatorID,@IsActive,@UserID,GETDATE(),@UserID,GETDATE())
	SELECT @ObsRubricID = SCOPE_IDENTITY();	
	
END
GO
