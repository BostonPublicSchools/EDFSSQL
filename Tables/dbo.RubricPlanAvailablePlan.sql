CREATE TABLE [dbo].[RubricPlanAvailablePlan]
(
[AvailablePlanID] [int] NOT NULL IDENTITY(1, 1),
[RubricPlanTypeID] [int] NULL,
[RubricPlanIsMultiYear] [bit] NULL,
[EvalTypeID] [int] NULL,
[OverallRatingID] [int] NULL,
[AvaliablePlanTypeID] [int] NOT NULL,
[IsMultiYear] [bit] NULL,
[EmplClassID] [int] NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF_RubricPlanAvailablePlan_IsActive_1] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdateDate] [datetime] NULL,
[IsProvEmplClass] [bit] NULL CONSTRAINT [DF_RubricPlanAvailablePlan_IsProvEmplClass] DEFAULT ((0)),
[IsJobChange] [bit] NULL,
[IsNewJob] [bit] NULL CONSTRAINT [DF_RubricPlanAvailablePlan_IsNewJob] DEFAULT ((0)),
[NewJobRubricID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RubricPlanAvailablePlan] ADD CONSTRAINT [PK_RubricPlanAvailablePlan] PRIMARY KEY CLUSTERED  ([AvailablePlanID]) ON [PRIMARY]
GO
