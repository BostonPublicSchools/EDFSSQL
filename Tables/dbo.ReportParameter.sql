CREATE TABLE [dbo].[ReportParameter]
(
[ReportParameterID] [int] NOT NULL IDENTITY(1, 1),
[ReportParameterName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_ReportParameter_LastUpdatedDt] DEFAULT (getdate()),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReportParameter_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_ReportParameter_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReportParameter_LastUpdatedByID] DEFAULT ('000000')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportParameter] ADD CONSTRAINT [PK_ReportParameter] PRIMARY KEY CLUSTERED  ([ReportParameterID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportParameter] ADD CONSTRAINT [IX_ReportParameterName] UNIQUE NONCLUSTERED  ([ReportParameterName]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
