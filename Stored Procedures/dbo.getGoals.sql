SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/24/2012
-- Description:	List of goals associated with a plan
-- =============================================
CREATE PROCEDURE [dbo].[getGoals]
    @PlanID AS INT = NULL ,
    @EvalID AS INT = NULL
AS
    BEGIN
        SET NOCOUNT ON;

        IF @PlanID IS NOT NULL
            BEGIN
                EXEC dbo.getGoalsByPlanID @PlanID;
			
            END;
        ELSE
            IF @EvalID IS NOT NULL
                BEGIN
                    EXEC dbo.getGoalsByEvalID @EvalID;
			
                END;
    END;
GO
