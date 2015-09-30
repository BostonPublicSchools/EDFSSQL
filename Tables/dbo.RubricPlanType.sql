CREATE TABLE [dbo].[RubricPlanType]
(
[RubricPlanTypeID] [int] NOT NULL IDENTITY(1, 1),
[RubricID] [int] NOT NULL,
[PlanTypeID] [int] NOT NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF_RubricPlanType_IsActive_1] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime] NULL,
[EmplClassList] [nchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RubricPlanType] ADD CONSTRAINT [PK_RubricPlanType] PRIMARY KEY CLUSTERED  ([RubricPlanTypeID]) ON [PRIMARY]
GO
