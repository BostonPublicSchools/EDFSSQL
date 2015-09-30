CREATE TABLE [dbo].[EvaluationStandardRating]
(
[EvalStdRatingID] [int] NOT NULL IDENTITY(1, 1),
[EvalID] [int] NOT NULL,
[StandardID] [int] NOT NULL,
[RatingID] [int] NOT NULL,
[Rationale] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[EvaluationStandardRatingUpdChangeLog] ON [dbo].[EvaluationStandardRating]
FOR UPDATE
AS
BEGIN
	IF (SELECT 
			COUNT(i.EvalStdRatingID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvalStdRatingID = d.EvalStdRatingID
		WHERE
			NOT d.RatingID = i.RatingID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'EvaluationStandardRating', i.EvalStdRatingID, i.LastUpdatedByID, 'EvalStd rating change for EvalStdRatingID ' + CAST(i.EvalStdRatingID AS NVARCHAR), i.LastUpdatedDt, d.RatingID, i.RatingID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.EvalStdRatingID = d.EvalStdRatingID
						JOIN Evaluation as e ON e.EvalID = i.EvalID
						JOIN EmplPlan ep on ep.PlanID = e.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END
	
	IF (SELECT 
			COUNT(i.EvalStdRatingID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvalStdRatingID = d.EvalStdRatingID
		WHERE
			NOT d.Rationale = i.Rationale) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'EvaluationStandardRating', i.EvalStdRatingID, i.LastUpdatedByID, 'EvalStd rationale change for EvalStdRatingID ' + CAST(i.EvalStdRatingID AS NVARCHAR),i.LastUpdatedDt, d.Rationale, i.Rationale, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.EvalStdRatingID = d.EvalStdRatingID
						JOIN Evaluation as e ON e.EvalID = i.EvalID
						JOIN EmplPlan ep on ep.PlanID = e.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
						
	END
	
END
GO
ALTER TABLE [dbo].[EvaluationStandardRating] ADD CONSTRAINT [PK_EvaluationStandardRating] PRIMARY KEY CLUSTERED  ([EvalStdRatingID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [EvaluationStandardRating_EvalID] ON [dbo].[EvaluationStandardRating] ([EvalID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EvaluationStandardRating] WITH NOCHECK ADD CONSTRAINT [FK_EvaluationStandardRating_Evaluation] FOREIGN KEY ([EvalID]) REFERENCES [dbo].[Evaluation] ([EvalID])
GO
ALTER TABLE [dbo].[EvaluationStandardRating] WITH NOCHECK ADD CONSTRAINT [FK_EvaluationStandardRating_RubricStandard] FOREIGN KEY ([StandardID]) REFERENCES [dbo].[RubricStandard] ([StandardID])
GO
