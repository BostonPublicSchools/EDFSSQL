SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 05/02/2012
-- Description:	Inserts standard rating into EvaluationStandardRating table
-- =============================================
CREATE PROCEDURE [dbo].[insEvaluationStandardRating]
	@EvalID as int
	,@StandardID as int
	,@RatingID as int
	,@Rationale as nvarchar(max) = null
	,@UserID as varchar(6) = null
	,@EvalStdRatingID int = 0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
IF NOT EXISTS(SELECT EvalStdRatingID FROM EvaluationStandardRating WHERE EvalID = @EvalID AND StandardID = @StandardID)
BEGIN
insert EvaluationStandardRating
		(	EvalID
			,StandardID
			,RatingID
			,Rationale
			,CreatedByID
			,CreatedDt
			,LastUpdatedByID
			,LastUpdatedDt
		)
values	(
			@EvalID
			,@StandardID
			,@RatingID
			,@Rationale
			,@UserID
			,GETDATE()
			,@UserID
			,GETDATE()
		)
SELECT @EvalStdRatingID = SCOPE_IDENTITY();		
END
END
GO
