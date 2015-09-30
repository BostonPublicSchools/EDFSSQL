CREATE TABLE [dbo].[PlanTypeMaxObservation]
(
[PlanTypeMaxID] [int] NOT NULL IDENTITY(1, 1),
[PlanTypeID] [int] NOT NULL,
[ObservationTypeID] [int] NOT NULL,
[MaxLimit] [int] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByDt] [datetime] NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDt] [datetime] NULL,
[EmplClass] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanTypeMaxObservation] ADD CONSTRAINT [Pk_PlanTypeMaxID] PRIMARY KEY CLUSTERED  ([PlanTypeMaxID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
