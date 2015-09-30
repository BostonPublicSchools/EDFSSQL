SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 04/02/2013
-- Description:	Import formative standards
-- =============================================
CREATE PROCEDURE [dbo].[EvalImportFormativeStd]
	@FormativeEvalID AS int,
	@EvalID AS int,
	@UserID AS nchar(6)	
AS
BEGIN
	--INSERT INTO EvaluationStandardRating(EvalID, StandardID, RatingID, Rationale, CreatedByID, CreatedDt, LastUpdatedByID, LastUpdatedDt)
	--	SELECT @EvalID, StandardID, RatingId, Rationale, @UserID, GETDATE(), @UserID, GETDATE() 
	--	FROM EvaluationStandardRating
	--	WHERE StandardID IN (SELECT StandardID FROM EvaluationStandardRating 
	--						 WHERE EvalID = @FormativeEvalID 
	--						 EXCEPT SELECT StandardID FROM EvaluationStandardRating WHERE EvalID = @EvalID
	--						 )
	--	AND EvalID = @FormativeEvalID
	
MERGE dbo.EvaluationStandardRating AS Target
USING (SELECT StandardID, Rationale, RatingId FROM EvaluationStandardRating  
							 WHERE EvalID = @FormativeEvalID) AS Source
ON (Target.StandardID = Source.StandardID AND Target.EvalID = @EvalID)
WHEN MATCHED THEN
   UPDATE SET Target.Rationale = Source.Rationale, Target.RatingId = Source.RatingId,
	Target.LastUpdatedByID = @UserID, Target.LastUpdatedDt = GETDATE()
WHEN NOT MATCHED BY TARGET THEN
  INSERT (EvalID, StandardID, RatingId, Rationale, CreatedByID, CreatedDt, LastUpdatedByID, LastUpdatedDt)
  VALUES (@EvalID, Source.StandardID, Source.RatingId, Source.Rationale, @UserID, GETDATE(), @UserID, GETDATE());
END
GO
