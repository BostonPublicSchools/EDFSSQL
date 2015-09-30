SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/17/2012
-- Description:	Inserts plan into plan table
-- =============================================
CREATE PROCEDURE [dbo].[insPlan]
	@EmplID AS nchar(6) = NULL
	,@EmplJobID AS int = NULL
	,@MgrID AS nchar(6) = NULL 
	,@PlanYear AS int = NULL
	,@PlanTypeID AS int = NULL
	,@PlanStartDt AS datetime = NULL
	,@PlanEndDt AS datetime = NULL
	,@PlanActive AS bit = NULL
	--,@Duration AS int = 0
	,@PlanEditLock AS bit = NULL
	,@SubEvalID as nchar(6) = null
	,@PlanStartEvalDate as datetime = NULL
	,@UserID AS nchar(6) = null	
	,@insPlanID as int = 0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @PlanID	AS int
			,@CurrentPlanID As int
			,@CurrentPlanActive As bit
			,@RubricID as int
			,@IsMultiYearPlan as bit=null
			
	--SELECT
	--	@CurrentPlanID = MAX(PlanID)
	--FROM
	--	EmplPlan
	--WHERE
	--	EmplJobID = @EmplJobID 		
	
	SELECT top 1
		@CurrentPlanID = (PlanID)
	FROM
		EmplPlan
	WHERE
		EmplJobID in (select EmplJobID from EmplEmplJob where emplID = @EmplID and RubricID = (SELECT RubricID FROM EmplEmplJob where EmplJobID = @EmplJobID))
		And IsInvalid = 0
	Order by PlanSchedEndDt desc, PlanActEndDt desc
 
----------------------------------------------------------
	SELECT
		@RubricID = RubricID
	FROM
		EmplEmplJob
	WHERE
		EmplJobID = @EmplJobID 			
---------------------------------------------------------- check if the previous plan is active for Lic Rubric
	SET @CurrentPlanActive = 0	
	IF EXISTS(SELECT TOP 1 * FROM RubricHdr WHERE Is5StepProcess=0 AND RubricID=@RubricID)
	Begin
	SELECT
		@CurrentPlanActive = PlanActive
	FROM
		EmplPlan
	WHERE
		PlanID = @CurrentPlanID
	End

---------------------------------------------------------- get the subevalId for the plan from the primary
  SET @SubEvalID = null
   SELECT
	@SubEvalID = se.EmplID
	FROM SubEval se 
	LEFT OUTER JOIN  SubevalAssignedEmplEmplJob sej on se.EvalID = sej.SubEvalID and sej.IsPrimary = 1 and sej.IsActive = 1 and sej.IsDeleted = 0
	WHERE sej.EmplJobID  = @EmplJobID and se.EvalActive = 1
	
----------------------------------------------------------	 	
	SELECT @IsMultiYearPlan=null
	DECLARE @CreatedByDt as date =GETDATE(), @CreatedByDtSchYr as nchar(9) , @PlanEndDtSchYr as nchar(9) = null
	DECLARE @isExistOrAfterInCalendar as int = -1
			
	IF @PlanTypeID=1 AND @PlanEndDt IS NOT NULL	
	BEGIN		
		DECLARE @ResultSet table (ResultFlag int)
		INSERT INTO @ResultSet (ResultFlag)
			exec @IsMultiYearPlan = CheckSDPlanYear @CreatedByDt,@PlanEndDt
		
		SELECT top 1 @IsMultiYearPlan= ResultFlag FROM @ResultSet
	END
	--PRINT @IsMultiYearPlan

--------------------------------------------------------set manager ID 
SELECT @MgrID = (CASE WHEN ex.MgrID Is not Null Then ex.MgrID 
					  WHEN ex.MgrID is null and ej.MgrID = '000000' THEN d.MgrID
					  ELSE ej.MgrID end) FROM EmplEmplJob ej
				 LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID
				 Join Department d on d.DeptID = ej.DeptID
				 WHERE ej.EmplJobID = @EmplJobID

---------------------------------------------------------- insert neew plan and update the prescription evalId for the new plan
	If (@CurrentPlanActive = 0)
	BEGIN
		--IF((SELECT CODEID FROM CodeLookUp where CodeType='NLPlanType') = @PlanTypeID and @PlanTypeID is not null) OR ((SELECT Is5StepProcess from RubricHdr where RubricID = @RubricID) = 0)
		--BEGIN
		--SET @PlanStartDt = GETDATE()
		----SET @PlanEndDt = '2014-06-01 00:00:00'
		--END
		
		INSERT INTO EmplPlan (EmplJobID, PlanYear, PlanTypeID, PlanStartDt, PlanSchedEndDt, PlanActive, PlanManagerID,SubEvalID, PlanEditLock,PlanStartEvalDate, LastUpdatedByID, CreatedByID, RubricID,IsMultiYearPlan)
				VALUES (@EmplJobID, @PlanYear, @PlanTypeID, @PlanStartDt, @PlanEndDt, @PlanActive, @MgrID,(case when @SubEvalID is not null then @SubEvalID else dbo.funcGetPrimaryManagerByEmplID(@EmplID)END),@PlanEditLock,@PlanStartEvalDate, @UserID, @UserID, @RubricID,@IsMultiYearPlan) 
			
		SET @PlanID = SCOPE_IDENTITY();
		
		IF @CurrentPlanID IS NOT NULL
		BEGIN
			UPDATE Evaluation
			SET
				pmfPlanID = @PlanID
			WHERE
				PlanID = @CurrentPlanID
			AND	pmfPlanID IS NULL
		END

		DECLARE @PrescriptEvalID as int
------------------------------------------------------------------------------------------------
		SELECT TOP 1
			@PrescriptEvalID = ISNULL(e.EvalID, 0)
		FROM 
			EvaluationPrescription as ep
		JOIN (SELECT MAX(EvalID) as EvalID, PlanID FROM Evaluation WHERE PlanID = @CurrentPlanID and IsDeleted = 0 Group by PlanID)as e on ep.EvalID = e.EvalID
		JOIN EmplPlan as p on e.PlanID = p.PlanID
							AND p.PlanID = @CurrentPlanID AND p.IsInvalid =0
							AND ep.IsDeleted=0 
																
		IF not exists (Select top 1 e.EvalID from Evaluation e where e.EvalID=@PrescriptEvalID and e.IsSigned=1)
			set @PrescriptEvalID=0
--		print @PrescriptEvalID	
		
		
		IF NOT @PrescriptEvalID = 0
		BEGIN
			DECLARE @EvalID as int
			
			--SELECT
			--	@EvalID = EvalID
			--FROM 
			--	Evaluation
			--WHERE
			--	PlanID = @CurrentPlanID
			--set the evalid that has prescription
			UPDATE EmplPlan
			SET
				PrescriptEvalID = null-- (CASE WHEN @PrescriptEvalID != 0 THEN @PrescriptEvalID ELSE NULL END)
				,HasPrescript = (CASE WHEN @PrescriptEvalID != 0 THEN 1 ELSE 0 END)
				,PrevPlanPrescptEvalID = (CASE WHEN @PrescriptEvalID != 0 THEN @PrescriptEvalID ELSE NULL END)
			WHERE
				PlanID = @PlanID
		
		END

	END

	SET @insPlanID = @PlanID
----------------------------------------------------------	
END
GO
