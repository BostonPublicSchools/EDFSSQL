SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 11/5/2013
-- Description: insert the evaluation released email
-- =============================================
CREATE PROCEDURE [dbo].[insEmailEvalDailyLog]	
@EmplJobID as int,
@EmailBody as nvarchar(3000)

AS 
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @EmplID as nchar(6)
	DECLARE @MgrID as nchar(6)
	
	SELECT @EmplID = EmplID FROM EmplEmplJob where EmplJobID = @EmplJobID
	
	SELECT @MgrID = (CASE WHEN ex.MgrID is not null THEN ex.MgrID else ej.MgrID end)
	FROM EmplEmplJob ej
	LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID
	where ej.EmplJobID = @EmplJobID
	
	--insert subevals into evaluatorDaily emailLog
	DECLARE @ResultSet table (EmplJobID int,IsActive bit,IsDeleted bit,IsPrimary bit, SubEvalID char(6),MgrId char(6),SubEmplName char(50),PrimaryCount int)
	INSERT INTO @ResultSet (EmplJobID,IsActive,IsDeleted,IsPrimary,SubEvalID,MgrId,SubEmplName,PrimaryCount)
		exec getAllSubEvalByEmplJobId @empljobid
	
	declare @counter int
	declare @productKey varchar(20)

	SET @counter = (select COUNT(*) from @ResultSet)

	WHILE (1=1 and @counter > 0) 
	BEGIN	
	INSERT into EvaluatorDailyEmailLog(MgrID, EmplID, SubEvalID, CurrentStatus, CreatedByDt, LastUpdatedByDt)
	SELECT top 1  @MgrID, @EmplID, SubEvalID, @EmailBody, GETDATE(), GETDATE() 
	FROM @ResultSet 
	WHERE IsDeleted = 0
		
	DELETE top (1) from @ResultSet 
	SET @counter-=1;
	
	IF (@counter=0) 
	BREAK;
	END

	--insert for manager
	INSERT into EvaluatorDailyEmailLog(MgrID, EmplID, SubEvalID, CurrentStatus, CreatedByDt, LastUpdatedByDt)
	VALUES(@MgrID, @EmplID, @MgrID, @EmailBody, GETDATE(), GETDATE())	
	
END
GO
