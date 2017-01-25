SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/24/2012
-- Description:	Inserts goal into goal table
-- =============================================
CREATE PROCEDURE [dbo].[insGoal]
    @PlanID AS INT = NULL ,
    @GoalYear AS INT = NULL ,
    @GoalTypeID AS INT = NULL ,
    @GoalLevelID AS INT = NULL ,
    @GoalText AS NVARCHAR(MAX) = NULL ,
    @GoalTag AS NVARCHAR(MAX) = NULL ,
    @UserID AS NCHAR(6) = NULL
	--,@GoalTagAcnTypeID as int = 0
    ,
    @GoalID AS INT = NULL OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;
	
        DECLARE @EmplID AS NCHAR(6) ,
            @MgrID AS NCHAR(6) --PriMgrid
            ,
            @PriSubEvalID AS NCHAR(6) ,
            @EvalEmplID AS NCHAR(6) ,
            @CodeID AS INT ,
            @EmplJobID INT ,
            @AllowInsert BIT = 0;
	
        SELECT TOP 1
                @EmplJobID = EmplJobID
        FROM    dbo.EmplPlan
        WHERE   PlanID = @PlanID;	
        SELECT TOP 1
                @EvalEmplID = EmplID
        FROM    dbo.EmplEmplJob
        WHERE   EmplJobID = @EmplJobID;	
	
        SELECT  @MgrID = dbo.funcGetPrimaryManagerByEmplID(@EvalEmplID);
	
        IF @MgrID = @UserID 	--OR @PriSubEvalID=@UserID
            BEGIN
                SELECT  @CodeID = CodeID
                FROM    dbo.CodeLookUp
                WHERE   CodeText = 'In Process'
                        AND CodeType = 'GoalStatus';
            END;
        ELSE
            IF @EvalEmplID = @UserID
                BEGIN
                    SELECT  @CodeID = CodeID
                    FROM    dbo.CodeLookUp
                    WHERE   CodeText = 'Not Yet Submitted'
                            AND CodeType = 'GoalStatus';
                END;
	
        IF ( @MgrID = @UserID
             OR @UserID = @EvalEmplID
           )
            BEGIN	
                IF ( @GoalTag IS NULL
                     OR @GoalTag = ''
                   )
                    BEGIN 
                        SET @GoalID = 0;
                        RETURN;
                    END;
			
                INSERT  INTO dbo.PlanGoal
                        ( PlanID ,
                          GoalYear ,
                          GoalTypeID ,
                          GoalLevelID ,
                          GoalStatusID ,
                          GoalText ,
                          CreatedByID ,
                          LastUpdatedByID
                        )
                VALUES  ( @PlanID ,
                          @GoalYear ,
                          @GoalTypeID ,
                          @GoalLevelID ,
                          @CodeID ,
                          @GoalText ,
                          @UserID ,
                          @UserID
                        );
				
                DECLARE @NextString NVARCHAR(MAX) ,
                    @Pos INT ,
                    @NextPos INT ,
                    @Delimiter NVARCHAR(40);

                SET @Delimiter = ',';
                SET @Pos = CHARINDEX(@Delimiter, @GoalTag);
		
                SET @GoalID = SCOPE_IDENTITY();

                WHILE ( @Pos <> 0 )
                    BEGIN
                        SET @NextString = SUBSTRING(@GoalTag, 1, @Pos - 1);
                        INSERT  INTO dbo.GoalTag
                                ( GoalID ,
                                  GoalTagID ,
                                  CreatedByID ,
                                  LastUpdatedByID
                                )
                        VALUES  ( @GoalID ,
                                  @NextString ,
                                  @UserID ,
                                  @UserID
                                );
                        SET @GoalTag = SUBSTRING(@GoalTag, @Pos + 1,
                                                 LEN(@GoalTag));
                        SET @Pos = CHARINDEX(@Delimiter, @GoalTag);
			
                    END; 
            END;
    END;
GO
