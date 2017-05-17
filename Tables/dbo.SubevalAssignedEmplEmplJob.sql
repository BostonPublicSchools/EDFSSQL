CREATE TABLE [dbo].[SubevalAssignedEmplEmplJob]
(
[AssignedSubevaluatorID] [int] NOT NULL IDENTITY(1, 1),
[EmplJobID] [int] NOT NULL,
[SubEvalID] [int] NOT NULL CONSTRAINT [DF_SubevalAssignedEmplEmplJob_SubEvalID] DEFAULT ((0)),
[IsActive] [bit] NOT NULL CONSTRAINT [DF_SubevalAssignedEmplEmplJob_IsActive] DEFAULT ((1)),
[IsPrimary] [bit] NOT NULL CONSTRAINT [DF_SubevalAssignedEmplEmplJob_IsPrimary] DEFAULT ((0)),
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_SubevalAssignedEmplEmplJob_IsDeleted] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SubevalAssignedEmplEmplJob_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_SubevalAssignedEmplEmplJob_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SubevalAssignedEmplEmplJob_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_SubevalAssignedEmplEmplJob_LastUpdatedDt] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SubevalAssignedEmplEmplJob] ADD CONSTRAINT [PK_SubevalAssignedEmplEmplJob] PRIMARY KEY CLUSTERED  ([AssignedSubevaluatorID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SubevalAssignedEmplEmplJob_EmplJobID_IsActive_isPrimary_IsDeleted] ON [dbo].[SubevalAssignedEmplEmplJob] ([EmplJobID], [IsActive], [IsPrimary], [IsDeleted]) INCLUDE ([SubEvalID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TemporaryLoadFixMay152015] ON [dbo].[SubevalAssignedEmplEmplJob] ([IsActive], [IsPrimary], [IsDeleted]) INCLUDE ([EmplJobID], [SubEvalID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SubevalAssignedEmplEmplJob] WITH NOCHECK ADD CONSTRAINT [FK_SubevalAssignedEmplEmplJob_EmplEmplJob] FOREIGN KEY ([EmplJobID]) REFERENCES [dbo].[EmplEmplJob] ([EmplJobID])
GO
ALTER TABLE [dbo].[SubevalAssignedEmplEmplJob] WITH NOCHECK ADD CONSTRAINT [FK_SubevalAssignedEmplEmplJob_Subeval] FOREIGN KEY ([SubEvalID]) REFERENCES [dbo].[SubEval] ([EvalID])
GO
