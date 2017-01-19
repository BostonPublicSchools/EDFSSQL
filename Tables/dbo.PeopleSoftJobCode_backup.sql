CREATE TABLE [dbo].[PeopleSoftJobCode_backup]
(
[JobCode] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JobDesc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnionCode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
