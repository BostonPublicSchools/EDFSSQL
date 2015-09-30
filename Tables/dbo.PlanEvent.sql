CREATE TABLE [dbo].[PlanEvent]
(
[EventID] [int] NOT NULL IDENTITY(1, 1),
[EventText] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventDesc] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventDuration] [numeric] (18, 2) NOT NULL,
[EventPerPlan] [int] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PlanEvent_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_PlanEvent_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PlanEvent_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_PlanEvent_LastUpdatedDt] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanEvent] ADD CONSTRAINT [PK_PlanEvent] PRIMARY KEY CLUSTERED  ([EventID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
