SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/07/2012
-- Description:	update Evaluation
-- =============================================
CREATE PROCEDURE [dbo].[updEvaluation]
    @EvalID INT ,
    @OverallRatingID AS INT ,
    @Rationale AS VARCHAR(MAX) = NULL ,
    @UserID AS VARCHAR(6) = NULL ,
    @EvaluatorsCmnt AS NVARCHAR(MAX) = NULL ,
    @EmplCmnt AS NVARCHAR(MAX) = NULL ,
    @EvaluatorSignature AS NVARCHAR(32) = NULL ,
    @IsSigned AS BIT = 0 ,
    @EditEndDt AS VARCHAR(50) = NULL ,
    @EmplSignature AS VARCHAR(32) = NULL ,
    @EvalTypeID AS INT = 0 ,
    @IsEndDateChanged AS BIT = 0 ,
    @PlanYearChange AS BIT = NULL ,
    @IsAdmin AS BIT = 0
AS
    BEGIN
        SET NOCOUNT ON;
	
        DECLARE @PlanID AS INT; 	
        SELECT  @PlanID = ( SELECT TOP 1
                                    PlanID
                            FROM    dbo.Evaluation
                            WHERE   EvalID = @EvalID
                          );

        DECLARE @OldEvalTypeID VARCHAR(100);
        DECLARE @EvalMgrID AS NCHAR(6) = NULL;
        DECLARE @EvalSubEvalID AS NCHAR(6) = NULL;
        DECLARE @SignEvaluatorsSignedDt AS DATETIME	 = GETDATE();
--------------------------------------------------------------------	
        IF @OverallRatingID = 0
            BEGIN
                SELECT  @OverallRatingID = OverallRatingID ,
                        @OldEvalTypeID = EvalTypeID
                FROM    dbo.Evaluation
                WHERE   EvalID = @EvalID;
            END;
---------------------------------------------------------------------	
        IF @EvalTypeID IS NULL
            OR @EvalTypeID = 0
            BEGIN
                SELECT  @EvalTypeID = EvalTypeID
                FROM    dbo.Evaluation
                WHERE   EvalID = @EvalID;
            END;
---------------------------------------------------------------------	
        IF @Rationale IS NULL
            OR @Rationale = ''
            BEGIN 
                SELECT  @Rationale = Rationale
                FROM    dbo.Evaluation
                WHERE   EvalID = @EvalID;
            END;
---------------------------------------------------------------------	
        IF @IsAdmin = 0
            BEGIN
                IF @IsSigned = 1
                    BEGIN
                        SELECT  @SignEvaluatorsSignedDt = ISNULL(EvaluatorSignedDt,
                                                              GETDATE())
                        FROM    dbo.Evaluation
                        WHERE   EvalID = @EvalID;	
                    END;
                ELSE
                    BEGIN			
                        SELECT  @SignEvaluatorsSignedDt = EvaluatorSignedDt ,
                                @IsSigned = IsSigned
                        FROM    dbo.Evaluation
                        WHERE   EvalID = @EvalID;
                    END;
            END;		
	
        ELSE
            IF @IsAdmin = 1
                AND @IsSigned = 0
                BEGIN
                    SET @SignEvaluatorsSignedDt = NULL;
                END;
	
---------------------------------------------------------------------
        IF @IsSigned = 1
            BEGIN
	---when signed set the evalManagerID and evalSubevalId.
                SELECT  @EvalMgrID = ( CASE WHEN ex.MgrID IS NOT NULL
                                            THEN ex.MgrID
                                            ELSE ej.MgrID
                                       END ) ,
                        @EvalSubEvalID = ( CASE WHEN ( ep.SubEvalID = '000000'
                                                       OR ep.SubEvalID IS NULL
                                                     )
                                                     AND s.EmplID IS NOT NULL
                                                THEN s.EmplID
                                                ELSE ep.SubEvalID
                                           END )
                FROM    dbo.Evaluation evi
                        JOIN dbo.EmplPlan ep ON evi.PlanID = ep.PlanID
                        JOIN dbo.EmplEmplJob ej ON ej.EmplJobID = ep.EmplJobID
                        LEFT OUTER JOIN dbo.EmplExceptions ex ON ex.EmplJobID = ej.EmplJobID
                        LEFT OUTER JOIN dbo.SubevalAssignedEmplEmplJob sej ON sej.EmplJobID = ej.EmplJobID
                                                              AND sej.IsPrimary = 1
                                                              AND sej.IsActive = 1
                                                              AND sej.IsDeleted = 1
                        LEFT OUTER JOIN dbo.SubEval s ON sej.SubEvalID = s.EvalID
                                                         AND s.EvalActive = 1
                WHERE   evi.EvalID = @EvalID;
            END;
---------------------------------------------------------------------
        IF @EmplCmnt IS NULL
            OR @EmplCmnt = ''
            BEGIN
                SELECT  @EmplCmnt = EmplCmnt
                FROM    dbo.Evaluation
                WHERE   EvalID = @EvalID;
	
            END;
---------------------------------------------------------------------
        IF @EvaluatorsCmnt IS NULL
            OR @EvaluatorsCmnt = ''
            BEGIN
                SELECT  @EvaluatorsCmnt = EvaluatorsCmnt
                FROM    dbo.Evaluation
                WHERE   EvalID = @EvalID;
	
            END;
---------------------------------------------------------------------
      --update PlanYear=2 in EmplPlan when Formative Evaluation of Self-directed Plan is signed 
        DECLARE @IsMultiYearPlan BIT= NULL;
        DECLARE @PlanYear INT ,
            @PlanTypeID INT;
        SELECT  @IsMultiYearPlan = IsMultiYearPlan ,
                @PlanYear = COALESCE(PlanYear, 1) ,
                @PlanTypeID = PlanTypeID
        FROM    dbo.EmplPlan
        WHERE   PlanID = @PlanID;     
		
		----Reverse Planyear when changed from FA to FE-----
        IF @PlanTypeID = 1
            AND @IsMultiYearPlan = 'true'
            AND @PlanYear = 1
            AND @OldEvalTypeID = ( SELECT TOP 1
                                            CodeID
                                   FROM     dbo.CodeLookUp
                                   WHERE    CodeText IN (
                                            'Formative Assessment',
                                            'Summative Evaluation' )
                                            AND CodeType = 'EvalType'
                                 )
            AND @EvalTypeID = ( SELECT TOP 1
                                        CodeID
                                FROM    dbo.CodeLookUp
                                WHERE   CodeText = 'Formative Evaluation'
                                        AND CodeType = 'EvalType'
                              )
            AND @IsSigned = 1
            AND @PlanYearChange = 'true'
            BEGIN
			--also check if it is the most recent
                DECLARE @maxEvalID INT; 
                SELECT  @maxEvalID = MAX(EvalID)
                FROM    dbo.Evaluation
                WHERE   PlanID = @PlanID;
                IF ( @maxEvalID = @EvalID )
                    BEGIN
                        UPDATE  dbo.EmplPlan
                        SET     PlanYear = 2
                        WHERE   PlanID = @PlanID;
                    END;
            END;
		
		-- update to planear =2 when Formative evaluation is signed
        IF @IsSigned = 1
            AND @PlanTypeID = 1
            AND @IsMultiYearPlan = 'true'
            AND @PlanYear = 1
            AND @PlanYearChange = 'true'
            AND @EvaluatorSignature IS NOT NULL
            AND @EvalTypeID = ( SELECT TOP 1
                                        CodeID
                                FROM    dbo.CodeLookUp
                                WHERE   CodeText = 'Formative Evaluation'
                                        AND CodeType = 'EvalType'
                              )
            BEGIN
                UPDATE  dbo.EmplPlan
                SET     PlanYear = 2
                WHERE   PlanID = @PlanID;
            END;
---------------------------------------------------------------------
        IF ( ( @EvaluatorSignature IS NULL
               OR @EvaluatorSignature = ''
             )
             AND ( @IsAdmin = 0 )
           )
            BEGIN
                SELECT  @EvaluatorSignature = EvaluatorsSignature
                FROM    dbo.Evaluation
                WHERE   EvalID = @EvalID;
	
            END;
---------------------------------------------------------------------	
        DECLARE @EmplSignDt DATETIME = GETDATE();
	
        IF ( ( @EmplSignature IS NULL
               OR @EmplSignature = ''
             )
             AND @IsAdmin = 0
           )
            BEGIN
                SELECT  @EmplSignature = EmplSignature ,
                        @EmplSignDt = EmplSignedDt
                FROM    dbo.Evaluation
                WHERE   EvalID = @EvalID;	
            END;
	
        IF ( ( @EmplSignature IS NULL
               OR @EmplSignature = ''
             )
             AND @IsAdmin = 1
           )
            BEGIN
                SELECT  @EmplSignDt = NULL
                FROM    dbo.Evaluation
                WHERE   EvalID = @EvalID;	
            END;
---------------------------------------------------------------------	
        IF @EditEndDt IS NOT NULL
            AND @IsAdmin = 0
            BEGIN	
                DECLARE @PrescriptEvalID AS INT ,
                    @CurrentPlanID AS INT ,
                    @EmplJobID AS INT;
					
                SELECT  @CurrentPlanID = PlanID
                FROM    dbo.Evaluation
                WHERE   EvalID = @EvalID;		
				
                SELECT TOP 1
                        @PrescriptEvalID = ISNULL(e.EvalID, 0)
                FROM    dbo.EvaluationPrescription AS ep
                        JOIN ( SELECT   MAX(EvalID) AS EvalID ,
                                        PlanID
                               FROM     dbo.Evaluation
                               WHERE    PlanID = @CurrentPlanID
                                        AND IsDeleted = 0
                               GROUP BY PlanID
                             ) AS e ON ep.EvalID = e.EvalID
			--JOIN Evaluation as e on ep.EvalID = e.EvalID
                        JOIN dbo.EmplPlan AS p ON e.PlanID = p.PlanID
                                                  AND p.PlanID = @CurrentPlanID
                                                  AND ep.IsDeleted = 0
                ORDER BY p.CreatedByDt DESC;
			
                SELECT  @EmplJobID = EmplJobID
                FROM    dbo.EmplPlan
                WHERE   PlanID = @CurrentPlanID;			
			
			--Update Current Plan when there is prescriptevalID
                UPDATE  dbo.EmplPlan
                SET     PrescriptEvalID = ( CASE WHEN @PrescriptEvalID IS NOT NULL
                                                      AND @PrescriptEvalID != 0
                                                 THEN @PrescriptEvalID
                                                 ELSE NULL
                                            END ) ,
                        HasPrescript = ( CASE WHEN @PrescriptEvalID IS NOT NULL
                                                   AND @PrescriptEvalID != 0
                                              THEN 1
                                              ELSE 0
                                         END ) ,
                        LastUpdatedByID = @UserID ,
                        LastUpdatedDt = GETDATE()
                WHERE   PlanID = @CurrentPlanID;
					
			--if the current plan has ended and new plan is created change the status of the new plan also
                IF EXISTS ( ( SELECT    PlanID
                              FROM      dbo.EmplPlan
                              WHERE     PlanID = @CurrentPlanID
                                        AND PlanActive = 0
                            ) )
                    BEGIN
				--if prescription exists for any of the evaluation 
                        IF EXISTS ( ( SELECT    PrescriptionId 
                                      FROM      dbo.EvaluationPrescription
                                      WHERE     EvalID = @PrescriptEvalID
                                                AND IsDeleted = 0
                                    ) )
                            BEGIN 
                                UPDATE  dbo.EmplPlan
                                SET     PrescriptEvalID = @PrescriptEvalID ,
                                        HasPrescript = 1 ,
                                        LastUpdatedByID = @UserID ,
                                        LastUpdatedDt = GETDATE()
                                WHERE   PlanID = ( SELECT TOP 1
                                                            ep.PlanID
                                                   FROM     dbo.EmplPlan ep
                                                            JOIN dbo.EmplEmplJob ej ON ej.EmplJobID = ep.EmplJobID
                                                   WHERE    ej.EmplJobID = @EmplJobID
                                                            AND ep.PlanActive = 1
                                                 );	
                            END;
                        ELSE
                            BEGIN
                                UPDATE  dbo.EmplPlan
                                SET     PrescriptEvalID = NULL ,
                                        HasPrescript = 0 ,
                                        LastUpdatedByID = @UserID ,
                                        LastUpdatedDt = GETDATE()
                                WHERE   PlanID = ( SELECT TOP 1
                                                            ep.PlanID
                                                   FROM     dbo.EmplPlan ep
                                                            JOIN dbo.EmplEmplJob ej ON ej.EmplJobID = ep.EmplJobID
                                                   WHERE    ej.EmplJobID = @EmplJobID
                                                            AND ep.PlanActive = 1
                                                 );	
                            END;
                    END;
											
                UPDATE  dbo.Evaluation
                SET     OverallRatingID = @OverallRatingID ,
                        Rationale = @Rationale ,
                        EvalTypeID = @EvalTypeID ,
                        EvaluatorsCmnt = @EvaluatorsCmnt ,
                        EmplCmnt = @EmplCmnt ,
                        EvaluatorsSignature = @EvaluatorSignature ,
                        IsSigned = @IsSigned ,
                        EvaluatorSignedDt = @SignEvaluatorsSignedDt ,
                        EmplSignature = @EmplSignature ,
                        EmplSignedDt = @EmplSignDt ,
                        LastUpdatedByID = @UserID ,
                        LastUpdatedDt = GETDATE() ,
                        EditEndDt = ( CASE WHEN @IsSigned = 0
                                                AND @IsEndDateChanged = 1
                                           THEN ( CONVERT(VARCHAR(50), CONVERT(DATE, @EditEndDt))
                                                  + ' 23:59:59.999' )
                                           WHEN @IsSigned = 1
                                                AND @IsEndDateChanged = 1
                                           THEN ( CONVERT(VARCHAR(50), CONVERT(DATE, @EditEndDt))
                                                  + ' 23:59:59.999' )
                                           ELSE EditEndDt
                                      END ) ,
                        EvalSignOffCount = ( CASE WHEN @IsSigned = 1
                                                  THEN EvalSignOffCount + 1
                                                  ELSE EvalSignOffCount
                                             END ) ,
                        EvalManagerID = ( CASE WHEN @IsSigned = 1
                                                    AND @EvalMgrID IS NOT NULL
                                               THEN @EvalMgrID
                                               ELSE EvalManagerID
                                          END ) ,
                        EvalSubEvalID = ( CASE WHEN @IsSigned = 1
                                                    AND @EvalSubEvalID IS NOT NULL
                                               THEN @EvalSubEvalID
                                               ELSE EvalSubEvalID
                                          END )
                WHERE   EvalID = @EvalID;
            END;
        ELSE
            BEGIN		
                UPDATE  dbo.Evaluation
                SET     OverallRatingID = @OverallRatingID ,
                        Rationale = @Rationale ,
                        EvaluatorsCmnt = @EvaluatorsCmnt ,
                        EvalTypeID = @EvalTypeID ,
                        EmplCmnt = @EmplCmnt ,
                        EvaluatorsSignature = @EvaluatorSignature ,
                        IsSigned = @IsSigned ,
                        EvaluatorSignedDt = @SignEvaluatorsSignedDt ,
                        EmplSignature = @EmplSignature ,
                        EmplSignedDt = @EmplSignDt ,
                        EditEndDt = ( CASE WHEN @IsSigned = 1
                                                AND @EditEndDt IS NOT NULL
                                           THEN ( CONVERT(VARCHAR(50), CONVERT(DATE, @EditEndDt))
                                                  + ' 23:59:59.999' )
                                           WHEN @IsSigned = 1
                                                AND @EditEndDt IS NULL
                                           THEN EditEndDt
                                           WHEN @IsSigned = 0
                                                AND @IsEndDateChanged = 1
                                           THEN ( CONVERT(VARCHAR(50), CONVERT(DATE, @EditEndDt))
                                                  + ' 23:59:59.999' )
                                           WHEN @IsSigned = 0
                                                AND @IsEndDateChanged = 0
                                           THEN NULL
                                           ELSE EditEndDt
                                      END ) ,
                        LastUpdatedByID = @UserID ,
                        LastUpdatedDt = GETDATE() ,
                        EvalSignOffCount = ( CASE WHEN @IsSigned = 1
                                                  THEN EvalSignOffCount + 1
                                                  ELSE EvalSignOffCount
                                             END ) ,
                        EvalManagerID = ( CASE WHEN @IsSigned = 1
                                                    AND @EvalMgrID IS NOT NULL
                                               THEN @EvalMgrID
                                               ELSE EvalManagerID
                                          END ) ,
                        EvalSubEvalID = ( CASE WHEN @IsSigned = 1
                                                    AND @EvalSubEvalID IS NOT NULL
                                               THEN @EvalSubEvalID
                                               ELSE EvalSubEvalID
                                          END )
                WHERE   EvalID = @EvalID;			
            END;
	---------------------------------------------------------------------
    END;
GO
