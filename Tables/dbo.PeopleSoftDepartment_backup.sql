CREATE TABLE [dbo].[PeopleSoftDepartment_backup]
(
[DeptID] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DeptDescription] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SetID] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationCode] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
