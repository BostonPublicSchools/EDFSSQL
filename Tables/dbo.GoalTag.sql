CREATE TABLE [dbo].[GoalTag]
(
[GoalGoalTagID] [int] NOT NULL IDENTITY(1, 1),
[GoalID] [int] NOT NULL,
[GoalTagID] [int] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__GoalTag__Created__41B8C09B] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__GoalTag__Created__42ACE4D4] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__GoalTag__LastUpd__43A1090D] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__GoalTag__LastUpd__44952D46] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GoalTag] ADD CONSTRAINT [PK_BPSEval_GoalTags] PRIMARY KEY CLUSTERED  ([GoalGoalTagID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GoalTag] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_GoalTags_BPSEval_Goals] FOREIGN KEY ([GoalID]) REFERENCES [dbo].[PlanGoal] ([GoalID])
GO
ALTER TABLE [dbo].[GoalTag] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_GoalTags_BPSEval_Codes] FOREIGN KEY ([GoalTagID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
