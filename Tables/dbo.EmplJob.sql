CREATE TABLE [dbo].[EmplJob]
(
[JobCode] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JobName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UnionCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplJob_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_EmplJob_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplJob_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_EmplJob_LastUpdatedDt] DEFAULT (getdate()),
[RubricID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplJob] ADD CONSTRAINT [PK_BPSEval_Jobs] PRIMARY KEY CLUSTERED  ([JobCode]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplJob] WITH NOCHECK ADD CONSTRAINT [FK_RubricHdr_rubricID] FOREIGN KEY ([RubricID]) REFERENCES [dbo].[RubricHdr] ([RubricID])
GO
ALTER TABLE [dbo].[EmplJob] WITH NOCHECK ADD CONSTRAINT [FK_EmplJob_EmplUnion] FOREIGN KEY ([UnionCode]) REFERENCES [dbo].[EmplUnion] ([UnionCode])
GO
