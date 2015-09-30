SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 07/25/2012
-- Description:	Get action steps for a goal
-- =============================================
CREATE PROCEDURE [dbo].[getActionSteps]
  @ncGoalID as INT = NULL
AS
BEGIN 
SET NOCOUNT ON;

SELECT gcs.ActionStepID, gcs.GoalID, gcs.ActionStepText, gcs.Supports, gcs.Frequency, gcs.IsDeleted, 
	   gcs.CreatedByID, gcs.CreatedByDt, gcs.LastUpdatedByID, gcs.LastUpdatedDt,
	   e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName, gcs.ActionStepStatusID,
	   ISNULL(cdl.CodeText, 'Not Yet Submitted') AS ActionStepStatus
FROM GoalActionStep gcs
JOIN Empl e on e.EmplID = gcs.CreatedById 
LEFT JOIN CodeLookUp cdl on cdl.CodeID = gcs.ActionStepStatusID
WHERE GoalID = @ncGoalID
ORDER BY CreatedByDt
END
GO
