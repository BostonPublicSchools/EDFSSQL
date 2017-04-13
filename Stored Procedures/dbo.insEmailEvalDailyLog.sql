SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 11/5/2013
-- Description: insert the evaluation released email
-- =============================================
CREATE PROCEDURE [dbo].[insEmailEvalDailyLog]
    @EmplJobID AS INT ,
    @EmailBody AS NVARCHAR(3000)
AS
    BEGIN
        SET NOCOUNT ON;
	
        DECLARE @EmplID AS NCHAR(6);
        DECLARE @MgrID AS NCHAR(6);
	
        SELECT  @EmplID = EmplID
        FROM    dbo.EmplEmplJob
        WHERE   EmplJobID = @EmplJobID;
	
        SELECT  @MgrID = ( CASE WHEN ex.MgrID IS NOT NULL THEN ex.MgrID
                                ELSE ej.MgrID
                           END )
        FROM    dbo.EmplEmplJob ej
                LEFT OUTER JOIN dbo.EmplExceptions ex ON ex.EmplJobID = ej.EmplJobID
        WHERE   ej.EmplJobID = @EmplJobID;
	
	--insert subevals into evaluatorDaily emailLog
        DECLARE @ResultSet TABLE
            (
              EmplJobID INT ,
              IsActive BIT ,
              IsDeleted BIT ,
              IsPrimary BIT ,
              SubEvalID CHAR(6) ,
              MgrId CHAR(6) ,
              SubEmplName CHAR(50) ,
              PrimaryCount INT
            );
        INSERT  INTO @ResultSet
                ( EmplJobID ,
                  IsActive ,
                  IsDeleted ,
                  IsPrimary ,
                  SubEvalID ,
                  MgrId ,
                  SubEmplName ,
                  PrimaryCount
                )
                EXEC dbo.getAllSubEvalByEmplJobId @EmplJobID;
	
        DECLARE @counter INT;
        DECLARE @productKey VARCHAR(20);

        SET @counter = ( SELECT COUNT(EmplJobID)
                         FROM   @ResultSet
                       );

        WHILE ( 1 = 1
                AND @counter > 0
              )
            BEGIN	
                INSERT  INTO dbo.EvaluatorDailyEmailLog
                        ( MgrID ,
                          EmplID ,
                          SubEvalID ,
                          CurrentStatus ,
                          CreatedByDt ,
                          LastUpdatedByDt
                        )
                        SELECT TOP 1
                                @MgrID ,
                                @EmplID ,
                                SubEvalID ,
                                @EmailBody ,
                                GETDATE() ,
                                GETDATE()
                        FROM    @ResultSet
                        WHERE   IsDeleted = 0;
		
                DELETE TOP ( 1 )
                FROM    @ResultSet; 
                SET @counter -= 1;
	
                IF ( @counter = 0 )
                    BREAK;
            END;

	--insert for manager
        INSERT  INTO dbo.EvaluatorDailyEmailLog
                ( MgrID ,
                  EmplID ,
                  SubEvalID ,
                  CurrentStatus ,
                  CreatedByDt ,
                  LastUpdatedByDt
                )
        VALUES  ( @MgrID ,
                  @EmplID ,
                  @MgrID ,
                  @EmailBody ,
                  GETDATE() ,
                  GETDATE()
                );	
	END;
GO
