CREATE TABLE [dbo].[EmplEmplJob_backup]
(
[EmplJobID] [int] NOT NULL IDENTITY(1, 1),
[JobCode] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplRcdNo] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MgrID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL,
[DeptID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PositionNo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDt] [datetime] NULL,
[EmplClass] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NOT NULL,
[FTE] [numeric] (8, 6) NOT NULL,
[RubricID] [int] NOT NULL,
[RubricOverrideReason] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobEntryDate] [date] NULL,
[SalaryAdministrationPlan] [nchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalaryGrade] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Step] [int] NULL,
[StepEntryDate] [date] NULL
) ON [PRIMARY]
GO
