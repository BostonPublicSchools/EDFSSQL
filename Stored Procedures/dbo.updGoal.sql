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
    @GoalID AS INT = NULL ,
    @GoalTypeID AS INT = NULL ,
    @GoalLevelID AS INT = NULL ,
    @GoalText AS NVARCHAR(MAX) = NULL ,
    @GoalTag AS NVARCHAR(MAX) = NULL ,
    @UserID AS NCHAR(6) = NULL ,
    @ProgressCodeID AS INT = NULL ,
    @Rationale AS NVARCHAR(MAX) = NULL ,
    @EvalID AS INT = NULL ,
    @GoalEvalID AS INT = NULL
	--,@GoalTagAcnTypeID as int = 0
    ,
    @isCanceldSignOff AS INT = 0 OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;
	
        UPDATE  dbo.PlanGoal
        SET     GoalTypeID = @GoalTypeID ,
                GoalLevelID = @GoalLevelID ,
                GoalText = @GoalText ,
                LastUpdatedByID = @UserID ,
                LastUpdatedDt = GETDATE()
        WHERE   GoalID = @GoalID;
		
	--Future enhancement don't delete goal tags but validate changes and update only those that are needed.
	--IF @GoalTag IS NOT NULL --
        IF @EvalID = 0
            AND @GoalID <> 0
            BEGIN
                DELETE  FROM dbo.GoalTag
                WHERE   GoalID = @GoalID;
		
		--IF(@GoalTagAcnTypeID = 0)
		--BEGIN
		--	SELECT @GoalTagAcnTypeID = CODEID FROM CodeLookUp WHERE CodeType = 'GoalTagAcn' and CodeText= 'ElementType'
		--END			
			
                DECLARE @NextString NVARCHAR(MAX);
                DECLARE @Pos INT;
                DECLARE @NextPos INT;
                DECLARE @Delimiter NVARCHAR(40);

                SET @Delimiter = ', ';
                SET @Pos = CHARINDEX(@Delimiter, @GoalTag);

                WHILE ( @Pos <> 0 )
                    BEGIN
                        SET @NextString = SUBSTRING(@GoalTag, 1, @Pos - 1);
                        INSERT  INTO dbo.GoalTag
                                ( GoalID ,
                                  GoalTagID ,
                                  CreatedByID ,
                                  LastUpdatedByID
                                )
                        VALUES  ( @GoalID ,
                                  @NextString ,
                                  @UserID ,
                                  @UserID
                                );
                        SET @GoalTag = SUBSTRING(@GoalTag, @Pos + 1,
                                                 LEN(@GoalTag));
                        SET @Pos = CHARINDEX(@Delimiter, @GoalTag);
			
                    END;
            END;

        IF NOT @EvalID = 0
            BEGIN
                IF @GoalEvalID = 0
                    AND NOT EXISTS ( SELECT GoalEvalID
                                     FROM   dbo.GoalEvaluationProgress
                                     WHERE  GoalID = @GoalID
                                            AND EvalId = @EvalID )
                    BEGIN
                        INSERT  INTO dbo.GoalEvaluationProgress
                                ( GoalID ,
                                  EvalId ,
                                  ProgressCodeID ,
                                  Rationale ,
                                  CreatedByID ,
                                  CreatedByDt ,
                                  LastUpdatedByID ,
                                  LastUpdatedDt
                                )
                        VALUES  ( @GoalID ,
                                  @EvalID ,
                                  @ProgressCodeID ,
                                  @Rationale ,
                                  @UserID ,
                                  GETDATE() ,
                                  @UserID ,
                                  GETDATE()
                                );
		
                    END;
                ELSE
                    BEGIN 
		
                        DECLARE @PreviousGoalProgressID AS INT;
                        SELECT  @PreviousGoalProgressID = ProgressCodeID
                        FROM    dbo.GoalEvaluationProgress
                        WHERE   GoalEvalID = @GoalEvalID;
                        UPDATE  dbo.GoalEvaluationProgress
                        SET     ProgressCodeID = @ProgressCodeID ,
                                Rationale = @Rationale ,
                                LastUpdatedByID = @UserID ,
                                LastUpdatedDt = GETDATE()
                        WHERE   GoalEvalID = @GoalEvalID;
				
                        IF EXISTS ( SELECT  EvalID
                                    FROM    dbo.Evaluation
                                    WHERE   EvalID = @EvalID
                                            AND IsSigned = 1
                                            AND ( DATEDIFF(DAY, GETDATE(),
                                                           EditEndDt) >= 0 ) )
                            BEGIN				
                                IF ( @PreviousGoalProgressID != @ProgressCodeID )
                                    BEGIN	
                                        UPDATE  dbo.Evaluation
                                        SET     IsSigned = 0 ,
                                                EvaluatorSignedDt = NULL ,
                                                EvaluatorsSignature = NULL ,
                                                EmplSignature = NULL ,
                                                EmplSignedDt = NULL ,
                                                OverallRatingID = NULL ,
                                                LastUpdatedByID = @UserID ,
                                                LastUpdatedDt = GETDATE()
                                        WHERE   EvalID = @EvalID;
				   
                                        SET @isCanceldSignOff = 1;
					
					--###Update PlanYear from 2 to 1 when evauation is formative for SD Plan
                                        DECLARE @IsMultiyear INT ,
                                            @PlanTypeID INT ,
                                            @PlanYear INT ,
                                            @PlanID INT;
                                        SELECT  @IsMultiyear = IsMultiYearPlan ,
                                                @PlanTypeID = PlanTypeID ,
                                                @PlanYear = PlanYear ,
                                                @PlanID = PlanID
                                        FROM    dbo.EmplPlan
                                        WHERE   PlanID = ( SELECT TOP 1
                                                              PlanID
                                                           FROM
                                                              dbo.Evaluation
                                                           WHERE
                                                              EvalID = @EvalID
                                                              AND EvalPlanYear = 1
                                                              AND EvalTypeID = ( SELECT TOP 1
                                                              CodeID
                                                              FROM
                                                              dbo.CodeLookUp
                                                              WHERE
                                                              CodeType = 'EvalType'
                                                              AND CodeText = 'Formative Evaluation'
                                                              )
                                                         );
                                        IF @IsMultiyear = 1
                                            AND @PlanTypeID = 1
                                            AND @PlanYear = 2
                                            BEGIN
                                                UPDATE  dbo.EmplPlan
                                                SET     PlanYear = 1
                                                WHERE   PlanID = @PlanID;
                                            END;	
				 	--###
				 	   
                                    END; 		
                            END;	
				
                    END;
		
            END;
		
    END;
GO
