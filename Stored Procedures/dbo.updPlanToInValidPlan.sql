SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Newa, Matina
-- Create date: 05/18/2014
-- Description:	Set Plan as Invalid Plan,
-- =============================================
CREATE PROCEDURE [dbo].[updPlanToInValidPlan]
	@PlanID int
	,@IsInvalid bit
	,@InvalidNote varchar(255)
	,@UserID nchar(6)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	Update EmplPlan 
	Set 
		 PlanActive=0
		,IsInvalid = @IsInvalid
		,InvalidNote = @InvalidNote
		,LastUpdatedByID=@UserID
		,LastUpdatedDt = GETDATE()
	Where PlanID =@PlanID
	
	-----###### REVIEW AND FIX above and below plan if necessary for : prescption 
	if exists ( select distinct planid from EmplPlan 
			 where PrevPlanPrescptEvalID in(select EvalID from Evaluation where IsDeleted=0 and PlanID = @PlanID) )
	Begin

		Declare @PlanidAfter as int 			
		Select distinct Top 1 @PlanidAfter = PlanID 
		From EmplPlan 
		Where PrevPlanPrescptEvalID in(select EvalID from Evaluation where IsDeleted=0 and PlanID = @PlanID)	
		
		Declare @PlanidBefore as int 	
		Select distinct top 2 @PlanidBefore= PlanID from Evaluation where EvalID in (
													Select PrevPlanPrescptEvalID
													From EmplPlan 
													Where PlanID = @PlanID)
		Declare @PrevPlanPrescptEvalID int, @HasPrescript bit
		
		Select
			 @PrevPlanPrescptEvalID= PrevPlanPrescptEvalID  -- A 
			,@HasPrescript = HasPrescript
		From Emplplan
		Where Planid = @PlanID	
		
		--## Updating After Plan
		DECLARE @PrescriptEvalID_AfterPlan as int
		SELECT TOP 1
			@PrescriptEvalID_AfterPlan = ISNULL(e.EvalID, 0)
		FROM
			EvaluationPrescription as ep
		JOIN (SELECT MAX(EvalID) as EvalID, PlanID FROM Evaluation WHERE PlanID = @PlanidAfter and IsDeleted = 0 Group by PlanID)as e on ep.EvalID = e.EvalID
		JOIN EmplPlan as p on e.PlanID = p.PlanID
							AND p.PlanID = @PlanidAfter AND p.IsInvalid =0
							AND ep.IsDeleted=0 
							
		
		Update EmplPlan
		Set 
			 PrevPlanPrescptEvalID = @PrevPlanPrescptEvalID 
			,HasPrescript = Case 
								When @PrescriptEvalID_AfterPlan !=0 then 1 
								When @PrevPlanPrescptEvalID > 0 then 1 else 0 
							End -- @HasPrescript
		where PlanID = @PlanidAfter
		
	
	End
	
	
END		



GO
