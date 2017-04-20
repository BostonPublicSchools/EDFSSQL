SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 10/09/2012
-- Description:	Rubric by Job Code
-- =============================================
CREATE PROCEDURE [dbo].[getRubricbyRubricID]
    @RubricID AS NCHAR(6) = NULL
AS
    BEGIN
        SET NOCOUNT ON;		
        SELECT  ej.JobCode ,
                ej.RubricID ,
                rbh.Is5StepProcess ,
                rbh.RubricName ,
                rbh.IsActive
        FROM    dbo.RubricHdr rbh ( NOLOCK )
                JOIN dbo.EmplEmplJob ej ( NOLOCK ) ON rbh.RubricID = ej.RubricID
        WHERE   rbh.RubricID = @RubricID;
    END;
GO
