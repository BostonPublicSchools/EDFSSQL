CREATE TABLE [dbo].[Filters]
(
[FilterID] [int] NOT NULL IDENTITY(1, 1),
[ParentFilterID] [int] NOT NULL,
[FilterCode] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Filtertext] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilterSubText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Filters_New_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_Filters_New_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Filters_New_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_Filters_New_LastUpdatedDt] DEFAULT (getdate()),
[SortOrder] [int] NULL,
[IsDeleted] [bit] NULL CONSTRAINT [DF__Filters__IsDelet__4FE7AFB8] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Filters] ADD CONSTRAINT [PK_Filters_New] PRIMARY KEY CLUSTERED  ([FilterID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
