SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 12/12/2012
-- Description: ReActivate the plan by planID
-- Task1: set emplplan PlanActive=true b. move to NewJOb active 
-- Task2: Change of PlanYear in case of SD with formative evaluation
-- =============================================
CREATE PROCEDURE [dbo].[ReActivatePlanByPlanID]
	@PlanID AS int,
	@UserId AS nchar(6),
	@EmplJobID AS INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
IF @EmplJobID IS NULL
	SElect @EmplJobID=EmplJobID FROM EmplPlan WHERE PlanID = @PlanID
	
	UPDATE EmplPlan 
	SET PlanActive = 1,
		PlanActEndDt = NULL,
		EmplJobID =@EmplJobID,
		PlanEndReasonID  = (SELECT CODEID FROM CodeLookUp WHERE CodeType='PlanEndRsn' and Code='plReactv'),
		LastUpdatedByID = @UserId,
		LastUpdatedDt = GETDATE()
	WHERE PlanID = @PlanID
	
	--SD Reactivate change PlanYear=2 When it has last signed formative evaluation 
	 IF (
		SELECT TOP 1 PlanYear
		FROM EmplPlan
		WHERE PlanID = @PlanID
			AND PlanTypeID = (
				SELECT TOP 1 codeid
				FROM CodeLookUp
				WHERE CodeType = 'plantype'
					AND CodeText = 'Self-Directed'
				)
			AND IsMultiYearPlan = 1
		) = 1
	BEGIN
		DECLARE @topEvalid INT ,@topEvaltypid INT ,@topEvalIsSigned INT

		SELECT TOP (1) @topEvalid = EvalID
			,@topEvaltypid = EvalTypeID
			,@topEvalIsSigned = isSigned
		FROM Evaluation
		WHERE PlanID = @PlanID
			AND IsDeleted = 0
		ORDER BY CreatedDt DESC

		IF (
				@topEvaltypid = (
					SELECT TOP 1 codeid
					FROM CodeLookUp
					WHERE CodeType = 'evaltype'
						AND CodeText = 'Formative Evaluation'
					)
				AND @topEvalIsSigned = 1
				)
		BEGIN
			UPDATE EmplPlan 
			SET PlanYear=2
			WHERE PlanID=@PlanID
		END
	END



END
GO
