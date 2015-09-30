SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/24/2012
-- Description:	Updates an individual goal status
-- =============================================
CREATE PROCEDURE [dbo].[updIndGoalStatus]
	@GoalID	AS int
	,@GoalStatus AS nvarchar(50) = null
	,@UserID AS nchar(6) = null
	,@IsAdmin as bit = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @GoalStatusID AS int
	
	
	SELECT
		@GoalStatusID =	CodeID 
	FROM 
		CodeLookUp 
	WHERE
		CodeText = @GoalStatus and CodeType = 'GoalStatus'
	
	UPDATE PlanGoal
	SET
		GoalStatusID = @GoalStatusID
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		GoalID = @GoalID
	
	IF @IsAdmin = 1
	BEGIN
		IF @GoalStatus = 'Returned' OR @GoalStatus = 'Ignored' 
		BEGIN
			DECLARE @ActnStepStatusID AS int
			SELECT @ActnStepStatusID = CodeID FROM CodeLookUp WHERE CodeText = (CASE WHEN @GoalStatus = 'Returned' THEN 'Returned' 
																					 WHEN @GoalStatus = 'Ignored' THEN 'Ignored'
																					 END) and CodeType = 'AcnStatus'
			UPDATE GoalActionStep 
			SET ActionStepStatusID = @ActnStepStatusID,
				LastUpdatedByID = @UserID,
				LastUpdatedDt = GETDATE()
			WHERE GoalID = @GoalID and ActionStepStatusID != (SELECT CodeID FROM CodeLookUp WHERE CodeText = 'In Process' and CodeType = 'AcnStatus')								 
		END	
	END
END
GO
