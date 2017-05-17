CREATE TABLE [dbo].[ChangelogArchive]
(
[LogID] [int] NOT NULL IDENTITY(1, 1),
[TableName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoggedEvent] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDt] [datetime] NOT NULL,
[PreviousText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Changelog__Creat__0C26B6F1] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__Changelog__Creat__0D1ADB2A] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Changelog__LastU__0E0EFF63] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__Changelog__LastU__0F03239C] DEFAULT (getdate()),
[IdentityID] [int] NOT NULL CONSTRAINT [DF__Changelog__Ident__0FF747D5] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChangelogArchive] ADD CONSTRAINT [PK_BPSEval_logsArchive] PRIMARY KEY CLUSTERED  ([LogID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
