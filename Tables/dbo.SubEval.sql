CREATE TABLE [dbo].[SubEval]
(
[EvalID] [int] NOT NULL IDENTITY(1, 1),
[MgrID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EvalActive] [bit] NOT NULL CONSTRAINT [DF_BPSEval_Evaluators_EvalActive] DEFAULT ((1)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__SubEval__Created__54CB950F] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__SubEval__Created__55BFB948] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__SubEval__LastUpd__56B3DD81] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__SubEval__LastUpd__57A801BA] DEFAULT (getdate()),
[Is5StepProcess] [bit] NOT NULL CONSTRAINT [DF__SubEval__IsLicEv__3D89085B] DEFAULT ((1)),
[IsNon5StepProcess] [bit] NOT NULL CONSTRAINT [DF__SubEval__IsNonLi__768C7B8D] DEFAULT ((0)),
[IsEvalManager] [bit] NOT NULL CONSTRAINT [DF__SubEval__IsEvalM__3ACC9741] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SubEval] ADD CONSTRAINT [PK_BPSEval_Evaluators] PRIMARY KEY CLUSTERED  ([EvalID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SubEval] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_Evaluators_Employees] FOREIGN KEY ([EmplID]) REFERENCES [dbo].[Empl] ([EmplID])
GO
ALTER TABLE [dbo].[SubEval] WITH NOCHECK ADD CONSTRAINT [FK_SubEval_Empl] FOREIGN KEY ([MgrID]) REFERENCES [dbo].[Empl] ([EmplID])
GO
