CREATE TABLE [dbo].[ProgramSubject]
(
[PositionSubjectID] [int] NOT NULL IDENTITY(1, 1),
[EmplJobID] [int] NOT NULL,
[SubjectCodeID] [int] NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_ProgramSubject_LastUpdatedDt] DEFAULT (getdate()),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProgramSubject_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_ProgramSubject_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProgramSubject_LastUpdatedByID] DEFAULT ('000000')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramSubject] ADD CONSTRAINT [PK_ProgramSubject] PRIMARY KEY CLUSTERED  ([PositionSubjectID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramSubject] WITH NOCHECK ADD CONSTRAINT [FK_ProgramSubject_EmplEmplJob] FOREIGN KEY ([EmplJobID]) REFERENCES [dbo].[EmplEmplJob] ([EmplJobID])
GO
ALTER TABLE [dbo].[ProgramSubject] WITH NOCHECK ADD CONSTRAINT [FK_ProgramSubject_CodeLookUp] FOREIGN KEY ([SubjectCodeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
