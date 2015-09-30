SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Avery, Bryce
-- Create date: 02/06/2012
-- Description:	Inserts a new comment in to the comment table
-- =============================================
CREATE PROCEDURE [dbo].[insComment]
	@EmplID AS nchar(6) = NULL
	,@PlanID AS int = NULL
	,@CommentTypeText AS nvarchar(50) = NULL
	,@CommentText AS nvarchar(max) = NULL
	,@UserID AS nchar(6) = null
	,@OtherID AS INT = NULL
	,@CommentID AS int = null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CommentTypeID AS int
	
	SELECT
		@CommentTypeID = CodeID
	FROM
		CodeLookUp
	WHERE
		CodeType = 'ComType'
	AND	CodeText = @CommentTypeText
	
	IF(@OtherID IS NULL)
	BEGIN
		INSERT INTO Comment (PlanID, CommentTypeID, EmplID, CommentDt, CommentText, CreatedByID, LastUpdatedByID)
						VALUES (@PlanID, @CommentTypeID, @EmplID, GETDATE(), @CommentText, @UserID, @UserID)
						
		set @CommentID = SCOPE_IDENTITY();								
	END
	ELSE IF(@OtherID IS NOT NULL)
	BEGIN		
		INSERT INTO Comment (PlanID, CommentTypeID, EmplID, CommentDt, CommentText, CreatedByID, LastUpdatedByID,OtherID)
						VALUES (@PlanID, @CommentTypeID, @EmplID, GETDATE(), @CommentText, @UserID, @UserID,@OtherID)
		
		set @CommentID = SCOPE_IDENTITY();		
		--when new comment is added insert record for all the educator and evaluators of a emplempljob 
		--and mark Isview as false except if the user id is emplID	
		DECLARE @EmplJobID as int
		SELECT @EmplJobID = ej.EmplJobID
		FROM Comment c
		join EmplPlan ep on ep.PlanID = c.PlanID
		join EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID
		WHERE c.CommentID = @CommentID

		DECLARE @temptable table(emplID nvarchar(6))
		INSERT INTO @temptable
			exec getAssignedEmplsByEmplJobID @EmplJobID

		INSERT INTO CommentsViewHistory (commentID, AssignedEmplID, IsViewed, CreatedDt, CreatedByID, LastUpdatedDt, LastUpdatedByID)
			SELECT @CommentID, s.EmplID as AssignedEmplID, (CASE WHEN @UserID = s.EmplID  THEN 1 ELSE 0 END), GETDATE(), @UserID, GETDATE(), @UserID
			FROM @temptable s		
			
		IF(@CommentTypeText = 'Observation Comment' and @EmplID = @UserID)											
		BEGIN
			exec insEmailEvalDailyLog @EmplJobId, 'Educator added an observation comment'
		END
	END
END

GO
