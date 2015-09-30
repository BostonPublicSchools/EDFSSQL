SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 01/14/2014
-- Description:	get all the comments based on commentType
-- =============================================
CREATE PROCEDURE [dbo].[getCommentsViewHistory]
		@OtherID AS int,
		@UserID as nvarchar(6),
		@OtherIDCommentType as nvarchar(max)
AS		
BEGIN
	SET NOCOUNT ON;
	
	IF(@OtherIDCommentType = 'Evidence')
	BEGIN
		SELECT COUNT(c.CommentID) as TotalCommentCount, COUNT(cwh.CommentsViewID) as 	UnReadCommentCount	
		from Comment c    
		Left outer join CommentsViewHistory cwh on cwh.CommentID = c.CommentID and cwh.AssignedEmplID = @UserID and cwh.IsViewed = 0
		join Evidence evi on evi.EvidenceID = c.OtherID 
		join CodeLookUp cd on cd.CodeID = c.CommentTypeID and cd.CodeType='ComType' and CodeText='Evidence Comment'
		WHERE c.OtherID = @OtherID and c.IsDeleted = 0
	END
	
	
	ELSE IF(@OtherIDCommentType = 'Goals')
	BEGIN
		SELECT COUNT(c.CommentID) as TotalCommentCount, COUNT(cwh.CommentsViewID) as 	UnReadCommentCount	
		from Comment c    
		Left outer join CommentsViewHistory cwh on cwh.CommentID = c.CommentID and cwh.AssignedEmplID = @UserID and cwh.IsViewed = 0
		join PlanGoal pg on pg.GoalID = c.OtherID 
		join CodeLookUp cd on cd.CodeID = c.CommentTypeID and cd.CodeType='ComType' and CodeText='Goal'
		WHERE c.OtherID = @OtherID and c.IsDeleted = 0
	END
	
	ELSE IF(@OtherIDCommentType = 'ActionSteps')
	BEGIN
		SELECT COUNT(c.CommentID) as TotalCommentCount, COUNT(cwh.CommentsViewID) as 	UnReadCommentCount	
		from Comment c    
		Left outer join CommentsViewHistory cwh on cwh.CommentID = c.CommentID and cwh.AssignedEmplID = @UserID and cwh.IsViewed = 0
		join GoalActionStep gc on gc.ActionStepID = c.OtherID 
		join CodeLookUp cd on cd.CodeID = c.CommentTypeID and cd.CodeType='ComType' and CodeText='ActionSteps'
		WHERE c.OtherID = @OtherID and c.IsDeleted = 0
	END
	
END	
GO
