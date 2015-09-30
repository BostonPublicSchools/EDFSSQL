CREATE TABLE [dbo].[ReportReportParameter]
(
[ReportReportParameterID] [int] NOT NULL IDENTITY(1, 1),
[ReportID] [int] NOT NULL,
[ReportParameterID] [int] NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_ReportReportParameter_LastUpdatedDt] DEFAULT (getdate()),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReportReportParameter_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_ReportReportParameter_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReportReportParameter_LastUpdatedByID] DEFAULT ('000000')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportReportParameter] ADD CONSTRAINT [PK_ReportReportParameter] PRIMARY KEY CLUSTERED  ([ReportReportParameterID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportReportParameter] ADD CONSTRAINT [FK_ReportReportParameter_Report] FOREIGN KEY ([ReportID]) REFERENCES [dbo].[Report] ([ReportID])
GO
ALTER TABLE [dbo].[ReportReportParameter] ADD CONSTRAINT [FK_ReportReportParameter_ReportParameter] FOREIGN KEY ([ReportParameterID]) REFERENCES [dbo].[ReportParameter] ([ReportParameterID])
GO
