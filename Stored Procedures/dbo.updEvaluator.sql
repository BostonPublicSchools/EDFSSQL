SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/23/2012
-- Description:	Updates to a new evaluator
-- =============================================
CREATE PROCEDURE [dbo].[updEvaluator]
	@SubEvalID	AS nchar(6) = null
	,@EmplID	AS nchar(6) = null
	,@UserID	AS nchar(6) = null
	,@EmplJobID	as int = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ExceptionID int
	declare @AssignedSubevaluatorID int
	declare @SubEvalIDint int
			
	SET @ExceptionID = null

	select
		@AssignedSubevaluatorID = AssignedSubevaluatorID
	from
		SubevalAssignedEmplEmplJob
	where
		EmplJobID = @EmplJobID

	select
		@SubEvalIDint = EvalID
	from
		SubEval
	where
			EmplID = @SubEvalID
		AND MgrID = @UserID
		and EvalActive = 1
			
	if @SubEvalID = @UserID
	begin
			UPDATE SubevalAssignedEmplEmplJob
			SET
				IsDeleted = 1
				,LastUpdatedByID =  @UserID
				,LastUpdatedDt = GETDATE()
			WHERE
				AssignedSubevaluatorID = @AssignedSubevaluatorID
	end
	else
	begin
		if @AssignedSubevaluatorID is not null
		begin
			UPDATE SubevalAssignedEmplEmplJob
			SET
				SubEvalID = @SubEvalIDint
				,IsPrimary = 1
				,IsDeleted = 0
				,LastUpdatedByID =  @UserID
				,LastUpdatedDt = GETDATE()
			WHERE
				AssignedSubevaluatorID = @AssignedSubevaluatorID
		end
		else
		begin
			insert SubevalAssignedEmplEmplJob (EmplJobID, SubEvalID, IsPrimary, CreatedByID, LastUpdatedByID)
										values (@EmplJobID, @SubEvalIDint, 1, @UserID, @UserID)
										
		end
	end
	
	UPDATE EmplPlan 
	SET 
		SubEvalID = @SubEvalID
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()	
	WHERE 
		EmplJobID = @EmplJobID
		AND PlanActive = 1		
END
GO
