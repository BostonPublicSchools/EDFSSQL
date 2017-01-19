CREATE TABLE [dbo].[EmplExceptions_backup]
(
[ExceptionID] [int] NOT NULL IDENTITY(1, 1),
[EmplJobID] [int] NOT NULL,
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MgrID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
