SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[insObservationDetailRubricIndicator]

	@ObsvDID as int
	,@IndicatorID as int
	,@UserID AS nchar(6)
	,@ObsvDetRubricID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	--SELECt @ObsvDetRubricID = ObsvDetRubricID from ObservationDetailRubricIndicator where IndicatorID = @IndicatorID and ObsvDID = @ObsvDID
	
	--if @ObsvDetRubricID =0
	--BEGIN
	DECLARE @ParentIndicatorID int
	SELECT @ParentIndicatorID = ParentIndicatorID from RubricIndicator where IndicatorID = @IndicatorID
	
	IF ISNULL(@ParentIndicatorID,0) <> 0
	BEGIN
		DECLARE @TempObsvDetRubricID int
		SELECT @TempObsvDetRubricID = ObsvDetRubricID FROM ObservationDetailRubricIndicator WHERE IndicatorID = @ParentIndicatorID and ObsvDID = @ObsvDID
	END
	
	IF ISNULL(@TempObsvDetRubricID, 0) <> 0
	BEGIN
			UPDATE ObservationDetailRubricIndicator set IsDeleted = 1 where ObsvDetRubricID = @TempObsvDetRubricID
			SELECT @ObsvDetRubricID = -1 
	END
	ELSE
	BEGIN
			INSERT INTO ObservationDetailRubricIndicator(ObsvDID
														,IndicatorID
														,IsDeleted
														,CreatedByID
														,CreatedByDt
														,LastUpdatedByID
														,LastUpdatedDt
														)
			VALUES(@ObsvDID,@IndicatorID,0,@UserID,GETDATE(),@UserID,GETDATE())
			SELECT @ObsvDetRubricID = SCOPE_IDENTITY();
			return
	END
	
	DECLARE @ElementID int
	SELECT top 1 @ElementID =IndicatorID from RubricIndicator WHERE ParentIndicatorID = @IndicatorID
	
	IF ISNULL(@elementID,0) <>0
	BEGIN
		DECLARE @TempObsvDetRubricID1 INT
		SELECT @TempObsvDetRubricID1 = ObsvDetRubricID FROM ObservationDetailRubricIndicator WHERE IndicatorID = @ElementID and ObsvDID = @ObsvDID
		return 
	END
	
	IF ISNULL(@TempObsvDetRubricID1,0) <>0
	BEGIN
		SELECT @ObsvDetRubricID = -1
		return
	END
	ELSE
	BEGIN
			INSERT INTO ObservationDetailRubricIndicator(ObsvDID
														,IndicatorID
														,IsDeleted
														,CreatedByID
														,CreatedByDt
														,LastUpdatedByID
														,LastUpdatedDt
														)
			VALUES(@ObsvDID,@IndicatorID,0,@UserID,GETDATE(),@UserID,GETDATE())
			SELECT @ObsvDetRubricID = SCOPE_IDENTITY();		
			return 
			
	END
	--END	
	
		
END
GO
