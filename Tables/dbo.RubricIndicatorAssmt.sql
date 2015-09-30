CREATE TABLE [dbo].[RubricIndicatorAssmt]
(
[AssmtID] [int] NOT NULL IDENTITY(1, 1),
[CodeID] [int] NOT NULL,
[IndicatorID] [int] NOT NULL,
[AssmtText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RubricIndicatorAssmt_CreatedByID] DEFAULT ('000000'),
[CreatedDt] [datetime] NOT NULL CONSTRAINT [DF_RubricIndicatorAssmt_CreatedDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RubricIndicatorAssmt_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_RubricIndicatorAssmt_LastUpdatedDt] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[RubricIndicatorAssmt] ADD CONSTRAINT [PK_RubricIndicatorAssmt] PRIMARY KEY CLUSTERED  ([AssmtID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RubricIndicatorAssmt] ADD CONSTRAINT [FK_RubricIndicatorAssmt_CodeLookUp] FOREIGN KEY ([CodeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[RubricIndicatorAssmt] ADD CONSTRAINT [FK_RubricIndicatorAssmt_RubricIndicator] FOREIGN KEY ([IndicatorID]) REFERENCES [dbo].[RubricIndicator] ([IndicatorID])
GO
