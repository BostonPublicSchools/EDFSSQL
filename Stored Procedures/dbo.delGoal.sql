SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/24/2012
-- Description:	Delete goal from goal table
-- =============================================
CREATE PROCEDURE [dbo].[delGoal]
	@GoalID	AS int = null
	,@UserID AS nchar(6) = null
	,@IsDeleted AS bit = 1
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE PlanGoal
	SET
		IsDeleted = @IsDeleted
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		GoalID = @GoalID
	
--delete the artifacts associated with goals	
	DECLARE @EvidenceID AS int	
	DECLARE cEvidence CURSOR FOR SELECT
										EvidenceID
									FROM
										EmplPlanEvidence
									WHERE		
										EvidenceTypeID = (select CodeID from CodeLookUp where CodeText = 'Goal Evidence')
									AND ForeignID = @GoalID
	
	OPEN cEvidence
	FETCH NEXT FROM cEvidence INTO @EvidenceID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE EmplPlanEvidence
		SET
			IsDeleted = @IsDeleted
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE
			EvidenceID = @EvidenceID
			
		UPDATE Evidence
		SET
			IsDeleted = @IsDeleted
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE
			EvidenceID = @EvidenceID
	FETCH NEXT FROM cEvidence INTO @EvidenceID
	END		
	CLOSE cEvidence
	DEALLOCATE	cEvidence
	
	--delete actionsteps for the goals
	UPDATE GoalActionStep
	SET
		IsDeleted = @IsDeleted
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		GoalID = @GoalID
			
END
GO
