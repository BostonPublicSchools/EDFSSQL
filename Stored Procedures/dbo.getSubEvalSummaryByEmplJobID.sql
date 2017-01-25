SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 02/08/2013
-- Description:	get all subeval by empljobID
-- =============================================
CREATE PROCEDURE [dbo].[getSubEvalSummaryByEmplJobID]
    @EmplJobID INT ,
    @MgrID AS NCHAR(6) ,
    @IsNonLic AS BIT = 0
AS
    BEGIN
        SET NOCOUNT ON;
	


--#1.get the emplId.		
        DECLARE @EmplID AS NCHAR(6);
        SET @EmplID = ( SELECT  EmplID
                        FROM    dbo.EmplEmplJob
                        WHERE   EmplJobID = @EmplJobID
                      );
		
	
--#2.the list of managers of all the active emplJob for an employee		
        DECLARE @ListOfMangerID TABLE ( managerID NVARCHAR(6) );
        INSERT  INTO @ListOfMangerID
                SELECT  ( CASE WHEN ( ex.MgrID IS NULL
                                      OR ex.MgrID = '000000'
                                    ) THEN ej.MgrID
                               ELSE ex.MgrID
                          END )
                FROM    dbo.EmplEmplJob ej
                        LEFT OUTER JOIN dbo.EmplExceptions ex ON ex.EmplJobID = ej.EmplJobID
                WHERE   ej.EmplID = @EmplID
                        AND ej.IsActive = 1;

--#3.Get the primary for the emplId.
        DECLARE @PrimaryCount AS INT = 0;
        SET @PrimaryCount = ( SELECT    COUNT(se.IsPrimary)
                              FROM      dbo.SubevalAssignedEmplEmplJob se
                                        JOIN dbo.SubEval s ON s.EvalID = se.SubEvalID
                                                          AND s.EvalActive = 1
                              WHERE     se.EmplJobID IN ( SELECT
                                                              EmplJobID
                                                          FROM
                                                              dbo.EmplEmplJob
                                                          WHERE
                                                              EmplID = @EmplID
                                                              AND IsActive = 1 )
                                        AND se.IsDeleted = 0
                                        AND se.IsActive = 1
                                        AND se.IsPrimary = 1
                                        AND s.MgrID IN ( SELECT
                                                              managerID
                                                         FROM @ListOfMangerID )
                            );			
	

		
--#4.All the subevals which includes all the managers for the empl, all the subeval for the logged in mangers 		
        WITH    allEval
                  AS (
	--#11. select managers
                       SELECT   ej.EmplJobID ,
                                ( CASE WHEN ( ex.MgrID IS NULL
                                              OR ex.MgrID = '000000'
                                            ) THEN ej.MgrID
                                       ELSE ex.MgrID
                                  END ) AS EmplID ,
                                e.NameLast + ', ' + e.NameFirst + ' '
                                + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID
                                + ')' AS EmplName ,
                                ( CASE WHEN ( ex.MgrID IS NULL
                                              OR ex.MgrID = '000000'
                                            ) THEN ej.MgrID
                                       ELSE ex.MgrID
                                  END ) AS MgrID ,
                                1 AS IsActive ,
                                0 AS IsDeleted ,
                                1 AS IsManagers ,
                                ( CASE WHEN EXISTS ( SELECT sej.AssignedSubevaluatorID
                                                     FROM   dbo.SubevalAssignedEmplEmplJob sej
                                                            JOIN dbo.SubEval s ON s.EvalID = sej.SubEvalID
                                                              AND s.EvalActive = 1
                                                     WHERE  s.EmplID = e.EmplID
                                                            AND sej.EmplJobID = @EmplJobID
                                                            AND sej.IsPrimary = 1
                                                            AND sej.IsActive = 1
                                                            AND sej.IsDeleted = 0 )
                                       THEN 1
                                       ELSE 0
                                  END ) AS IsPrimary ,
                                1 AS Is5StepProcess ,
                                1 AS IsNon5StepProcess ,
                                ( CASE WHEN ej.EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID)
                                       THEN 1
                                       ELSE 0
                                  END ) AS IsPrimaryJobManager ,
                                @PrimaryCount AS PrimaryCount
                       FROM     dbo.EmplEmplJob ej
                                LEFT OUTER JOIN dbo.EmplExceptions ex ON ex.EmplJobID = ej.EmplJobID
                                JOIN dbo.Empl e ON e.EmplID = ( CASE
                                                              WHEN ( ex.MgrID IS NULL
                                                              OR ex.MgrID = '000000'
                                                              ) THEN ej.MgrID
                                                              ELSE ex.MgrID
                                                            END )
                                               AND e.EmplActive = 1
                       WHERE    ej.EmplID = @EmplID
                                AND ej.IsActive = 1
                       EXCEPT 

--remove the emplJob that has the same manager.
                       SELECT   ej.EmplJobID ,
                                ( CASE WHEN ( ex.MgrID IS NULL
                                              OR ex.MgrID = '000000'
                                            ) THEN ej.MgrID
                                       ELSE ex.MgrID
                                  END ) AS EmplID ,
                                e.NameLast + ', ' + e.NameFirst + ' '
                                + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID
                                + ')' AS EmplName ,
                                ( CASE WHEN ( ex.MgrID IS NULL
                                              OR ex.MgrID = '000000'
                                            ) THEN ej.MgrID
                                       ELSE ex.MgrID
                                  END ) AS MgrID ,
                                1 AS IsActive ,
                                0 AS IsDeleted ,
                                1 AS IsManagers ,
                                ( CASE WHEN EXISTS ( SELECT sej.AssignedSubevaluatorID 
                                                     FROM   dbo.SubevalAssignedEmplEmplJob sej
                                                            JOIN dbo.SubEval s ON s.EvalID = sej.SubEvalID
                                                              AND s.EvalActive = 1
                                                     WHERE  s.EmplID = e.EmplID
                                                            AND sej.EmplJobID = @EmplJobID
                                                            AND sej.IsPrimary = 1
                                                            AND sej.IsActive = 1
                                                            AND sej.IsDeleted = 0 )
                                       THEN 1
                                       ELSE 0
                                  END ) AS IsPrimary ,
                                1 AS Is5StepProcess ,
                                1 AS IsNon5StepProcess ,
                                ( CASE WHEN ej.EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID)
                                       THEN 1
                                       ELSE 0
                                  END ) AS IsPrimaryJobManager ,
                                @PrimaryCount AS PrimaryCount
                       FROM     dbo.EmplEmplJob ej
                                LEFT OUTER JOIN dbo.EmplExceptions ex ON ex.EmplJobID = ej.EmplJobID
                                JOIN dbo.Empl e ON e.EmplID = ( CASE
                                                              WHEN ( ex.MgrID IS NULL
                                                              OR ex.MgrID = '000000'
                                                              ) THEN ej.MgrID
                                                              ELSE ex.MgrID
                                                            END )
                                               AND e.EmplActive = 1
                       WHERE    ej.EmplID = @EmplID
                                AND ej.IsActive = 1
                                AND ej.EmplJobID != @EmplJobID
                                AND ( CASE WHEN ( ex.MgrID IS NULL
                                                  OR ex.MgrID = '000000'
                                                ) THEN ej.MgrID
                                           ELSE ex.MgrID
                                      END ) = @MgrID
                       UNION
	--#12.select subevals for the loggedin managers
                       SELECT   ase.EmplJobID ,
                                s.EmplID AS EmplID ,
                                e.NameLast + ', ' + e.NameFirst + ' '
                                + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID
                                + ')' AS EmplName ,
                                s.MgrID ,
                                ase.IsActive ,
                                ase.IsDeleted ,
                                0 AS IsManagers ,
                                ase.IsPrimary AS IsPrimary ,
                                s.Is5StepProcess ,
                                s.IsNon5StepProcess ,
                                0 AS IsPrimaryJobManager ,
                                @PrimaryCount AS PrimaryCount
                       FROM     dbo.SubEval s
                                LEFT OUTER JOIN dbo.SubevalAssignedEmplEmplJob ase ON ase.SubEvalID = s.EvalID
                                                              AND ase.EmplJobID = @EmplJobID
                                                              AND ase.IsDeleted = 0
                                                              AND ase.IsActive = 1
                                JOIN dbo.Empl e ON e.EmplID = s.EmplID
                                               AND e.EmplActive = 1
                       WHERE    s.MgrID = @MgrID
                                AND s.EvalActive = 1
                                AND s.EmplID NOT IN ( SELECT  managerID
                                                      FROM    @ListOfMangerID )
                       UNION

 --#13. select emplemplJob record for all the other managers and the subevals.
                       SELECT   ase.EmplJobID ,
                                s.EmplID AS EmplID ,
                                e.NameLast + ', ' + e.NameFirst + ' '
                                + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID
                                + ')' AS EmplName ,
                                s.MgrID ,
                                ase.IsActive ,
                                ase.IsDeleted ,
                                0 AS IsManagers ,
                                ase.IsPrimary AS IsPrimary ,
                                s.Is5StepProcess ,
                                s.IsNon5StepProcess ,
                                0 AS IsPrimaryJobManager ,
                                @PrimaryCount AS PrimaryCount
                       FROM     dbo.SubEval s
                                JOIN dbo.SubevalAssignedEmplEmplJob ase ON ase.SubEvalID = s.EvalID
                                                              AND ase.IsDeleted = 0
                                                              AND ase.IsActive = 1
                                JOIN ( SELECT   ( (CASE WHEN ( ex.MgrID IS NULL
                                                              OR ex.MgrID = '000000'
                                                             ) THEN ej.MgrID
                                                        ELSE ex.MgrID
                                                   END) ) AS ManagerID ,
                                                ej.EmplJobID
                                       FROM     dbo.EmplEmplJob ej
                                                LEFT OUTER JOIN dbo.EmplExceptions ex ON ex.EmplJobID = ej.EmplJobID
                                       WHERE    ej.EmplID = @EmplID
                                                AND ej.IsActive = 1
                                     ) AS filEmplJob ON filEmplJob.EmplJobID = ase.EmplJobID
                                JOIN dbo.Empl e ON e.EmplID = s.EmplID
                                               AND e.EmplActive = 1
                       WHERE    s.EvalActive = 1
                                AND filEmplJob.ManagerID != @MgrID
                                AND s.IsEvalManager = 0
                                AND s.MgrID IN ( SELECT managerID
                                                 FROM   @ListOfMangerID )
                     )
            SELECT DISTINCT
                    allEval.EmplJobID ,
                    allEval.EmplID ,
                    allEval.EmplName ,
                    allEval.MgrID ,
                    allEval.IsActive ,
                    allEval.IsDeleted ,
                    allEval.IsManagers ,
                    allEval.IsPrimary ,
                    allEval.Is5StepProcess ,
                    allEval.IsNon5StepProcess ,
                    allEval.IsPrimaryJobManager ,
                    allEval.PrimaryCount
            FROM    allEval
            ORDER BY allEval.IsManagers DESC ,
                    allEval.IsPrimaryJobManager DESC ,
                    allEval.IsPrimary DESC ,
                    allEval.IsActive DESC ,
                    allEval.MgrID ,
                    allEval.EmplName;		

	
    END;




GO
