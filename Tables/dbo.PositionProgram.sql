CREATE TABLE [dbo].[PositionProgram]
(
[PositionProgramID] [int] NOT NULL IDENTITY(1, 1),
[ProgramCodeID] [int] NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_PositionProgram_LastUpdatedDt] DEFAULT (getdate()),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PositionProgram_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_PositionProgram_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PositionProgram_LastUpdatedByID] DEFAULT ('000000'),
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsPrimary] [bit] NOT NULL CONSTRAINT [DF_PositionProgram_IsPrimary] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PositionProgram] ADD CONSTRAINT [PK_PositionProgram] PRIMARY KEY CLUSTERED  ([PositionProgramID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PositionProgram] WITH NOCHECK ADD CONSTRAINT [FK_PositionProgram_CodeLookUp] FOREIGN KEY ([ProgramCodeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
