CREATE TABLE [dbo].[EmplJobAppRole_backup]
(
[JobRoleID] [int] NOT NULL IDENTITY(1, 1),
[JobCode] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RoleID] [int] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
