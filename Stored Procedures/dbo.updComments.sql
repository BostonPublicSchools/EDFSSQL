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
    @CommentID INT ,
    @CommentText NVARCHAR(MAX) ,
    @PlanID INT ,
    @UserID NVARCHAR(6)
AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE  dbo.Comment
        SET     CommentText = @CommentText
        WHERE   CommentID = @CommentID
                AND PlanID = @PlanID;

        DECLARE @CodeType AS NVARCHAR(10);
        SELECT  @CodeType = c.Code
        FROM    dbo.CodeLookUp c
                JOIN dbo.Comment ct ON ct.CommentTypeID = c.CodeID
        WHERE   ct.CommentID = @CommentID;

--update the existing comment
        IF ( ( @CodeType = 'EviCom' )
             AND EXISTS ( SELECT    CommentsViewID 
                          FROM      dbo.CommentsViewHistory
                          WHERE     CommentID = @CommentID )
           )
            BEGIN 
                UPDATE  cwh
                SET     cwh.IsViewed = 0 ,
                        cwh.LastUpdatedByID = @UserID ,
                        cwh.LastUpdatedDt = GETDATE()
                FROM    dbo.CommentsViewHistory cwh
                        JOIN dbo.Comment c ON c.CommentID = cwh.CommentID
                WHERE   c.CommentID = @CommentID
                        AND cwh.AssignedEmplID != @UserID;
            END;

---insert new for the comments if it doesnt exists.
        ELSE
            IF ( ( @CodeType = 'EviCom' )
                 AND NOT EXISTS ( SELECT    CommentsViewID
                                  FROM      dbo.CommentsViewHistory
                                  WHERE     CommentID = @CommentID )
               )
                BEGIN
                    DECLARE @EmplJobID AS INT;
                    SELECT  @EmplJobID = ej.EmplJobID
                    FROM    dbo.Comment c
                            JOIN dbo.EmplPlan ep ON ep.PlanID = c.PlanID
                            JOIN dbo.EmplEmplJob ej ON ej.EmplJobID = ep.EmplJobID
                    WHERE   c.CommentID = @CommentID;

                    DECLARE @temptable TABLE ( emplID NVARCHAR(6) );
                    INSERT  INTO @temptable
                            EXEC dbo.getAssignedEmplsByEmplJobID @EmplJobID;

                    INSERT  INTO dbo.CommentsViewHistory
                            ( CommentID ,
                              AssignedEmplID ,
                              IsViewed ,
                              CreatedDt ,
                              CreatedByID ,
                              LastUpdatedDt ,
                              LastUpdatedByID
                            )
                            SELECT  @CommentID ,
                                    s.emplID AS AssignedEmplID ,
                                    ( CASE WHEN @UserID = s.emplID THEN 1
                                           ELSE 0
                                      END ) ,
                                    GETDATE() ,
                                    @UserID ,
                                    GETDATE() ,
                                    @UserID
                            FROM    @temptable s;		
                END;
    END;

GO
