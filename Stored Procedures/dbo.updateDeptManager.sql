SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/05/2012
-- Description: update the departments and other tables
-- =============================================
CREATE PROCEDURE [dbo].[updateDeptManager]
	@DeptID as nchar(6),
	@DeptMgrId as nchar(6), 
	@DeptIsSchool as bit,
	@DeptUpdatedById as nchar(6),
	@OldManagerID as nchar(6),
	@isManagerChanged as bit,
	@DeptCategoryId as int,
	@ImplSpecialistID as nchar(6) =null,
	@DeptRptEmplID as nchar(6) =null
AS
BEGIN 
SET NOCOUNT ON;

IF @isManagerChanged = 0
BEGIN
	UPDATE Department SET 
	IsSchool = @DeptIsSchool,
	LastUpdatedByID = @DeptUpdatedById,
	ImplSpecialistID = @ImplSpecialistID,		
	DeptRptEmplID = (Case WHEN @DeptRptEmplID IS NOT NULL THEN @DeptRptEmplID ELSE DeptRptEmplID END),
	DeptCategoryID = (CASE WHEN @DeptCategoryId != 0
						THEN @DeptCategoryId
					    ELSE NULL END),
	LastUpdatedDt = GETDATE()
	WHERE DeptID = @DeptID
END

ELSE
BEGIN
	
	/**
	* if the selected new manager is subeval of the same department,
	* then inactivate all the subevalassigned empljob records.
	**/	
	IF(Exists(SELECT * FROM SubEval WHERE EmplID = @DeptMgrId and EvalActive = 1))
	BEGIN 
		UPDATE SubevalAssignedEmplEmplJob 
		SET IsActive = 0 ,
		LastUpdatedByID = @DeptUpdatedById,
		LastUpdatedDt = GETDATE()
		WHERE AssignedSubevaluatorID IN(SELECT AssignedSubevaluatorID FROM SubevalAssignedEmplEmplJob WHERE EmplJobID IN 
													(SELECT EmplJobID FROM EmplEmplJob WHERE DeptID =@DeptID) AND	
			
										SubEvalID IN (SELECT EvalID FROM SubEval WHERE EmplID = @DeptMgrId AND EvalActive = 1))		
		
		
		/**
		inactivate the eval where the manager is the old manager and new manager is the eval
		**/													
		UPDATE SubEval 
		SET EvalActive = 0,
		LastUpdatedByID = @DeptUpdatedById,
		LastUpdatedDt  = GETDATE()
		WHERE EmplID = @DeptMgrId and MgrID = @OldManagerID
		
	END
	
	/**
	* If the manager is changed.
	**/
	UPDATE Department SET 
	IsSchool = @DeptIsSchool,
	DeptID = @DeptID,
	MgrID = @DeptMgrId,
	ImplSpecialistID = @ImplSpecialistID,
	DeptRptEmplID = (Case WHEN @DeptIsSchool = 0 and @DeptRptEmplID IS NOT NULL THEN @DeptRptEmplID ELSE DeptRptEmplID END),
	DeptCategoryID = (CASE WHEN @DeptCategoryId != 0
						THEN @DeptCategoryId
					    ELSE NULL END),
	LastUpdatedByID = @DeptUpdatedById,
	LastUpdatedDt = GETDATE()
	WHERE DeptID = @DeptID
	
	/** transfer all eval to the new manager and if one of the eval is the new manager, turn them into inactive
			which is handled in the previous step 
		**/
		
	IF((SELECT count(distinct DeptID) FROM EmplEmplJob where EmplID = @OldManagerID and IsActive = 1)> 1)
	BEGIN
		---create a duplicate copy of all subeval for the new manager and update all the emplJob for changed dept with new subevalId
		EXECUTE CopySubEvalNewMgr @DeptID,@OldManagerId,@DeptMgrId,@DeptUpdatedById 
	END 
			
	ELSE
	BEGIN		
		UPDATE SubEval
		SET MgrID = @DeptMgrId
		,LastUpdatedByID = @DeptUpdatedById
		,LastUpdatedDt = GETDATE()
		WHERE EvalID IN (
							SELECT EvalID FROM SubEval 
							WHERE EvalID IN (SELECT DISTINCT SubEvalID FROM SubevalAssignedEmplEmplJob 
											 WHERE EmplJobID IN(SELECT ej.emplJobId
																FROM EmplEmplJob ej
																LEFT OUTER JOIN EmplExceptions ex ON ex.EmplJobID = ej.EmplJobID
																WHERE ej.DeptID = @DeptID AND (CASE WHEN ex.MgrID IS NULL THEN ej.MgrID 
																ELSE ex.MgrID END) = @OldManagerID )
											  )
						)
		AND MgrID = @OldManagerID AND EvalActive = 1	
	END	 
	
	/**
		Update the subeval in the plan to the new manager ID
		if the plan
	**/
	
	EXECUTE updEvalIDByDeptID @UpdDeptID = @DeptID, @UpdDeptMgrId = @DeptMgrId
									,@UpdDeptUpdatedById  = @DeptUpdatedById
									,@UpdOldManagerID 	= @OldManagerID 
								    ,@UpdDeptCategoryId = @DeptCategoryId
	
	
	
	
	/** 
	update emplempljob record with new manager
	for the department.
	inactivate the new emplempljob record if an emplemplJob record 
	already exists for the new manager 
	with the same department, same jobcode and same active 
	**/	
	UPDATE ej SET 
	--MgrID = @DeptMgrId,
	MgrID = (CASE WHEN EmplID != @DeptMgrId
			      THEN @DeptMgrId
			      ELSE '000000'
			      END), 		
	LastUpdatedByID = @DeptUpdatedById,
	LastUpdatedDt = GETDATE(),
	IsActive = (CASE 
				WHEN exists(SELECT EmplJobID FROM EmplEmplJob ej1 
							JOIN (SELECT JobCode, emplID FROM EmplEmplJob WHERE MgrID = @DeptMgrId) as filterJob on filterJob.Jobcode = ej1.jobCode and filterJob.emplID = ej.emplID
							WHERE MgrID=@DeptMgrId AND DeptID = @DeptID AND IsActive =1 )
				THEN 0
				ELSE 1 
				END)				
	FROM emplempljob ej			
	WHERE (MgrID = @OldManagerID OR MgrID='000000') AND IsActive = 1 AND DeptID = @DeptID
END

IF NOT Exists(SELECT ObsRubricId FROM ObservationRubricDefault WHERE EmplID = @DeptMgrId)
BEGIN
	INSERT INTO ObservationRubricDefault (EmplID, RubricID, IndicatorID, IsActive, IsDeleted, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
	SELECT 
		@DeptMgrId
		,rh.RubricID
		,ri.IndicatorID
		,1
		,0 
		,'000000'
		,GETDATE()
		,'000000'
		,GETDATE()	
	FROM 
		RubricIndicator AS ri 
	JOIN RubricStandard AS rs ON ri.StandardID = rs.StandardID
								AND (rs.StandardText like 'II.%' OR rs.StandardText like 'II:%')
								AND rs.IsActive = 1
								AND rs.IsDeleted = 0
	JOIN RubricHdr AS rh ON rs.RubricID = rh.RubricID
							AND rh.IsActive = 1
							AND rh.IsDeleted = 0
	WHERE 
		ri.ParentIndicatorID = 0
	ORDER BY
	 rh.RubricID, rs.StandardID, ri.IndicatorID
END		

IF (SELECT COUNT(DeptID) from Department where MgrID = @OldManagerID) <= 1
BEGIN
DELETE FROM ObservationRubricDefault WHERE EmplID = @OldManagerID
END

--delete if any override exists for the manager when the DeptReport is added.
IF(@DeptRptEmplID IS NOT NULL)
BEGIN	
	IF(EXISTS(SELECT * FROM EmplExceptions WHERE EmplJobID in (SELECT EmplJobID FROM EmplEmplJob WHERE EmplID = @DeptMgrId and DeptID = @DeptID and IsActive =1 )))
	BEGIN
		DELETE FROM EmplExceptions WHERE EmplJobID in (SELECT EmplJobID FROM EmplEmplJob WHERE EmplID = @DeptMgrId and DeptID = @DeptID and IsActive =1)
	END
	
	--update the manager to report mgrID
	UPDATE EmplEmplJob SET MgrID = @DeptRptEmplID WHERE EmplID = @DeptMgrId and DeptID = @DeptID and IsActive =1 
	
	--reset the primary subevalID
	UPDATE EmplPlan
	SET SubEvalID = dbo.funcGetPrimaryManagerByEmplID(@DeptMgrID)
	WHERE EmplJobID in (SELECT EmplJobID FROM EmplEmplJob WHERE EmplID = @DeptMgrId and DeptID = @DeptID and IsActive =1)
	AND PlanActive = 1
END
END
GO
