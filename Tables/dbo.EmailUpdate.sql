CREATE TABLE [dbo].[EmailUpdate]
(
[PlanID] [int] NOT NULL,
[PlanEndDt] [datetime] NULL,
[Duration] [int] NOT NULL,
[LastUpdatedByID] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WhoIsRecevinganEmail] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailMessage] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
