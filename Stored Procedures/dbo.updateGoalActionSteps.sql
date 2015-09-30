SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 07/25/2012
-- Description:	update action steps for a goal 
--				using goalid and actionstepid
-- =============================================
CREATE PROCEDURE [dbo].[updateGoalActionSteps]
	   @ActionStepText as nvarchar(max),
	   @ActionStepID as int,
	   @GoalID as int,
	   @Supports as nvarchar(max),
	   @Frequency as nvarchar(max),
	   @LastUpdatedByID as nchar(6)
AS

BEGIN
	SET NOCOUNT ON;

UPDATE GoalActionStep SET
			ActionStepText = @ActionStepText, 
			Supports = @Supports, 
			Frequency = @Frequency,
			LastUpdatedByID = @LastUpdatedByID, 
			LastUpdatedDt = GETDATE()
WHERE GoalID = @GoalID AND ActionStepID = @ActionStepID
	   

END
GO
