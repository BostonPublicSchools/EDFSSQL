CREATE TABLE [dbo].[ReportAppRole]
(
[ReportAppRoleID] [int] NOT NULL IDENTITY(1, 1),
[RoleID] [int] NOT NULL,
[ReportID] [int] NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_ReportAppRole_LastUpdatedDt] DEFAULT (getdate()),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReportAppRole_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_ReportAppRole_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReportAppRole_LastUpdatedByID] DEFAULT ('000000')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportAppRole] ADD CONSTRAINT [PK_ReportAppRole] PRIMARY KEY CLUSTERED  ([ReportAppRoleID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportAppRole] ADD CONSTRAINT [FK_ReportAppRole_Report] FOREIGN KEY ([ReportID]) REFERENCES [dbo].[Report] ([ReportID])
GO
ALTER TABLE [dbo].[ReportAppRole] ADD CONSTRAINT [FK_ReportAppRole_AppRole] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[AppRole] ([RoleID])
GO
