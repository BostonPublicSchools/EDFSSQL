CREATE TABLE [dbo].[SchoolSchoolDepartment]
(
[SchSchDeptID] [int] NOT NULL IDENTITY(1, 1),
[SchoolID] [nchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchDeptID] [int] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SchoolSchoolDepartment] ADD CONSTRAINT [pk_SchSchDept_id] PRIMARY KEY CLUSTERED  ([SchSchDeptID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SchoolSchoolDepartment] ADD CONSTRAINT [fk_SchSchDeptID] FOREIGN KEY ([SchDeptID]) REFERENCES [dbo].[SchoolDepartment] ([SchDeptID])
GO
ALTER TABLE [dbo].[SchoolSchoolDepartment] ADD CONSTRAINT [fk_SchSchID] FOREIGN KEY ([SchoolID]) REFERENCES [dbo].[School] ([SchoolID])
GO
