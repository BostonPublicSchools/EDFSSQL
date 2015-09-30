CREATE TABLE [dbo].[RubricStandard]
(
[StandardID] [int] NOT NULL IDENTITY(1, 1),
[StandardText] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StandardDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RubricStandard_CreatedByID] DEFAULT ('000000'),
[CreatedDt] [datetime] NOT NULL CONSTRAINT [DF_RubricStandard_CreatedDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RubricStandard_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_RubricStandard_LastUpdatedDt] DEFAULT (getdate()),
[SortOrder] [int] NOT NULL CONSTRAINT [DF__RubricSta__SortO__77DFC722] DEFAULT ((0)),
[IsActive] [bit] NOT NULL CONSTRAINT [DF__RubricSta__IsAct__7A521F79] DEFAULT ((1)),
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF__RubricSta__IsDel__7B4643B2] DEFAULT ((0)),
[RubricID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[RubricStandard] ADD CONSTRAINT [PK_RubricStandard] PRIMARY KEY CLUSTERED  ([StandardID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RubricStandard] ADD CONSTRAINT [FK_RubricStandard_RubricHdr] FOREIGN KEY ([RubricID]) REFERENCES [dbo].[RubricHdr] ([RubricID])
GO
