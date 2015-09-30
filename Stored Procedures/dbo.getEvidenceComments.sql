SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 01/14/2012
-- Description:	get all the comments for an evidence
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceComments]
		@EvidenceID AS int,
		@UserID as nvarchar(6)
		--,@CommentsCount as int= 0 OUTPUT
AS		
BEGIN
	SET NOCOUNT ON;
	
	
	--SELECT  COUNT(*) 
	SELECT COUNT(c.CommentID) as EviCommentCount, COUNT(cwh.CommentsViewID) as 	UnreadEviCommentCount	
	from Comment c    
	Left outer join CommentsViewHistory cwh on cwh.CommentID = c.CommentID and cwh.AssignedEmplID = @UserID and cwh.IsViewed = 0
	join Evidence evi on evi.EvidenceID = c.OtherID 
	join CodeLookUp cd on cd.CodeID = c.CommentTypeID and cd.CodeType='ComType' and CodeText='Evidence Comment'
	WHERE c.OtherID = @EvidenceID and c.IsDeleted = 0
	
	
END	
GO
