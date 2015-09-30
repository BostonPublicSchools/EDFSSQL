CREATE TABLE [dbo].[PlanSelfAsmt]
(
[SelfAsmtID] [int] NOT NULL IDENTITY(1, 1),
[PlanID] [int] NOT NULL,
[StandardID] [int] NOT NULL,
[IndicatorID] [int] NOT NULL,
[SelfAsmtTypeID] [int] NOT NULL,
[SelfAsmtText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_PlanSelfAsmt_IsDeleted] DEFAULT ('0'),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PlanSelfAsmt_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_PlanSelfAsmt_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PlanSelfAsmt_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_PlanSelfAsmt_LastUpdatedDt] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[PlamSelfAsmtUpdChangeLog] ON [dbo].[PlanSelfAsmt]
FOR UPDATE
AS
BEGIN
	IF (SELECT 
			COUNT(i.SelfAsmtID)
		FROM
			inserted as i
		JOIN deleted as d ON i.SelfAsmtID = d.SelfAsmtID
		WHERE
			NOT d.StandardID = i.StandardID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
						SELECT 
								'PlanSelfAsmt', i.SelfAsmtID, i.LastUpdatedByID, 'Self Asmt standard change for SelfAsmtID ' + CAST(i.SelfAsmtID AS NVARCHAR),i.LastUpdatedDt, d.StandardID, i.StandardID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE()
						FROM
							inserted as i
						JOIN deleted as d ON i.SelfAsmtID = d.SelfAsmtID
						
	END

	IF (SELECT 
			COUNT(i.SelfAsmtID)
		FROM
			inserted as i
		JOIN deleted as d ON i.SelfAsmtID = d.SelfAsmtID
		WHERE
			NOT d.IndicatorID = i.IndicatorID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
						SELECT 
								'PlanSelfAsmt', i.SelfAsmtID, i.LastUpdatedByID, 'Self Asmt indicator or element change for SelfAsmtID ' + CAST(i.SelfAsmtID AS NVARCHAR),i.LastUpdatedDt, d.IndicatorID, i.IndicatorID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE()
						FROM
							inserted as i
						JOIN deleted as d ON i.SelfAsmtID = d.SelfAsmtID
						
	END
		
	IF (SELECT 
			COUNT(i.SelfAsmtID)
		FROM
			inserted as i
		JOIN deleted as d ON i.SelfAsmtID = d.SelfAsmtID
		WHERE
			NOT d.SelfAsmtText = i.SelfAsmtText) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName,  IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
						SELECT 
								'PlanSelfAsmt', i.SelfAsmtID, i.LastUpdatedByID, 'Self Asmt text change for SelfAsmtID ' + CAST(i.SelfAsmtID AS NVARCHAR),i.LastUpdatedDt, d.SelfAsmtText, i.SelfAsmtText, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE()
						FROM
							inserted as i
						JOIN deleted as d ON i.SelfAsmtID = d.SelfAsmtID
						
	END
	
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[PlanSelfAsmtInsertChangeLog] ON [dbo].[PlanSelfAsmt]
AFTER INSERT
AS
BEGIN
	INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
	SELECT		   		  'PlanSelfAsmt', i.SelfAsmtID, i.LastUpdatedByID, 'Self Assessment text entered for SelfAsmtID ' + CAST(i.SelfAsmtID AS NVARCHAR),i.LastUpdatedDt, '', i.SelfAsmtText, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
					FROM
						inserted as i
						JOIN EmplPlan ep on ep.PlanID = i.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID							
							
END

GO
ALTER TABLE [dbo].[PlanSelfAsmt] ADD CONSTRAINT [PK_PlanSelfAsmt] PRIMARY KEY CLUSTERED  ([SelfAsmtID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlanSelfAsmt] ADD CONSTRAINT [FK_PlanSelfAsmt_RubricIndicator] FOREIGN KEY ([IndicatorID]) REFERENCES [dbo].[RubricIndicator] ([IndicatorID])
GO
ALTER TABLE [dbo].[PlanSelfAsmt] ADD CONSTRAINT [FK_PlanSelfAsmt_EmplPlan] FOREIGN KEY ([PlanID]) REFERENCES [dbo].[EmplPlan] ([PlanID])
GO
ALTER TABLE [dbo].[PlanSelfAsmt] ADD CONSTRAINT [FK_PlanSelfAsmt_RubricStandard] FOREIGN KEY ([StandardID]) REFERENCES [dbo].[RubricStandard] ([StandardID])
GO
