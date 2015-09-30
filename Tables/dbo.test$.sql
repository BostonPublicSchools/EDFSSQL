CREATE TABLE [dbo].[test$]
(
[FilterID] [float] NULL,
[ParentFilterID] [float] NULL,
[FilterCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Filtertext] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterSubText] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [float] NULL,
[CreatedByDt] [datetime] NULL,
[LastUpdatedByID] [float] NULL,
[LastUpdatedDt] [datetime] NULL,
[SortOrder] [float] NULL,
[FilterRowCount] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
