SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[getEmplCountByEvaluatorIDNew]
    @EvaluatorID AS NCHAR(6) ,
    @UserRoleID AS INT
AS
    BEGIN
        SET NOCOUNT ON;
	--declare @EvaluatorID as nchar(6)
	--declare @UserRoleID as int
	--set @EvaluatorID = '036008'
	--set @UserRoleID = 1
		
        SELECT DISTINCT
                COUNT(e.EmplID) AS EmplCount
        FROM    dbo.Empl AS e ( NOLOCK )
                JOIN dbo.EmplEmplJob AS ej ( NOLOCK ) ON ej.IsActive = 1
                                                     AND e.EmplID = ej.EmplID
                LEFT OUTER JOIN dbo.EmplExceptions AS emplEx ( NOLOCK ) ON emplEx.EmplJobID = ej.EmplJobID
                JOIN dbo.RubricHdr AS rh ( NOLOCK ) ON ej.RubricID = rh.RubricID
        WHERE   e.EmplActive = 1
                AND ( ( ( CASE WHEN ( emplEx.MgrID IS NOT NULL )
                               THEN emplEx.MgrID
                               ELSE ej.MgrID
                          END = @EvaluatorID )
                        AND @UserRoleID = 1
                      )
                      OR ( @EvaluatorID IN (
                           SELECT   s.EmplID
                           FROM     dbo.SubevalAssignedEmplEmplJob AS ase ( NOLOCK )
                                    JOIN dbo.SubEval s ( NOLOCK ) ON s.EvalActive = 1
                                                              AND ase.SubEvalID = s.EvalID
                           WHERE    ase.EmplJobID = ej.EmplJobID
                                    AND ase.IsActive = 1
                                    AND ase.IsDeleted = 0 )
                           AND @UserRoleID = 2
                         )
                      OR ( ej.EmplID = @EvaluatorID
                           AND @UserRoleID = 3
                         )
                    );			

    END;

GO
