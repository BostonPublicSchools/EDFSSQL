SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina
-- Create date: sept 17 2013
-- Description:	Inserts user activity in [ChangeLog]
--	For 'Activity' log, Identity=0, IdentityEmplID= whose info is accessing, @EmplID= @CreatedByID
-- =============================================
CREATE PROCEDURE [dbo].[InsChangeLog]	
	@TableName AS NVARCHAR(50)
	,@IdentityID as nchar(6) 	
	,@EmplID as nchar(6) 
	,@LoggedEvent nvarchar(max)	
	,@CreatedByID nvarchar(6)
AS
BEGIN	
	SET NOCOUNT ON;

	INSERT INTO dbo.Changelog(TableName,IdentityID,EmplID,LoggedEvent,EventDt,PreviousText,CreatedByID,CreatedByDt,LastUpdatedByID,LastUpdatedDt,IdentityEmplID)
		VALUES(@TableName,0,@CreatedByID,@LoggedEvent,GETDATE(),'',@CreatedByID,GETDATE(),@CreatedByID,GETDATE(),@IdentityID)
    
END
GO
