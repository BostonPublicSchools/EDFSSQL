CREATE TABLE [dbo].[AppRole]
(
[RoleID] [int] NOT NULL IDENTITY(1, 1),
[RoleDesc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__AppRole__Created__2AD55B43] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__AppRole__Created__2BC97F7C] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__AppRole__LastUpd__2CBDA3B5] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__AppRole__LastUpd__2DB1C7EE] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppRole] ADD CONSTRAINT [PK_BPSEval_Roles] PRIMARY KEY CLUSTERED  ([RoleID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
