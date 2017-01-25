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
    @PlanID AS INT ,
    @EvidenceType AS NVARCHAR(50)
AS
    BEGIN
        SET NOCOUNT ON;
        IF ( @EvidenceType IS NOT NULL
             AND ( @EvidenceType = 'Standard Evidence' )
           )
            BEGIN			
                SELECT	DISTINCT
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
                        ,
                        rsi.StandardText AS DisplayText	
					--,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID + ')' AS CreatedBy
                FROM    dbo.EmplPlanEvidence epe
                        LEFT JOIN dbo.Evidence e ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
                        LEFT JOIN dbo.RubricIndicator ri ON ri.IndicatorID = epe.ForeignID
                                                        AND ( c.CodeText = 'Indicator Evidence' )
                        LEFT JOIN dbo.RubricIndicator rii ON rii.IndicatorID = ri.IndicatorID
                        LEFT JOIN dbo.RubricStandard rsi ON rsi.StandardID = rii.StandardID
			--LEFT JOIN Empl em (NOLOCK) on em.EmplID = e.CreatedByID 
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp
                        WHERE   ( CodeText = 'Indicator Evidence' )
                                AND CodeType = 'EviType' )
			--order by ri.SortOrder
			--ORDER BY EvidenceTypeID, sortOrder, CreatedByDt, EvidenceID
                UNION
                SELECT	DISTINCT
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
                        ,
                        rsi.StandardText AS DisplayText	
					--,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID + ')' AS CreatedBy
                FROM    dbo.EmplPlanEvidence epe
                        LEFT JOIN dbo.Evidence e ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
			--LEFT JOIN RubricIndicator ri on ri.IndicatorID = epe.ForeignID and 
			--LEFT JOIN RubricIndicator rii on rii.IndicatorID = ri.IndicatorID
                        LEFT JOIN dbo.RubricStandard rsi ON rsi.StandardID = epe.ForeignID
                                                        AND ( c.CodeText = 'Standard Evidence' )
			--LEFT JOIN Empl em (NOLOCK) on em.EmplID = e.CreatedByID 
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp
                        WHERE   ( c.CodeText = 'Standard Evidence' )
                                AND CodeType = 'EviType' ); 
			--order by rsi.SortOrder
			--ORDER BY EvidenceTypeID, sortOrder, CreatedByDt, EvidenceID;
			
            END;
	
	
        IF ( @EvidenceType IS NOT NULL
             AND ( @EvidenceType = 'Prescription Evidence' )
           )
            BEGIN			
			--WITH [AllEvidence] as (
                SELECT	DISTINCT
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
                        ,
                        rs.StandardText AS DisplayText
					--,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID + ')' AS CreatedBy
                FROM    dbo.EmplPlanEvidence epe
                        LEFT JOIN dbo.Evidence e ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
                        LEFT JOIN dbo.RubricStandard rs ON rs.StandardID = epe.ForeignID
                                                       AND c.CodeText = 'Standard Evidence'			
			--LEFT JOIN Empl em (NOLOCK) on em.EmplID = e.CreatedByID 
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp
                        WHERE   ( CodeText = 'Standard Evidence' )
                                AND CodeType = 'EviType' )
                ORDER BY epe.ForeignID;
            END;
	
        IF ( @EvidenceType IS NOT NULL
             AND @EvidenceType = 'Goal Evidence'
           )
            BEGIN
                SELECT	DISTINCT
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
                        ,
                        ( ctp.CodeText + '  |  ' + clv.CodeText + '  |  '
                          + pg.GoalText ) AS DisplayText
					--,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID + ')' AS CreatedBy
                FROM    dbo.EmplPlanEvidence epe
                        LEFT JOIN dbo.Evidence e ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
                        LEFT JOIN dbo.PlanGoal pg ON pg.GoalID = epe.ForeignID
                                                 AND c.CodeText = @EvidenceType
                        LEFT JOIN dbo.CodeLookUp ctp ON ctp.CodeID = pg.GoalTypeID
                        LEFT JOIN dbo.CodeLookUp clv ON clv.CodeID = pg.GoalLevelID 	
			--LEFT JOIN Empl em (NOLOCK) on em.EmplID = e.CreatedByID 
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID = ( SELECT   CodeID
                                                   FROM     dbo.CodeLookUp
                                                   WHERE    CodeText = @EvidenceType
                                                            AND CodeType = 'EviType'
                                                 )
                ORDER BY epe.ForeignID;
            END;	
    END;
GO
