CREATE TABLE [dbo].[RptUnionCode]
(
[UnionCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobCode] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RptUnionCode_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_RptUnionCode_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RptUnionCode_LastUpdatedID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_RptUnionCode_LastUpdatedDt] DEFAULT (getdate()),
[IsActive] [bit] NOT NULL CONSTRAINT [DF_RptUnionCode_IsActive] DEFAULT ((1))
) ON [PRIMARY]
GO
