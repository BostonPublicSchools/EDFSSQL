CREATE TABLE [dbo].[EmplJobChange_backup]
(
[JobChangeID] [int] NOT NULL IDENTITY(1, 1),
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MgrID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewJobCode] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PreviousJobCode] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEmailSent] [bit] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL,
[NewEmplJobID] [int] NULL,
[PreviousEmplJobID] [int] NULL,
[NewJobEnttryDate] [date] NULL,
[NewEmplEmplJoBCreatedDt] [datetime] NULL
) ON [PRIMARY]
GO
