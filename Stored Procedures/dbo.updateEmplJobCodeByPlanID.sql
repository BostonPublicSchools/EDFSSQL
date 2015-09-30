SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 10/11/2012
-- Description:	update the plan with new jobcodes.
-- =============================================
CREATE PROCEDURE [dbo].[updateEmplJobCodeByPlanID]
  @PlanID AS int,
  @EmplJobCode AS nchar(6),
  @EmplID AS nchar(6),
  @DeptID AS nchar(6),
  @UserID AS nchar(6),
  @EmplJobID AS int =0,
  @IsJobCodeChanged AS bit,
  @IsJobCodeUpdated AS bit = 0 OUTPUT
  
AS
BEGIN 
SET NOCOUNT ON;

--DECLARE @OldEmplJobID AS int 

--SELECT @OldEmplJobID = EmplJobID FROM EmplPlan WHERE PlanID = PlanID

DECLARE @PlanRubricID int 
DECLARE @EmplJobRubricID int

SELECT @PlanRubricID = RubricID FROM EmplPlan where PlanID = @PlanID
SELECT @EmplJobRubricID = RubricID FROM EmplEmplJob WHERE EmplJobID = (CASE WHEN @EmplJobID = 0 THEN 
																		(SELECT EmplJobID FROM EmplEmplJob WHERE JobCode = @EmplJobCode AND DeptID = @DeptID AND EmplID = @EmplID AND IsActive = 1)
														   			   ELSE
																		@EmplJobID
																	  END)

IF(@PlanRubricID = @EmplJobRubricID)
BEGIN
UPDATE EmplPlan 
SET  EmplJobID = (CASE WHEN @EmplJobID = 0 THEN 
						(SELECT EmplJobID FROM EmplEmplJob WHERE JobCode = @EmplJobCode AND DeptID = @DeptID AND EmplID = @EmplID AND IsActive = 1)
					  ELSE
						@EmplJobID
				  END),
     PlanManagerID = (SELECT (CASE WHEN ex.MgrID Is not Null Then ex.MgrID 
								WHEN ex.MgrID is null and ej.MgrID = '000000' THEN d.MgrID
								ELSE ej.MgrID end) FROM EmplEmplJob ej
							LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID
							Join Department d on d.DeptID = ej.DeptID
							WHERE JobCode = @EmplJobCode 
								AND ej.DeptID = @DeptID 
								AND ej.EmplID = @EmplID AND ej.IsActive = 1),				  
	 SubEvalID = dbo.funcGetPrimaryManagerByEmplID(@EmplID),					  
	 LastUpdatedByID = @UserID,
	 LastUpdatedDt = GETDATE()
WHERE PlanID = @PlanID
SET @IsJobCodeUpdated = 1
END 

IF(@IsJobCodeChanged = 1) 
	BEGIN
		UPDATE Evaluation
		SET EvalRubricID = (SELECT RubricID FROM EmplJob WHERE JobCode = @EmplJobCode),
			LastUpdatedByID = @UserID,
			LastUpdatedDt = GETDATE()
		WHERE PlanID = @PlanID AND IsSigned = 0
	END
END
GO
