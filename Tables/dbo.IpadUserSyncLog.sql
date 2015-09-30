CREATE TABLE [dbo].[IpadUserSyncLog]
(
[LogId] [int] NOT NULL IDENTITY(1, 1),
[UserId] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastSync] [datetime] NULL,
[CreatedDt] [datetime] NOT NULL CONSTRAINT [DF_IpadSyncLog_CreatedDt] DEFAULT (getdate()),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDt] [datetime] NULL CONSTRAINT [DF_IpadUserSyncLog_LastUpdatedDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastAppDownloaddt] [datetime] NULL,
[LastAppDownloadVersion] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IpadUserSyncLog] ADD CONSTRAINT [PK_IpadSyncLog] PRIMARY KEY CLUSTERED  ([LogId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IpadUserSyncUserID] ON [dbo].[IpadUserSyncLog] ([UserId]) ON [PRIMARY]
GO
