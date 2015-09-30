CREATE TABLE [dbo].[Changelog]
(
[LogID] [int] NOT NULL IDENTITY(1, 1),
[TableName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoggedEvent] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDt] [datetime] NOT NULL,
[PreviousText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Changelog__Creat__2EA5EC27] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__Changelog__Creat__2F9A1060] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Changelog__LastU__308E3499] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__Changelog__LastU__318258D2] DEFAULT (getdate()),
[IdentityID] [int] NOT NULL CONSTRAINT [DF__Changelog__Ident__53A266AC] DEFAULT ((0)),
[IdentityEmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Changelog] ADD CONSTRAINT [PK_BPSEval_logs] PRIMARY KEY CLUSTERED  ([LogID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [INDEX_IDX_EMPLID_Both] ON [dbo].[Changelog] ([EmplID], [IdentityEmplID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IdentityID_ChangeLog] ON [dbo].[Changelog] ([IdentityID]) ON [PRIMARY]
GO
