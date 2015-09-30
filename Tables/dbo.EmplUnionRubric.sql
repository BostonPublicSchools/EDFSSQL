CREATE TABLE [dbo].[EmplUnionRubric]
(
[EmplUnionRubricID] [int] NOT NULL IDENTITY(1, 1),
[RubricID] [int] NOT NULL,
[UnionCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplUnionRubric_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_EmplUnionRubric_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplUnionRubric_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_EmplUnionRubric_LastUpdatedDt] DEFAULT (getdate()),
[IsDeleted] [bit] NOT NULL CONSTRAINT [IsDeleted_default] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplUnionRubric] ADD CONSTRAINT [PK_EmplUnionRubric] PRIMARY KEY CLUSTERED  ([EmplUnionRubricID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplUnionRubric] ADD CONSTRAINT [FK_EmplUnionRubric_RubricHdr] FOREIGN KEY ([RubricID]) REFERENCES [dbo].[RubricHdr] ([RubricID])
GO
ALTER TABLE [dbo].[EmplUnionRubric] ADD CONSTRAINT [FK_EmplUnionRubric_EmplUnion] FOREIGN KEY ([UnionCode]) REFERENCES [dbo].[EmplUnion] ([UnionCode])
GO
