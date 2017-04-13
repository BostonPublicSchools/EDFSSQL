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
    @EvidenceID AS INT ,
    @UserID AS NVARCHAR(6)
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT  COUNT(c.CommentID) AS EviCommentCount ,
                COUNT(cwh.CommentsViewID) AS UnreadEviCommentCount
        FROM    dbo.Comment c ( NOLOCK )
                LEFT OUTER JOIN dbo.CommentsViewHistory cwh ( NOLOCK ) ON cwh.AssignedEmplID = @UserID
                                                           AND cwh.IsViewed = 0
														   AND cwh.CommentID = c.CommentID
                JOIN dbo.Evidence evi ( NOLOCK ) ON evi.EvidenceID = c.OtherID
                JOIN dbo.CodeLookUp cd ( NOLOCK ) ON cd.CodeType = 'ComType'
                                      AND cd.CodeText = 'Evidence Comment'
									  AND cd.CodeID = c.CommentTypeID
        WHERE   c.OtherID = @EvidenceID
                AND c.IsDeleted = 0;
	END;	
GO
