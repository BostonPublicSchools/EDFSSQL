SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Newa,Matina
-- Create date: 04/12/2013
-- Description:	Gets all the prescription of the PlanID that are associated with Artifacts
--				And get all the prescription of the plan 
--              This returns all the presprtion irresptive of evidence content
--				getPrecriptionEvidenceCountByPlanID @PlanID=3415
-- =============================================
CREATE PROCEDURE [dbo].[getPrecriptionEvidenceCountByPlanID]
	@PlanID int
AS
BEGIN
	SET NOCOUNT ON;

	
	--select 
	--	evalp.PrescriptionId,COUNT(evalp.PrescriptionId) [EviPrespCount],
	--	evalp.IndicatorID,ri.IndicatorText,rs.StandardID,rs.StandardText,
	--	(ri.IndicatorText + ' | ' + evalp.PrscriptionStmt)[DisplayTag]
	--from 
	--	EmplPlanEvidence ep inner join EvaluationPrescription evalp on  ep.ForeignID =evalp.PrescriptionId
	--	inner join RubricIndicator ri inner join RubricStandard rs on ri.StandardID=rs.StandardID on evalp.IndicatorID=ri.IndicatorID
	--where ep.PlanID=@PlanID and ep.IsDeleted=0 and ep.EvidenceTypeID=110
	--and evalp.IsDeleted=0
	--group by evalp.PrescriptionId,evalp.PrscriptionStmt,evalp.IndicatorID, ri.IndicatorID, ri.IndicatorText,rs.StandardID ,rs.StandardText
	--order by ri.IndicatorText
		

	select 
		TblAllPrescptWithEvidence.PrescriptionId,
		TblAllPrescptWithEvidence.DisplayTag,
		sum(TblAllPrescptWithEvidence.EviPrespCount) EviPrespCount
	from
	(
		select EvidencePrescpt.PrescriptionId,EvidencePrescpt.DisplayTag,EvidencePrescpt.EviPrespCount
		from 
		(
			select 
				evalp.PrescriptionId,COUNT(evalp.PrescriptionId) [EviPrespCount],
				evalp.IndicatorID,ri.IndicatorText,rs.StandardID,rs.StandardText,
				(ri.IndicatorText + ' | ' + evalp.PrscriptionStmt)[DisplayTag]
			from 
				EmplPlanEvidence ep inner join EvaluationPrescription evalp on  ep.ForeignID =evalp.PrescriptionId
				inner join RubricIndicator ri inner join RubricStandard rs on ri.StandardID=rs.StandardID on evalp.IndicatorID=ri.IndicatorID
			where ep.PlanID=@PlanID and 
				  ep.IsDeleted=0 and ep.EvidenceTypeID=110 and evalp.IsDeleted=0
			group by evalp.PrescriptionId,evalp.PrscriptionStmt,evalp.IndicatorID, ri.IndicatorID, ri.IndicatorText,rs.StandardID ,rs.StandardText
		) EvidencePrescpt
		
		union
		(
			SELECT	ep.PrescriptionId		
			,(ri.IndicatorText + ' | ' + ep.PrscriptionStmt)[DisplayTag]
			,0 EviPrespCount
			FROM 
				EvaluationPrescription ep
				LEFT JOIN RubricIndicator ri on ri.IndicatorID = ep.IndicatorID
				LEFT JOIN RubricStandard rs on rs.StandardID = ri.StandardID
				LEFT JOIN Evaluation e on e.EvalID = ep.EvalID
				LEFT JOIN EvaluationStandardRating esr on esr.EvalID =ep.EvalID and esr.StandardID = ri.StandardID
				LEFT JOIN CodeLookUp c on c.CodeID=esr.RatingID
			WHERE 
				e.PlanID = @PlanID and ep.IsDeleted = 0 and e.IsSigned = 1
				and CodeID in (select codeid from codelookup where codetype='StdRating' and (codetext='Needs Improvement' or codetext='Unsatisfactory'))
		)
	)
	TblAllPrescptWithEvidence
	group by TblAllPrescptWithEvidence.PrescriptionId,TblAllPrescptWithEvidence.DisplayTag
	order by TblAllPrescptWithEvidence.DisplayTag
END




GO
