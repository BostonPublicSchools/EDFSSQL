SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 07/25/2012
-- Description:	delete action steps for a goal 
--				using goalid and actionstepid
-- =============================================
CREATE PROCEDURE [dbo].[deleteGoalActionSteps]
	   @ActionStepID as int = 0,
	   @GoalID as int,
	   @IsDeleted as bit = 1,
	   @UserID as nchar(6)
	   
AS

BEGIN
	SET NOCOUNT ON;

IF @ActionStepID IS NOT NULL AND @ActionStepID > 0
BEGIN
UPDATE GoalActionStep
SET IsDeleted = @IsDeleted,
	LastUpdatedByID = @UserID,
	LastUpdatedDt = GETDATE()
WHERE GoalID = @GoalID AND ActionStepID = @ActionStepID	   
END

ELSE
BEGIN
UPDATE GoalActionStep
SET IsDeleted = @IsDeleted,
	LastUpdatedByID = @UserID,
	LastUpdatedDt = GETDATE()

WHERE GoalID = @GoalID 
END

END
GO
