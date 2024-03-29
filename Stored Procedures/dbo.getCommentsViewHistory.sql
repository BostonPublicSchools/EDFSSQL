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
    @OtherID AS INT ,
    @UserID AS NVARCHAR(6) ,
    @OtherIDCommentType AS NVARCHAR(MAX)
AS
    BEGIN
        SET NOCOUNT ON;
	
        IF ( @OtherIDCommentType = 'Evidence' )
            BEGIN
                SELECT  COUNT(c.CommentID) AS TotalCommentCount ,
                        COUNT(cwh.CommentsViewID) AS UnReadCommentCount
                FROM    dbo.Comment c ( NOLOCK )
                        LEFT OUTER JOIN dbo.CommentsViewHistory cwh ( NOLOCK ) ON cwh.AssignedEmplID = @UserID
                                                              AND cwh.IsViewed = 0
															  AND cwh.CommentID = c.CommentID
                        JOIN dbo.Evidence evi ( NOLOCK ) ON evi.EvidenceID = c.OtherID
                        JOIN dbo.CodeLookUp cd ( NOLOCK ) ON cd.CodeType = 'ComType'
                                                             AND cd.CodeText = 'Evidence Comment'
															 AND cd.CodeID = c.CommentTypeID
                WHERE   c.OtherID = @OtherID
                        AND c.IsDeleted = 0;
            END;
	
        ELSE
            IF ( @OtherIDCommentType = 'Goals' )
                BEGIN
                    SELECT  COUNT(c.CommentID) AS TotalCommentCount ,
                            COUNT(cwh.CommentsViewID) AS UnReadCommentCount
                    FROM    dbo.Comment c ( NOLOCK )
                            LEFT OUTER JOIN dbo.CommentsViewHistory cwh ( NOLOCK ) ON cwh.AssignedEmplID = @UserID
                                                              AND cwh.IsViewed = 0
															  AND cwh.CommentID = c.CommentID
                            JOIN dbo.PlanGoal pg ( NOLOCK ) ON pg.GoalID = c.OtherID
                            JOIN dbo.CodeLookUp cd ( NOLOCK ) ON cd.CodeType = 'ComType'
                                                              AND cd.CodeText = 'Goal'
															  AND cd.CodeID = c.CommentTypeID
                    WHERE   c.OtherID = @OtherID
                            AND c.IsDeleted = 0;
                END;
	
            ELSE
                IF ( @OtherIDCommentType = 'ActionSteps' )
                    BEGIN
                        SELECT  COUNT(c.CommentID) AS TotalCommentCount ,
                                COUNT(cwh.CommentsViewID) AS UnReadCommentCount
                        FROM    dbo.Comment c ( NOLOCK )
                                LEFT OUTER JOIN dbo.CommentsViewHistory cwh ( NOLOCK ) ON cwh.AssignedEmplID = @UserID
                                                              AND cwh.IsViewed = 0
															  AND cwh.CommentID = c.CommentID
                                JOIN dbo.GoalActionStep gc ( NOLOCK ) ON gc.ActionStepID = c.OtherID
                                JOIN dbo.CodeLookUp cd ( NOLOCK ) ON cd.CodeType = 'ComType'
                                                              AND cd.CodeText = 'ActionSteps'
															  AND cd.CodeID = c.CommentTypeID
                        WHERE   c.OtherID = @OtherID
                                AND c.IsDeleted = 0;
                    END;
    END;
GO
