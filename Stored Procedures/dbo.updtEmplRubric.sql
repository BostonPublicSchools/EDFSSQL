SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/26/2012
-- Description: update the rubrc id for an emplJob
-- =============================================
CREATE PROCEDURE [dbo].[updtEmplRubric]
	@RubricID AS int,
	@JobCode AS nchar(6),
	@UserID AS nchar(6),
	@UpdateInAll As bit
AS
BEGIN
	SET NOCOUNT ON;		
	
	UPDATE EmplJob
	SET RubricID = @RubricID,
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE()
	WHERE JobCode = @JobCode
	
	IF @UpdateInAll=1
	Begin
		Update EmplEmplJob
		Set RubricID = @RubricID ,
			LastUpdatedByID= @UserID,
			LastUpdatedDt=GetDate()
		From EmplEmplJob j Join Empl em ON j.EmplID=em.EmplID And em.EmplActive=1
		Where j.IsActive=1 And j.JobCode=@JobCode
	End
	
	
	--UPDATE Evaluation SET EvalRubricID = @RubricID
	--FROM Evaluation eval
	--JOIN EmplPlan eplan ON eplan.PlanID = eval.PlanID
	--LEFT OUTER JOIN EmplEmplJob emplJob ON emplJob.EmplJobID = eplan.EmplJobID
	--LEFT OUTER JOIN EmplJob ej ON ej.JobCode = emplJob.JobCode
	--WHERE ej.JobCode = @JobCode and eval.IsSigned = 0
END
GO
