SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi		
-- Create date: 05/23/2013
-- Description:	Update the plan prescription status
-- if there are no prescription
-- =============================================
Create PROCEDURE [dbo].[UpdatePlanPrescritionStatus]
	 @EvalID as int
	,@PlanID as int
	,@UserID as varchar(6) 
	
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @PrescriptStatus as bit
	
	IF NOT Exists(SELECT * FROM EvaluationStandardRating 
					WHERE RatingID IN (SELECT CodeID FROM CodeLookUp 
										WHERE CodeType = 'StdRating' 
										AND CodeText IN('Needs Improvement','Unsatisfactory') 
									  )
					AND EvalID = @EvalID)
	BEGIN
		SET @PrescriptStatus = 0
	END				     		
	ELSE
	BEGIN
		SET @PrescriptStatus = 1
	END
	
		UPDATE EmplPlan
		SET HasPrescript = @PrescriptStatus,
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE()
		WHERE PlanID = @PlanID 
END
GO
