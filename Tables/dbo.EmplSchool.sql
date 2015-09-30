CREATE TABLE [dbo].[EmplSchool]
(
[EmplSchoolID] [int] NOT NULL IDENTITY(1, 1),
[SchoolID] [nchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__EmplSchoo__Creat__3DE82FB7] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__EmplSchoo__Creat__3EDC53F0] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__EmplSchoo__LastU__3FD07829] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__EmplSchoo__LastU__40C49C62] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplSchool] ADD CONSTRAINT [PK_BPSEval_EmployeeSchools] PRIMARY KEY CLUSTERED  ([EmplSchoolID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplSchool] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_EmployeeSchools_BPSEval_Employees] FOREIGN KEY ([EmplID]) REFERENCES [dbo].[Empl] ([EmplID])
GO
ALTER TABLE [dbo].[EmplSchool] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_EmployeeSchools_BPSEval_Schools] FOREIGN KEY ([SchoolID]) REFERENCES [dbo].[School] ([SchoolID])
GO
