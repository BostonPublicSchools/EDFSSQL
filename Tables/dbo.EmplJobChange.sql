CREATE TABLE [dbo].[EmplJobChange]
(
[JobChangeID] [int] NOT NULL IDENTITY(1, 1),
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MgrID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewJobCode] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PreviousJobCode] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEmailSent] [bit] NOT NULL CONSTRAINT [DF_EmplJobChange_IsEmailSent] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplJobChange_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_EmplJobChange_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplJobChange_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_EmplJobChange_LastUpdatedDt] DEFAULT (getdate()),
[NewEmplJobID] [int] NULL,
[PreviousEmplJobID] [int] NULL,
[NewJobEnttryDate] [date] NULL,
[NewEmplEmplJoBCreatedDt] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplJobChange] ADD CONSTRAINT [PK_EmplJobChange] PRIMARY KEY CLUSTERED  ([JobChangeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
