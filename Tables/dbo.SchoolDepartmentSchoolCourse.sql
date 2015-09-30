CREATE TABLE [dbo].[SchoolDepartmentSchoolCourse]
(
[SchDeptSchCourseID] [int] NOT NULL IDENTITY(1, 1),
[SchDeptID] [int] NULL,
[SchCourseID] [int] NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SchoolDepartmentSchoolCourse] ADD CONSTRAINT [pk_SchDeptCourse_id] PRIMARY KEY CLUSTERED  ([SchDeptSchCourseID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SchoolDepartmentSchoolCourse] ADD CONSTRAINT [fk_SchCourseID] FOREIGN KEY ([SchCourseID]) REFERENCES [dbo].[SchoolCourse] ([SchCourseID])
GO
ALTER TABLE [dbo].[SchoolDepartmentSchoolCourse] ADD CONSTRAINT [fk_SchDeptID] FOREIGN KEY ([SchDeptID]) REFERENCES [dbo].[SchoolDepartment] ([SchDeptID])
GO
