SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara,Krunal
-- Create date: 04/09/2012
-- Description:	End plan, change end date n mark it non active
-- =============================================
CREATE PROCEDURE [dbo].[updPlan]
@PlanID int,
	@PlanStartDt varchar(50) = null,
	@PlanEndDt varchar(50) = null,
	@PlanActive bit = 1,
	@UserID nchar(6) = null,
	@PlanTypeID int = null,
	--@Duration int = null,
	@PlanEndDate datetime= null,
	@PlanEndReasonID int = null,
	--@SelfAsmtStrength varchar(max) = null,
	--@SelfAsmtWeakness varchar(max) = null,
	@IsSignedAsmt bit = 0,
	@SignatureAsmt varchar(50) = null,
	@PrescriptionEvalID int = null,
	@NeedToEnd bit =0,
	--@SignDate datetime = getdate()
	@PlanStartEvalDate as datetime = NULL,
	@AnticipatedEvalWeek as varchar(25) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @CurrPlanActive bit
	Declare @HasPrescription bit
	Declare @IsAsmtSubmited int
	DECLARE @IsMultiYearPlan bit = NULL
	DECLARE @CreatedByDt datetime
	
	SELECT @CurrPlanActive = PlanActive FROM EmplPlan WHERE PlanID = @PlanID
	
	IF @PlanTypeID is null  OR @PlanTypeID = 0
	BEGIN
		SELECT 
			@PlanTypeID = PlanTypeID 			
		FROM EmplPlan 
		WHERE PlanID = @PlanID
	END
	SELECT
		@CreatedByDt= CreatedByDt		
		FROM EmplPlan 
		WHERE PlanID = @PlanID		
	--IF @Duration is null OR @Duration = 0
	--BEGIN
	--	SELECT @Duration = duration FROM EmplPlan WHERE PlanID = @PlanID
	--END
	
	if @PlanStartDt is null 
	BEGIN 
		SELECT @PlanStartDt = PlanstartDt FROM EmplPlan WHERE PlanID = @PlanID
	END

	if @PrescriptionEvalID is null or @PrescriptionEvalID = 0
	BEGIN 
		SELECT @PrescriptionEvalID = PrescriptEvalID,@HasPrescription = HasPrescript from EmplPlan where PlanID = @PlanID
		
	END	
	ELSE
	BEGIN
		SET @HasPrescription = 1
	END	
	
	if @NeedToEnd = 0 
	BEGIN 
		SELECT @NeedToEnd = NeedToEnd from EmplPlan where PlanID =@PlanID
	END
	
	IF @PlanEndDate is null
	BEGIN
		select @PlanEndDate = PlanActEndDt from EmplPlan where PlanID = @PlanID
	END
	
	if @PlanEndReasonID is null
	BEGIN
		SELECT @PlanEndReasonID = PlanEndReasonID from EmplPlan where PlanID = @PlanID
	END

--## update Formative date
	IF @PlanStartEvalDate IS NULL
		SELECT @PlanStartEvalDate = PlanStartEvalDate from EmplPlan where PlanID=@PlanID
	ELSE 
	BEGIN
		IF @AnticipatedEvalWeek IS NULL
			SELECT @AnticipatedEvalWeek = AnticipatedEvalWeek from EmplPlan where PlanID=@PlanID
		UPDATE EmplPlan
		SET 
			PlanStartEvalDate = @PlanStartEvalDate
			,AnticipatedEvalWeek = @AnticipatedEvalWeek
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE PlanID = @PlanID
	END
	
	
	SET @IsAsmtSubmited=-1
	SELECT @IsAsmtSubmited = EvalID FROM Evaluation WHERE  PlanID =@PlanID 
	/*Self Assessment Submit */ 
	IF (LEN(@SignatureAsmt) > 0 AND @IsAsmtSubmited=-1)
	BEGIN 
		UPDATE EmplPlan
		SET
			SignatureAsmt = @SignatureAsmt
			,DateSignedAsmt = GETDATE()
			,PlanActive = @PlanActive
			,PlanActEndDt = @PlanEndDate
			,planendReasonID = @PlanEndReasonID
			,IsSignedAsmt = 1
			,HasPrescript = @HasPrescription
			,PrescriptEvalID = @PrescriptionEvalID
			--,Duration = @Duration
			,NeedToEnd = @NeedToEnd
			,PlanStartEvalDate = @PlanStartEvalDate
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE
			PlanID = @PlanID
		--print 'A'
	END
	/*Self Assessment Release */
	ELSE IF (LEN(@SignatureAsmt) > 0 AND @IsAsmtSubmited>-1)
	BEGIN 
		UPDATE EmplPlan
		SET
			SignatureAsmt = @SignatureAsmt
			--,DateSignedAsmt = GETDATE()
			,PlanActive = @PlanActive
			,PlanActEndDt = @PlanEndDate
			,planendReasonID = @PlanEndReasonID
			,IsSignedAsmt = 1
			,HasPrescript = @HasPrescription
			,PrescriptEvalID = @PrescriptionEvalID
			--,Duration = @Duration
			,NeedToEnd = @NeedToEnd
			,PlanStartEvalDate = @PlanStartEvalDate
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE
			PlanID = @PlanID
		--print 'A'
	END
			
	IF(@PlanEndDt is not null AND @PlanTypeID = 1 )-- UPDATE IsMultiYearPlan FLAG WHEN @PlanEndDt IS CHANGED FOR SD PLAN
	BEGIN		
		DECLARE @ResultSet table (ResultFlag int)
		INSERT INTO @ResultSet (ResultFlag)
			exec @IsMultiYearPlan = CheckSDPlanYear @CreatedByDt,@PlanEndDt
	
		SELECT top 1 @IsMultiYearPlan= ResultFlag FROM @ResultSet 		
	END
	ELSE
	BEGIN
		SET @IsMultiYearPlan =0
	END
   --Also, Do not change @IsMultiYearPlan when plan is end
	IF(LEN(@PlanEndDt) > 0 AND @PlanEndDt is not null AND @PlanTypeID = 1 AND @PlanActive=N'False'
		AND @PlanEndReasonID in(select codeid from codelookup where codetype='PlanEndRsn' and code='EvalEnd' ) )		
		SELECT @IsMultiYearPlan = IsMultiYearPlan FROM EmplPlan WHERE PlanID = @PlanID
		
	IF LEN(@PlanEndDt) > 0
	BEGIN
		UPDATE EmplPlan
		SET
			PlanSchedEndDt = @PlanEndDt
			,PlanActive = @PlanActive
			,PlanActEndDt = @PlanEndDate
			,planendReasonID = @PlanEndReasonID
			,PlanTypeID = @PlanTypeID
			,IsMultiYearPlan=@IsMultiYearPlan
			--,Duration = @Duration
			,HasPrescript = @HasPrescription
			,PrescriptEvalID = @PrescriptionEvalID
			,NeedToEnd = @NeedToEnd
			,PlanStartEvalDate = @PlanStartEvalDate
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE
			PlanID = @PlanID
			--print 'C'
	END
	
	/*ELSE
	BEGIN
		UPDATE EmplPlan
		SET
			PlanStartDt = @PlanStartDt 
			,PlanEndDt = @PlanEndDt 
--			,PlanActive = @PlanActive
			,PlanTypeID = @PlanTypeID
			,Duration = @Duration
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE 
			PlanID = @PlanID
	END
	*/	
END

GO
