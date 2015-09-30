CREATE TABLE [dbo].[EmplPlanEvidence]
(
[PlanEvidenceID] [int] NOT NULL IDENTITY(1, 1),
[EvidenceID] [int] NOT NULL,
[PlanID] [int] NOT NULL,
[EvidenceTypeID] [int] NOT NULL,
[ForeignID] [int] NOT NULL,
[IsDeleted] [bit] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplPlanEvidence_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_EmplPlanEvidence_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplPlanEvidence_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_EmplPlanEvidence_LastUpdatedDt] DEFAULT (getdate())
) ON [PRIMARY]
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
CREATE TRIGGER  [dbo].[EmplPlanEvidenceChangeLog]
   ON  [dbo].[EmplPlanEvidence] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	---when evidencetypeID is changed
	IF (SELECT 
			COUNT(i.EvidenceID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanEvidenceID= d.PlanEvidenceID
		WHERE 
			NOT d.IsDeleted = i.IsDeleted
			AND i.IsDeleted=1) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
		SELECT	distinct   		  'EmplPlanEvidence', i.PlanEvidenceID, i.LastUpdatedByID, 'Deleted evidence tag(s) for plan ' + CAST(i.PlanID AS NVARCHAR) +'- EvidenceID '++ CAST(i.EvidenceID AS NVARCHAR)  ,i.LastUpdatedDt, d.IsDeleted, i.IsDeleted, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
			FROM
				inserted as i
				JOIN deleted as d ON i.EvidenceID = d.EvidenceID
				JOIN EmplPlan ep on d.PlanID = ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID				
						
	END				
	
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
CREATE TRIGGER  [dbo].[EmplPlanEvidenceInsertChangeLog]
   ON  [dbo].[EmplPlanEvidence] 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET NOCOUNT ON;
	INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
	SELECT	'EmplPlanEvidence', i.PlanEvidenceID,  i.LastUpdatedByID, 'Evidence '+ CAST(i.EvidenceID as nvarchar)  +' Inserted for the plan ', i.LastUpdatedDt, '', i.PlanID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
					FROM
						inserted as i				
				JOIN EmplPlan ep on i.PlanID = ep.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID							
						
	INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
	SELECT	'EmplPlanEvidence', i.PlanEvidenceID,  i.LastUpdatedByID, 'Inserted EvidenceTypeId for the evidence'+ CAST(i.EvidenceID as nvarchar),i.LastUpdatedDt, '', CAST(cd.CodeText AS NVARCHAR), i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
					FROM
						inserted as i
						Join CodeLookUp cd on cd.CodeID = i.EvidenceTypeID
						JOIN EmplPlan ep on i.PlanID = ep.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID
											
						
 --   -- Insert statements for trigger here

END





GO
ALTER TABLE [dbo].[EmplPlanEvidence] ADD CONSTRAINT [PK_EmplPlanEvidence] PRIMARY KEY CLUSTERED  ([PlanEvidenceID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EmplPlanEvidence_EvidenceID] ON [dbo].[EmplPlanEvidence] ([EvidenceID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EmplPlanEvidence_EvidenceTypeID] ON [dbo].[EmplPlanEvidence] ([EvidenceTypeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EmplPlanEvidence_ForeignID] ON [dbo].[EmplPlanEvidence] ([ForeignID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PlanID_IsDeleted_EvidenceID] ON [dbo].[EmplPlanEvidence] ([PlanID], [IsDeleted], [EvidenceID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplPlanEvidence] ADD CONSTRAINT [FK_EmplPlanEvidence_Evidence] FOREIGN KEY ([EvidenceID]) REFERENCES [dbo].[Evidence] ([EvidenceID])
GO
ALTER TABLE [dbo].[EmplPlanEvidence] ADD CONSTRAINT [FK_EmplPlanEvidence_CodeLookUp] FOREIGN KEY ([EvidenceTypeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[EmplPlanEvidence] ADD CONSTRAINT [FK_EmplPlanEvidence_EmplPlan] FOREIGN KEY ([PlanID]) REFERENCES [dbo].[EmplPlan] ([PlanID])
GO
