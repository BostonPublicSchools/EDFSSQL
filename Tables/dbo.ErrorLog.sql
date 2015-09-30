CREATE TABLE [dbo].[ErrorLog]
(
[ErrorID] [int] NOT NULL IDENTITY(1, 1),
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Browser] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Url] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorMsg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDt] [datetime] NOT NULL CONSTRAINT [DF_ErrorLog_CreatedDt] DEFAULT (getdate()),
[EmplJobID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ErrorLog] ADD CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED  ([ErrorID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
