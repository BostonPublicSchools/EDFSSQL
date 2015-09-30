CREATE TABLE [dbo].[Report]
(
[ReportID] [int] NOT NULL IDENTITY(1, 1),
[ReportName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportPath] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_Report_LastUpdatedDt] DEFAULT (getdate()),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Report_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_Report_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Report_LastUpdatedByID] DEFAULT ('000000'),
[IsDeleted] [bit] NULL CONSTRAINT [DF__Report__IsDelete__2902ECC1] DEFAULT ((0)),
[ProcedureName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SelectedRptColumns] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Report] ADD CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED  ([ReportID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Report] ADD CONSTRAINT [IX_ReportName] UNIQUE NONCLUSTERED  ([ReportName]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
