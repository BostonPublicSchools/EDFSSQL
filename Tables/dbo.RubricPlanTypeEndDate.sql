CREATE TABLE [dbo].[RubricPlanTypeEndDate]
(
[PlanEndDateID] [int] NOT NULL IDENTITY(1, 1),
[RubricPlanTypeID] [int] NOT NULL,
[EndTypeID] [int] NOT NULL,
[PlanEndDateTypeID] [int] NOT NULL,
[DefaultPlanEndDate] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF_RubricPlanTypeEndDate_IsActive_1] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime] NULL,
[DefaultFormativeValue] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isNewJob] [bit] NULL CONSTRAINT [DF__RubricPla__isNew__5733CBC5] DEFAULT ((0)),
[DefaultPlanEndDateMax] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RubricPlanTypeEndDate] ADD CONSTRAINT [PK_RubricPlanTypeEndDate] PRIMARY KEY CLUSTERED  ([PlanEndDateID]) ON [PRIMARY]
GO
