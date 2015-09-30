SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 03/15/2013
-- Description:	Top 10 empl by count of artifacts in active plan
-- =============================================
CREATE PROCEDURE [dbo].[getTopEmplArtifacts]
AS
BEGIN

select top 10 ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') as EmplName
		,e1.EmplID
		,Max(ep.PlanID) as PlanID
		,EmplList.TotalArtifacts
from 
(select eej.EmplID, count(temp.EvidenceID) as TotalArtifacts from 
			(select distinct evi.EvidenceID,evi.FileSize,ep.EmplJobID from Evidence evi
		left join EmplPlanEvidence epe on epe.EvidenceID = evi.EvidenceID
		left join EmplPlan ep on ep.PlanID = epe.PlanID
		where ep.PlanActive = 1 and evi.IsDeleted=0) as temp
		left join EmplEmplJob eej on eej.EmplJobID = temp.EmplJobID
		left join Empl e on eej.EmplID = e.EmplID
		group by eej.EmplID) as EmplList
Left join Empl e1 on e1.EmplID = EmplList.EmplID
left join EmplEmplJob eej on eej.EmplID = e1.EmplID and eej.IsActive = 1
left join EmplPlan ep on ep.EmplJobID = eej.EmplJobID 
group by e1.NameFirst,e1.NameMiddle,e1.NameLast,e1.EmplID,empllist.TotalArtifacts
order by EmplList.TotalArtifacts desc

			
		
END


GO
