SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/17/2012
-- Description:	Determine valid user and user's rights
-- =============================================
CREATE PROCEDURE [dbo].[getUser]
    @ncUserId AS NCHAR(6) = NULL ,
    @EmplJobID AS INT = 0
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @ActiveEmployeeCount AS INT = 0 ,
            @IsManger AS INT = 0 ,
            @IsEmplActive AS BIT ,
            @HasTempActiveAccess AS BIT = 0; -- @@HasTempActiveAccess, True till 30 days
	
        SELECT  @IsEmplActive = EmplActive ,
                @HasTempActiveAccess = ( CASE WHEN EmplActive = 0
                                                   AND ( DATEDIFF(dd,
                                                              GETDATE(),
                                                              EmplActiveDt) > -1
                                                         AND DATEDIFF(dd,
                                                              GETDATE(),
                                                              EmplActiveDt) < 31
                                                       ) THEN 1
                                              ELSE 0
                                         END )
        FROM    dbo.Empl
        WHERE   EmplID = @ncUserId;
		
        IF NOT GETDATE() BETWEEN '05/31/2017 18:00:00.000'
                         AND     '06/01/2017 18:00:00.000'
            BEGIN
                IF @IsEmplActive = 1
                    BEGIN
                        SELECT  @ActiveEmployeeCount = COUNT(DISTINCT ej.EmplID)
                        FROM    dbo.EmplEmplJob AS ej
                                LEFT OUTER JOIN dbo.EmplExceptions ex ON ex.EmplJobID = ej.EmplJobID
                                JOIN dbo.SubevalAssignedEmplEmplJob AS sej ON ej.EmplJobID = sej.EmplJobID
                                                              AND sej.IsActive = 1
                                                              AND sej.IsDeleted = 0
                                JOIN dbo.SubEval AS s ON sej.SubEvalID = s.EvalID
                                                         AND s.EvalActive = 1
                                                         AND s.EmplID = @ncUserId
                                                         AND s.MgrID = ( CASE
                                                              WHEN ex.MgrID IS NOT NULL
                                                              THEN ex.MgrID
                                                              ELSE ej.MgrID
                                                              END )
                                                         AND s.MgrID IN (
                                                         SELECT
                                                              EmplID
                                                         FROM dbo.Empl
                                                         WHERE
                                                              EmplActive = 1 )
                        WHERE   ej.IsActive = 1;

                        SELECT  @IsManger = COUNT(DISTINCT MgrID)
                        FROM    dbo.Department
                        WHERE   MgrID = @ncUserId;
				
                        IF @EmplJobID = 0
                            BEGIN
                                SELECT  e.EmplID ,
                                        ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                               THEN emplEx.MgrID
                                               ELSE ej.MgrID
                                          END ) AS MgrID ,
                                        CASE WHEN s.EmplID IS NULL
                                             THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                                       THEN emplEx.MgrID
                                                       ELSE ej.MgrID
                                                  END
                                             ELSE s.EmplID
                                        END SubEvalID ,
                                        e.NameFirst ,
                                        e.NameMiddle ,
                                        e.NameLast ,
                                        e.NameLast + ', ' + e.NameFirst + ' '
                                        + ISNULL(e.NameMiddle, '') + ' ('
                                        + e.EmplID + ')' AS EmplName ,
                                        dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) AS SubEvalID ,
                                        ( SELECT    ISNULL(e1.NameFirst, '')
                                                    + ' '
                                                    + ISNULL(e1.NameMiddle, '')
                                                    + ' ' + ISNULL(e1.NameLast,
                                                              '')
                                          FROM      dbo.Empl e1
                                          WHERE     e1.EmplID = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)
                                        ) AS SubEvalName ,
                                        e.IsAdmin ,
                                        e.HasReadOnlyAccess ,
                                        ej.EmplJobID ,
                                        e.EmplActive ,
                                        j.JobCode ,
                                        j.JobName ,
                                        CASE WHEN ( SELECT TOP 1
                                                            MgrID
                                                    FROM    dbo.Department
                                                    WHERE   MgrID = e.EmplID
                                                  ) IS NOT NULL THEN 'Manager'
                                             WHEN ( SELECT TOP 1
                                                            MgrID
                                                    FROM    dbo.EmplExceptions
                                                    WHERE   MgrID = e.EmplID
                                                            AND EmplJobID IN (
                                                            SELECT
                                                              EmplJobID
                                                            FROM
                                                              dbo.EmplEmplJob
                                                            WHERE
                                                              IsActive = 1 )
                                                  ) IS NOT NULL THEN 'Manager'
                                             WHEN ( SELECT TOP 1
                                                            EmplID
                                                    FROM    dbo.SubEval
                                                    WHERE   EmplID = e.EmplID
                                                            AND EvalActive = 1
                                                  ) IS NOT NULL
                                                  AND @ActiveEmployeeCount > 0
                                             THEN 'Subevaluator'
                                             ELSE 'Educator'
                                        END AS RoleDesc ,
                                        CASE WHEN @ActiveEmployeeCount > 0
                                             THEN e.EmplID
                                             ELSE NULL
                                        END AS IsEvaluator ,
                                        ed.DeptID ,
                                        ed.DeptName ,
                                        ed.IsSchool ,
                                        rh.Is5StepProcess ,
                                        rh.RubricID ,
                                        ( CASE WHEN dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID) = ej.EmplJobID
                                               THEN 1
                                               ELSE 0
                                          END ) AS IsPrimaryJob
                                FROM    dbo.Empl AS e ( NOLOCK )
                                        JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON e.EmplID = ej.EmplID
                                                              AND ej.IsActive = 1
                                        JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON ej.RubricID = rh.RubricID
                                        LEFT JOIN dbo.SubevalAssignedEmplEmplJob
                                        AS ase ( NOLOCK ) ON ej.EmplJobID = ase.EmplJobID
                                                             AND ase.IsActive = 1
                                                             AND ase.IsDeleted = 0
                                                             AND ase.IsPrimary = 1
                                        LEFT JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                                              AND s.EvalActive = 1
                                        JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
												--	AND ej.IsActive = 1
                                        JOIN dbo.Department AS ed ( NOLOCK ) ON ej.DeptID = ed.DeptID
                                        LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ON emplEx.MgrID = e.EmplID
                                                              OR emplEx.EmplJobID = ej.EmplJobID
                                        LEFT OUTER JOIN dbo.EmplExceptions AS emplEx1 ON emplEx1.EmplJobID = ej.EmplJobID
                                WHERE   e.EmplID = @ncUserId
                                ORDER BY IsPrimaryJob DESC ,
                                        ej.IsActive DESC ,
                                        ej.FTE DESC ,
                                        ej.EmplRcdNo ASC ,
                                        ej.EmplJobID DESC;
                            END;
                        ELSE
                            BEGIN
                                SELECT  e.EmplID ,
                                        ( CASE WHEN ( emplEx1.MgrID IS NOT NULL )
                                               THEN emplEx1.MgrID
                                               ELSE ej.MgrID
                                          END ) AS MgrID ,
                                        dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) AS SubEvalID ,
                                        e.NameFirst ,
                                        e.NameMiddle ,
                                        e.NameLast ,
                                        e.NameLast + ', ' + e.NameFirst + ' '
                                        + ISNULL(e.NameMiddle, '') + ' ('
                                        + e.EmplID + ')' AS EmplName ,
                                        ( SELECT    ISNULL(e1.NameFirst, '')
                                                    + ' '
                                                    + ISNULL(e1.NameMiddle, '')
                                                    + ' ' + ISNULL(e1.NameLast,
                                                              '')
                                          FROM      dbo.Empl e1
                                          WHERE     e1.EmplID = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)
                                        ) AS SubEvalName ,
                                        e.IsAdmin ,
                                        ej.EmplJobID ,
                                        e.EmplActive ,
                                        j.JobCode ,
                                        j.JobName ,
                                        CASE WHEN ej.MgrID = '000000'
                                                  OR emplEx.MgrID IS NOT NULL
                                             THEN 'Manager'
                                             WHEN ( SELECT TOP 1
                                                            EmplID
                                                    FROM    dbo.SubEval
                                                    WHERE   EmplID = e.EmplID
                                                            AND EvalActive = 1
                                                  ) IS NOT NULL
                                                  AND @ActiveEmployeeCount > 0
                                             THEN 'Subevaluator'
                                             ELSE 'Educator'
                                        END AS RoleDesc ,
                                        CASE WHEN @ActiveEmployeeCount > 0
                                             THEN e.EmplID
                                             ELSE NULL
                                        END AS IsEvaluator ,
                                        ed.DeptID ,
                                        ed.DeptName ,
                                        ed.IsSchool ,
                                        rh.Is5StepProcess ,
                                        rh.RubricID ,
                                        ( CASE WHEN dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID) = ej.EmplJobID
                                               THEN 1
                                               ELSE 0
                                          END ) AS IsPrimaryJob
                                FROM    dbo.Empl AS e ( NOLOCK )
                                        JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON e.EmplID = ej.EmplID
                                                              AND ej.IsActive = 1
                                        JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON ej.RubricID = rh.RubricID
                                        LEFT JOIN dbo.SubevalAssignedEmplEmplJob
                                        AS ase ( NOLOCK ) ON ej.EmplJobID = ase.EmplJobID
                                                             AND ase.IsActive = 1
                                                             AND ase.IsDeleted = 0
                                                             AND ase.IsPrimary = 1
                                        LEFT JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                                              AND s.EvalActive = 1
                                        JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
														--AND ej.IsActive = 1
                                        JOIN dbo.Department AS ed ( NOLOCK ) ON ej.DeptID = ed.DeptID
                                        LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ON emplEx.MgrID = e.EmplID
                                                              OR emplEx.EmplJobID = ej.EmplJobID
                                        LEFT OUTER JOIN dbo.EmplExceptions AS emplEx1 ON emplEx1.EmplJobID = ej.EmplJobID
                                WHERE   e.EmplID = @ncUserId
                                        AND ej.EmplJobID = @EmplJobID
                                ORDER BY IsPrimaryJob DESC ,
                                        ej.IsActive DESC ,
                                        ej.FTE DESC ,
                                        ej.EmplRcdNo ASC ,
                                        ej.EmplJobID DESC;
                            END;
		
                    END;	
                ELSE
                    IF @IsEmplActive = 0
                        AND @HasTempActiveAccess = 1
                        BEGIN		
                            SELECT  e.EmplID ,
                                    ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                           THEN emplEx.MgrID
                                           ELSE ej.MgrID
                                      END ) AS MgrID ,
                                    CASE WHEN s.EmplID IS NULL
                                         THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                                   THEN emplEx.MgrID
                                                   ELSE ej.MgrID
                                              END
                                         ELSE s.EmplID
                                    END SubEvalID ,
                                    e.NameFirst ,
                                    e.NameMiddle ,
                                    e.NameLast ,
                                    e.NameLast + ', ' + e.NameFirst + ' '
                                    + ISNULL(e.NameMiddle, '') + ' ('
                                    + e.EmplID + ')' AS EmplName ,
                                    ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                           THEN emplEx.MgrID
                                           ELSE ej.MgrID
                                      END ) AS MgrID ,
                                    CASE WHEN s.EmplID IS NULL
                                         THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                                   THEN emplEx.MgrID
                                                   ELSE ej.MgrID
                                              END
                                         ELSE s.EmplID
                                    END SubEvalID ,
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
                                    ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                                                + ISNULL(e1.NameMiddle, '')
                                                + ' ' + ISNULL(e1.NameLast, '')
                                      FROM      dbo.Empl e1
                                      WHERE     e1.EmplID = s.EmplID
                                    ) AS SubEvalName ,
                                    CONVERT(BIT, 0) IsAdmin ,
                                    e.HasReadOnlyAccess ,
                                    ej.EmplJobID ,
                                    CONVERT(BIT, 1) AS EmplActive ,
                                    j.JobCode ,
                                    j.JobName ,
                                    'Educator' AS RoleDesc ,
                                    NULL AS IsEvaluator ,
                                    ed.DeptID ,
                                    ed.DeptName ,
                                    ed.IsSchool ,
                                    rh.Is5StepProcess ,
                                    rh.RubricID ,
                                    ( CASE WHEN dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID) = ej.EmplJobID
                                           THEN 1
                                           ELSE 0
                                      END ) AS IsPrimaryJob
                            FROM    dbo.Empl AS e ( NOLOCK )
                                    JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON e.EmplID = ej.EmplID
										--	and ej.IsActive = 1
                                    JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON ej.RubricID = rh.RubricID
                                    LEFT JOIN dbo.SubevalAssignedEmplEmplJob
                                    AS ase ( NOLOCK ) ON ej.EmplJobID = ase.EmplJobID
                                                         AND ase.IsActive = 1
                                                         AND ase.IsDeleted = 0
                                                         AND ase.IsPrimary = 1
                                    LEFT JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                                              AND s.EvalActive = 1
                                    JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
												--	AND ej.IsActive = 1
                                    JOIN dbo.Department AS ed ( NOLOCK ) ON ej.DeptID = ed.DeptID
                                    LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ON emplEx.MgrID = e.EmplID
                                                              OR emplEx.EmplJobID = ej.EmplJobID
                                    LEFT OUTER JOIN dbo.EmplExceptions AS emplEx1 ON emplEx1.EmplJobID = ej.EmplJobID
                            WHERE   e.EmplID = @ncUserId
                            ORDER BY IsPrimaryJob DESC ,
                                    ej.IsActive DESC ,
                                    ej.FTE DESC ,
                                    ej.EmplRcdNo ASC ,
                                    ej.EmplJobID DESC;
                        END;
            END;
        ELSE
            BEGIN
                IF @IsEmplActive = 1
                    BEGIN
                        SELECT  @ActiveEmployeeCount = COUNT(DISTINCT ej.EmplID)
                        FROM    dbo.EmplEmplJob AS ej
                                LEFT OUTER JOIN dbo.EmplExceptions ex ON ex.EmplJobID = ej.EmplJobID
                                JOIN dbo.SubevalAssignedEmplEmplJob AS sej ON ej.EmplJobID = sej.EmplJobID
                                                              AND sej.IsActive = 1
                                                              AND sej.IsDeleted = 0
                                JOIN dbo.SubEval AS s ON sej.SubEvalID = s.EvalID
                                                         AND s.EvalActive = 1
                                                         AND s.EmplID = @ncUserId
                                                         AND s.MgrID = ( CASE
                                                              WHEN ex.MgrID IS NOT NULL
                                                              THEN ex.MgrID
                                                              ELSE ej.MgrID
                                                              END )
                                                         AND s.MgrID IN (
                                                         SELECT
                                                              EmplID
                                                         FROM dbo.Empl
                                                         WHERE
                                                              EmplActive = 1 )
                        WHERE   ej.IsActive = 1;

                        SELECT  @IsManger = COUNT(DISTINCT MgrID)
                        FROM    dbo.Department
                        WHERE   MgrID = @ncUserId;
				
                        IF @EmplJobID = 0
                            BEGIN
                                SELECT  e.EmplID ,
                                        ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                               THEN emplEx.MgrID
                                               ELSE ej.MgrID
                                          END ) AS MgrID ,
                                        CASE WHEN s.EmplID IS NULL
                                             THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                                       THEN emplEx.MgrID
                                                       ELSE ej.MgrID
                                                  END
                                             ELSE s.EmplID
                                        END SubEvalID ,
                                        e.NameFirst ,
                                        e.NameMiddle ,
                                        e.NameLast ,
                                        e.NameLast + ', ' + e.NameFirst + ' '
                                        + ISNULL(e.NameMiddle, '') + ' ('
                                        + e.EmplID + ')' AS EmplName ,
                                        dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) AS SubEvalID ,
                                        ( SELECT    ISNULL(e1.NameFirst, '')
                                                    + ' '
                                                    + ISNULL(e1.NameMiddle, '')
                                                    + ' ' + ISNULL(e1.NameLast,
                                                              '')
                                          FROM      dbo.Empl e1
                                          WHERE     e1.EmplID = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)
                                        ) AS SubEvalName ,
                                        e.IsAdmin ,
                                        e.HasReadOnlyAccess ,
                                        ej.EmplJobID ,
                                        e.EmplActive ,
                                        j.JobCode ,
                                        j.JobName ,
                                        CASE WHEN ( SELECT TOP 1
                                                            MgrID
                                                    FROM    dbo.Department
                                                    WHERE   MgrID = e.EmplID
                                                  ) IS NOT NULL THEN 'Manager'
                                             WHEN ( SELECT TOP 1
                                                            MgrID
                                                    FROM    dbo.EmplExceptions
                                                    WHERE   MgrID = e.EmplID
                                                            AND EmplJobID IN (
                                                            SELECT
                                                              EmplJobID
                                                            FROM
                                                              dbo.EmplEmplJob
                                                            WHERE
                                                              IsActive = 1 )
                                                  ) IS NOT NULL THEN 'Manager'
                                             WHEN ( SELECT TOP 1
                                                            EmplID
                                                    FROM    dbo.SubEval
                                                    WHERE   EmplID = e.EmplID
                                                            AND EvalActive = 1
                                                  ) IS NOT NULL
                                             THEN 'Subevaluator'
                                             ELSE 'Educator'
                                        END AS RoleDesc ,
                                        e.EmplID AS IsEvaluator ,
                                        ed.DeptID ,
                                        ed.DeptName ,
                                        ed.IsSchool ,
                                        rh.Is5StepProcess ,
                                        rh.RubricID ,
                                        ( CASE WHEN dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID) = ej.EmplJobID
                                               THEN 1
                                               ELSE 0
                                          END ) AS IsPrimaryJob
                                FROM    dbo.Empl AS e ( NOLOCK )
                                        JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON e.EmplID = ej.EmplID
                                                              AND ej.IsActive = 1
                                        JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON ej.RubricID = rh.RubricID
                                        LEFT JOIN dbo.SubevalAssignedEmplEmplJob
                                        AS ase ( NOLOCK ) ON ej.EmplJobID = ase.EmplJobID
                                                             AND ase.IsActive = 1
                                                             AND ase.IsDeleted = 0
                                                             AND ase.IsPrimary = 1
                                        LEFT JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                                              AND s.EvalActive = 1
                                        JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
												--	AND ej.IsActive = 1
                                        JOIN dbo.Department AS ed ( NOLOCK ) ON ej.DeptID = ed.DeptID
                                        LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ON emplEx.MgrID = e.EmplID
                                                              OR emplEx.EmplJobID = ej.EmplJobID
                                        LEFT OUTER JOIN dbo.EmplExceptions AS emplEx1 ON emplEx1.EmplJobID = ej.EmplJobID
                                WHERE   e.EmplID = @ncUserId
                                        AND ( NOT CASE WHEN ( SELECT TOP 1
                                                              MgrID
                                                              FROM
                                                              dbo.Department
                                                              WHERE
                                                              MgrID = e.EmplID
                                                            ) IS NOT NULL
                                                       THEN 'Manager'
                                                       WHEN ( SELECT TOP 1
                                                              MgrID
                                                              FROM
                                                              dbo.EmplExceptions
                                                              WHERE
                                                              MgrID = e.EmplID
                                                              AND EmplJobID IN (
                                                              SELECT
                                                              EmplJobID
                                                              FROM
                                                              dbo.EmplEmplJob
                                                              WHERE
                                                              IsActive = 1 )
                                                            ) IS NOT NULL
                                                       THEN 'Manager'
                                                       WHEN ( SELECT TOP 1
                                                              EmplID
                                                              FROM
                                                              dbo.SubEval
                                                              WHERE
                                                              EmplID = e.EmplID
                                                              AND EvalActive = 1
                                                            ) IS NOT NULL
                                                       THEN 'Subevaluator'
                                                       ELSE 'Educator'
                                                  END = 'Educator'
                                              OR e.IsAdmin = 1
                                            )
                                ORDER BY IsPrimaryJob DESC ,
                                        ej.IsActive DESC ,
                                        ej.FTE DESC ,
                                        ej.EmplRcdNo ASC ,
                                        ej.EmplJobID DESC;
                            END;
                        ELSE
                            BEGIN
                                SELECT  e.EmplID ,
                                        ( CASE WHEN ( emplEx1.MgrID IS NOT NULL )
                                               THEN emplEx1.MgrID
                                               ELSE ej.MgrID
                                          END ) AS MgrID ,
                                        dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) AS SubEvalID ,
                                        e.NameFirst ,
                                        e.NameMiddle ,
                                        e.NameLast ,
                                        e.NameLast + ', ' + e.NameFirst + ' '
                                        + ISNULL(e.NameMiddle, '') + ' ('
                                        + e.EmplID + ')' AS EmplName ,
                                        ( SELECT    ISNULL(e1.NameFirst, '')
                                                    + ' '
                                                    + ISNULL(e1.NameMiddle, '')
                                                    + ' ' + ISNULL(e1.NameLast,
                                                              '')
                                          FROM      dbo.Empl e1
                                          WHERE     e1.EmplID = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)
                                        ) AS SubEvalName ,
                                        e.IsAdmin ,
                                        ej.EmplJobID ,
                                        e.EmplActive ,
                                        j.JobCode ,
                                        j.JobName ,
                                        CASE WHEN ej.MgrID = '000000'
                                                  OR emplEx.MgrID IS NOT NULL
                                             THEN 'Manager'
                                             WHEN ( SELECT TOP 1
                                                            EmplID
                                                    FROM    dbo.SubEval
                                                    WHERE   EmplID = e.EmplID
                                                            AND EvalActive = 1
                                                  ) IS NOT NULL
                                                  AND @ActiveEmployeeCount > 0
                                             THEN 'Subevaluator'
                                             ELSE 'Educator'
                                        END AS RoleDesc ,
                                        e.EmplID AS IsEvaluator ,
                                        ed.DeptID ,
                                        ed.DeptName ,
                                        ed.IsSchool ,
                                        rh.Is5StepProcess ,
                                        rh.RubricID ,
                                        ( CASE WHEN dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID) = ej.EmplJobID
                                               THEN 1
                                               ELSE 0
                                          END ) AS IsPrimaryJob
                                FROM    dbo.Empl AS e ( NOLOCK )
                                        JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON e.EmplID = ej.EmplID
                                                              AND ej.IsActive = 1
                                        JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON ej.RubricID = rh.RubricID
                                        LEFT JOIN dbo.SubevalAssignedEmplEmplJob
                                        AS ase ( NOLOCK ) ON ej.EmplJobID = ase.EmplJobID
                                                             AND ase.IsActive = 1
                                                             AND ase.IsDeleted = 0
                                                             AND ase.IsPrimary = 1
                                        LEFT JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                                              AND s.EvalActive = 1
                                        JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
														--AND ej.IsActive = 1
                                        JOIN dbo.Department AS ed ( NOLOCK ) ON ej.DeptID = ed.DeptID
                                        LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ON emplEx.MgrID = e.EmplID
                                                              OR emplEx.EmplJobID = ej.EmplJobID
                                        LEFT OUTER JOIN dbo.EmplExceptions AS emplEx1 ON emplEx1.EmplJobID = ej.EmplJobID
                                WHERE   e.EmplID = @ncUserId
                                        AND ej.EmplJobID = @EmplJobID
                                        AND ( NOT CASE WHEN ( SELECT TOP 1
                                                              MgrID
                                                              FROM
                                                              dbo.Department
                                                              WHERE
                                                              MgrID = e.EmplID
                                                            ) IS NOT NULL
                                                       THEN 'Manager'
                                                       WHEN ( SELECT TOP 1
                                                              MgrID
                                                              FROM
                                                              dbo.EmplExceptions
                                                              WHERE
                                                              MgrID = e.EmplID
                                                              AND EmplJobID IN (
                                                              SELECT
                                                              EmplJobID
                                                              FROM
                                                              dbo.EmplEmplJob
                                                              WHERE
                                                              IsActive = 1 )
                                                            ) IS NOT NULL
                                                       THEN 'Manager'
                                                       WHEN ( SELECT TOP 1
                                                              EmplID
                                                              FROM
                                                              dbo.SubEval
                                                              WHERE
                                                              EmplID = e.EmplID
                                                              AND EvalActive = 1
                                                            ) IS NOT NULL
                                                       THEN 'Subevaluator'
                                                       ELSE 'Educator'
                                                  END = 'Educator'
                                              OR e.IsAdmin = 1
                                            )
                                ORDER BY IsPrimaryJob DESC ,
                                        ej.IsActive DESC ,
                                        ej.FTE DESC ,
                                        ej.EmplRcdNo ASC ,
                                        ej.EmplJobID DESC;
                            END;
		
                    END;	
                ELSE
                    IF @IsEmplActive = 0
                        AND @HasTempActiveAccess = 1
                        BEGIN		
                            SELECT  e.EmplID ,
                                    ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                           THEN emplEx.MgrID
                                           ELSE ej.MgrID
                                      END ) AS MgrID ,
                                    CASE WHEN s.EmplID IS NULL
                                         THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                                   THEN emplEx.MgrID
                                                   ELSE ej.MgrID
                                              END
                                         ELSE s.EmplID
                                    END SubEvalID ,
                                    e.NameFirst ,
                                    e.NameMiddle ,
                                    e.NameLast ,
                                    e.NameLast + ', ' + e.NameFirst + ' '
                                    + ISNULL(e.NameMiddle, '') + ' ('
                                    + e.EmplID + ')' AS EmplName ,
                                    ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                           THEN emplEx.MgrID
                                           ELSE ej.MgrID
                                      END ) AS MgrID ,
                                    CASE WHEN s.EmplID IS NULL
                                         THEN CASE WHEN ( emplEx.MgrID IS NOT NULL )
                                                   THEN emplEx.MgrID
                                                   ELSE ej.MgrID
                                              END
                                         ELSE s.EmplID
                                    END SubEvalID ,
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
                                    ( SELECT    ISNULL(e1.NameFirst, '') + ' '
                                                + ISNULL(e1.NameMiddle, '')
                                                + ' ' + ISNULL(e1.NameLast, '')
                                      FROM      dbo.Empl e1
                                      WHERE     e1.EmplID = s.EmplID
                                    ) AS SubEvalName ,
                                    CONVERT(BIT, 0) IsAdmin ,
                                    e.HasReadOnlyAccess ,
                                    ej.EmplJobID ,
                                    CONVERT(BIT, 1) AS EmplActive ,
                                    j.JobCode ,
                                    j.JobName ,
                                    'Educator' AS RoleDesc ,
                                    NULL AS IsEvaluator ,
                                    ed.DeptID ,
                                    ed.DeptName ,
                                    ed.IsSchool ,
                                    rh.Is5StepProcess ,
                                    rh.RubricID ,
                                    ( CASE WHEN dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID) = ej.EmplJobID
                                           THEN 1
                                           ELSE 0
                                      END ) AS IsPrimaryJob
                            FROM    dbo.Empl AS e ( NOLOCK )
                                    JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON e.EmplID = ej.EmplID
										--	and ej.IsActive = 1
                                    JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON ej.RubricID = rh.RubricID
                                    LEFT JOIN dbo.SubevalAssignedEmplEmplJob
                                    AS ase ( NOLOCK ) ON ej.EmplJobID = ase.EmplJobID
                                                         AND ase.IsActive = 1
                                                         AND ase.IsDeleted = 0
                                                         AND ase.IsPrimary = 1
                                    LEFT JOIN dbo.SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
                                                              AND s.EvalActive = 1
                                    JOIN dbo.EmplJob AS j ( NOLOCK ) ON ej.JobCode = j.JobCode
												--	AND ej.IsActive = 1
                                    JOIN dbo.Department AS ed ( NOLOCK ) ON ej.DeptID = ed.DeptID
                                    LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ON emplEx.MgrID = e.EmplID
                                                              OR emplEx.EmplJobID = ej.EmplJobID
                                    LEFT OUTER JOIN dbo.EmplExceptions AS emplEx1 ON emplEx1.EmplJobID = ej.EmplJobID
                            WHERE   e.EmplID = @ncUserId
                                    AND ( NOT CASE WHEN ( SELECT TOP 1
                                                              MgrID
                                                          FROM
                                                              dbo.Department
                                                          WHERE
                                                              MgrID = e.EmplID
                                                        ) IS NOT NULL
                                                   THEN 'Manager'
                                                   WHEN ( SELECT TOP 1
                                                              MgrID
                                                          FROM
                                                              dbo.EmplExceptions
                                                          WHERE
                                                              MgrID = e.EmplID
                                                              AND EmplJobID IN (
                                                              SELECT
                                                              EmplJobID
                                                              FROM
                                                              dbo.EmplEmplJob
                                                              WHERE
                                                              IsActive = 1 )
                                                        ) IS NOT NULL
                                                   THEN 'Manager'
                                                   WHEN ( SELECT TOP 1
                                                              EmplID
                                                          FROM
                                                              dbo.SubEval
                                                          WHERE
                                                              EmplID = e.EmplID
                                                              AND EvalActive = 1
                                                        ) IS NOT NULL
                                                   THEN 'Subevaluator'
                                                   ELSE 'Educator'
                                              END = 'Educator'
                                          OR e.IsAdmin = 1
                                        )
                            ORDER BY IsPrimaryJob DESC ,
                                    ej.IsActive DESC ,
                                    ej.FTE DESC ,
                                    ej.EmplRcdNo ASC ,
                                    ej.EmplJobID DESC;
                        END;
            END;
    END;
GO
