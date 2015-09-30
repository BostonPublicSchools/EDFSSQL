CREATE TABLE [dbo].[ObservationRubricDefault]
(
[ObsRubricID] [int] NOT NULL IDENTITY(1, 1),
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RubricID] [int] NOT NULL,
[IndicatorID] [int] NOT NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF_ObservationRubricDefault_IsActive] DEFAULT ((1)),
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_ObservationRubricDefault_IsDeleted] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ObservationRubricDefault_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_ObservationRubricDefault_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ObservationRubricDefault_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_ObservationRubricDefault_LastUpdatedDt] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ObservationRubricDefault] ADD CONSTRAINT [PK_ObservationRubricDefault] PRIMARY KEY CLUSTERED  ([ObsRubricID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ObservationRubricDefault] ADD CONSTRAINT [FK_ObservationRubricDefault_Empl] FOREIGN KEY ([EmplID]) REFERENCES [dbo].[Empl] ([EmplID])
GO
ALTER TABLE [dbo].[ObservationRubricDefault] ADD CONSTRAINT [FK_ObservationRubricDefault_RubricIndicator] FOREIGN KEY ([IndicatorID]) REFERENCES [dbo].[RubricIndicator] ([IndicatorID])
GO
ALTER TABLE [dbo].[ObservationRubricDefault] ADD CONSTRAINT [FK_ObservationRubricDefault_RubricHdr] FOREIGN KEY ([RubricID]) REFERENCES [dbo].[RubricHdr] ([RubricID])
GO
