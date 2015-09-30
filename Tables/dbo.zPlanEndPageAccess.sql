CREATE TABLE [dbo].[zPlanEndPageAccess]
(
[PagePlanID] [int] NOT NULL,
[PlanID] [int] NOT NULL,
[PageName] [nchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsAccess] [bit] NOT NULL CONSTRAINT [DF_PlanPageAccess_IsAccess] DEFAULT ((0)),
[AccessEndDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
