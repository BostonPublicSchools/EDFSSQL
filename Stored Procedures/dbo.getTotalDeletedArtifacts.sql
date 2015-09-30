SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 03/12/2013
-- Description:	Get total number of deleted artifacts
-- =============================================
CREATE PROCEDURE [dbo].[getTotalDeletedArtifacts]
@InActivePlan as bit 
AS
BEGIN
	SET NOCOUNT ON;
	if @InActivePlan = 0
	BEGIN
		select Count(EvidenceID) as TotalArtifacts  from Evidence where IsDeleted = 1
	END
	ELSE
	BEGIN
		select Count(temp.EvidenceID) as TotalArtifacts from 
			(select distinct evi.EvidenceID from Evidence evi
		left join EmplPlanEvidence epe on epe.EvidenceID = evi.EvidenceID
		left join EmplPlan ep on ep.PlanID = epe.PlanID
		where ep.PlanActive = 1 and evi.IsDeleted=1) as temp
		
	END
	
END


GO
