CREATE TABLE [dbo].[Release]
(
[ReleaseID] [int] NOT NULL IDENTITY(1, 1),
[ReleaseDate] [date] NOT NULL,
[ReleaseType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleaseVersion] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
