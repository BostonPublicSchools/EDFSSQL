CREATE TABLE [dbo].[ObservationHeader]
(
[ObsvID] [int] NOT NULL IDENTITY(1, 1),
[PlanID] [int] NOT NULL,
[ObsvTypeID] [int] NOT NULL,
[ObsvDt] [datetime] NOT NULL,
[ObsvRelease] [bit] NOT NULL CONSTRAINT [DF_ObservationHeader_ObsvRelease] DEFAULT ((0)),
[ObsvReleaseDt] [datetime] NULL,
[ObsvStartTime] [datetime] NULL,
[ObsvEndTime] [datetime] NULL,
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_ObservationHeader_IsDeleted] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ObservationHeader_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_ObservationHeader_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ObservationHeader_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_ObservationHeader_LastUpdatedDt] DEFAULT (getdate()),
[IsEditEndDt] [datetime] NOT NULL CONSTRAINT [DF__Observati__IsEdi__2779CBAB] DEFAULT (dateadd(day,(5),getdate())),
[Comment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmplComment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmplIsEditEndDt] [datetime] NULL,
[ObsvSubject] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmplCommentDt] [datetime] NULL,
[IsEmplViewed] [bit] NULL CONSTRAINT [DF__Observati__IsEmp__6F8A7843] DEFAULT ((0)),
[EmplViewedDate] [datetime] NULL,
[IsFromIpad] [bit] NOT NULL CONSTRAINT [DF_ObservationHeader_IsFromIpad] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[ObservationHeaderInsertChangeLog] ON [dbo].[ObservationHeader]
AFTER INSERT
AS
BEGIN
	INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
	SELECT		   		  'ObservationHeader', i.ObsvID,  i.LastUpdatedByID, 'Observation date entered for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, '', i.ObsvDt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
					FROM
						inserted as i						
						JOIN EmplPlan ep on i.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						

	INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
	SELECT		   		  'ObservationHeader', i.ObsvID, i.LastUpdatedByID, 'Observation IsEditEndDt entered for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, '', i.IsEditEndDt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
					FROM
						inserted as i							
						JOIN EmplPlan ep on i.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						

	IF ((SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		WHERE
			i.ObsvStartTime IS NOT NULL) > 0)
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationHeader', i.ObsvID, i.LastUpdatedByID, 'Observation start time entered for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, '', i.ObsvStartTime, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN EmplPlan ep on i.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID							
	END
	
	IF ((SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		WHERE
			i.ObsvEndTime IS NOT NULL) > 0)
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationHeader', i.ObsvID, i.LastUpdatedByID, 'Observation end time entered for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, '', i.ObsvEndTime, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN EmplPlan ep on i.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID							
	END
							
	IF ((SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		WHERE
			i.ObsvReleaseDt IS NOT NULL) > 0)
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationDetail', i.ObsvID, i.LastUpdatedByID, 'Observation release date entered for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, '', i.ObsvReleaseDt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN EmplPlan ep on i.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID							
							
	END

	IF ((SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		WHERE
			i.Comment IS NOT NULL) > 0)
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationDetail', i.ObsvID, i.LastUpdatedByID, 'Observation comment entered for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, '', i.Comment, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN EmplPlan ep on i.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID							
							
	END
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[ObservationHeaderUpdChangeLog] ON [dbo].[ObservationHeader]
FOR UPDATE
AS
BEGIN
	IF (SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ObsvID = d.ObsvID
		WHERE
			NOT d.ObsvDt = i.ObsvDt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationHeader', i.ObsvID,  i.LastUpdatedByID, 'Observation date changed for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, d.ObsvDt, i.ObsvDt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
			FROM
				inserted as i
				JOIN deleted as d ON i.ObsvID = d.ObsvID
				JOIN EmplPlan ep on i.PlanID= ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID					
						
	END
	
	IF (SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ObsvID = d.ObsvID
		WHERE
			NOT d.IsEditEndDt = i.IsEditEndDt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationHeader', i.ObsvID, i.LastUpdatedByID, 'Observation IsEditEndDt changed for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, d.IsEditEndDt, i.IsEditEndDt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
				FROM
					inserted as i
				JOIN deleted as d ON i.ObsvID = d.ObsvID
				JOIN EmplPlan ep on i.PlanID= ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID									
						
	END

	IF (SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ObsvID = d.ObsvID
		WHERE
			NOT d.ObsvStartTime = i.ObsvStartTime) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationHeader', i.ObsvID, i.LastUpdatedByID, 'Observation start time changed for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, d.ObsvStartTime, i.ObsvStartTime, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
				FROM
					inserted as i
				JOIN deleted as d ON i.ObsvID = d.ObsvID
				JOIN EmplPlan ep on i.PlanID= ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID									
						
	END
	
	IF (SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ObsvID = d.ObsvID
		WHERE
			NOT d.ObsvStartTime = i.ObsvStartTime) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationHeader', i.ObsvID, i.LastUpdatedByID, 'Observation start time changed for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, d.ObsvStartTime, i.ObsvStartTime, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
				FROM
					inserted as i
				JOIN deleted as d ON i.ObsvID = d.ObsvID
				JOIN EmplPlan ep on i.PlanID= ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID									
						
	END		
	
	IF (SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ObsvID = d.ObsvID
		WHERE
			NOT d.ObsvEndTime = i.ObsvEndTime) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationHeader', i.ObsvID, i.LastUpdatedByID, 'Observation end time changed for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, d.ObsvEndTime, i.ObsvEndTime, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
				FROM
					inserted as i
				JOIN deleted as d ON i.ObsvID = d.ObsvID
				JOIN EmplPlan ep on i.PlanID= ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID									
						
	END		
	
	IF (SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ObsvID = d.ObsvID
		WHERE
			NOT d.ObsvReleaseDt = i.ObsvReleaseDt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationHeader', i.ObsvID, i.LastUpdatedByID, 'Observation release date changed for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, d.ObsvReleaseDt, i.ObsvReleaseDt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
				FROM
					inserted as i
				JOIN deleted as d ON i.ObsvID = d.ObsvID
				JOIN EmplPlan ep on i.PlanID= ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID									
						
	END		
	
	IF (SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ObsvID = d.ObsvID
		WHERE
			NOT d.ObsvRelease = i.ObsvRelease) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationHeader', i.ObsvID, i.LastUpdatedByID, 'Observation release changed for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, ISNULL(d.ObsvRelease, 0), i.ObsvRelease, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
				FROM
					inserted as i
				JOIN deleted as d ON i.ObsvID = d.ObsvID
				JOIN EmplPlan ep on i.PlanID= ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID									
						
	END		
	
	IF (SELECT 
			COUNT(i.ObsvID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ObsvID = d.ObsvID
		WHERE
			NOT d.Comment = i.Comment) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'ObservationHeader', i.ObsvID, i.LastUpdatedByID, 'Observation comment changed for ObsvID ' + CAST(i.ObsvID AS NVARCHAR),i.LastUpdatedDt, d.Comment, i.Comment, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
				FROM
					inserted as i
				JOIN deleted as d ON i.ObsvID = d.ObsvID
				JOIN EmplPlan ep on i.PlanID= ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID									
						
	END		
END

GO
ALTER TABLE [dbo].[ObservationHeader] ADD CONSTRAINT [PK_ObservationHeader] PRIMARY KEY CLUSTERED  ([ObsvID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ObservationHeader] ADD CONSTRAINT [FK_ObservationHeader_EmplPlan] FOREIGN KEY ([PlanID]) REFERENCES [dbo].[EmplPlan] ([PlanID])
GO
