CREATE TABLE [dbo].[EmplEmplJob]
(
[EmplJobID] [int] NOT NULL IDENTITY(1, 1),
[JobCode] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmplRcdNo] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MgrID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__EmplEmplJ__MgrID__1C873BEC] DEFAULT ('000000'),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__EmplEmplJ__Creat__1E6F845E] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__EmplEmplJ__Creat__1F63A897] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__EmplEmplJ__LastU__2057CCD0] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__EmplEmplJ__LastU__214BF109] DEFAULT (getdate()),
[DeptID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PositionNo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDt] [datetime] NULL,
[EmplClass] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF__EmplEmplJ__IsAct__24485945] DEFAULT ((1)),
[FTE] [numeric] (8, 6) NOT NULL CONSTRAINT [DF__EmplEmplJob__FTE__2F6FF32E] DEFAULT ((0.0)),
[RubricID] [int] NOT NULL CONSTRAINT [DF__EmplEmplJ__Rubri__30641767] DEFAULT ((1)),
[RubricOverrideReason] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobEntryDate] [date] NULL,
[SalaryAdministrationPlan] [nchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalaryGrade] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Step] [int] NULL,
[StepEntryDate] [date] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 05/29/2013
-- Description:	Track changes on rubric ID
-- =============================================
CREATE TRIGGER [dbo].[EmplEmplJobUpdateChange]
   ON  [dbo].[EmplEmplJob] 
   FOR UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	IF (SELECT 
			COUNT(i.EmplJobID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EmplJobID = d.EmplJobID
		WHERE
			NOT d.RubricID = i.RubricID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'EmplEmplJob', i.RubricID, i.LastUpdatedByID, 'Rubric changed for EmplJobID ' + CAST(i.EmplJobID AS NVARCHAR), i.LastUpdatedDt, d.RubricID, i.RubricID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),i.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.EmplJobID = d.EmplJobID
						
	END

END
GO
ALTER TABLE [dbo].[EmplEmplJob] ADD CONSTRAINT [PK_BPSEval_EmployeeJobs] PRIMARY KEY CLUSTERED  ([EmplJobID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EmplEmplJob_JobCodeEmplIDMgrID] ON [dbo].[EmplEmplJob] ([EmplID], [JobCode], [MgrID], [DeptID], [EmplRcdNo], [FTE]) WHERE ([IsActive]=(1)) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IsActive_EmplJoBID_EmplRcdNo_DeptID_PostionNo_RubricID] ON [dbo].[EmplEmplJob] ([IsActive], [EmplJobID], [JobCode], [EmplID], [EmplRcdNo], [DeptID], [PositionNo], [RubricID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RubricID_EmplJobID_EmplID_MgrId_DeptID] ON [dbo].[EmplEmplJob] ([RubricID], [EmplJobID], [EmplID], [MgrID], [DeptID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplEmplJob] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_EmployeeJobs_BPSEval_Employees] FOREIGN KEY ([EmplID]) REFERENCES [dbo].[Empl] ([EmplID])
GO
ALTER TABLE [dbo].[EmplEmplJob] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_EmployeeJobs_BPSEval_Jobs] FOREIGN KEY ([JobCode]) REFERENCES [dbo].[EmplJob] ([JobCode])
GO
ALTER TABLE [dbo].[EmplEmplJob] WITH NOCHECK ADD CONSTRAINT [fk_RubricHdr] FOREIGN KEY ([RubricID]) REFERENCES [dbo].[RubricHdr] ([RubricID])
GO
