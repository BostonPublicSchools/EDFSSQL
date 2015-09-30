CREATE TABLE [dbo].[zRubricPlanEndPageAccess]
(
[RubricPlanPageID] [int] NOT NULL,
[RubricPlanTypeID] [int] NULL,
[RubricPlanIsMultiYear] [bit] NULL,
[PageName] [nchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccessDays] [int] NULL,
[IsActive] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[zRubricPlanEndPageAccess] ADD CONSTRAINT [PK_RubricPlanEndPageAccess] PRIMARY KEY CLUSTERED  ([RubricPlanPageID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[zRubricPlanEndPageAccess] ADD CONSTRAINT [FK_RubricPlanEndPageAccess_RubricPlanType] FOREIGN KEY ([RubricPlanTypeID]) REFERENCES [dbo].[RubricPlanType] ([RubricPlanTypeID])
GO
