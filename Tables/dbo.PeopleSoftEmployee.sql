CREATE TABLE [dbo].[PeopleSoftEmployee]
(
[EmplID] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplRCD] [int] NOT NULL,
[EffectiveDate] [date] NULL,
[EffectiveSequence] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine1] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine2] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HomePhone] [char] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkPhone] [char] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NationalID] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalStartDate] [date] NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [date] NULL,
[EthnicGroup] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisabledVeteran] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MilitaryStatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpectedReturnDate] [date] NULL,
[TeminationDate] [date] NULL,
[UnionCode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnionSeniorityDate] [date] NULL,
[Department] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepartmentName] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobCode] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobTitle] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayrollStatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Action] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActionDate] [date] NULL,
[ReasonCode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationCode] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PositonNumber] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayGroup] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompensationRate] [numeric] (13, 6) NULL,
[CompensationFrequency] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalaryGrade] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Step] [int] NULL,
[SalaryAdministrationPlan] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AnnualRate] [numeric] (16, 3) NULL,
[ServiceDate] [date] NULL,
[FTE] [numeric] (8, 6) NULL,
[ImportDate] [datetime] NOT NULL CONSTRAINT [PeopleSoftEmployee_ImportDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
