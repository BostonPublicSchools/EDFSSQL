CREATE TABLE [dbo].[Comment]
(
[CommentID] [int] NOT NULL IDENTITY(1, 1),
[PlanID] [int] NOT NULL,
[CommentTypeID] [int] NOT NULL,
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommentDt] [datetime] NOT NULL,
[CommentText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Comment__Created__36470DEF] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__Comment__Created__373B3228] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Comment__LastUpd__382F5661] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__Comment__LastUpd__39237A9A] DEFAULT (getdate()),
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF__Comment__IsDelet__595B4002] DEFAULT ((0)),
[OtherID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Comment] ADD CONSTRAINT [PK_BPSEval_Comments] PRIMARY KEY CLUSTERED  ([CommentID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Comment_IsDeleted_OtherID] ON [dbo].[Comment] ([IsDeleted], [OtherID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Comment] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_Comments_BPSEval_Codes] FOREIGN KEY ([CommentTypeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[Comment] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_Comments_BPSEval_Employees] FOREIGN KEY ([EmplID]) REFERENCES [dbo].[Empl] ([EmplID])
GO
ALTER TABLE [dbo].[Comment] WITH NOCHECK ADD CONSTRAINT [FK_Comment_EmplPlan] FOREIGN KEY ([PlanID]) REFERENCES [dbo].[EmplPlan] ([PlanID])
GO
