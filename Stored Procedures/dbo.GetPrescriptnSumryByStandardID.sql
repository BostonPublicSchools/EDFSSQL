SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 01/09/2014	
-- Description:	Get the prescription and previous prescription by standardID
-- =============================================
CREATE PROCEDURE [dbo].[GetPrescriptnSumryByStandardID]
	 @EvalID as int
	,@PlanID as int	
	,@StandardID as int 
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @PrevPrescriptionEvalID as int = 0
	SELECT
		@PrevPrescriptionEvalID = (CASE WHEN HasPrescript = 1 AND (PrescriptEvalID IS NULL OR PrescriptEvalID = @EvalID) THEN PrevPlanPrescptEvalID ELSE PrescriptEvalID END) 	
	FROM EmplPlan 
	WHERE PlanID  = @PlanID;
	
with cte as(
SELECT ep.PrescriptionID, ep.EvalID, ev.PlanID,
ep.ProblemStmt, ep.EvidenceStmt, ep.PrscriptionStmt, 
ri.IndicatorText, ri.IndicatorID, 
rs.StandardText, rs.StandardID,
PrevPescriptionTable.*	   
FROM EvaluationPrescription ep		
JOIN Evaluation ev on ev.EvalID = ep.EvalID
JOIN RubricIndicator ri on ri.IndicatorID = ep.IndicatorID and ri.IsDeleted = 0
JOIN RubricStandard rs on rs.StandardID = ri.StandardID and rs.IsDeleted = 0
LEFT Outer JOIN (SELECT ep.PrescriptionID as PrevPrescriptionID, ep.EvalID as PrevEvalID, ev.PlanID as PrevPlanID, 
				   ep.ProblemStmt as PrevProblemStmnt, ep.EvidenceStmt as PrevEvidenceStmt, ep.PrscriptionStmt as PrevPrescStmnt,
				   ri.IndicatorText as PrevIndicatorText, ri.IndicatorID as PrevIndicatorID,
				   rs.StandardText as PrevStandardText, rs.StandardID as PrevStandID					  
				FROM EvaluationPrescription ep
				JOIN Evaluation ev on ev.EvalID = ep.EvalID
				JOIN RubricIndicator ri on ri.IndicatorID = ep.IndicatorID and ri.IsDeleted = 0
				JOIN RubricStandard rs on rs.StandardID = ri.StandardID and rs.IsDeleted = 0
				WHERE rs.StandardID = @StandardID and ep.EvalID = @PrevPrescriptionEvalID and ep.IsDeleted=0) as PrevPescriptionTable on PrevPescriptionTable.PrevIndicatorID = ri.IndicatorID
WHERE rs.StandardID = @StandardID and ep.EvalID = @EvalID and ep.IsDeleted = 0

UNION 

SELECT CurrentPrescription.*, ep.PrescriptionID as PrevPrescriptionID, ep.EvalID as PrevEvalID, ev.PlanID as PrevPlanID, 
		ep.ProblemStmt as PrevProblemStmnt, ep.EvidenceStmt as PrevEvidenceStmt, ep.PrscriptionStmt as PrevPrescStmnt,
		ri.IndicatorText as PrevIndicatorText, ri.IndicatorID as PrevIndicatorID,
		rs.StandardText as PrevStandardText, rs.StandardID as PrevStandID					  
		FROM EvaluationPrescription ep
		JOIN Evaluation ev on ev.EvalID = ep.EvalID
		JOIN RubricIndicator ri on ri.IndicatorID = ep.IndicatorID and ri.IsDeleted = 0
		JOIN RubricStandard rs on rs.StandardID = ri.StandardID and rs.IsDeleted = 0
		LEFT Outer JOIN (SELECT ep.PrescriptionID, ep.EvalID, ev.PlanID,
						   ep.ProblemStmt, ep.EvidenceStmt, ep.PrscriptionStmt, 
						   ri.IndicatorText, ri.IndicatorID, 
						   rs.StandardText, rs.StandardID		   	   
						FROM EvaluationPrescription ep	
						JOIN Evaluation ev on ev.EvalID = ep.EvalID	
						JOIN RubricIndicator ri on ri.IndicatorID = ep.IndicatorID and ri.IsDeleted = 0
						JOIN RubricStandard rs on rs.StandardID = ri.StandardID and rs.IsDeleted = 0											
						WHERE rs.StandardID = @StandardID and ep.EvalID = @EvalID and ep.IsDeleted=0) as CurrentPrescription on CurrentPrescription.IndicatorID = ri.IndicatorID
		WHERE rs.StandardID = @StandardID and ep.EvalID = @PrevPrescriptionEvalID and ep.IsDeleted=0
)

select * from cte
order by IndicatorText, IndicatorID asc
		
END
GO
