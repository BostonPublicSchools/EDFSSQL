SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/03/2012
-- Description:	update standard rating 
-- =============================================
CREATE PROCEDURE [dbo].[updEvaluationStandardRating]
	@EvalStdRatingID int
	,@RatingID as int
	,@Rationale as nvarchar(max) = null
	,@UserID as varchar(6) = null
	,@EvalID as int
	,@isCanceldSignOff as int = 0 OUTPUT
	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @PreviousRatingID as int
	SELECT @PreviousRatingID = RatingID  FROM EvaluationStandardRating WHERE EvalStdRatingID = @EvalStdRatingID
	
	UPDATE EvaluationStandardRating
		SET RatingID = @RatingID
			,Rationale = Case when @Rationale is not null then @Rationale else Rationale end
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
	WHERE EvalStdRatingID = @EvalStdRatingID
	
	--if the evaluation is signed and has valid edit end date and rating are changed - revoke the evaluation status.
	IF Exists(SELECT * FROM Evaluation WHERE EvalID=@EvalID and IsSigned=1 and (DATEDIFF(DAY, GETDATE(), EditEndDt) >= 0))
	BEGIN
		--(SELECT rs.SortOrder FROM EvaluationStandardRating esr JOIN RubricStandard rs ON rs.StandardID = esr.StandardID and rs.IsActive =1 WHERE esr.EvalStdRatingID = @EvalStdRatingID) <= 2
		     --AND (@PreviousRatingID in (SELECT CodeID FROM CodeLookUp WHERE CodeType='stdRating' and (CodeText='Exemplary' OR CodeText='Proficient')))AND (@RatingID in (SELECT CodeID FROM CodeLookUp WHERE CodeType='stdRating' and (CodeText='Needs Improvement' OR CodeText='Unsatisfactory')))
		 IF (@PreviousRatingID != @RatingID)
		 
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
				WHERE PlanID =(
								SELECT TOP 1 PlanID 
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
GO
