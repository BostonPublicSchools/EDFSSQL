CREATE TABLE [dbo].[DepartmentSchool]
(
[DeptSchoolID] [int] NOT NULL IDENTITY(1, 1),
[DeptID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchoolID] [nchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DepartmentSchool] ADD CONSTRAINT [pk_DeptSchool_id] PRIMARY KEY CLUSTERED  ([DeptSchoolID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DepartmentSchool] ADD CONSTRAINT [fk_deptID] FOREIGN KEY ([DeptID]) REFERENCES [dbo].[Department] ([DeptID])
GO
ALTER TABLE [dbo].[DepartmentSchool] ADD CONSTRAINT [fk_SchoolID] FOREIGN KEY ([SchoolID]) REFERENCES [dbo].[School] ([SchoolID])
GO
