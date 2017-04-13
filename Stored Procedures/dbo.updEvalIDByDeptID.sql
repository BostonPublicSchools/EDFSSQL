SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 03/13/2013
-- Description: update the emplPlan and emplJob 
-- with the new subeval.
-- =============================================
CREATE PROCEDURE [dbo].[updEvalIDByDeptID]
    @UpdDeptID AS NCHAR(6) ,
    @UpdDeptMgrId AS NCHAR(6) ,
    @UpdDeptUpdatedById AS NCHAR(6) ,
    @UpdOldManagerID AS NCHAR(6) ,
    @UpdDeptCategoryId AS INT
AS
    BEGIN 
        SET NOCOUNT ON;
	
	/**
	Update all the emplPlan with the new subevalID for the department	
	**/	
        UPDATE  dbo.EmplPlan
        SET     SubEvalID = @UpdDeptMgrId
        WHERE   PlanID IN (
                SELECT  PlanID
                FROM    dbo.EmplPlan (NOLOCK)
                WHERE   EmplJobID IN ( SELECT   EmplJobID
                                       FROM     dbo.EmplEmplJob (NOLOCK)
                                       WHERE    DeptID = @UpdDeptID
                                                AND IsActive = 1 ) )
                AND SubEvalID = @UpdOldManagerID;
	
	
        DECLARE @TableVar TABLE
            (
              RowID INT NOT NULL ,
              EmplID NCHAR(6) NOT NULL
            );
        INSERT  INTO @TableVar
                ( RowID ,
                  EmplID
                )
                ( SELECT    ROW_NUMBER() OVER ( ORDER BY ej.EmplID ) AS RowID ,
                            ej.EmplID
                  FROM      dbo.EmplEmplJob ej ( NOLOCK )
                            JOIN dbo.EmplPlan ep ON ep.PlanActive = 1
                                                    AND ( ep.SubEvalID IS NULL
                                                          OR ep.SubEvalID = '000000'
                                                        )
                                                    AND ej.EmplJobID = ep.EmplJobID
                  WHERE     ej.DeptID = @UpdDeptID
                ); 


        DECLARE @EmplID VARCHAR(20);
        DECLARE @id INT;
        DECLARE @rowNum INT;
        DECLARE @maxrows INT;
        SELECT TOP 1
                @id = RowID ,
                @EmplID = EmplID
        FROM    @TableVar;
        SELECT  @maxrows = COUNT(RowID)
        FROM    @TableVar;
        SET @rowNum = 0;
	-- this will until the last row is reached
        WHILE @rowNum < @maxrows
            BEGIN
                SET @rowNum = @rowNum + 1;
	-- foreach employee update the subeval for the plan with highest FTE of all the emplJob for the empl.
                UPDATE  dbo.EmplPlan
                SET     SubEvalID = @UpdDeptMgrId ,
                        LastUpdatedByID = @UpdDeptUpdatedById ,
                        LastUpdatedDt = GETDATE()
                WHERE   EmplJobID = ( SELECT TOP 1
                                                ( EmplJobID )
                                      FROM      dbo.EmplEmplJob (NOLOCK)
                                      WHERE     FTE IN (
                                                SELECT TOP 1
                                                        MAX(FTE)
                                                FROM    dbo.EmplEmplJob (NOLOCK)
                                                WHERE   EmplID = @EmplID
                                                        AND IsActive = 1 )
                                                AND EmplID = @EmplID
                                      ORDER BY  EmplRcdNo ASC
                                    )
                        AND PlanActive = 1;							

                SELECT TOP 1
                        @id = RowID ,
                        @EmplID = EmplID
                FROM    @TableVar
                WHERE   RowID > @id;
            END;

    END;
GO
