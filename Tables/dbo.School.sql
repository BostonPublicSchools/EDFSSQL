CREATE TABLE [dbo].[School]
(
[SchoolID] [nchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchoolDeptID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchoolName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__School__CreatedB__50FB042B] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__School__CreatedB__51EF2864] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__School__LastUpda__52E34C9D] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__School__LastUpda__53D770D6] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[School] ADD CONSTRAINT [PK_BPSEval_Schools] PRIMARY KEY CLUSTERED  ([SchoolID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
