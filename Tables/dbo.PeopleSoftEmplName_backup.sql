CREATE TABLE [dbo].[PeopleSoftEmplName_backup]
(
[EmplID] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
