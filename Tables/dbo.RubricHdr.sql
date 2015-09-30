CREATE TABLE [dbo].[RubricHdr]
(
[RubricID] [int] NOT NULL IDENTITY(1, 1),
[RubricName] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF_RubricHdr_IsActive] DEFAULT ((1)),
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_RubricHdr_IsDeleted] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RubricHdr_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_RubricHdr_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RubricHdr_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_RubricHdr_LastUpdatedDt] DEFAULT (getdate()),
[Is5StepProcess] [bit] NOT NULL CONSTRAINT [RubricHdr_IsNonLic_Default] DEFAULT ((0)),
[IsDESELic] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RubricHdr] ADD CONSTRAINT [PK_RubricHdr] PRIMARY KEY CLUSTERED  ([RubricID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
