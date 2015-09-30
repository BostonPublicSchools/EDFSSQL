SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 10/24/2013
-- Description:	Get count of employee associated with particular SubEval/Manager
-- =============================================

CREATE PROCEDURE [dbo].[getEmplCountByEvaluatorID]
	@EvaluatorID AS nchar(6)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	
	
	SELECT COUNT(sae.AssignedSubevaluatorID) as EmplCount
	FROM SubevalAssignedEmplEmplJob sae
	LEFT JOIN SubEval s on sae.SubEvalID = s.EvalID
	WHERE s.EmplID = @EvaluatorID and sae.IsPrimary = 1
	--SELECT COUNT( distinct evidenceID) as EvidenceCount
	--FROM EmplPlanEvidence
	--WHERE EvidenceTypeID = @EvidenceTypeID
	--AND ForeignID = @ForeignID

END

GO
