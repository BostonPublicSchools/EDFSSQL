CREATE TABLE [dbo].[Initiative]
(
[InitiativeID] [int] NOT NULL IDENTITY(1, 1),
[MgrID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntiativeTypeID] [int] NOT NULL,
[IntiativeText] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntiativeStatusID] [int] NOT NULL CONSTRAINT [DF__BPSEval_M__GoalS__58D1301D] DEFAULT ((0)),
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF__Initiativ__IsDel__0F2D40CE] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Initiativ__Creat__4589517F] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__Initiativ__Creat__467D75B8] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Initiativ__LastU__477199F1] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__Initiativ__LastU__4865BE2A] DEFAULT (getdate()),
[SchYear] [nchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Initiative] ADD CONSTRAINT [PK_BPSEval_RptToGoals] PRIMARY KEY CLUSTERED  ([InitiativeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Initiative] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_MgrGoals_BPSEval_Codes] FOREIGN KEY ([IntiativeTypeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[Initiative] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_RptToGoals_BPSEval_Employees] FOREIGN KEY ([MgrID]) REFERENCES [dbo].[Empl] ([EmplID])
GO
