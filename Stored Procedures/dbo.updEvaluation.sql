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
	@EvalID int
	,@OverallRatingID as int
	,@Rationale as varchar(max) =null
	,@UserID as varchar(6) = null
	,@EvaluatorsCmnt as nvarchar(max) = null
	,@EmplCmnt as nvarchar(max) = null
	,@EvaluatorSignature as nvarchar(32) = null
	,@IsSigned as bit = 0
	,@EditEndDt as varchar(50) = null
	,@EmplSignature as varchar(32) = null
	,@EvalTypeID as int  =0
	,@IsEndDateChanged as bit = 0
	,@PlanYearChange as bit = null
	,@IsAdmin as bit = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @PlanID as int 	
	SELECT @PlanID= (SELECT TOP 1 PlanID FROM Evaluation WHERE EvalID = @EvalID )

	DECLARE @OldEvalTypeID varchar(100)
	DECLARE @EvalMgrID as nchar(6) = null
	DECLARE @EvalSubEvalID as nchar(6) = null
	DECLARE @SignEvaluatorsSignedDt as DateTime	 = GETDATE()
--------------------------------------------------------------------	
	IF @OverallRatingID = 0
	BEGIN
		SELECT
			@OverallRatingID = OverallRatingID
			,@OldEvalTypeID = EvalTypeID
		FROM
			Evaluation
		WHERE
			EvalID = @EvalID
	END
---------------------------------------------------------------------	
	IF @EvalTypeID is null or @EvalTypeID = 0
	BEGIN
		SELECT 
			@EvalTypeID = EvalTypeID
		FROM 
			Evaluation
		WHERE 
			EvalID = @EvalID
	END
---------------------------------------------------------------------	
	IF @Rationale is null or @Rationale = ''
	BEGIN 
		SELECT 
			@Rationale = Rationale
		FROM 
			Evaluation
		WHERE 
			EvalID = @EvalID
	END
---------------------------------------------------------------------	
	IF @IsAdmin = 0
	BEGIN
		IF @IsSigned = 1 
		BEGIN
			SELECT
				@SignEvaluatorsSignedDt = ISNULL(EvaluatorSignedDt, GETDATE())
			FROM
				Evaluation
			WHERE 
				EvalID = @EvalID	
		END
		ELSE 
		BEGIN			
			SELECT
				@SignEvaluatorsSignedDt = EvaluatorSignedDt
				,@IsSigned = IsSigned
			FROM
				Evaluation
			WHERE
				EvalID = @EvalID
		END
	END		
	
	ELSE IF @IsAdmin = 1 and @IsSigned = 0
	BEGIN
	SET @SignEvaluatorsSignedDt = null
	END
	
---------------------------------------------------------------------
IF @IsSigned = 1
BEGIN
	---when signed set the evalManagerID and evalSubevalId.
	SELECT 
	@EvalMgrID = (CASE WHEN ex.MgrID IS NOT NULL THEN ex.MgrID ELSE ej.MgrID END),
	@EvalSubEvalID = (CASE WHEN (ep.SubEvalID = '000000' OR ep.SubEvalID IS NULL) AND s.EmplID IS NOT NULL THEN s.EmplID ELSE ep.SubEvalID END)
	FROM Evaluation evi
	JOIN EmplPlan ep on evi.PlanID = ep.PlanID
	JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID
	LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID=ej.EmplJobID
	LEFT OUTER JOIN SubevalAssignedEmplEmplJob sej on sej.EmplJobID = ej.EmplJobID  and sej.IsPrimary = 1 and sej.IsActive =1 and sej.IsDeleted = 1
	LEFT OUTER JOIN SubEval s on sej.SubEvalID = s.EvalID and s.EvalActive = 1 
	WHERE evi.EvalID = @EvalID
END
---------------------------------------------------------------------
	IF @EmplCmnt IS NULL OR @EmplCmnt = ''
	BEGIN
		SELECT
			@EmplCmnt = EmplCmnt
		FROM
			Evaluation
		WHERE
			EvalID = @EvalID
	
	END
---------------------------------------------------------------------
	IF @EvaluatorsCmnt IS NULL OR @EvaluatorsCmnt = ''
	BEGIN
		SELECT
			@EvaluatorsCmnt = EvaluatorsCmnt
		FROM
			Evaluation
		WHERE
			EvalID = @EvalID
	
	END
---------------------------------------------------------------------
      --update PlanYear=2 in EmplPlan when Formative Evaluation of Self-directed Plan is signed 
    DECLARE @IsMultiYearPlan BIT=NULL
    DECLARE @PlanYear INT , @PlanTypeID INT
    SELECT 
		@IsMultiYearPlan= IsMultiYearPlan, 
		@PlanYear = COALESCE(PlanYear,1),
		@PlanTypeID=PlanTypeID
		FROM EmplPlan WHERE PlanID= @PlanID     
		
		----Reverse Planyear when changed from FA to FE-----
		IF @PlanTypeID=1 and @IsMultiYearPlan='true' AND @PlanYear = 1 AND 
		   @OldEvalTypeID=(select top 1 CodeID from CodeLookUp where CodeText in('Formative Assessment','Summative Evaluation') and CodeType='EvalType') and 
		   @EvalTypeID=(select top 1 CodeID from CodeLookUp where CodeText='Formative Evaluation' and CodeType='EvalType') 
		   and @IsSigned =1 and @PlanYearChange='true' 		   
		begin
			--also check if it is the most recent
			declare @maxEvalID int 
			select @maxEvalID = MAX(EvalID) from Evaluation where PlanID= @PlanID
			if(@maxEvalID = @EvalID)
				begin
					update EmplPlan 
					set PlanYear=2
					where PlanID =@PlanID
				end
		end
		
		-- update to planear =2 when Formative evaluation is signed
	IF @IsSigned = 1 
		AND @PlanTypeID=1
		AND	@IsMultiYearPlan = 'true'
		AND @PlanYear=1
		AND @PlanYearChange='true'
		AND @EvaluatorSignature IS NOT NULL
		AND @EvalTypeID=(SELECT top 1 CODEID FROM CodeLookUp WHERE CodeText='Formative Evaluation' and CodeType='EvalType')		
	BEGIN
		UPDATE EmplPlan 
		SET PlanYear = 2
		WHERE PlanID=@PlanID
	END
---------------------------------------------------------------------
	IF ((@EvaluatorSignature IS NULL OR @EvaluatorSignature = '') AND (@IsAdmin = 0))
	BEGIN
		SELECT
			@EvaluatorSignature = EvaluatorsSignature
		FROM
			Evaluation
		WHERE
			EvalID = @EvalID
	
	END
---------------------------------------------------------------------	
	DECLARE @EmplSignDt datetime = getdate()
	
	IF ((@EmplSignature is null or @EmplSignature = '') AND @IsAdmin = 0)
	BEGIN
		SELECT 
			@EmplSignature = Emplsignature
			,@EmplSignDt = EmplSignedDt
		FROM
			Evaluation
		WHERE 
			EvalID = @EvalID	
	END
	
	IF ((@EmplSignature is null or @EmplSignature = '') AND @IsAdmin = 1)
	BEGIN
		SELECT 
			@EmplSignDt = NULL
		FROM
			Evaluation
		WHERE 
			EvalID = @EvalID	
	END
---------------------------------------------------------------------	
	if @EditEndDt IS NOT NULL AND @IsAdmin = 0
	begin	
			DECLARE @PrescriptEvalID as int
					,@CurrentPlanID as int
					,@EmplJobID as int
					
			select
				@CurrentPlanID = PlanID
			from
				Evaluation
			where
				EvalID = @EvalID		
				
			SELECT TOP 1
				@PrescriptEvalID = ISNULL(e.EvalID, 0)
			FROM
				EvaluationPrescription as ep
			JOIN (SELECT MAX(EvalID) as EvalID, PlanID FROM Evaluation WHERE PlanID = @CurrentPlanID and IsDeleted = 0 Group by PlanID)as e on ep.EvalID = e.EvalID
			--JOIN Evaluation as e on ep.EvalID = e.EvalID
			JOIN EmplPlan as p on e.PlanID = p.PlanID
								AND p.PlanID = @CurrentPlanID
								AND ep.IsDeleted = 0
			order by
				CreatedByDt desc
			
			SELECT @EmplJobID = emplJobID FROM EmplPlan 
			WHERE PlanID = @CurrentPlanID			
			
			--Update Current Plan when there is prescriptevalID
			UPDATE EmplPlan
				SET
					PrescriptEvalID = (CASE WHEN @PrescriptEvalID IS NOT NULL AND @PrescriptEvalID != 0 THEN @PrescriptEvalID ELSE NULL END)  
					,HasPrescript = (CASE WHEN @PrescriptEvalID IS NOT NULL AND @PrescriptEvalID != 0 THEN 1 ELSE 0 END)
					,LastUpdatedByID = @UserID
					,LastUpdatedDt = GETDATE()  
					WHERE
					PlanID = @CurrentPlanID
					
			--if the current plan has ended and new plan is created change the status of the new plan also
			IF EXISTS((SELECT * FROM EmplPlan WHERE PlanID = @CurrentPlanID AND PlanActive = 0))
			BEGIN
				--if prescription exists for any of the evaluation 
				IF EXISTS((SELECT * FROM EvaluationPrescription WHERE EvalID = @PrescriptEvalID and IsDeleted=0))
				BEGIN 
					UPDATE EmplPlan
					SET
						PrescriptEvalID = @PrescriptEvalID
						,HasPrescript = 1
						,LastUpdatedByID = @UserID
						,LastUpdatedDt = GETDATE()
					WHERE
						PlanID = (SELECT top 1 PlanID FROM EmplPlan ep
								JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID
								WHERE ej.EmplJobID = @EmplJobID and ep.PlanActive = 1)	
				END
				ELSE
				BEGIN
				UPDATE EmplPlan
					SET
						PrescriptEvalID = NULL
						,HasPrescript = 0
						,LastUpdatedByID = @UserID
						,LastUpdatedDt = GETDATE()
					WHERE
						PlanID = (SELECT top 1 PlanID FROM EmplPlan ep
								JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID
								WHERE ej.EmplJobID = @EmplJobID and ep.PlanActive = 1)	
				END
			END
											
			UPDATE Evaluation
				SET OverallRatingID = @OverallRatingID
					,Rationale = @Rationale
					,EvalTypeID = @EvalTypeID
					,EvaluatorsCmnt = @EvaluatorsCmnt
					,EmplCmnt = @EmplCmnt
					,EvaluatorsSignature = @EvaluatorSignature
					,IsSigned = @IsSigned
					,EvaluatorSignedDt = @SignEvaluatorsSignedDt
					,EmplSignature = @EmplSignature
					,EmplSignedDt = @EmplSignDt
					,LastUpdatedByID = @UserID
					,LastUpdatedDt = GETDATE()
					,EditEndDt = (CASE WHEN @IsSigned = 0 and @IsEndDateChanged = 1
									   THEN (Convert(varchar(50), CONVERT(date, @EditEndDt))+' 23:59:59.999') 
									   WHEN @IsSigned = 1 and @IsEndDateChanged = 1
									   THEN (Convert(varchar(50), CONVERT(date, @EditEndDt))+' 23:59:59.999') 
									   ELSE EditEndDt
									END)
					,EvalSignOffCount = (CASE WHEN @IsSigned = 1
											  THEN EvalSignOffCount+1
											  ELSE EvalSignOffCount
										  END)
					,EvalManagerID = (CASE WHEN @IsSigned = 1 and @EvalMgrID is not null THEN @EvalMgrID ELSE EvalManagerID END)
					,EvalSubEvalID = (CASE WHEN @IsSigned = 1 and @EvalSubEvalID is not null THEN @EvalSubEvalID ELSE EvalSubEvalID END)
			WHERE EvalID = @EvalID
	end
	else
	begin		
			UPDATE Evaluation
				SET OverallRatingID = @OverallRatingID
					,Rationale = @Rationale
					,EvaluatorsCmnt = @EvaluatorsCmnt
					,EvalTypeID = @EvalTypeID
					,EmplCmnt = @EmplCmnt
					,EvaluatorsSignature = @EvaluatorSignature
					,IsSigned = @IsSigned
					,EvaluatorSignedDt = @SignEvaluatorsSignedDt
					,EmplSignature = @EmplSignature
					,EmplSignedDt = @EmplSignDt
					,EditEndDt =  (CASE WHEN @IsSigned = 1 And @EditEndDt is Not null
									   THEN (Convert(varchar(50), CONVERT(date, @EditEndDt))+' 23:59:59.999') 
									   WHEN @IsSigned = 1 And @EditEndDt is null
									   THEN EditEndDt
									   WHEN @IsSigned = 0 and @IsEndDateChanged = 1
									   THEN (Convert(varchar(50), CONVERT(date, @EditEndDt))+' 23:59:59.999') 
									   WHEN @IsSigned = 0 and @IsEndDateChanged = 0
									   THEN NULL
									   ELSE EditEndDt
									END)
					,LastUpdatedByID = @UserID
					,LastUpdatedDt = GETDATE()
					,EvalSignOffCount = (CASE WHEN @IsSigned = 1
											  THEN EvalSignOffCount+1
											  ELSE EvalSignOffCount
										  END)		
					,EvalManagerID = (CASE WHEN @IsSigned = 1 and @EvalMgrID is not null THEN @EvalMgrID ELSE EvalManagerID END)
					,EvalSubEvalID = (CASE WHEN @IsSigned = 1 and @EvalSubEvalID is not null THEN @EvalSubEvalID ELSE EvalSubEvalID END)										  					
			WHERE EvalID = @EvalID			
	end
	---------------------------------------------------------------------
end
GO
