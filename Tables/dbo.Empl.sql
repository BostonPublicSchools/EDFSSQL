CREATE TABLE [dbo].[Empl]
(
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NameLast] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NameFirst] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NameMiddle] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmplActive] [bit] NOT NULL CONSTRAINT [DF_BPSEval_Employees_EmplActive] DEFAULT ((1)),
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Empl__CreatedByI__22401542] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF__Empl__CreatedByD__2334397B] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Empl__LastUpdate__24285DB4] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF__Empl__LastUpdate__251C81ED] DEFAULT (getdate()),
[IsAdmin] [bit] NOT NULL CONSTRAINT [DF__Empl__IsAdmin__24E777C3] DEFAULT ('0'),
[Sex] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthDt] [datetime] NULL,
[Race] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsContractor] [bit] NOT NULL CONSTRAINT [Empl_IsContractor_Default] DEFAULT ((0)),
[PrimaryEvalID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EMPL_PrimaryEvalID] DEFAULT ('000000'),
[HasReadOnlyAccess] [bit] NOT NULL CONSTRAINT [DF_EMPL_ReadOnly] DEFAULT ((0)),
[ExpectedReturnDate] [date] NULL,
[OriginalHireDate] [date] NULL,
[EmplActiveDt] [datetime] NULL,
[EmplPWord] [varbinary] (max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[InActiceEmplTempAccessUpdateChangelog] ON [dbo].[Empl]
FOR UPDATE
AS 
BEGIN
	
	SET NOCOUNT ON;

	IF (SELECT 
			COUNT(i.EmplID)
		FROM
			inserted as i
		JOIN deleted as d ON i.EmplID = d.EmplID
		WHERE
			d.EmplActive=0 And
			 ( (d.EmplActiveDt is null and d.EmplPWord is null and i.EmplActiveDt is not null and i.EmplPWord is not null)
				 or (d.EmplActiveDt != i.EmplActiveDt)
				 or (d.EmplPWord != i.EmplPWord) )
			  ) > 0
			 
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'Empl', d.EmplID, i.LastUpdatedByID, 'Temporary Access to Emplid ' + CAST(d.EmplID AS NVARCHAR) ,i.LastUpdatedDt
								, CONVERT(varchar, (case when d.EmplActiveDt is null then '' else convert(nvarchar,d.EmplActiveDt  )end)) 
								, CONVERT(varchar, (case when i.EmplActiveDt is null then '' else convert(nvarchar,i.EmplActiveDt  )end)) 								
								, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(), d.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.EmplID = d.EmplID
						and d.EmplActive=0
	END

END
GO
ALTER TABLE [dbo].[Empl] ADD CONSTRAINT [PK_BPSEval_Employees] PRIMARY KEY CLUSTERED  ([EmplID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [EmplActive_EmplID_NameLast_Name_first_NameMiddle] ON [dbo].[Empl] ([EmplActive], [EmplID], [NameLast], [NameFirst], [NameMiddle]) ON [PRIMARY]
GO
