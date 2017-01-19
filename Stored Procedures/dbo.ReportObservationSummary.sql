SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		P Bryce Avery
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[ReportObservationSummary] 
	-- Add the parameters for the stored procedure here
    @ncUserId AS NCHAR(6) = NULL ,
    @UserRoleID AS INT
AS
    BEGIN
        SET NOCOUNT ON;

        SELECT  DeptID [Dept. ID],
                DeptName [Dept],
                SubEvalName [Evaluator] ,
                EmplName [Empl. Name & ID] ,
				EmplName [EducatorName],
                PlanType [Plan],
                PlanEndDt [EndDate],
                PlanDuration [Duration] ,
                FirstObsvDt [First Obs] ,
                UnAnnouncedObsvCnt [Unannounced],
                UnAnnouncedMax [Unannounced reqd],
                AnnouncedObsvCnt [Announced],
                AnnouncedMax [Announced reqd],
                GreaterThan30ObsvCnt [Obs < 30 mins],
                ObsvStdI [obs tagged #1],
                ObsvStdII [obs tagged #2],
                ObsvStdIII [obs tagged #3],
                ObsvStdIV [obs tagged #4],
                FormAsmtEvalDt [Formative],
                StdRateBelow [below proficient],
                FollowUpDt [follow-up obs Date]
        FROM    dbo.ObservationAnalyst
        WHERE   ( MgrID = @ncUserId
                  AND @UserRoleID = 1
                )
                OR ( SubEvalID IN (
                     SELECT s.EmplID
                     FROM   SubevalAssignedEmplEmplJob AS ase ( NOLOCK )
                            JOIN SubEval s ( NOLOCK ) ON ase.SubEvalID = s.EvalID
														AND s.EmplID = @ncUserId
                                                         AND s.EvalActive = 1
                     WHERE  ase.EmplJobID = EmplJobID
                            AND ase.IsActive = 1
                            AND ase.IsDeleted = 0 )
                     AND @UserRoleID = 2
                   )
                OR ( EmplID = @ncUserId
                     AND @UserRoleID = 3
                   );

    END;
GO
