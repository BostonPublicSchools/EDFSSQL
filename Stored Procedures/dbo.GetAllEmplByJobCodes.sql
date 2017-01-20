SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 11/20/2012
-- Description:	get all the empl details by the jobcode
-- =============================================
CREATE PROCEDURE [dbo].[GetAllEmplByJobCodes] @ncJobCode AS NCHAR(6)
  --@pageIndex as int = 1,
  --@pageSize as int = 300
AS
    BEGIN 
        SET NOCOUNT ON;

        WITH    AllEmplJobTable
                  AS ( SELECT -- ROW_NUMBER() OVER(ORDER BY ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'')) AS RowNumber
                                ej.EmplID ,
                                ISNULL(e1.NameFirst, '') + ' '
                                + ISNULL(e1.NameMiddle, '') + ' '
                                + ISNULL(e1.NameLast, '') AS EmplName ,
                                ej.EmplJobID ,
                                j.JobName ,
                                ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                       THEN emplEx.MgrID
                                       ELSE d.MgrID
                                  END ) AS MgrID ,
                                ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                       THEN ( SELECT    ISNULL(e1.NameFirst,
                                                              '') + ' '
                                                        + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                                                        + ISNULL(e1.NameLast,
                                                              '')
                                              FROM      dbo.Empl e1
                                              WHERE     e1.EmplID = emplEx.MgrID
                                            )
                                       ELSE ( SELECT    ISNULL(e1.NameFirst,
                                                              '') + ' '
                                                        + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                                                        + ISNULL(e1.NameLast,
                                                              '')
                                              FROM      dbo.Empl e1
                                              WHERE     e1.EmplID = ej.MgrID
                                            )
                                  END ) AS ManagerName ,
                                CASE WHEN s.EmplID IS NULL
                                     THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                               THEN emplEx.MgrID
                                               ELSE ej.MgrID
                                          END
                                     ELSE s.EmplID
                                END SubEvalID ,
                                ( CASE WHEN s.EmplID IS NULL
                                       THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                                 THEN ( SELECT
                                                              ISNULL(e1.NameFirst,
                                                              '') + ' '
                                                              + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                                                              + ISNULL(e1.NameLast,
                                                              '')
                                                        FROM  dbo.Empl e1
                                                        WHERE e1.EmplID = emplEx.MgrID
                                                      )
                                                 ELSE ( SELECT
                                                              ISNULL(e1.NameFirst,
                                                              '') + ' '
                                                              + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                                                              + ISNULL(e1.NameLast,
                                                              '')
                                                        FROM  dbo.Empl e1
                                                        WHERE e1.EmplID = ej.MgrID
                                                      )
                                            END
                                       ELSE ( SELECT    ISNULL(e1.NameFirst,
                                                              '') + ' '
                                                        + ISNULL(e1.NameMiddle,
                                                              '') + ' '
                                                        + ISNULL(e1.NameLast,
                                                              '')
                                              FROM      dbo.Empl e1
                                              WHERE     e1.EmplID = s.EmplID
                                            )
                                  END ) AS SubEvalName ,
                                ej.DeptID ,
                                j.UnionCode ,
                                d.DeptName ,
                                ej.FTE ,
                                r.RubricID ,
                                r.RubricName ,
                                r.Is5StepProcess
                       FROM     dbo.EmplEmplJob ej
                                JOIN dbo.EmplJob j ON ej.JobCode = j.JobCode
                                JOIN dbo.RubricHdr r ON ej.RubricID = r.RubricID
                                LEFT JOIN dbo.SubevalAssignedEmplEmplJob AS ase ( NOLOCK ) ON ej.EmplJobID = ase.EmplJobID
                                                              AND ase.IsActive = 1
                                                              AND ase.IsDeleted = 0
                                                              AND ase.IsPrimary = 1
                                LEFT JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                                              AND s.EvalActive = 1
                                LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
                                LEFT JOIN dbo.Department d ON ej.DeptID = d.DeptID
                                LEFT JOIN dbo.Empl e1 ON e1.EmplID = ej.EmplID
                                LEFT JOIN dbo.Empl e2 ON e2.EmplID = ej.MgrID
                       WHERE    ej.JobCode = @ncJobCode
                                AND ej.IsActive = 1
                                AND e1.EmplActive = 1
                     )
            SELECT  AllEmplJobTable.EmplID ,
                    AllEmplJobTable.EmplName ,
                    AllEmplJobTable.EmplJobID ,
                    AllEmplJobTable.JobName ,
                    AllEmplJobTable.MgrID ,
                    AllEmplJobTable.ManagerName ,
                    AllEmplJobTable.SubEvalID ,
                    AllEmplJobTable.SubEvalName ,
                    AllEmplJobTable.DeptID ,
                    AllEmplJobTable.UnionCode ,
                    AllEmplJobTable.DeptName ,
                    AllEmplJobTable.FTE ,
                    AllEmplJobTable.RubricID ,
                    AllEmplJobTable.RubricName ,
                    AllEmplJobTable.Is5StepProcess
            FROM    AllEmplJobTable
            ORDER BY AllEmplJobTable.EmplName;

    END;

GO
