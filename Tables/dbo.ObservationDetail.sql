CREATE TABLE [dbo].[ObservationDetail]
(
[ObsvDID] [int] NOT NULL IDENTITY(1, 1),
[ObsvID] [int] NOT NULL,
[IndicatorID] [int] NOT NULL,
[ObsvDEvidence] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObsvDFeedBack] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ObservationDetail_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_ObservationDetail_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ObservationDetail_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_ObservationDetail_LastUpdatedDt] DEFAULT (getdate()),
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_ObservationDetail_IsDeleted] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[ObservationDetailInsertChangeLog] ON [dbo].[ObservationDetail]
AFTER INSERT
AS
BEGIN
	IF ((SELECT 
			COUNT(i.ObsvDID)
		FROM
			inserted as i
		WHERE
			i.ObsvDEvidence IS NOT NULL) > 0)
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationDetail', i.ObsvDID, i.LastUpdatedByID, 'Observation evidence entered for ObsvDID ' + CAST(i.ObsvDID AS NVARCHAR),i.LastUpdatedDt, '', i.ObsvDEvidence, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN ObservationHeader oh on oh.ObsvID = i.ObsvID
						JOIN EmplPlan ep on oh.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID							
	END

	IF ((SELECT 
			COUNT(i.ObsvDID)
		FROM
			inserted as i
		WHERE
			i.ObsvDFeedBack IS NOT NULL) > 0)
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationDetail', i.ObsvDID, i.LastUpdatedByID, 'Observation feedback entered for ObsvDID ' + CAST(i.ObsvDID AS NVARCHAR),i.LastUpdatedDt, '', i.ObsvDFeedBack, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN ObservationHeader oh on oh.ObsvID = i.ObsvID
						JOIN EmplPlan ep on oh.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID							
							
	END	

END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ObservationDetailUpdChangeLog] ON [dbo].[ObservationDetail]
FOR UPDATE
AS
BEGIN
	IF (SELECT 
			COUNT(i.ObsvDID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ObsvDID = d.ObsvDID
		WHERE
			NOT d.ObsvDEvidence = i.ObsvDEvidence) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationDetail', i.ObsvDID, i.LastUpdatedByID, 'Observation evidence changed for ObsvDID ' + CAST(i.ObsvDID AS NVARCHAR),i.LastUpdatedDt, d.ObsvDEvidence, i.ObsvDEvidence, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
			FROM
				inserted as i
				JOIN deleted as d ON i.ObsvID = d.ObsvID
				JOIN ObservationHeader oh on oh.ObsvID = i.ObsvID
				JOIN EmplPlan ep on oh.PlanID = ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID				
						
	END
	
	IF (SELECT 
			COUNT(i.ObsvDID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ObsvDID = d.ObsvDID
		WHERE
			NOT d.ObsvDFeedBack = i.ObsvDFeedBack) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationDetail', i.ObsvDID, i.LastUpdatedByID, 'Observation feedback changed for ObsvDID ' + CAST(i.ObsvDID AS NVARCHAR),i.LastUpdatedDt, D.ObsvDFeedBack, i.ObsvDFeedBack, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
			FROM
				inserted as i
				JOIN deleted as d ON i.ObsvID = d.ObsvID
				JOIN ObservationHeader oh on oh.ObsvID = i.ObsvID
				JOIN EmplPlan ep on oh.PlanID = ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID				
						
	END	
END
GO
ALTER TABLE [dbo].[ObservationDetail] ADD CONSTRAINT [PK_ObservationDetail] PRIMARY KEY CLUSTERED  ([ObsvDID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ObservationDetail] ADD CONSTRAINT [FK_ObservationDetail_ObservationHeader] FOREIGN KEY ([ObsvID]) REFERENCES [dbo].[ObservationHeader] ([ObsvID])
GO
