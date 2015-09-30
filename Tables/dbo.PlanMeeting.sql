CREATE TABLE [dbo].[PlanMeeting]
(
[MeetingID] [int] NOT NULL IDENTITY(1, 1),
[PlanID] [int] NOT NULL,
[ForeignIdentityID] [int] NULL,
[MeetingTypeID] [int] NOT NULL,
[MeetingDate] [date] NOT NULL,
[MeetingStartTime] [time] NOT NULL,
[MeetingEndTime] [time] NOT NULL,
[MeetingLocation] [nchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeetingDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeetingStatusID] [int] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PlanMeeting_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_PlanMeeting_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PlanMeeting_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_PlanMeeting_LastUpdatedDt] DEFAULT (getdate()),
[EvaluatorComment] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmployeeComment] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsMeetingReleased] [bit] NULL CONSTRAINT [DF__PlanMeeti__IsMee__59662CFA] DEFAULT ((0)),
[MeetingReleasedDt] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanMeeting] ADD CONSTRAINT [PK_PlanMeeting] PRIMARY KEY CLUSTERED  ([MeetingID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanMeeting] ADD CONSTRAINT [FK_PlanMeeting_EmplPlan] FOREIGN KEY ([PlanID]) REFERENCES [dbo].[EmplPlan] ([PlanID])
GO
