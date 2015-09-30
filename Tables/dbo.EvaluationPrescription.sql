CREATE TABLE [dbo].[EvaluationPrescription]
(
[PrescriptionId] [int] NOT NULL IDENTITY(1, 1),
[EvalID] [int] NOT NULL,
[IndicatorID] [int] NOT NULL,
[ProblemStmt] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EvidenceStmt] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrscriptionStmt] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL,
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF__Evaluatio__IsDel__6FD49106] DEFAULT ((0)),
[AssmtID] [int] NULL CONSTRAINT [DF__Evaluatio__Assmt__7C3A67EB] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[EvaluationPrescriptionUpdChangeLog] ON [dbo].[EvaluationPrescription]
FOR UPDATE
AS
BEGIN
	IF (SELECT 
			COUNT(i.PrescriptionId)
		FROM
			inserted as i
		JOIN deleted as d ON i.PrescriptionId = d.PrescriptionId
		WHERE
			NOT d.ProblemStmt = i.ProblemStmt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'EvaluationPrescription', i.PrescriptionId, i.LastUpdatedByID, 'ProblemStmt change for PrescriptionId ' + CAST(i.PrescriptionId AS NVARCHAR),i.LastUpdatedDt, d.ProblemStmt, i.ProblemStmt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PrescriptionId = d.PrescriptionId
						JOIN Evaluation as e ON e.EvalID = i.EvalID
						JOIN EmplPlan ep on ep.PlanID = e.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END

	IF (SELECT 
			COUNT(i.PrescriptionId)
		FROM
			inserted as i
		JOIN deleted as d ON i.PrescriptionId = d.PrescriptionId
		WHERE
			NOT d.EvidenceStmt = i.EvidenceStmt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'EvaluationPrescription', i.PrescriptionId, i.LastUpdatedByID, 'EvidenceStmt change for PrescriptionId ' + CAST(i.PrescriptionId AS NVARCHAR),i.LastUpdatedDt, d.EvidenceStmt, i.EvidenceStmt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PrescriptionId = d.PrescriptionId
						JOIN Evaluation as e ON e.EvalID = i.EvalID
						JOIN EmplPlan ep on ep.PlanID = e.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END

	IF (SELECT 
			COUNT(i.PrescriptionId)
		FROM
			inserted as i
		JOIN deleted as d ON i.PrescriptionId = d.PrescriptionId
		WHERE
			NOT d.PrscriptionStmt = i.PrscriptionStmt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'EvaluationPrescription', i.PrescriptionId, i.LastUpdatedByID, 'PrscriptionStmt change for PrescriptionId ' + CAST(i.PrescriptionId AS NVARCHAR),i.LastUpdatedDt, d.PrscriptionStmt, i.PrscriptionStmt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PrescriptionId = d.PrescriptionId
						JOIN Evaluation as e ON e.EvalID = i.EvalID
						JOIN EmplPlan ep on ep.PlanID = e.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID								
	END
	
	
END
GO
ALTER TABLE [dbo].[EvaluationPrescription] ADD CONSTRAINT [PK_EvaluationPrescription] PRIMARY KEY CLUSTERED  ([PrescriptionId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EvaluationPrescription] WITH NOCHECK ADD CONSTRAINT [FK_EvaluationPrescription_Evaluation] FOREIGN KEY ([EvalID]) REFERENCES [dbo].[Evaluation] ([EvalID])
GO
ALTER TABLE [dbo].[EvaluationPrescription] WITH NOCHECK ADD CONSTRAINT [FK_EvaluationPrescription_RubricIndicator] FOREIGN KEY ([IndicatorID]) REFERENCES [dbo].[RubricIndicator] ([IndicatorID])
GO
