SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/02/2012
-- Description:	Updates comments based on plan id 
--				and comments ID				
-- =============================================
CREATE PROCEDURE [dbo].[updComments]
@CommentID int,
@CommentText nvarchar(max),
@PlanID int,
@UserID nvarchar(6)

AS 
BEGIN
SET NOCOUNT ON;
UPDATE Comment SET 
	CommentText = @CommentText
WHERE CommentID = @CommentID and PlanID = @PlanID

DECLARE @CodeType as nvarchar(10)
SELECT @CodeType = Code FROM CodeLookUp c 
					JOIN Comment ct on ct.CommentTypeID = c.CodeID 
					where ct.CommentID = @CommentID

--update the existing comment
IF((@CodeType = 'EviCom') and Exists(SELECT * FROM CommentsViewHistory WHERE CommentID = @CommentID))
BEGIN 
	UPDATE cwh
	SET cwh.IsViewed = 0,
		cwh.LastUpdatedByID = @UserID,
		cwh.LastUpdatedDt = GETDATE()
	FROM CommentsViewHistory cwh 
	JOIN Comment c on c.CommentID = cwh.CommentID
	WHERE c.CommentID = @CommentID and cwh.AssignedEmplID != @UserID
END

---insert new for the comments if it doesnt exists.
ELSE IF ((@CodeType = 'EviCom') and not Exists(SELECT * FROM CommentsViewHistory WHERE CommentID = @CommentID))
	BEGIN
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
	END
END

GO
