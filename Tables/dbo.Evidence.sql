CREATE TABLE [dbo].[Evidence]
(
[EvidenceID] [int] NOT NULL IDENTITY(1, 1),
[FileName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileExt] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileSize] [bigint] NOT NULL,
[IsDeleted] [bit] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Evidence_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_Evidence_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Evidence_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_Evidence_LastUpdatedDt] DEFAULT (getdate()),
[Description] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rationale] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsEvidenceViewed] [bit] NULL CONSTRAINT [DF__Evidence__IsEvid__67E9567B] DEFAULT ((0)),
[EvidenceViewedDt] [datetime] NULL,
[EvidenceViewedBy] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastCommentViewDt] [datetime] NOT NULL CONSTRAINT [DF__Evidence__LastCo__04C58C4B] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER  [dbo].[EvidenceInsertChangeLog]
   ON  [dbo].[Evidence] 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
	SELECT		   		  'Evidence', i.EvidenceID,  i.LastUpdatedByID, 'Inserted description ',i.LastUpdatedDt, '', i.Description, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
					FROM
						inserted as i
						JOIN EmplPlanEvidence ev on ev.EvidenceID = i.EvidenceID
						JOIN EmplPlan ep on ev.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID							
						
	INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
	SELECT		   		  'Evidence', i.EvidenceID,  i.LastUpdatedByID, 'Inserted rationale ',i.LastUpdatedDt, '', i.Rationale, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
					FROM
						inserted as i		
						JOIN EmplPlanEvidence ev on ev.EvidenceID = i.EvidenceID
						JOIN EmplPlan ep on ev.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID	
												
	INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
	SELECT		   		  'Evidence', i.EvidenceID,  i.LastUpdatedByID, 'Attached file name is ', '',  CAST(i.FileName +' '+ i.FileExt AS NVARCHAR) ,GETDATE(), i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
					FROM
						inserted as i						
						JOIN EmplPlanEvidence ev on ev.EvidenceID = i.EvidenceID
						JOIN EmplPlan ep on ev.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID											

END




GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER  [dbo].[EvidenceUpdateChangeLog]
   ON  [dbo].[Evidence] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	---description update
	IF (SELECT 
			COUNT(i.EvidenceID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvidenceID= d.EvidenceID
		WHERE
			NOT d.Description = i.Description) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'Evidence', i.EvidenceID, i.LastUpdatedByID, 'Description changed for ' + CAST(i.EvidenceID AS NVARCHAR),i.LastUpdatedDt, d.Description, i.Description, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
			FROM
				inserted as i
				JOIN deleted as d ON i.EvidenceID = d.EvidenceID
				JOIN EmplPlanEvidence ev on ev.EvidenceID = i.EvidenceID
				JOIN EmplPlan ep on ev.PlanID = ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID						
	END				
					
	--rationale update					
	IF (SELECT 
			COUNT(i.EvidenceID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvidenceID= d.EvidenceID
		WHERE
			NOT d.Rationale = i.Rationale) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'Evidence', i.EvidenceID, i.LastUpdatedByID, 'Rationale changed for ' + CAST(i.EvidenceID AS NVARCHAR),i.LastUpdatedDt, d.Rationale, i.Rationale, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
			FROM
				inserted as i
				JOIN deleted as d ON i.EvidenceID = d.EvidenceID
				JOIN EmplPlanEvidence ev on ev.EvidenceID = i.EvidenceID
				JOIN EmplPlan ep on ev.PlanID = ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID					
						
	END		
	
	---Filename changed			
	IF (SELECT 
			COUNT(i.EvidenceID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvidenceID= d.EvidenceID
		WHERE
			NOT d.FileName = i.FileName) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT		   		  'Evidence', i.EvidenceID, i.LastUpdatedByID, 'Filename changed for ' + CAST(i.EvidenceID AS NVARCHAR),i.LastUpdatedDt, d.FileName, i.FileName, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
			FROM
				inserted as i
				JOIN deleted as d ON i.EvidenceID = d.EvidenceID
				JOIN EmplPlanEvidence ev on ev.EvidenceID = i.EvidenceID
				JOIN EmplPlan ep on ev.PlanID = ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID					
						
	END	
	
	--isDeleted 
	IF (SELECT 
			COUNT(i.EvidenceID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvidenceID= d.EvidenceID
		WHERE
			NOT d.IsDeleted = i.IsDeleted
			And i.IsDeleted=1) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT	distinct	   		  'Evidence', i.EvidenceID, i.LastUpdatedByID, 'Evidence ' + CAST(i.EvidenceID AS NVARCHAR)+ ' deleted.',i.LastUpdatedDt, d.FileName, i.FileName, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
			FROM
				inserted as i
				JOIN deleted as d ON i.EvidenceID = d.EvidenceID
				JOIN EmplPlanEvidence ev on ev.EvidenceID = i.EvidenceID
				JOIN EmplPlan ep on ev.PlanID = ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID					
						
	END	
	
	--For UnDeleted	
	IF (SELECT 
			COUNT(i.EvidenceID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EvidenceID= d.EvidenceID
		WHERE
			NOT d.IsDeleted = i.IsDeleted
			And i.IsDeleted=0) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT	distinct	   		  'Evidence', i.EvidenceID, i.LastUpdatedByID, 'Evidence ' + CAST(i.EvidenceID AS NVARCHAR)+ ' undeleted.',i.LastUpdatedDt, d.FileName, i.FileName, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
			FROM
				inserted as i
				JOIN deleted as d ON i.EvidenceID = d.EvidenceID
				JOIN EmplPlanEvidence ev on ev.EvidenceID = i.EvidenceID
				JOIN EmplPlan ep on ev.PlanID = ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID					
						
	END											

END

GO
ALTER TABLE [dbo].[Evidence] ADD CONSTRAINT [PK_Evidence] PRIMARY KEY CLUSTERED  ([EvidenceID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
