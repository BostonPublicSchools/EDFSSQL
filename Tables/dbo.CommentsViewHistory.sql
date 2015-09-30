CREATE TABLE [dbo].[CommentsViewHistory]
(
[CommentsViewID] [int] NOT NULL IDENTITY(1, 1),
[CommentID] [int] NOT NULL,
[AssignedEmplID] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsViewed] [bit] NOT NULL CONSTRAINT [DF__CommentsV__IsVie__2CD37DA5] DEFAULT ((0)),
[CreatedDt] [datetime] NULL,
[CreatedByID] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDt] [datetime] NULL,
[LastUpdatedByID] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
