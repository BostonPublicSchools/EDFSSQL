CREATE TABLE [dbo].[InitiativeTag]
(
[IntiativeIntiativeTagID] [int] NOT NULL IDENTITY(1, 1),
[IntiativeID] [int] NOT NULL,
[GoalTagID] [int] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Initiativ__Creat__4959E263] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__Initiativ__Creat__4A4E069C] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Initiativ__LastU__4B422AD5] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__Initiativ__LastU__4C364F0E] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InitiativeTag] ADD CONSTRAINT [PK_IntiativeTag] PRIMARY KEY CLUSTERED  ([IntiativeIntiativeTagID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InitiativeTag] WITH NOCHECK ADD CONSTRAINT [FK_IntiativeTag_CodeLookUp] FOREIGN KEY ([GoalTagID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[InitiativeTag] WITH NOCHECK ADD CONSTRAINT [FK_IntiativeTag_Initiative] FOREIGN KEY ([IntiativeID]) REFERENCES [dbo].[Initiative] ([InitiativeID])
GO
