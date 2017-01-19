SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi		
-- Create date: 05/23/2013
-- Description:	Update the plan prescription status
-- if there are no prescription
-- =============================================
CREATE PROCEDURE [dbo].[UpdatePlanPrescritionStatus]
    @EvalID AS INT ,
    @PlanID AS INT ,
    @UserID AS VARCHAR(6)
AS
    BEGIN
        SET NOCOUNT ON;
	
        DECLARE @PrescriptStatus AS BIT;
	
        IF NOT EXISTS ( SELECT  EvalStdRatingID
                        FROM    dbo.EvaluationStandardRating
                        WHERE   RatingID IN (
                                SELECT  CodeID
                                FROM    dbo.CodeLookUp
                                WHERE   CodeType = 'StdRating'
                                        AND CodeText IN ( 'Needs Improvement',
                                                          'Unsatisfactory' ) )
                                AND EvalID = @EvalID )
            BEGIN
                SET @PrescriptStatus = 0;
            END;				     		
        ELSE
            BEGIN
                SET @PrescriptStatus = 1;
            END;
	
        UPDATE  dbo.EmplPlan
        SET     HasPrescript = @PrescriptStatus ,
                LastUpdatedByID = @UserID ,
                LastUpdatedDt = GETDATE()
        WHERE   PlanID = @PlanID; 
    END;
GO
