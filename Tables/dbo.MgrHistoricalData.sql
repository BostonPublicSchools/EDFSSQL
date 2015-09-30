CREATE TABLE [dbo].[MgrHistoricalData]
(
[DeptID] [int] NULL,
[ManagerId] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[MgrStatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
