CREATE TABLE [dbo].[Department]
(
[DeptID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DeptName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MgrID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Deptartment_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_Deptartment_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Deptartment_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_Deptartment_LastUpdatedDt] DEFAULT (getdate()),
[IsSchool] [bit] NOT NULL CONSTRAINT [DF__Departmen__IsSch__40257DE4] DEFAULT ((0)),
[DeptCategoryID] [int] NULL,
[ImplSpecialistID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeptRptEmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Department] ADD CONSTRAINT [PK_Deptartment] PRIMARY KEY CLUSTERED  ([DeptID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
