SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 03/13/2013
-- Description: update the emplPlan and emplJob 
-- with the new subeval.
-- =============================================
CREATE PROCEDURE [dbo].[updEvalIDByDeptID]
	@UpdDeptID as nchar(6),
	@UpdDeptMgrId as nchar(6), 	
	@UpdDeptUpdatedById as nchar(6),
	@UpdOldManagerID as nchar(6),	
	@UpdDeptCategoryId as int
AS
BEGIN 
SET NOCOUNT ON;
	
	/**
	Update all the emplPlan with the new subevalID for the department	
	**/	
	UPDATE EmplPlan
	SET SubEvalID = @UpdDeptMgrId
	WHERE PlanID in (SELECT PlanID FROM EmplPlan WHERE EmplJobID IN (SELECT EmplJobID FROM EmplEmplJob WHERE DeptID = @UpdDeptID AND IsActive =1)) 
		  AND SubEvalID = @UpdOldManagerID
	
	
	DECLARE @TableVar TABLE (RowID INT NOT NULL, EmplID nchar(6) NOT null )
	INSERT INTO @TableVar(RowID, EmplID)
			(SELECT Row_Number() OVER(ORDER BY EmplID) AS RowID, EmplID FROM EmplEmplJob ej
				JOIN EmplPlan ep ON ej.EmplJobID = ep.EmplJobID AND ep.PlanActive=1 AND (ep.SubEvalID  IS NULL OR ep.SubEvalID = '000000')
			  WHERE ej.DeptID = @UpdDeptID) 


	DECLARE @EmplID varchar(20)
	DECLARE @id int
	DECLARE @rowNum int
	DECLARE @maxrows int
	SELECT top 1 @id = RowID, @EmplID = EmplID FROM @TableVar
	SELECT @maxRows = count(*) from @TableVar
	SET @rowNum = 0
	-- this will until the last row is reached
	WHILE @rowNum < @maxRows
	BEGIN
	SET @rowNum = @rowNum + 1
	-- foreach employee update the subeval for the plan with highest FTE of all the emplJob for the empl.
	UPDATE EmplPlan 
	SET SubEvalID = @UpdDeptMgrId,
	LastUpdatedByID = @UpdDeptUpdatedById,
	LastUpdatedDt = GETDATE()
	WHERE EmplJobID = (SELECT TOP 1(EmplJobID) FROM EmplEmplJob WHERE FTE IN 
												(SELECT TOP 1 MAX(FTE)FROM EmplEmplJob 
												 WHERE EmplID = @EmplID AND IsActive = 1)
								AND EmplID = @EmplID ORDER BY EmplRcdNo asc)
	AND PlanActive = 1							

	SELECT TOP 1 @id = RowID, @EmplID = EmplID FROM @TableVar WHERE RowID > @id
END

END
GO
