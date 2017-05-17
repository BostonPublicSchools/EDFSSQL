CREATE TABLE [dbo].[EmplExceptions]
(
[ExceptionID] [int] NOT NULL IDENTITY(1, 1),
[EmplJobID] [int] NOT NULL,
[EmplID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MgrID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplExceptions_CreatedByID] DEFAULT ('000000'),
[CreatedByDt] [datetime] NOT NULL CONSTRAINT [DF_EmplExceptions_CreatedByDt] DEFAULT (getdate()),
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EmplExceptions_LastUpdatedByID] DEFAULT ('000000'),
[LastUpdatedDt] [datetime] NOT NULL CONSTRAINT [DF_EmplExceptions_LastUpdatedDt] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[EmplExceptionsInsertChangeLog] ON [dbo].[EmplExceptions]
AFTER INSERT
AS
BEGIN
	INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
	SELECT		   		  'EmplExceptions', i.ExceptionID, i.LastUpdatedByID, 'Insert manager override for ExceptionID ' + CAST(i.ExceptionID AS NVARCHAR),i.LastUpdatedDt, '', i.MgrID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
					FROM
						inserted as i					
					JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID				 
							
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[EmplExceptionsUpdChangeLog] ON [dbo].[EmplExceptions]
FOR UPDATE
AS
BEGIN
	IF (SELECT 
			COUNT(i.ExceptionID)
		FROM
			inserted as i
		JOIN deleted as d ON i.ExceptionID = d.ExceptionID
		WHERE
			NOT d.MgrID = i.MgrID) > 0
	BEGIN
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,IdentityEmplID)
						SELECT 
								'EmplExceptions', i.ExceptionID, i.LastUpdatedByID, 'Manager override for ExceptionID ' + CAST(i.ExceptionID AS NVARCHAR), i.LastUpdatedDt, d.MgrID, i.MgrID, i.LastUpdatedByID, GETDATE(), i.LastUpdatedByID, GETDATE(),ej.EmplID
						FROM
							inserted as i
						JOIN deleted as d ON i.ExceptionID = d.ExceptionID						
						JOIN EmplEmplJob ej on ej.EmplJobID = i.EmplJobID
						
	END

	
END
GO
ALTER TABLE [dbo].[EmplExceptions] ADD CONSTRAINT [PK_EmplExceptions] PRIMARY KEY CLUSTERED  ([ExceptionID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [EmplExceptions_EmplJobID] ON [dbo].[EmplExceptions] ([EmplJobID]) INCLUDE ([MgrID]) ON [PRIMARY]
GO
