SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 01/15/2013
-- Description:	Update comments entered for the evidence.
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEvidenceComments]
	@EvidenceID int,
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
	WHERE c.OtherID = @EvidenceID and cwh.AssignedEmplID = @UserID
	
		
	--IF(@EvalComment IS NOT NULL AND @EvalComment != '')
	--BEGIN
	--	UPDATE Evidence
	--	SET	EvalComment = @EvalComment,
	--		EvalCommentDt = GETDATE(),		
	--		LastUpdatedByID = @UserID, 
	--		LastUpdatedDt = GETDATE()
	--	WHERE EvidenceID = @EvidenceID
	--END
	
	--IF(@EmplComment IS NOT NULL AND @EmplComment != '')
	--BEGIN
	--	UPDATE Evidence
	--	SET	EmplComment = @EmplComment,
	--		EmplCommentDt = GETDATE(),		
	--		LastUpdatedByID = @UserID, 
	--		LastUpdatedDt = GETDATE()
	--	WHERE EvidenceID = @EvidenceID
	--END
END
GO
