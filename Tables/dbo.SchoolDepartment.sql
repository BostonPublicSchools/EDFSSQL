CREATE TABLE [dbo].[SchoolDepartment]
(
[SchDeptID] [int] NOT NULL IDENTITY(1, 1),
[SchDeptCode] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchDeptName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SchoolDepartment] ADD CONSTRAINT [pk_SchDept_id] PRIMARY KEY CLUSTERED  ([SchDeptID]) ON [PRIMARY]
GO
