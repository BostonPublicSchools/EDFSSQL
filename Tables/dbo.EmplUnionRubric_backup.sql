CREATE TABLE [dbo].[EmplUnionRubric_backup]
(
[EmplUnionRubricID] [int] NOT NULL IDENTITY(1, 1),
[RubricID] [int] NOT NULL,
[UnionCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL,
[IsDeleted] [bit] NOT NULL
) ON [PRIMARY]
GO
