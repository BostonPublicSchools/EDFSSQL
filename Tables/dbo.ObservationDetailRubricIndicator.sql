CREATE TABLE [dbo].[ObservationDetailRubricIndicator]
(
[ObsvDetRubricID] [int] NOT NULL IDENTITY(1, 1),
[ObsvDID] [int] NOT NULL,
[IndicatorID] [int] NOT NULL,
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_ObservationDetailRubricIndicator_IsDeleted] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ObservationDetailRubricIndicator_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_ObservationDetailRubricIndicator_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ObservationDetailRubricIndicator_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_ObservationDetailRubricIndicator_LastUpdatedDt] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ObservationDetailRubricIndicator] ADD CONSTRAINT [PK_ObservationDetailRubricIndicator] PRIMARY KEY CLUSTERED  ([ObsvDetRubricID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ObservationDetailRubricIndicator] ADD CONSTRAINT [FK_ObservationDetailRubricIndicator_RubricIndicator] FOREIGN KEY ([IndicatorID]) REFERENCES [dbo].[RubricIndicator] ([IndicatorID])
GO
ALTER TABLE [dbo].[ObservationDetailRubricIndicator] ADD CONSTRAINT [FK_ObservationDetailRubricIndicator_ObservationDetail] FOREIGN KEY ([ObsvDID]) REFERENCES [dbo].[ObservationDetail] ([ObsvDID])
GO
