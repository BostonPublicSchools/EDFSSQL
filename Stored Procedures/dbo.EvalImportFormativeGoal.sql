SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 04/02/2013
-- Description:	Import formative standards
-- =============================================
CREATE PROCEDURE [dbo].[EvalImportFormativeGoal]
	@FormativeEvalID AS int,
	@EvalID AS int,
	@UserID AS nchar(6)	
AS
BEGIN
	--INSERT INTO GoalEvaluationProgress(EvalID, GoalID, ProgressCodeID, Rationale, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
	--	SELECT @EvalID, GoalID, ProgressCodeID, Rationale, @UserID, GETDATE(), @UserID, GETDATE() 
	--	FROM GoalEvaluationProgress
	--	WHERE GoalID IN (SELECT GoalID FROM GoalEvaluationProgress 
	--						 WHERE EvalID = @FormativeEvalID 
	--						 EXCEPT SELECT GoalID FROM GoalEvaluationProgress WHERE EvalID = @EvalID
	--						 )
	--	AND EvalID = @FormativeEvalID
	
MERGE dbo.GoalEvaluationProgress AS Target
USING (SELECT GoalID, Rationale, ProgressCodeID FROM GoalEvaluationProgress  
							 WHERE EvalID = @FormativeEvalID) AS Source
ON (Target.GoalID = Source.GoalID AND Target.EvalID = @EvalID)
WHEN MATCHED THEN
  UPDATE SET Target.Rationale = Source.Rationale, Target.ProgressCodeID = Source.ProgressCodeID,
  Target.LastUpdatedByID = @UserID, Target.LastUpdatedDt = GETDATE()
WHEN NOT MATCHED BY TARGET THEN
  INSERT (EvalID, GoalID, ProgressCodeID, Rationale, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
  VALUES (@EvalID, Source.GoalID, Source.ProgressCodeID, Source.Rationale, @UserID, GETDATE(), @UserID, GETDATE());
 
END
GO
