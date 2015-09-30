SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 05/20/2014
-- Description:	Get action steps by actionstepID
-- =============================================
CREATE PROCEDURE [dbo].[getActionStepByID]
  @ncActionStepID as int
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
WHERE ActionStepID = @ncActionStepID
ORDER BY CreatedByDt
END
GO
