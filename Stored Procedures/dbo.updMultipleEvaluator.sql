SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 02/08/2013
-- Description:	Updates to a new evaluator
-- =============================================
CREATE PROCEDURE [dbo].[updMultipleEvaluator]
	@SubEvalID	AS nchar(6) = null
	,@EmplID	AS nchar(6) = null
	,@MgrID		AS nchar(6)
	,@UserID	AS nchar(6) = null
	,@IsChecked AS bit = 0
	,@EmplJobID	as int = 0
	,@IsPrimary AS bit = 0
	,@IsEvalManager AS bit = 0
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @EvalID int = 0
		DECLARE @AssignedSubevaluatorID int =0
		
		IF(@SubEvalID != @MgrID)
		BEGIN
			SELECT @EvalID = EvalID 
			FROM SubEval
			WHERE EmplID = @SubEvalID AND MgrID = @MgrID AND EvalActive = 1
			
			IF(@EvalID = 0)
			BEGIN 
				INSERT INTO SubEval(MgrID, EmplID, EvalActive, Is5StepProcess, IsEvalManager, IsNon5StepProcess, CreatedByDt, CreatedByID, LastUpdatedByID, LastUpdatedDt)
				VALUES(@MgrID, @SubEvalID, 1, 1, 1, @IsEvalManager, GETDATE(), '000000', '000000', GETDATE())
				
				SET @EvalID = SCOPE_IDENTITY()
			END 
			
			--save only if eval relation exists 
			If(@EvalID != 0)
			BEGIN
				SELECT @AssignedSubevaluatorID = AssignedSubevaluatorID 
				FROM SubevalAssignedEmplEmplJob 
				WHERE SubEvalID = @EvalID AND EmplJobID = @EmplJobID and IsActive =1 and IsDeleted = 0
				
				---if any primary exists for the empljob and if the current update is primary, remove the old primary and update the new.
				UPDATE SubevalAssignedEmplEmplJob 
				SET IsPrimary = 0,
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
				WHERE EmplJobID in (SELECT EmplJobID from EmplEmplJob where EmplID = @EmplID) and SubEvalID != @EvalID and @IsPrimary = 1
			
				IF @AssignedSubevaluatorID IS NOT NULL AND @AssignedSubevaluatorID != 0
					BEGIN
						UPDATE SubevalAssignedEmplEmplJob
						SET IsActive = @IsChecked,
							IsDeleted = (CASE WHEN @IsChecked = 0 THEN 1 ELSE 0 END),
							IsPrimary = @IsPrimary,
							LastUpdatedByID = @UserID,
							LastUpdatedDt = GETDATE()
						WHERE AssignedSubevaluatorID = @AssignedSubevaluatorID			
					END
				ELSE
					BEGIN
					IF @EvalID IS NOT NULL AND @IsChecked != 0		
						INSERT INTO SubevalAssignedEmplEmplJob (EmplJobID, SubEvalID, IsPrimary, IsActive, CreatedByID, LastUpdatedByID, LastUpdatedDt, CreatedByDt)
												VALUES(@EmplJobID, @EvalID, @IsPrimary, @IsChecked, @UserID, @UserID, GETDATE(), GETDATE())
					END	
			END
		END
	
	IF(@IsPrimary = 1)
	BEGIN
	  --if its primary update all the plan of all the jobs of an employee provided the job is Lic.
		UPDATE EmplPlan SET 
			SubEvalID = @SubEvalID,
			LastUpdatedByID = @UserID,
			LastUpdatedDt = GETDATE()
		WHERE (EmplJobID in (SELECT EmplJobID from EmplEmplJob ej
							join RubricHdr rh on ej.RubricID = rh.RubricID
							where ej.IsActive=1 and ej.EmplID = @EmplID and rh.Is5StepProcess = 0) OR EmplJobID = @EmplJobID) and PlanActive = 1
	END	
	
	--update the plansubeval when the primary is also changed/removed
	ELSE IF(@IsPrimary = 0 and @SubEvalID = (SELECT top 1 SubEvalID FROM EmplPlan WHERE EmplJobID = @EmplJobID and PlanActive = 1))
	BEGIN
		UPDATE ep SET 
			ep.SubEvalID = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID),
			ep.LastUpdatedByID = @UserID,
			ep.LastUpdatedDt = GETDATE()
		FROM EmplPlan ep 	
		JOIN EmplEmplJob ej on ep.EmplJobID = ej.EmplJobID		
		WHERE ep.EmplJobID = @EmplJobID and ep.PlanActive = 1
	END
END


GO
