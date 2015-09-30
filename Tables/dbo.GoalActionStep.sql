CREATE TABLE [dbo].[GoalActionStep]
(
[ActionStepID] [int] NOT NULL IDENTITY(1, 1),
[GoalID] [int] NOT NULL,
[ActionStepText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Supports] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_GoalActionStep_IsDeleted] DEFAULT ('0'),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GoalActionStep_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_GoalActionStep_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GoalActionStep_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_GoalActionStep_LastUpdatedDt] DEFAULT (getdate()),
[ActionStepStatusID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[GoalActionStepInsertChangeLog] ON [dbo].[GoalActionStep]
AFTER INSERT
AS
BEGIN
	INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
	SELECT		   		  'GoalActionStep', i.ActionStepID, i.LastUpdatedByID, 'Action step text entered for ActionStepID ' + CAST(i.ActionStepID AS NVARCHAR),i.LastUpdatedDt, '', i.ActionStepText, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), ej.EmplID
					FROM
						inserted as i
					JOIN PlanGoal pg on pg.GoalID = i.GoalID
					JOIN EmplPlan ep on ep.PlanID = pg.PlanID
					JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID
							
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[GoalActionStepUpdChangeLog] ON [dbo].[GoalActionStep]
FOR UPDATE
AS
BEGIN
	IF (SELECT 
			COUNT(i.ActionStepID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ActionStepID = d.ActionStepID
		WHERE
			NOT d.ActionStepText = i.ActionStepText) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'GoalActionStep', i.ActionStepID, i.LastUpdatedByID, 'Action step text change for ActionStepID ' + CAST(i.ActionStepID AS NVARCHAR),i.LastUpdatedDt, d.ActionStepText, i.ActionStepText, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.ActionStepID = d.ActionStepID
						JOIN PlanGoal pg on pg.GoalID = i.GoalID
						JOIN EmplPlan ep on ep.PlanID = pg.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID
						
	END

	IF (SELECT 
			COUNT(i.ActionStepID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ActionStepID = d.ActionStepID
		WHERE
			NOT d.Frequency = i.Frequency) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'GoalActionStep', i.ActionStepID, i.LastUpdatedByID, 'Action step frequency or element change for ActionStepID ' + CAST(i.ActionStepID AS NVARCHAR),i.LastUpdatedDt, d.Frequency, i.Frequency, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.ActionStepID = d.ActionStepID
						JOIN PlanGoal pg on pg.GoalID = i.GoalID
						JOIN EmplPlan ep on ep.PlanID = pg.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END
		
	IF (SELECT 
			COUNT(i.ActionStepID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ActionStepID = d.ActionStepID
		WHERE
			NOT d.Supports = i.Supports) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'GoalActionStep', i.ActionStepID, i.LastUpdatedByID, 'Action step support or element change for ActionStepID ' + CAST(i.ActionStepID AS NVARCHAR),i.LastUpdatedDt, d.Supports, i.Supports, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.ActionStepID = d.ActionStepID
						JOIN PlanGoal pg on pg.GoalID = i.GoalID
						JOIN EmplPlan ep on ep.PlanID = pg.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END
	
	IF (SELECT 
			COUNT(i.ActionStepID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ActionStepID = d.ActionStepID
		WHERE
			NOT d.ActionStepStatusID = i.ActionStepStatusID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'GoalActionStep', i.ActionStepID, i.LastUpdatedByID, 'Action step status or element change for ActionStepID ' + CAST(i.ActionStepID AS NVARCHAR),i.LastUpdatedDt, d.ActionStepStatusID, i.ActionStepStatusID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.ActionStepID = d.ActionStepID
						JOIN PlanGoal pg on pg.GoalID = i.GoalID
						JOIN EmplPlan ep on ep.PlanID = pg.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END	
	
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[TR_ActnStepStatusID_Insert]
   ON  [dbo].[GoalActionStep]
   AFTER INSERT
AS 
BEGIN
   SET NOCOUNT ON;
   UPDATE GoalActionStep 
   SET ActionStepStatusID = (SELECT CODEID FROM CodeLookUp where CodeType='AcnStatus' and CodeSortOrder = 1)
   FROM INSERTED AS I
   WHERE GoalActionStep.ActionStepID = I.ActionStepID AND GoalActionStep.ActionStepStatusID = NULL
END
GO
ALTER TABLE [dbo].[GoalActionStep] ADD CONSTRAINT [PK_GoalActionStep] PRIMARY KEY CLUSTERED  ([ActionStepID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GoalActionStep] ADD CONSTRAINT [FK_GoalActionStep_PlanGoal] FOREIGN KEY ([GoalID]) REFERENCES [dbo].[PlanGoal] ([GoalID])
GO
