CREATE TABLE [dbo].[tt]
(
[LastName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmplID] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[minOriginalStartDate] [date] NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EthnicGroup] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[maxExpectedReturnDate] [date] NULL,
[DateOfBirth] [date] NULL
) ON [PRIMARY]
GO
