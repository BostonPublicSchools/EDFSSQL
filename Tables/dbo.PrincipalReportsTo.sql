CREATE TABLE [dbo].[PrincipalReportsTo]
(
[Descr] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeptID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Better name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Principal] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[priority] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Turnaround] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Assign plan] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
