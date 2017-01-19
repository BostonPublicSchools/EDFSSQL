CREATE TABLE [dbo].[Empl_backup]
(
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NameLast] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NameFirst] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NameMiddle] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmplActive] [bit] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL,
[IsAdmin] [bit] NOT NULL,
[Sex] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthDt] [datetime] NULL,
[Race] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsContractor] [bit] NOT NULL,
[PrimaryEvalID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasReadOnlyAccess] [bit] NOT NULL,
[ExpectedReturnDate] [date] NULL,
[OriginalHireDate] [date] NULL,
[EmplActiveDt] [datetime] NULL,
[EmplPWord] [varbinary] (max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
