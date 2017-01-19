SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 12/06/2013
-- Description: Copy all the subeval to the new manager of 
--				the department only if the old manager has multiple 
--				active emplJobs.
-- =============================================
CREATE PROCEDURE [dbo].[CopySubEvalNewMgr]
    @DeptID AS INT ,
    @OldManagerId AS NCHAR(6) ,
    @ManagerId AS NCHAR(6) ,
    @UserID AS NCHAR(6)
AS
    BEGIN

        SET NOCOUNT ON;

        DECLARE @ResultSet TABLE
            (
              rsEmplID NCHAR(6) ,
              rsEvalActive BIT ,
              rsIsLicEval BIT ,
              rsIsNonLicEval BIT ,
              rsIsEvalManager BIT
            );

        INSERT  INTO @ResultSet
                ( rsEmplID ,
                  rsEvalActive ,
                  rsIsLicEval ,
                  rsIsNonLicEval ,
                  rsIsEvalManager
                )
                SELECT  EmplID ,
                        EvalActive ,
                        Is5StepProcess ,
                        IsNon5StepProcess ,
                        IsEvalManager
                FROM    dbo.SubEval
                WHERE   MgrID = @OldManagerId
                        AND EvalActive = 1
                        AND EmplID != @ManagerId;

---Iterate through the evaluators
        DECLARE @counter INT;
        DECLARE @productKey VARCHAR(20);

        SET @counter = ( SELECT COUNT(*)
                         FROM   @ResultSet
                       );

        WHILE ( 1 = 1
                AND @counter > 0
              )
            BEGIN	
	
                DECLARE @newEvalID AS INT;
                DECLARE @EmplID AS NCHAR(6);
	
                SET @EmplID = ( SELECT TOP 1
                                        rsEmplID
                                FROM    @ResultSet
                              );
	
                IF NOT EXISTS ( SELECT  EvalID ,
                                        MgrID ,
                                        EmplID ,
                                        EvalActive ,
                                        CreatedByID ,
                                        CreatedByDt ,
                                        LastUpdatedByID ,
                                        LastUpdatedDt ,
                                        Is5StepProcess ,
                                        IsNon5StepProcess ,
                                        IsEvalManager
                                FROM    dbo.SubEval
                                WHERE   MgrID = @ManagerId
                                        AND EmplID = @EmplID
                                        AND EvalActive = 1 )
                    BEGIN	
                        INSERT  INTO dbo.SubEval
                                ( MgrID ,
                                  EmplID ,
                                  CreatedByDt ,
                                  CreatedByID ,
                                  EvalActive ,
                                  IsEvalManager ,
                                  Is5StepProcess ,
                                  IsNon5StepProcess ,
                                  LastUpdatedByID ,
                                  LastUpdatedDt
                                )
                                SELECT TOP 1
                                        @ManagerId ,
                                        rsEmplID ,
                                        GETDATE() ,
                                        @UserID ,
                                        rsEvalActive ,
                                        rsIsEvalManager ,
                                        rsIsLicEval ,
                                        rsIsNonLicEval ,
                                        @UserID ,
                                        GETDATE()
                                FROM    @ResultSet; 
	
                        SET @newEvalID = SCOPE_IDENTITY();
	
	---update the subeval of all the emplJobs of the dept with new manager relations.
                        UPDATE  sej
                        SET     sej.SubEvalID = @newEvalID
                        FROM    dbo.SubevalAssignedEmplEmplJob sej
                        WHERE   sej.EmplJobID IN ( SELECT   EmplJobID
                                                   FROM     dbo.EmplEmplJob
                                                   WHERE    DeptID = @DeptID
                                                            AND IsActive = 1 )
                                AND sej.SubEvalID IN (
                                SELECT  EvalID
                                FROM    dbo.SubEval
                                WHERE   EvalActive = 1
                                        AND MgrID = @OldManagerId
                                        AND EmplID = @EmplID )
                                AND sej.IsActive = 1;
                    END;		
                DELETE TOP ( 1 )
                FROM    @ResultSet; 
                SET @counter -= 1;
	
                IF ( @counter = 0 )
                    BREAK;
            END;
    END;
GO
