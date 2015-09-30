CREATE TABLE [dbo].[PlanGoal]
(
[GoalID] [int] NOT NULL IDENTITY(1, 1),
[PlanID] [int] NOT NULL,
[GoalYear] [int] NOT NULL,
[GoalTypeID] [int] NOT NULL,
[GoalLevelID] [int] NOT NULL,
[GoalStatusID] [int] NOT NULL,
[GoalText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF__BPSEval_G__IsDel__2BFE89A6] DEFAULT ('0'),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PlanGoal__Create__4D2A7347] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__PlanGoal__Create__4E1E9780] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PlanGoal__LastUp__4F12BBB9] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__PlanGoal__LastUp__5006DFF2] DEFAULT (getdate()),
[GoalApprovedDt] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[PlanGoalInsertChangeLog] ON [dbo].[PlanGoal]
AFTER INSERT
AS
BEGIN
	INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
	SELECT		   		  'PlanGoal', i.GoalID, i.LastUpdatedByID, 'Goal text entered for GoalID ' + CAST(i.GoalID AS NVARCHAR),i.LastUpdatedDt, '', i.GoalText, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
					FROM
						inserted as i
					JOIN EmplPlan ep on ep.PlanID = i.PlanID
					JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID
							
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[PlanGoalUpdChangeLog] ON [dbo].[PlanGoal]
FOR UPDATE
AS
BEGIN
	IF (SELECT 
			COUNT(i.GoalID)
		FROM
			inserted as i
		JOIN deleted as d ON i.GoalID = d.GoalID
		WHERE
			NOT d.GoalStatusID = i.GoalStatusID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'PlanGoal', i.GoalID, i.LastUpdatedByID, 'Goal status change for GoalID ' + CAST(i.GoalID AS NVARCHAR), i.LastUpdatedDt, d.GoalStatusID, i.GoalStatusID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.GoalID = d.GoalID
						JOIN EmplPlan ep on ep.PlanID = i.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END
	
	IF (SELECT 
			COUNT(i.GoalID)
		FROM
			inserted as i
		JOIN deleted as d ON i.GoalID = d.GoalID
		WHERE
			NOT d.GoalText = i.GoalText) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'PlanGoal', i.GoalID, i.LastUpdatedByID, 'Goal text change for GoalID ' + CAST(i.GoalID AS NVARCHAR),i.LastUpdatedDt, d.GoalText, i.GoalText, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.GoalID = d.GoalID
						JOIN EmplPlan ep on ep.PlanID = i.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID							
						
	END
	
	IF (SELECT 
			COUNT(i.GoalID)
		FROM
			inserted as i
		JOIN deleted as d ON i.GoalID = d.GoalID
		WHERE			
			 i.GoalStatusID=(select top 1 CodeID from CodeLookUp where CodeText='Approved' and CodeType='GoalStatus') ) > 0
			 
	BEGIN
		UPDATE g
		SET GoalApprovedDt =i.LastUpdatedDt
		FROM inserted i 
			join PlanGoal g on i.GoalID=g.GoalID
	END
	
END
GO
ALTER TABLE [dbo].[PlanGoal] ADD CONSTRAINT [PK_BPSEval_Goals] PRIMARY KEY CLUSTERED  ([GoalID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PlanGoal_PlanID] ON [dbo].[PlanGoal] ([PlanID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanGoal] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_Goals_BPSEval_Codes1] FOREIGN KEY ([GoalLevelID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[PlanGoal] WITH NOCHECK ADD CONSTRAINT [FK_PlanGoal_GoalStatus] FOREIGN KEY ([GoalStatusID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[PlanGoal] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_Goals_BPSEval_Codes] FOREIGN KEY ([GoalTypeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[PlanGoal] WITH NOCHECK ADD CONSTRAINT [FK_PlanGoal_EmplPlan] FOREIGN KEY ([PlanID]) REFERENCES [dbo].[EmplPlan] ([PlanID])
GO
