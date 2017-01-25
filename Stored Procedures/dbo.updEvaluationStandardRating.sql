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
    @EvalStdRatingID INT ,
    @RatingID AS INT ,
    @Rationale AS NVARCHAR(MAX) = NULL ,
    @UserID AS VARCHAR(6) = NULL ,
    @EvalID AS INT ,
    @isCanceldSignOff AS INT = 0 OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @PreviousRatingID AS INT;
        SELECT  @PreviousRatingID = RatingID
        FROM    dbo.EvaluationStandardRating
        WHERE   EvalStdRatingID = @EvalStdRatingID;
	
        UPDATE  dbo.EvaluationStandardRating
        SET     RatingID = @RatingID ,
                Rationale = CASE WHEN @Rationale IS NOT NULL THEN @Rationale
                                 ELSE Rationale
                            END ,
                LastUpdatedByID = @UserID ,
                LastUpdatedDt = GETDATE()
        WHERE   EvalStdRatingID = @EvalStdRatingID;
	
	--if the evaluation is signed and has valid edit end date and rating are changed - revoke the evaluation status.
        IF EXISTS ( SELECT  EvalID 
                    FROM    dbo.Evaluation
                    WHERE   EvalID = @EvalID
                            AND IsSigned = 1
                            AND ( DATEDIFF(DAY, GETDATE(), EditEndDt) >= 0 ) )
            BEGIN
		--(SELECT rs.SortOrder FROM EvaluationStandardRating esr JOIN RubricStandard rs ON rs.StandardID = esr.StandardID and rs.IsActive =1 WHERE esr.EvalStdRatingID = @EvalStdRatingID) <= 2
		     --AND (@PreviousRatingID in (SELECT CodeID FROM CodeLookUp WHERE CodeType='stdRating' and (CodeText='Exemplary' OR CodeText='Proficient')))AND (@RatingID in (SELECT CodeID FROM CodeLookUp WHERE CodeType='stdRating' and (CodeText='Needs Improvement' OR CodeText='Unsatisfactory')))
                IF ( @PreviousRatingID != @RatingID )
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
                                           FROM     dbo.Evaluation
                                           WHERE    EvalID = @EvalID
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
GO
