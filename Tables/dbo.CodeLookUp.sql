CREATE TABLE [dbo].[CodeLookUp]
(
[CodeID] [int] NOT NULL IDENTITY(1, 1),
[CodeType] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Code] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeText] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeSortOrder] [int] NOT NULL,
[CodeActive] [bit] NOT NULL CONSTRAINT [DF_BPSEval_Codes_CodeActive] DEFAULT ((1)),
[CodeSubText] [varchar] (6600) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CodeLookU__Creat__32767D0B] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__CodeLookU__Creat__336AA144] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CodeLookU__LastU__345EC57D] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__CodeLookU__LastU__3552E9B6] DEFAULT (getdate()),
[IsManaged] [bit] NOT NULL CONSTRAINT [Code_IsManaged_Default] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeLookUp] ADD CONSTRAINT [PK_BPSEval_Codes] PRIMARY KEY CLUSTERED  ([CodeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CodeLookUp_CodeText] ON [dbo].[CodeLookUp] ([CodeText]) ON [PRIMARY]
GO
