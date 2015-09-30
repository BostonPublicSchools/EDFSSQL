CREATE TABLE [dbo].[SchoolCalendar]
(
[SchDayID] [int] NOT NULL IDENTITY(1, 1),
[SchYear] [nchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CalendarDate] [date] NOT NULL,
[IsSchoolDay] [bit] NOT NULL CONSTRAINT [DF_SchoolCalendar_IsSchoolDay] DEFAULT ((0)),
[SchoolDayNum] [int] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SchoolCalendar_New_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_SchoolCalendar_New_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SchoolCalendar_New_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_SchoolCalendar_New_LastUpdatedDt] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SchoolCalendar] ADD CONSTRAINT [PK_SchoolCalendar] PRIMARY KEY CLUSTERED  ([SchDayID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
