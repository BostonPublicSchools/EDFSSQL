CREATE TABLE [dbo].[UserLog]
(
[LogId] [int] NOT NULL IDENTITY(1, 1),
[UserId] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BrowserInfo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginIssue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDt] [datetime] NOT NULL CONSTRAINT [DF_UserLog_CreatedDt] DEFAULT (getdate()),
[LogoutDt] [datetime] NULL,
[IsOverridePwd] [bit] NULL,
[UserLogOut] [bit] NOT NULL CONSTRAINT [DF_UserLog_UserLogOut] DEFAULT ((0)),
[IpAddress] [nchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserLog] ADD CONSTRAINT [PK_UserLog] PRIMARY KEY CLUSTERED  ([LogId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
