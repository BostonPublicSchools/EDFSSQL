SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 01/15/2013
-- Description:	Update comments.
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCommentsViewed]
	@OtherID int,
	@OtherIDCommentType nvarchar(max),
	@UserID nvarchar(6)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE cwh
	SET cwh.IsViewed = 1,
		cwh.LastUpdatedByID = @UserID,
		cwh.LastUpdatedDt = GETDATE()
	FROM CommentsViewHistory cwh 
	JOIN Comment c on c.CommentID = cwh.CommentID
	WHERE c.OtherID = @OtherID and cwh.AssignedEmplID = @UserID
END
GO
