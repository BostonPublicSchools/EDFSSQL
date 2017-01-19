SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 01/17/2013
-- Description: 
-- =============================================

CREATE FUNCTION [dbo].[funPlanCurrentStatus]
    (
      @PlanID INTEGER ,
      @EvalID INTEGER
    )
RETURNS NVARCHAR(100)
AS
    BEGIN
        DECLARE @Final NVARCHAR(100);
        SET @Final = 'Plan';
        IF ( @EvalID IS NOT NULL )
            BEGIN
                SET @Final = ( SELECT   cd.CodeText
                               FROM     dbo.EmplPlan ep
                                        JOIN dbo.Evaluation ev ON ev.EvalID = @EvalID
                                        LEFT JOIN dbo.CodeLookUp cd ON cd.CodeID = ev.EvalTypeID
                               WHERE    ep.PlanActive = 1
                                        AND ep.PlanID = @PlanID
                             );
            END;
        ELSE
            IF ( EXISTS ( SELECT    GoalID 
                          FROM      dbo.PlanGoal
                          WHERE     PlanID = @PlanID ) )
                BEGIN 
                    DECLARE @GoalStatus NVARCHAR(100);
                    SET @GoalStatus = ( SELECT  CodeText
                                        FROM    dbo.CodeLookUp
                                        WHERE   CodeID = ( SELECT
                                                              GoalStatusID
                                                           FROM
                                                              dbo.EmplPlan
                                                           WHERE
                                                              PlanID = @PlanID
                                                         )
                                      );
                    IF ( EXISTS ( SELECT    ActionStepID
                                  FROM      dbo.GoalActionStep
                                  WHERE     GoalID IN ( SELECT
                                                              GoalID
                                                        FROM  dbo.PlanGoal
                                                        WHERE PlanID = @PlanID )
                                            AND @GoalStatus = 'Approved' ) )
                        BEGIN
                            DECLARE @AcnStepStatus NVARCHAR(100);
                            SET @AcnStepStatus = ( SELECT   CodeText
                                                   FROM     dbo.CodeLookUp
                                                   WHERE    CodeID = ( SELECT
                                                              ActnStepStatusID
                                                              FROM
                                                              dbo.EmplPlan
                                                              WHERE
                                                              PlanID = @PlanID
                                                              )
                                                 );
                            SET @Final = ( CASE WHEN @AcnStepStatus IS NULL
                                                THEN 'Action Steps'
                                                ELSE 'Action Steps '
                                                     + @AcnStepStatus
                                           END );
                        END;
                    ELSE
                        BEGIN
                            SET @Final = ( CASE WHEN @GoalStatus IS NULL
                                                THEN 'Goals'
                                                ELSE 'Goals ' + @AcnStepStatus
                                           END );
                        END;		
                END;
            ELSE
                IF ( EXISTS ( SELECT    SelfAsmtID 
                              FROM      dbo.PlanSelfAsmt
                              WHERE     PlanID = @PlanID ) )
                    BEGIN
                        SET @Final = 'Self-Assessment';
                    END;
                ELSE
                    IF ( EXISTS ( SELECT    PlanEvidenceID
                                  FROM      dbo.EmplPlanEvidence
                                  WHERE     PlanID = @PlanID ) )
                        BEGIN
                            SET @Final = 'Collect Evidence';
                        END;
                    ELSE
                        BEGIN 
                            SET @Final = '#N/A';
                        END;
	
        RETURN CASE WHEN @Final IS NULL THEN 'Plan' ELSE @Final END;
    END;
GO
