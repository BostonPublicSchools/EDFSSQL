CREATE TABLE [dbo].[PositionFund]
(
[PositionFundID] [int] NOT NULL IDENTITY(1, 1),
[EmplJobID] [int] NOT NULL,
[FundCodeID] [int] NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_PositionFund_LastUpdatedDt] DEFAULT (getdate()),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PositionFund_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_PositionFund_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PositionFund_LastUpdatedByID] DEFAULT ('000000')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PositionFund] ADD CONSTRAINT [PK_PositionFund] PRIMARY KEY CLUSTERED  ([PositionFundID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PositionFund] WITH NOCHECK ADD CONSTRAINT [FK_PositionFund_EmplEmplJob] FOREIGN KEY ([EmplJobID]) REFERENCES [dbo].[EmplEmplJob] ([EmplJobID])
GO
ALTER TABLE [dbo].[PositionFund] WITH NOCHECK ADD CONSTRAINT [FK_PositionFund_CodeLookUp] FOREIGN KEY ([FundCodeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
