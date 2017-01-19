CREATE TABLE [dbo].[EmplJob_backup]
(
[JobCode] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JobName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UnionCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL,
[RubricID] [int] NULL
) ON [PRIMARY]
GO
