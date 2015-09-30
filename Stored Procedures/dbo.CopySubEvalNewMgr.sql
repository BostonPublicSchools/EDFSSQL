SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 12/06/2013
-- Description: Copy all the subeval to the new manager of 
--				the department only if the old manager has multiple 
--				active emplJobs.
-- =============================================
CREATE PROCEDURE [dbo].[CopySubEvalNewMgr]
@DeptID as int,
@OldManagerId as nchar(6),
@ManagerId as nchar(6),
@UserID as nchar(6)

AS
BEGIN

SET NOCOUNT ON;

DECLARE @ResultSet table(rsEmplID nchar(6), rsEvalActive bit, rsIsLicEval bit, rsIsNonLicEval bit,rsIsEvalManager bit)

Insert into @ResultSet(rsEmplID, rsEvalActive,rsIsLicEval, rsIsNonLicEval,rsIsEvalManager)
	SELECT EmplID, EvalActive, Is5StepProcess, IsNon5StepProcess, IsEvalManager FROM SubEval
		WHERE MgrID = @OldManagerId and EvalActive=1 and EmplID != @ManagerId

---Iterate through the evaluators
	declare @counter int
	declare @productKey varchar(20)

	SET @counter = (select COUNT(*) from @ResultSet)

	WHILE (1=1 and @counter > 0) 
	BEGIN	
	
	DECLARE @newEvalID as int
	DECLARE @EmplID as nchar(6)
	
	SET @EmplID = (SELECT top 1 rsEmplID FROM @ResultSet)
	
	IF NOT EXISTS(SELECT * FROM SubEval WHERE MgrID = @ManagerId and EmplID = @EmplID and EvalActive = 1)
	BEGIN	
	INSERT into SubEval(MgrID, EmplID, CreatedByDt, CreatedByID, EvalActive, IsEvalManager, Is5StepProcess, IsNon5StepProcess, LastUpdatedByID, LastUpdatedDt)
		SELECT top 1  @ManagerId, rsEmplID, GETDATE(), @UserID, rsEvalActive, rsIsEvalManager, rsIsLicEval, rsIsNonLicEval, @UserID, GETDATE()
	FROM @ResultSet 
	
	SET @newEvalID = SCOPE_IDENTITY();
	
	---update the subeval of all the emplJobs of the dept with new manager relations.
	UPDATE sej
	SET sej.SubEvalID = @newEvalID
	FROM SubevalAssignedEmplEmplJob sej WHERE sej.EmplJobID in (SELECT EmplJobID FROM EmplEmplJob WHERE DeptID = @DeptID and IsActive = 1)
												and sej.SubEvalID in (SELECT EvalID FROM SubEval WHERE EvalActive = 1 and MgrID = @OldManagerID and EmplID = @EmplID)
												and sej.IsActive = 1
	END		
	DELETE top (1) from @ResultSet 
	SET @counter-=1;
	
	IF (@counter=0) 
	BREAK;
	END
END
GO
