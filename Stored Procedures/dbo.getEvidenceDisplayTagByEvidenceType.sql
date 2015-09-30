SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 07/09/2013
-- Description:	Get evidence display tag by EvidenceID and evidenceType
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceDisplayTagByEvidenceType]
	@PlanID AS int,
	@EvidenceType As nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	IF (@EvidenceType IS NOT NULL AND (@EvidenceType = 'Standard Evidence'))
		BEGIN			
			SELECT	distinct
					--epe.PlanEvidenceID, epe.EvidenceID
					--,epe.PlanID
					--,epe.EvidenceTypeID		
					--,c.CodeText as EvidenceType
					--,e.Description
					--,e.Rationale
					epe.ForeignID
					--,e.[FileName]
					--,e.FileExt
					--,e.FileSize
					--,e.CreatedByID	
					--,e.CreatedByDt			
					--,ri.IndicatorText as tagText
					--,ri.SortOrder as sortOrder	
					,rsi.StandardText as DisplayText	
					--,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID + ')' AS CreatedBy
			FROM EmplPlanEvidence epe
			LEFT JOIN Evidence e ON e.EvidenceID = epe.EvidenceID 
			JOIN CodeLookUp c (nolock) on c.CodeID = epe.EvidenceTypeID
			LEFT JOIN RubricIndicator ri on ri.IndicatorID = epe.ForeignID and (c.CodeText = 'Indicator Evidence' )
			LEFT JOIN RubricIndicator rii on rii.IndicatorID = ri.IndicatorID
			LEFT JOIN RubricStandard rsi on rsi.StandardID = rii.StandardID
			--LEFT JOIN Empl em (NOLOCK) on em.EmplID = e.CreatedByID 
			WHERE epe.PlanID = @PlanID
			AND epe.IsDeleted = 0 
			AND epe.EvidenceTypeID IN (SELECT codeID from CodeLookUp where (CodeText = 'Indicator Evidence' )  and CodeType='EviType')
			--order by ri.SortOrder
			--ORDER BY EvidenceTypeID, sortOrder, CreatedByDt, EvidenceID

			
			UNION 
			
			SELECT	distinct
					--epe.PlanEvidenceID, epe.EvidenceID
					--,epe.PlanID
					--,epe.EvidenceTypeID		
					--,c.CodeText as EvidenceType
					--,e.Description
					--,e.Rationale
					epe.ForeignID
					--,e.[FileName]
					--,e.FileExt
					--,e.FileSize
					--,e.CreatedByID	
					--,e.CreatedByDt			
					--,rsi.StandardText as tagText
					--,rsi.SortOrder as sortOrder	
					,rsi.StandardText as DisplayText	
					--,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID + ')' AS CreatedBy
			FROM EmplPlanEvidence epe
			LEFT JOIN Evidence e ON e.EvidenceID = epe.EvidenceID 
			JOIN CodeLookUp c (nolock) on c.CodeID = epe.EvidenceTypeID
			--LEFT JOIN RubricIndicator ri on ri.IndicatorID = epe.ForeignID and 
			--LEFT JOIN RubricIndicator rii on rii.IndicatorID = ri.IndicatorID
			LEFT JOIN RubricStandard rsi on rsi.StandardID = epe.ForeignID and (c.CodeText ='Standard Evidence')
			--LEFT JOIN Empl em (NOLOCK) on em.EmplID = e.CreatedByID 
			WHERE epe.PlanID = @PlanID
			AND epe.IsDeleted = 0 
			AND epe.EvidenceTypeID IN (SELECT codeID from CodeLookUp where ( c.CodeText ='Standard Evidence')  and CodeType='EviType') 
			--order by rsi.SortOrder
			--ORDER BY EvidenceTypeID, sortOrder, CreatedByDt, EvidenceID;
			
		END
	
	
	IF (@EvidenceType IS NOT NULL AND (@EvidenceType = 'Prescription Evidence'))
		BEGIN			
			--WITH [AllEvidence] as (
			SELECT	distinct
					--epe.PlanEvidenceID,
					--epe.EvidenceID
					--,epe.PlanID
					--,epe.EvidenceTypeID		
					--,c.CodeText as EvidenceType
					--,e.Description
					--,e.Rationale
					epe.ForeignID
					--,e.[FileName]
					--,e.FileExt
					--,e.FileSize
					--,e.CreatedByID	
					--,e.CreatedByDt			
					--,rs.StandardText as tagText		
					--,rs.SortOrder as sortOrder
					,rs.StandardText as DisplayText
					--,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID + ')' AS CreatedBy
			FROM EmplPlanEvidence epe
			LEFT JOIN Evidence e ON e.EvidenceID = epe.EvidenceID 
			JOIN CodeLookUp c (nolock) on c.CodeID = epe.EvidenceTypeID
			LEFT JOIN RubricStandard rs on rs.StandardID = epe.ForeignID and c.CodeText = 'Standard Evidence'			
			--LEFT JOIN Empl em (NOLOCK) on em.EmplID = e.CreatedByID 
			WHERE epe.PlanID = @PlanID
			AND epe.IsDeleted = 0 
			AND epe.EvidenceTypeID IN (SELECT codeID from CodeLookUp where (CodeText = 'Standard Evidence')  and CodeType='EviType'	) 	
			order by epe.ForeignID
			--ORDER BY EvidenceTypeID, sortOrder, CreatedByDt, EvidenceID
			
			--UNION
			
			--SELECT	epe.PlanEvidenceID, epe.EvidenceID
			--		,epe.PlanID
			--		,epe.EvidenceTypeID		
			--		,c.CodeText as EvidenceType
			--		,e.Description
			--		,e.Rationale
			--		,epe.ForeignID
			--		,e.[FileName]
			--		,e.FileExt
			--		,e.FileSize
			--		,e.CreatedByID	
			--		,e.CreatedByDt			
			--		,ri.IndicatorText as tagText		
			--		,ri.SortOrder as sortOrder		
			--FROM EmplPlanEvidence epe
			--LEFT JOIN Evidence e ON e.EvidenceID = epe.EvidenceID 
			--JOIN CodeLookUp c (nolock) on c.CodeID = epe.EvidenceTypeID
			--LEFT JOIN RubricIndicator ri on ri.IndicatorID = epe.ForeignID and c.CodeText = 'Indicator Evidence'
			--WHERE epe.PlanID = @PlanID
			--AND epe.IsDeleted = 0 
			--AND epe.EvidenceTypeID IN (SELECT codeID from CodeLookUp where (CodeText = 'Indicator Evidence')  and CodeType='EviType') 	
			
			--SELECT * FROM AllEvidence
			--ORDER BY EvidenceTypeID, sortOrder, CreatedByDt, EvidenceID
		END
	
	IF (@EvidenceType IS NOT NULL AND @EvidenceType = 'Goal Evidence')
		BEGIN
				SELECT	distinct
					--epe.PlanEvidenceID
					--,epe.EvidenceID
					--,epe.PlanID
					--,epe.EvidenceTypeID		
					--,c.CodeText as EvidenceType
					--,e.Description
					--,e.Rationale
					epe.ForeignID
					--,e.[FileName]
					--,e.FileExt
					--,e.FileSize
					--,e.CreatedByID	
					--,e.CreatedByDt			
					--,(pg.GoalText) as tagText								
					--,0 as standardsortOrder
					--,0 as indicatorsortOrder		
					,(ctp.CodeText +'  |  ' + clv.CodeText+'  |  ' +  pg.GoalText) as DisplayText
					--,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID + ')' AS CreatedBy
			FROM EmplPlanEvidence epe
			LEFT JOIN Evidence e ON e.EvidenceID = epe.EvidenceID 
			JOIN CodeLookUp c (nolock) on c.CodeID = epe.EvidenceTypeID
			LEFT JOIN PlanGoal pg on pg.GoalID = epe.ForeignID and c.CodeText = @EvidenceType
			LEFT JOIN CodeLookUp ctp on ctp.CodeID = pg.GoalTypeID 
			LEFT JOIN CodeLookUp clv on clv.CodeID = pg.GoalLevelID 	
			--LEFT JOIN Empl em (NOLOCK) on em.EmplID = e.CreatedByID 
			WHERE epe.PlanID = @PlanID
			AND epe.IsDeleted = 0 
			AND epe.EvidenceTypeID = (SELECT codeID from CodeLookUp where CodeText = @EvidenceType and CodeType='EviType') 		
			Order by epe.ForeignID
		END	
END
GO
