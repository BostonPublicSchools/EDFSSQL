CREATE TABLE [dbo].[PeopleSoftEmplName]
(
[EmplID] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImportDate] [datetime] NOT NULL CONSTRAINT [PeopleSoftEmplName_ImportDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PeopleSoftEmplName] ADD CONSTRAINT [PK_EmplName] PRIMARY KEY CLUSTERED  ([EmplID]) ON [PRIMARY]
GO
