SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/24/2012
-- Description:	Updates a goal
-- =============================================
CREATE PROCEDURE [dbo].[updGoal]
	@GoalID	AS int = null
	,@GoalTypeID AS int = null
	,@GoalLevelID AS int = null
	,@GoalText AS nvarchar(max) = null
	,@GoalTag AS nvarchar(max) = null
	,@UserID AS nchar(6) = null
	,@ProgressCodeID AS int = null
	,@Rationale AS nvarchar(max) = null
	,@EvalID AS int = null
	,@GoalEvalID AS int = null
	--,@GoalTagAcnTypeID as int = 0
	,@isCanceldSignOff as int = 0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE PlanGoal
	SET
	 GoalTypeID = @GoalTypeID
	 ,GoalLevelID = @GoalLevelID
	 ,GoalText = @GoalText
	 ,LastUpdatedByID = @UserID
	 ,LastUpdatedDt = GETDATE()
	WHERE
		GoalID = @GoalID
		
	--Future enhancement don't delete goal tags but validate changes and update only those that are needed.
	--IF @GoalTag IS NOT NULL --
	IF @EvalID = 0 And @GoalID <>0
	BEGIN
		DELETE 
		FROM 
			GoalTag
		WHERE
			GoalID = @GoalID
		
		--IF(@GoalTagAcnTypeID = 0)
		--BEGIN
		--	SELECT @GoalTagAcnTypeID = CODEID FROM CodeLookUp WHERE CodeType = 'GoalTagAcn' and CodeText= 'ElementType'
		--END			
			
		DECLARE @NextString nvarchar(max)
		DECLARE @Pos INT
		DECLARE @NextPos INT
		DECLARE @Delimiter NVARCHAR(40)

		SET @Delimiter = ', '
		SET @Pos = charindex(@Delimiter, @GoalTag)

		WHILE (@pos <> 0)
		BEGIN
			SET @NextString = substring(@GoalTag,1,@Pos - 1)
			INSERT INTO GoalTag (GoalID, GoalTagID, CreatedByID, LastUpdatedByID)
						VALUES (@GoalID, @NextString, @UserId, @UserId)
			SET @GoalTag = substring(@GoalTag,@pos+1,len(@GoalTag))
			SET @pos = charindex(@Delimiter,@GoalTag)
			
		END
	END

	IF NOT @EvalID = 0
	BEGIN
		IF @GoalEvalID = 0 AND NOT EXISTS(SELECT GoalEvalID FROM GoalEvaluationProgress WHERE GoalID=@GoalID and EvalId=@EvalID)
		BEGIN
			INSERT INTO GoalEvaluationProgress (GoalID, EvalId, ProgressCodeID, Rationale, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
									VALUES(@GoalID, @EvalID, @ProgressCodeID, @Rationale, @UserID, GETDATE(), @UserID, GETDATE())
		
		END
		ELSE
		BEGIN 
		
			DECLARE @PreviousGoalProgressID AS INT
			SELECT @PreviousGoalProgressID = ProgressCodeID FROM GoalEvaluationProgress WHERE GoalEvalID = @GoalEvalID
			UPDATE GoalEvaluationProgress
			SET
				ProgressCodeID = @ProgressCodeID
				,Rationale = @Rationale
				,LastUpdatedByID = @UserID
				,LastUpdatedDt = GETDATE()
			WHERE
				GoalEvalID = @GoalEvalID
				
			IF Exists(SELECT * FROM Evaluation WHERE EvalID=@EvalID and IsSigned=1 and (DATEDIFF(DAY, GETDATE(), EditEndDt) >= 0))
			BEGIN				
				 IF (@PreviousGoalProgressID != @ProgressCodeID)				 
				 BEGIN	
					UPDATE Evaluation  SET
					IsSigned = 0,
					EvaluatorSignedDt = NULL,
					EvaluatorsSignature = NULL,
					EmplSignature = NULL,
					EmplSignedDt = NULL,
					OverallRatingID = NULL,			
					LastUpdatedByID = @UserID,
					LastUpdatedDt = GETDATE()
					WHERE EvalID  =  @EvalID
				   
					SET @isCanceldSignOff = 1
					
					--###Update PlanYear from 2 to 1 when evauation is formative for SD Plan
					Declare @IsMultiyear int, @PlanTypeID int,@PlanYear int, @PlanID int
					SELECT @IsMultiyear = IsMultiYearPlan, @PlanTypeID=PlanTypeID,@PlanYear= PlanYear, @PlanID=PlanID 
						FROM EmplPlan 
						WHERE PlanID =(SELECT TOP 1 PlanID 
										FROM Evaluation 
										WHERE 
											EvalID=@EvalID And 
											EvalPlanYear=1 And
											EvalTypeID=(Select top 1 CodeID From CodeLookUp where CodeType='EvalType' and CodeText='Formative Evaluation' )
										)
					IF @IsMultiyear=1 AND @PlanTypeID=1 AND @PlanYear =2 
					BEGIN
						UPDATE EmplPlan 
						SET PlanYear=1
						WHERE PlanID =@PlanID
					END	
				 	--###
				 	   
				END 		
			END	
				
		END
		
	END
		
END
GO
