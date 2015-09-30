CREATE TABLE [dbo].[GoalEvaluationProgress]
(
[GoalEvalID] [int] NOT NULL IDENTITY(1, 1),
[GoalID] [int] NOT NULL,
[EvalId] [int] NOT NULL,
[ProgressCodeID] [int] NOT NULL,
[Rationale] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GoalEvaluationProgress_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_GoalEvaluationProgress_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GoalEvaluationProgress_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_GoalEvaluationProgress_LastUpdatedDt] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[GoalEvaluationProgressUpdChangeLog] ON [dbo].[GoalEvaluationProgress]
FOR UPDATE
AS
BEGIN
	IF (SELECT 
			COUNT(i.GoalEvalID)
		FROM
			inserted as i
		JOIN deleted as d ON i.GoalEvalID = d.GoalEvalID
		WHERE
			NOT d.ProgressCodeID = i.ProgressCodeID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'GoalEvaluationProgress', i.GoalEvalID, i.LastUpdatedByID, 'EvalGoal progress change for GoalEvalID ' + CAST(i.GoalEvalID AS NVARCHAR), i.LastUpdatedDt, d.ProgressCodeID, i.ProgressCodeID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.GoalEvalID = d.GoalEvalID						
						JOIN Evaluation as e ON e.EvalID = i.EvalId
						JOIN EmplPlan ep on ep.PlanID = e.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END
	
	IF (SELECT 
			COUNT(i.GoalEvalID)
		FROM
			inserted as i
		JOIN deleted as d ON i.GoalEvalID = d.GoalEvalID
		WHERE
			NOT d.Rationale = i.Rationale) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'GoalEvaluationProgress', i.GoalEvalID, i.LastUpdatedByID, 'EvalGoal rationale text change for GoalEvalID ' + CAST(i.GoalEvalID AS NVARCHAR),i.LastUpdatedDt, d.Rationale, i.Rationale, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.GoalEvalID = d.GoalEvalID
						JOIN Evaluation as e ON e.EvalID = i.EvalId
						JOIN EmplPlan ep on ep.PlanID = e.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID							
	END
	
END

GO
ALTER TABLE [dbo].[GoalEvaluationProgress] WITH NOCHECK ADD CONSTRAINT [FK_GoalEvaluationProgress_Evaluation] FOREIGN KEY ([EvalId]) REFERENCES [dbo].[Evaluation] ([EvalID])
GO
ALTER TABLE [dbo].[GoalEvaluationProgress] WITH NOCHECK ADD CONSTRAINT [FK_GoalEvaluationProgress_PlanGoal] FOREIGN KEY ([GoalID]) REFERENCES [dbo].[PlanGoal] ([GoalID])
GO
ALTER TABLE [dbo].[GoalEvaluationProgress] WITH NOCHECK ADD CONSTRAINT [FK_GoalEvaluationProgress_CodeLookUp] FOREIGN KEY ([ProgressCodeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
