CREATE TABLE [dbo].[SchoolCourse]
(
[SchCourseID] [int] NOT NULL IDENTITY(1, 1),
[EmplJobID] [int] NOT NULL,
[CourseCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CourseName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CourseGrade] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalStudentCount] [int] NOT NULL CONSTRAINT [DF__SchoolCou__Total__47F18835] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SchoolCourse] ADD CONSTRAINT [pk_SchCourse_id] PRIMARY KEY CLUSTERED  ([SchCourseID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SchoolCourse] ADD CONSTRAINT [fk_SchCrse_EmplJobID] FOREIGN KEY ([EmplJobID]) REFERENCES [dbo].[EmplEmplJob] ([EmplJobID])
GO
