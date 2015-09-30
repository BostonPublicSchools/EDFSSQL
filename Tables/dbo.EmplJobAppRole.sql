CREATE TABLE [dbo].[EmplJobAppRole]
(
[JobRoleID] [int] NOT NULL IDENTITY(1, 1),
[JobCode] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RoleID] [int] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__EmplJobAp__Creat__3A179ED3] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__EmplJobAp__Creat__3B0BC30C] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__EmplJobAp__LastU__3BFFE745] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__EmplJobAp__LastU__3CF40B7E] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplJobAppRole] ADD CONSTRAINT [PK_BPSEval_JobsRoles] PRIMARY KEY CLUSTERED  ([JobRoleID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplJobAppRole] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_JobsRoles_BPSEval_Jobs] FOREIGN KEY ([JobCode]) REFERENCES [dbo].[EmplJob] ([JobCode])
GO
ALTER TABLE [dbo].[EmplJobAppRole] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_JobsRoles_BPSEval_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[AppRole] ([RoleID])
GO
