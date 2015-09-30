CREATE TABLE [dbo].[EvaluatorDailyEmailLog]
(
[DailyChangeID] [int] NOT NULL IDENTITY(1, 1),
[MgrID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubEvalID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentStatus] [nvarchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EvaluatorDailyEmailLog_CreatedByID] DEFAULT ((0)),
[CreatedByDt] [datetime] NULL CONSTRAINT [DF_EvaluatorDailyEmailLog_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EvaluatorDailyEmailLog_LastUpdatedByID] DEFAULT ((0)),
[LastUpdatedByDt] [datetime] NULL CONSTRAINT [DF_EvaluatorDailyEmailLog_LastUpdatedByDt] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EvaluatorDailyEmailLog] ADD CONSTRAINT [PK_EvaluatorDailyEmailLog] PRIMARY KEY CLUSTERED  ([DailyChangeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
