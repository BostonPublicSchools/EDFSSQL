CREATE TABLE [dbo].[EmplUnion]
(
[UnionCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UnionName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplUnion_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_EmplUnion_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplUnion_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_EmplUnion_LastUpdatedDt] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplUnion] ADD CONSTRAINT [PK_EmplUnion] PRIMARY KEY CLUSTERED  ([UnionCode]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
