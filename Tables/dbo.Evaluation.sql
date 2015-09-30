CREATE TABLE [dbo].[Evaluation]
(
[EvalID] [int] NOT NULL IDENTITY(1, 1),
[PlanID] [int] NOT NULL,
[EvalTypeID] [int] NOT NULL,
[EvalDt] [datetime] NOT NULL,
[EvaluatorsCmnt] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmplCmnt] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverallRatingID] [int] NULL,
[EvaluatorsSignature] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EvaluatorSignedDt] [datetime] NULL,
[EmplSignature] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmplSignedDt] [datetime] NULL,
[WitnessSignature] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WitnessSignDt] [datetime] NULL,
[IsSigned] [bit] NOT NULL CONSTRAINT [DF_Evaluation_IsSigned] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL,
[Rationale] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF__Evaluatio__IsDel__6EE06CCD] DEFAULT ((0)),
[EditEndDt] [datetime] NULL,
[pmfPlanID] [int] NULL,
[EvalRubricID] [int] NULL,
[EvalSignOffCount] [int] NOT NULL CONSTRAINT [DF__Evaluatio__EvalS__56DEC60A] DEFAULT ((0)),
[EvalPlanYear] [int] NULL CONSTRAINT [DF_Evaluation_PlanYear] DEFAULT ((1)),
[EvalManagerID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EvalSubEvalID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[EvaluationUpdChangeLog] ON [dbo].[Evaluation]
FOR UPDATE
AS
BEGIN
	IF (SELECT 
			COUNT(i.EvalID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvalID = d.EvalID
		WHERE
			NOT d.OverallRatingID = i.OverallRatingID or 
			(d.OverallRatingID is null or i.OverallRatingID is not null) or 
			(d.OverallRatingID is not null or i.OverallRatingID is null)) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'Evaluation', i.EvalID, i.LastUpdatedByID, 'OverallRatingID change for EvalID ' + CAST(i.EvalID AS NVARCHAR), i.LastUpdatedDt, 
								case when d.OverallRatingID IS null then '' else d.OverallRatingID end ,
								case when i.OverallRatingID is null then '' else i.OverallRatingID end, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.EvalID = d.EvalID
						JOIN EmplPlan ep on ep.PlanID = i.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
						
	END
	
	IF (SELECT 
			COUNT(i.EvalID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvalID = d.EvalID
		WHERE
			NOT d.EvaluatorsCmnt = i.EvaluatorsCmnt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'Evaluation', i.EvalID, i.LastUpdatedByID, 'EvaluatorsCmnt change for EvalID ' + CAST(i.EvalID AS NVARCHAR),i.LastUpdatedDt, d.EvaluatorsCmnt, i.EvaluatorsCmnt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.EvalID = d.EvalID
						JOIN EmplPlan ep on ep.PlanID = i.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END

	IF (SELECT 
			COUNT(i.EvalID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvalID = d.EvalID
		WHERE
			NOT d.EmplCmnt = i.EmplCmnt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'Evaluation', i.EvalID, i.LastUpdatedByID, 'EmplCmnt change for EvalID ' + CAST(i.EvalID AS NVARCHAR),i.LastUpdatedDt, d.EmplCmnt, i.EmplCmnt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.EvalID = d.EvalID
						JOIN EmplPlan ep on ep.PlanID = i.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END
		
	IF (SELECT 
			COUNT(i.EvalID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvalID = d.EvalID
		WHERE
			NOT d.Rationale = i.Rationale) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'Evaluation', i.EvalID, i.LastUpdatedByID, 'Rationale change for EvalID ' + CAST(i.EvalID AS NVARCHAR),i.LastUpdatedDt, d.Rationale, i.Rationale, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.EvalID = d.EvalID
						JOIN EmplPlan ep on ep.PlanID = i.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END
	
	IF (SELECT 
			COUNT(i.EvalID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvalID = d.EvalID
		WHERE
			NOT d.EvalTypeID = i.EvalTypeID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'Evaluation', i.EvalID, i.LastUpdatedByID, 'Evaluation type was change for EvalID ' + CAST(i.EvalID AS NVARCHAR),i.LastUpdatedDt, d.EvalTypeID, i.EvalTypeID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.EvalID = d.EvalID
						JOIN EmplPlan ep on ep.PlanID = i.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END		

	IF (SELECT 
			COUNT(i.EvalID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvalID = d.EvalID
		WHERE
			NOT d.EditEndDt = i.EditEndDt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'Evaluation', i.EvalID, i.LastUpdatedByID, 'EditEndDt was changed for EvalID ' + CAST(i.EvalID AS NVARCHAR),i.LastUpdatedDt, 
								 (case when d.EditEndDt is null then '' else CONVERT(nvarchar,d.EditEndDt) end)  --d.EditEndDt
								,  (case when i.EditEndDt is null then '' else CONVERT(nvarchar,i.EditEndDt) end) --i.EditEndDt
								, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.EvalID = d.EvalID											
						JOIN EmplPlan ep on ep.PlanID = i.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID
	END			
END
GO
ALTER TABLE [dbo].[Evaluation] ADD CONSTRAINT [PK_Evaluation] PRIMARY KEY CLUSTERED  ([EvalID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PlanID_EvalTypeId_IsDeleted_EvalautorSignedDt] ON [dbo].[Evaluation] ([PlanID], [EvalTypeID], [IsDeleted], [EvaluatorSignedDt]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Evaluation] WITH NOCHECK ADD CONSTRAINT [FK_Evaluation_CodeLookUp] FOREIGN KEY ([EvalTypeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[Evaluation] WITH NOCHECK ADD CONSTRAINT [FK_Evaluation_CodeLookUp1] FOREIGN KEY ([OverallRatingID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[Evaluation] WITH NOCHECK ADD CONSTRAINT [FK_Evaluation_EmplPlan] FOREIGN KEY ([PlanID]) REFERENCES [dbo].[EmplPlan] ([PlanID])
GO
