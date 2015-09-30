SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 03/19/2012
-- Description:	Flag comment as deleted 
-- =============================================
CREATE PROCEDURE [dbo].[delComments]
	@CommentID	AS int = null
	,@UserID AS nchar(6) = null
	,@unDelete As int = null
AS
BEGIN
	SET NOCOUNT ON;

if(@unDelete is null)	
Begin
	UPDATE Comment
	SET
		IsDeleted = 1
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		CommentID = @CommentID AND
		CreatedByID = @UserID		

	--delete all the view history
	DELETE FROM CommentsViewHistory	WHERE CommentID = @CommentID
End		
Else  --undelete comment
Begin
	UPDATE Comment
	SET
		IsDeleted = 0 
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		CommentID = @CommentID AND
		CreatedByID = @UserID	
End
END
GO
