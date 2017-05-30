CREATE TABLE [dbo].[EmplPlan]
(
[PlanID] [int] NOT NULL IDENTITY(1, 1),
[PlanYear] [int] NOT NULL CONSTRAINT [DF_BPSEval_Plan_PlanYear] DEFAULT ((1)),
[PlanTypeID] [int] NOT NULL,
[PlanStartDt] [datetime] NULL,
[PlanSchedEndDt] [datetime] NULL,
[PlanEvalSign] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanEmplSign] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanEvalSignDt] [datetime] NULL,
[PlanEmplSignDt] [datetime] NULL,
[PlanActive] [bit] NOT NULL CONSTRAINT [DF_BPSEval_Plan_PlanActive] DEFAULT ((1)),
[PlanEditLock] [bit] NOT NULL CONSTRAINT [DF_BPSEval_Plan_PlanEditLock] DEFAULT ((0)),
[EmplJobID] [int] NOT NULL CONSTRAINT [DF__EmplPlan__EmplJo__2610A626] DEFAULT ((0)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__EmplPlan__Create__2704CA5F] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__EmplPlan__Create__27F8EE98] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__EmplPlan__LastUp__28ED12D1] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__EmplPlan__LastUp__29E1370A] DEFAULT (getdate()),
[GoalStatusID] [int] NULL,
[GoalStatusDt] [datetime] NULL,
[IsSigned] [bit] NOT NULL CONSTRAINT [DF_EmplPlan_IsSigned] DEFAULT ((0)),
[Signature] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateSigned] [datetime] NULL,
[IsSignedAsmt] [bit] NOT NULL CONSTRAINT [DF_EmplPlan_IsSignedAsmt1] DEFAULT ((0)),
[SignatureAsmt] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateSignedAsmt] [datetime] NULL,
[Duration] [int] NOT NULL CONSTRAINT [DF__EmplPlan__Durati__041093DD] DEFAULT ((0)),
[SubEvalID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__EmplPlan__SubEva__253C7D7E] DEFAULT ('000000'),
[SelfAsmtStrength] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SelfAsmtWeakness] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrescriptEvalID] [int] NULL,
[HasPrescript] [bit] NOT NULL CONSTRAINT [DF__EmplPlan__HasPre__4A38F803] DEFAULT ((0)),
[ActnStepStatusID] [int] NULL,
[ActnStepDt] [datetime] NULL,
[IsSignedActnStep] [bit] NOT NULL CONSTRAINT [DF_EmplPlan_IsSignedActnStep] DEFAULT ((0)),
[SignatureActnStep] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateSignedActnStep] [datetime] NULL,
[NeedToEnd] [bit] NOT NULL CONSTRAINT [DF_EmplPlan_NeedToEnd] DEFAULT ((0)),
[PlanActEndDt] [datetime] NULL,
[PlanEndReasonID] [int] NULL,
[PlanStartEvalDate] [datetime] NULL,
[RubricID] [int] NULL,
[IsMultiYearPlan] [bit] NULL,
[MultiYearGoalStatusID] [int] NULL,
[MultiYearGoalStatusDt] [datetime] NULL,
[MultiYearActnStepStatusID] [int] NULL,
[MultiYearActnStepDt] [datetime] NULL,
[PrevPlanPrescptEvalID] [int] NULL,
[FormativeStartDt] [date] NULL,
[FormativeEndDt] [date] NULL,
[AnticipatedEvalWeek] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanManagerID] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoalFirstSubmitDt] [datetime] NULL,
[IsInvalid] [int] NOT NULL CONSTRAINT [DF__EmplPlan__IsInva__496FBC53] DEFAULT ((0)),
[InvalidNote] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[EmailNotification] ON [dbo].[EmplPlan]
FOR UPDATE
AS
BEGIN

set nocount on;

INSERT INTO EmailUpdate
select EP.PlanID, EP.PlanSchedEndDt, COALESCE(DATEDIFF(day, EP.PlanStartDt, EP.PlanSchedEndDt),0) as Duration, EP.LastUpdatedByID, EEJ.EmplID + '@boston.k12.ma.us' as WhoIsRecevinganEmail, E.NameFirst + ' ' + E.NameLast + ' has created a new evaluation plan for you. Your next step is to develop and submit goals.  Let your evaluator know if you need any assistance.   Log in to the Employee Development & Feedback System at https://eval.mybps.org/evals/' as EmailMessage
from EmplPlan EP (nolock)
join EmplEmplJob EEJ (nolock)
on EP.EmplJobID = EEJ.EmplJobID
JOIN Empl E (nolock)
on E.EmplID = EP.LastUpdatedByID
join inserted i 
on i.PlanId = Ep.PlanID
where EP.PlanActive = 1 and
EEJ.EmplID IN (select distinct DI.EmplID from DirectedImprovementEmpl DI (nolock))


declare @PlanEndDt datetime
declare @Duration int
declare @Receiver varchar(200)
declare @Message varchar(1000)
declare @nSQL varchar(8000)

select @PlanEndDt = Eu.PlanEndDt, @Duration = Eu.Duration, @Receiver = WhoIsRecevinganEmail, @Message = EmailMessage 
from EmailUpdate Eu 
join inserted i 
on i.PlanId = Eu.PlanID 

if (@PlanEndDt is null OR @PlanEndDt = '') and @Duration > 0
BEGIN
	
set @nSQL  = '  EXEC msdb.dbo.sp_send_dbmail
				@profile_name = ''DBA'',
				@recipients = '''+@Receiver+''',
				@body = '''+@Message+''',
				@subject = ''New Evaluation Plan Tigger'''
--print @nSQL
exec (@nSQL)
END

if @PlanEndDt is not null and @Duration = 0
BEGIN
	set @nSQL  = '  EXEC msdb.dbo.sp_send_dbmail
					@profile_name = ''DBA'',
					@recipients = '''+@Receiver+''',
					@body = '''+@Message+''',
					@subject = ''New Evaluation Plan Trigger'''
--print @nSQL
exec (@nSQL)
END


delete E
from EmailUpdate E (nolock)
join inserted i  
on E.PlanID = i.PlanID

END




GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[EmplPlanUpdateChangelog] ON [dbo].[EmplPlan]
FOR UPDATE
AS
BEGIN
	IF (SELECT 
			COUNT(i.PlanID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanID = d.PlanID
		WHERE
			NOT d.GoalStatusID = i.GoalStatusID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'EmplPlan', d.PlanID, i.LastUpdatedByID, 'Goal status change for PlanID ' + CAST(d.PlanID AS NVARCHAR), i.LastUpdatedDt, ISNULL(d.GoalStatusID, 0), i.GoalStatusID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PlanID = d.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID	
	END

	IF (SELECT 
			COUNT(i.PlanID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanID = d.PlanID
		WHERE
			NOT d.PlanTypeID = i.PlanTypeID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'EmplPlan', d.PlanID, i.LastUpdatedByID, 'Plan type change for PlanID ' + CAST(d.PlanID AS NVARCHAR), i.LastUpdatedDt, ISNULL(d.PlanTypeID, 0), i.PlanTypeID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PlanID = d.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID	
	END	

	IF (SELECT 
			COUNT(i.PlanID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanID = d.PlanID
		WHERE
			NOT d.ActnStepStatusID = i.ActnStepStatusID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'EmplPlan', d.PlanID, i.LastUpdatedByID, 'Action steps status change for PlanID ' + CAST(d.PlanID AS NVARCHAR), i.LastUpdatedDt, ISNULL(d.ActnStepStatusID, 0), i.ActnStepStatusID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PlanID = d.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID	
	END

	IF (SELECT 
			COUNT(i.PlanID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanID = d.PlanID
		WHERE
			NOT d.DateSignedAsmt = i.DateSignedAsmt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'EmplPlan', d.PlanID, i.LastUpdatedByID, 'Self-assessment signed date change for PlanID ' + CAST(d.PlanID AS NVARCHAR), i.LastUpdatedDt, ISNULL(d.DateSignedAsmt, ''), i.DateSignedAsmt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PlanID = d.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID	
	END

	IF (SELECT 
			COUNT(i.PlanID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanID = d.PlanID
		WHERE
			NOT d.PlanStartDt = i.PlanStartDt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'EmplPlan', d.PlanID, i.LastUpdatedByID, 'Plan start date change for PlanID ' + CAST(d.PlanID AS NVARCHAR), i.LastUpdatedDt, ISNULL(d.PlanStartDt, ''), i.PlanStartDt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PlanID = d.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID	
	END

	IF (SELECT 
			COUNT(i.PlanID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanID = d.PlanID
		WHERE
			NOT d.PlanSchedEndDt = i.PlanSchedEndDt) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'EmplPlan', d.PlanID, i.LastUpdatedByID, 'Plan end date change for PlanID ' + CAST(d.PlanID AS NVARCHAR), i.LastUpdatedDt, ISNULL(d.PlanSchedEndDt, ''), i.PlanSchedEndDt, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PlanID = d.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID	
	END
	
	IF (SELECT 
			COUNT(i.PlanID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanID = d.PlanID
		WHERE
			NOT d.RubricID = i.RubricID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'EmplPlan', d.PlanID, i.LastUpdatedByID, 'Rubric changed for PlanID ' + CAST(d.PlanID AS NVARCHAR), i.LastUpdatedDt, ISNULL(d.RubricID,''), i.RubricID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PlanID = d.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID	
	END
	
	IF (SELECT 
			COUNT(i.PlanID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanID = d.PlanID
		WHERE
			(d.PlanActEndDt IS NULL and i.PlanActEndDt IS NOT NULL) OR (not d.PlanActEndDt = i.PlanActEndDt) OR (d.PlanActive=0 and i.PlanActive=1) ) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'EmplPlan', d.PlanID, i.LastUpdatedByID,								
								(CASE WHEN i.PlanActive = 1 and d.PlanActive = 0 THEN 'Plan is re-activated for PlanID ' + CAST(d.PlanID AS NVARCHAR) ELSE 'Plan is ended for PlanID ' + CAST(d.PlanID AS NVARCHAR) END), i.LastUpdatedDt, ISNULL(d.PlanActive, 0), ISNULL(i.PlanActive, 0), i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PlanID = d.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID					
	END

	IF (SELECT 
			COUNT(i.PlanID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanID = d.PlanID
		WHERE
			NOT d.MultiYearGoalStatusID = i.MultiYearGoalStatusID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'EmplPlan', d.PlanID, i.LastUpdatedByID, 'Next year goal status change for PlanID ' + CAST(d.PlanID AS NVARCHAR), i.LastUpdatedDt, ISNULL(d.MultiYearGoalStatusID, 0), i.MultiYearGoalStatusID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PlanID = d.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID	
	END
	
	IF (SELECT 
			COUNT(i.PlanID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanID = d.PlanID
		WHERE
			NOT d.MultiYearActnStepStatusID = i.MultiYearActnStepStatusID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'EmplPlan', d.PlanID, i.LastUpdatedByID, 'Next year action steps status change for PlanID ' + CAST(d.PlanID AS NVARCHAR), i.LastUpdatedDt, ISNULL(d.MultiYearActnStepStatusID, 0), i.MultiYearActnStepStatusID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.PlanID = d.PlanID
						JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID	
	END	
	
	--Update GoalFirstSubmitDt of EmplPlan: is first occurance date of goal submitted
	IF (SELECT 
			COUNT(i.PlanID)
		FROM
			inserted as i
		JOIN deleted as d ON i.PlanID = d.PlanID
		WHERE
			 d.GoalStatusID is null and 
			 d.GoalFirstSubmitDt is null and
			 i.GoalStatusID=(select top 1 codeid from CodeLookUp where CodeText='Awaiting Approval' and CodeType='GoalStatus') ) > 0
			 
	BEGIN
		UPDATE p
		SET GoalFirstSubmitDt =i.GoalStatusDt
		FROM inserted i 
			join EmplPlan p on i.PlanID=p.PlanID 
	END
	
	--Plan Invalid - Set
	IF (SELECT
		COUNT(i.PlanID)
		FROM inserted as i 
		JOIN deleted as d on i.PlanID =d.PlanID
		WHERE d.IsInvalid = 0 and i.IsInvalid =1 )>0
		BEGIN
			INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
			SELECT 'EmplPlan', i.PlanID,i.LastUpdatedByID, 'Plan set to Invalid with Reason ', i.LastUpdatedDt, ISNULL(d.InvalidNote,'') , i.InvalidNote, i.LastUpdatedByID,i.LastUpdatedDt, i.LastUpdatedByID,i.LastUpdatedDt,ej.EmplID 
			FROM 
				inserted as i
				JOIN deleted as d ON i.PlanID = d.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID	
		END
	--Plan Invalid - InValid Note Reason changed
	IF (SELECT
		COUNT(i.PlanID)
		FROM inserted as i 
		JOIN deleted as d on i.PlanID =d.PlanID
		WHERE i.IsInvalid = 1 AND d.InvalidNote !=i.InvalidNote )>0
		BEGIN
			INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
			SELECT 'EmplPlan', i.PlanID,i.LastUpdatedByID, 'Plan Invalid Reason changed', i.LastUpdatedDt, d.InvalidNote , i.InvalidNote,  i.LastUpdatedByID,i.LastUpdatedDt, i.LastUpdatedByID,i.LastUpdatedDt,ej.EmplID 
			FROM 
				inserted as i
				JOIN deleted as d ON i.PlanID = d.PlanID
				JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID	
		END
END


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[TR_ActnStepStatus_Insert]
   ON  [dbo].[EmplPlan]
   AFTER INSERT
AS 
BEGIN
   SET NOCOUNT ON;
   UPDATE EmplPlan 
   SET ActnStepStatusID = (SELECT CODEID FROM CodeLookUp where CodeType='AcnStatus' and CodeSortOrder = 1)
   FROM INSERTED AS I
   WHERE EmplPlan.PlanID = I.PlanID
END
GO
ALTER TABLE [dbo].[EmplPlan] ADD CONSTRAINT [PK_BPSEval_Plan] PRIMARY KEY CLUSTERED  ([PlanID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [EmplJobID_PlanID] ON [dbo].[EmplPlan] ([EmplJobID], [PlanID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [EmplPlan_PlanID_PlanActive_EmplJobID] ON [dbo].[EmplPlan] ([PlanActive], [EmplJobID], [PlanID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nciEmplPlan_PlanActive_IsInvalid] ON [dbo].[EmplPlan] ([PlanActive], [IsInvalid]) INCLUDE ([EmplJobID], [PlanID], [PlanSchedEndDt], [PlanStartDt], [PlanTypeID], [RubricID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PlanEndDt_EmplJobID] ON [dbo].[EmplPlan] ([PlanSchedEndDt], [EmplJobID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmplPlan] WITH NOCHECK ADD CONSTRAINT [FK_BPSEval_Plan_BPSEval_Codes] FOREIGN KEY ([PlanTypeID]) REFERENCES [dbo].[CodeLookUp] ([CodeID])
GO
ALTER TABLE [dbo].[EmplPlan] WITH NOCHECK ADD CONSTRAINT [FK_EmplPlan_EmplEmplJob] FOREIGN KEY ([EmplJobID]) REFERENCES [dbo].[EmplEmplJob] ([EmplJobID])
GO
ALTER TABLE [dbo].[EmplPlan] ADD CONSTRAINT [FK_EmplPlan_RubricHdr] FOREIGN KEY ([RubricID]) REFERENCES [dbo].[RubricHdr] ([RubricID])
GO
