CREATE TABLE [dbo].[PositionAccount]
(
[PositionAccountID] [int] NOT NULL IDENTITY(1, 1),
[EmplJobID] [int] NOT NULL,
[AccountCodeID] [int] NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_PositionAccount_LastUpdatedDt] DEFAULT (getdate()),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PositionAccount_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_PositionAccount_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PositionAccount_LastUpdatedByID] DEFAULT ('000000')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PositionAccount] ADD CONSTRAINT [PK_PositionAccount] PRIMARY KEY CLUSTERED  ([PositionAccountID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PositionAccount] WITH NOCHECK ADD CONSTRAINT [FK_PositionAccount_CodeLookUp] FOREIGN KEY ([AccountCodeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[PositionAccount] WITH NOCHECK ADD CONSTRAINT [FK_PositionAccount_EmplEmplJob] FOREIGN KEY ([EmplJobID]) REFERENCES [dbo].[EmplEmplJob] ([EmplJobID])
GO
