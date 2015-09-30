SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 07/25/2012
-- Description:	insert action steps for a goal
-- =============================================
CREATE PROCEDURE [dbo].[insGoalActionSteps]
	   @ActionStepText as nvarchar(max),
	   @GoalID as int,
	   @Supports as nvarchar(max),
	   @Frequency as nvarchar(max),
	   @CreatedByID as nchar(6),
	   @LastUpdatedByID as nchar(6),
	   @ActionStepStatus as nvarchar(50),
	   @ActionStepID as int OUTPUT
AS

BEGIN
	SET NOCOUNT ON;

DECLARE @ActionStepStatusID as int
SELECT @ActionStepStatusID = CODEID FROM CodeLookUp where CodeType='AcnStatus' and CodeText = @ActionStepStatus

INSERT INTO GoalActionStep(GoalID, ActionStepText, Supports, Frequency,CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, ActionStepStatusID)
	   VALUES(@GoalID, @ActionStepText, @Supports, @Frequency, @CreatedByID, GETDATE(), @LastUpdatedByID, GETDATE(), @ActionStepStatusID)

SELECT @ActionStepID = SCOPE_IDENTITY();	
END
GO
