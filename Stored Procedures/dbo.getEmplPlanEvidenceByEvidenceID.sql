SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/30/2012
-- Description:	Get  Evidence by EvidenceID
--				[hasIndicator]: tells if the standard contains its corresponding indicator or not
-- =============================================
CREATE PROCEDURE [dbo].[getEmplPlanEvidenceByEvidenceID]
	@EvidenceID AS int,
	@IsDisplayDeleted AS bit=0  -- display (deleted)tags of deleted evidence
AS
BEGIN
	SET NOCOUNT ON;

with cte 
as
(
	select EvidenceID, standardID
	from EmplPlanEvidence e inner join RubricIndicator on IndicatorID=e.ForeignID
	where e.EvidenceID=@EvidenceID and e.IsDeleted=@IsDisplayDeleted and e.EvidenceTypeID =265
)

SELECT	epe.PlanEvidenceID
		,epe.EvidenceID
		,epe.PlanID
		,epe.EvidenceTypeID
		,c.CodeText as EvidenceType
		,e.Description
		,e.Rationale
		,epe.ForeignID
		,e.[FileName]
		,e.FileExt
		,e.FileSize
		,e.CreatedByID
		,e.IsEvidenceViewed
		,e.EvidenceViewedDt
		,e.EvidenceViewedBy
		,(case 
			when EvidenceTypeID =(select CodeID from CodeLookUp where CodeText  in('Indicator Evidence')) then (select StandardID from RubricIndicator  where IndicatorID=ForeignID)
		end ) [StandardID]		
		,(case  when  epe.EvidenceTypeID =(select CodeID from CodeLookUp where CodeText  in('Standard Evidence'))
				then	case when   
								(select COUNT(ct.EvidenceID) from  cte ct
								 where ct.standardID =epe.ForeignID  
								 group by ct.EvidenceID ) >0 
							then 'Yes'
							else 'No'
						end
		 end ) [hasIndicator]		
 
FROM EmplPlanEvidence epe
LEFT JOIN Evidence e ON e.EvidenceID = epe.EvidenceID
JOIN CodeLookUp c (nolock) on c.CodeID = epe.EvidenceTypeID
WHERE epe.EvidenceID = @EvidenceID
AND epe.IsDeleted = @IsDisplayDeleted
order by c.CodeSortOrder 

END
GO
