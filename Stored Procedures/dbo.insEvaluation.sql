SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 04/02/2012
-- Description:	Insert Evaluation 
-- =============================================
CREATE PROCEDURE [dbo].[insEvaluation]
	@PlanID AS nchar(6) 
	,@EvalTypeID AS nchar(6) 	
	,@UserID AS nchar(6)
	,@EvalID int OUTPUT
	,@EvalEditEndDt as Datetime = null
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @EvalPlanYear as int
	SELECT @EvalPlanYear =COALESCE(PlanYear,1) from EmplPlan WHERE PlanID = @PlanID
	
	DECLARE @EmplID as nchar(6)
	SELECT @EmplID = emplID from EmplEmplJob where (EmplJobID = (SELECT top 1 EmplJobID FROM EmplPlan where PlanID = @PlanID))
		
	DECLARE @EvalRubricID as int
    SET @EvalRubricID = (SELECT ep.RubricID from EmplPlan ep where ep.PlanID = @PlanID)
	
	DECLARE @EvalMgrID as nchar(6)
	DECLARE @EvalSubEvalID as nchar(6)
		SELECT 
		@EvalMgrID = (CASE WHEN ex.MgrID IS NOT NULL THEN ex.MgrID ELSE ej.MgrID END),
		@EvalSubEvalID = dbo.funcGetPrimaryManagerByEmplID(@EmplID)
		FROM EmplPlan ep 
		JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID
		LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID=ej.EmplJobID
		LEFT OUTER JOIN SubevalAssignedEmplEmplJob sej on sej.EmplJobID = ej.EmplJobID  and sej.IsPrimary = 1 and sej.IsActive =1 and sej.IsDeleted = 1
		LEFT OUTER JOIN SubEval s on sej.SubEvalID = s.EvalID and s.EvalActive = 1 
		WHERE ep.PlanId = @PlanId
	
	INSERT INTO Evaluation(PlanID,EvalTypeID,EvalDt, EditEndDt, IsSigned,CreatedByID,LastUpdatedByID,LastUpdatedDt,CreatedDt,EvalRubricID, EvalPlanYear, EvalManagerID, EvalSubEvalID) 
				VALUES (@PlanID,@EvalTypeID,GETDATE(),@EvalEditEndDt, 0,@UserID,@UserID,GETDATE(),GETDATE(), @EvalRubricID, @EvalPlanYear, @EvalMgrID, @EvalSubEvalID)
	SELECT @EvalID = SCOPE_IDENTITY();
END
GO
