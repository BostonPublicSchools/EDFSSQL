CREATE TABLE [dbo].[RubricIndicator]
(
[IndicatorID] [int] NOT NULL IDENTITY(1, 1),
[StandardID] [int] NOT NULL CONSTRAINT [DF_RubricIndicator_StandardId] DEFAULT ((0)),
[ParentIndicatorID] [int] NOT NULL CONSTRAINT [DF_RubricIndicator_ParentIndicatorID] DEFAULT ((0)),
[IndicatorText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IndicatorDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RubricIndicator_CreatedByID] DEFAULT ('000000'),
[CreatedDt] [datetime] NOT NULL CONSTRAINT [DF_RubricIndicator_CreatedDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RubricIndicator_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_RubricIndicator_LastUpdatedDt] DEFAULT (getdate()),
[SortOrder] [int] NOT NULL CONSTRAINT [DF__RubricInd__SortO__78D3EB5B] DEFAULT ((0)),
[IsActive] [bit] NOT NULL CONSTRAINT [DF__RubricInd__IsAct__7869D707] DEFAULT ((1)),
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF__RubricInd__IsDel__795DFB40] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[RubricIndicator] ADD CONSTRAINT [PK_RubricIndicator] PRIMARY KEY CLUSTERED  ([IndicatorID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RubricIndicator] WITH NOCHECK ADD CONSTRAINT [FK_RubricIndicator_RubricStandard] FOREIGN KEY ([StandardID]) REFERENCES [dbo].[RubricStandard] ([StandardID])
GO
