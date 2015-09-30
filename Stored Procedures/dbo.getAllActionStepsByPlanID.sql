SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 07/25/2012
-- Description:	Get action steps for all the goals in plan
-- =============================================
CREATE PROCEDURE [dbo].[getAllActionStepsByPlanID]
  @ncPlanID as INT = NULL
AS
BEGIN 
SET NOCOUNT ON;

SELECT gcs.ActionStepID, gcs.GoalID, pg.GoalText, gcs.ActionStepText, gcs.Supports, gcs.Frequency, gcs.IsDeleted,	   
	   gcs.CreatedByID, gcs.CreatedByDt, gcs.LastUpdatedByID, gcs.LastUpdatedDt,
	   e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName, gcs.ActionStepStatusID,
	   ISNULL(cdl.CodeText, 'Not Yet Submitted') AS ActionStepStatus
	   ,pg.GoalYear As GoalYear
FROM GoalActionStep gcs
JOIN PlanGoal pg on pg.GoalID = gcs.GoalID 
LEFT JOIN Empl e on e.EmplID = gcs.CreatedById 
LEFT JOIN CodeLookUp cdl on cdl.CodeID = gcs.ActionStepStatusID
WHERE pg.PlanID = @ncPlanID 
--AND pg.GoalStatusID != (select CodeID from CodeLookUp where CodeText='Not Applicable' and CodeType = 'goalstatus')
--and gcs.IsDeleted = 0
 --gcs.GoalID in (Select GoalID from PlanGoal where PlanID = @ncPlanID and PlanGoal.IsDeleted = 0)
ORDER BY GoalID
END
GO
