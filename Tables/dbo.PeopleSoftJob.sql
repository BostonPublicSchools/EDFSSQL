CREATE TABLE [dbo].[PeopleSoftJob]
(
[EmplID] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplRCD] [int] NOT NULL,
[EffectiveDate] [date] NOT NULL,
[EffectiveSequence] [int] NOT NULL,
[Department] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobCode] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobEntryDate] [date] NULL,
[PostionNumber] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayrollStatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Action] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActionDate] [date] NULL,
[ReasonCode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationCode] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmplClass] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTE] [numeric] (8, 6) NULL,
[PayGroup] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompensationRate] [numeric] (13, 6) NULL,
[CompensationFrequency] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalaryGrade] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Step] [int] NULL,
[SalaryAdministrationPlan] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AnnualRate] [numeric] (16, 3) NULL,
[UnionSeniortyDate] [date] NULL,
[StandardHours] [numeric] (5, 2) NULL,
[UnionCode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobIndicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StepEntryDate] [date] NULL,
[ImportDate] [datetime] NOT NULL CONSTRAINT [PeopleSoftJob_ImportDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PeopleSoftJob] ADD CONSTRAINT [PK_Job_1] PRIMARY KEY CLUSTERED  ([EmplID], [EmplRCD], [EffectiveDate], [EffectiveSequence]) ON [PRIMARY]
GO
