SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 11/16/2012
-- Description:	Get evidence by EvidenceID and evidenceType
-- =============================================
CREATE PROCEDURE [dbo].[getEvidenceByEvidenceType]
    @PlanID AS INT ,
    @EvidenceType AS NVARCHAR(50)
AS
    BEGIN
        SET NOCOUNT ON;
        IF ( @EvidenceType IS NOT NULL
             AND ( @EvidenceType = 'Standard Evidence' )
           )
            BEGIN			
                SELECT  epe.PlanEvidenceID ,
                        epe.EvidenceID ,
                        epe.PlanID ,
                        epe.EvidenceTypeID ,
                        c.CodeText AS EvidenceType ,
                        e.Description ,
                        e.Rationale ,
                        epe.ForeignID ,
                        e.FileName ,
                        e.FileExt ,
                        e.FileSize ,
                        e.CreatedByID ,
                        e.CreatedByDt ,
                        ri.IndicatorText AS tagText ,
                        ri.SortOrder AS sortOrder ,
                        rsi.StandardText AS DisplayText ,
                        em.NameLast + ', ' + em.NameFirst + ' '
                        + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID
                        + ')' AS CreatedBy
                FROM    dbo.EmplPlanEvidence epe
                        LEFT JOIN dbo.Evidence e ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
                        LEFT JOIN dbo.RubricIndicator ri ON ri.IndicatorID = epe.ForeignID
                                                            AND ( c.CodeText = 'Indicator Evidence' )
                        LEFT JOIN dbo.RubricIndicator rii ON rii.IndicatorID = ri.IndicatorID
                        LEFT JOIN dbo.RubricStandard rsi ON rsi.StandardID = rii.StandardID
                        LEFT JOIN dbo.Empl em ( NOLOCK ) ON em.EmplID = e.CreatedByID
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp
                        WHERE   ( CodeText = 'Indicator Evidence' )
                                AND CodeType = 'EviType' )
			
			--ORDER BY EvidenceTypeID, sortOrder, CreatedByDt, EvidenceID
                UNION
                SELECT  epe.PlanEvidenceID ,
                        epe.EvidenceID ,
                        epe.PlanID ,
                        epe.EvidenceTypeID ,
                        c.CodeText AS EvidenceType ,
                        e.Description ,
                        e.Rationale ,
                        epe.ForeignID ,
                        e.FileName ,
                        e.FileExt ,
                        e.FileSize ,
                        e.CreatedByID ,
                        e.CreatedByDt ,
                        rsi.StandardText AS tagText ,
                        rsi.SortOrder AS sortOrder ,
                        rsi.StandardText AS DisplayText ,
                        em.NameLast + ', ' + em.NameFirst + ' '
                        + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID
                        + ')' AS CreatedBy
                FROM    dbo.EmplPlanEvidence epe
                        LEFT JOIN dbo.Evidence e ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
			--LEFT JOIN RubricIndicator ri on ri.IndicatorID = epe.ForeignID and 
			--LEFT JOIN RubricIndicator rii on rii.IndicatorID = ri.IndicatorID
                        LEFT JOIN dbo.RubricStandard rsi ON rsi.StandardID = epe.ForeignID
                                                            AND ( c.CodeText = 'Standard Evidence' )
                        LEFT JOIN dbo.Empl em ( NOLOCK ) ON em.EmplID = e.CreatedByID
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp
                        WHERE   ( c.CodeText = 'Standard Evidence' )
                                AND CodeType = 'EviType' )
                ORDER BY epe.EvidenceTypeID ,
                        sortOrder ,
                        CreatedByDt ,
                        EvidenceID;
			
            END;
	
	
        IF ( @EvidenceType IS NOT NULL
             AND ( @EvidenceType = 'Prescription Evidence' )
           )
            BEGIN			
			--WITH [AllEvidence] as (
                SELECT  epe.PlanEvidenceID ,
                        epe.EvidenceID ,
                        epe.PlanID ,
                        epe.EvidenceTypeID ,
                        c.CodeText AS EvidenceType ,
                        e.Description ,
                        e.Rationale ,
                        epe.ForeignID ,
                        e.FileName ,
                        e.FileExt ,
                        e.FileSize ,
                        e.CreatedByID ,
                        e.CreatedByDt ,
                        rs.StandardText AS tagText ,
                        rs.SortOrder AS sortOrder ,
                        rs.StandardText AS DisplayText ,
                        em.NameLast + ', ' + em.NameFirst + ' '
                        + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID
                        + ')' AS CreatedBy
                FROM    dbo.EmplPlanEvidence epe
                        LEFT JOIN dbo.Evidence e ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
                        LEFT JOIN dbo.RubricStandard rs ON rs.StandardID = epe.ForeignID
                                                           AND c.CodeText = 'Standard Evidence'
                        LEFT JOIN dbo.Empl em ( NOLOCK ) ON em.EmplID = e.CreatedByID
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp
                        WHERE   ( CodeText = 'Standard Evidence' )
                                AND CodeType = 'EviType' )
                ORDER BY epe.EvidenceTypeID ,
                        sortOrder ,
                        em.CreatedByDt ,
                        e.EvidenceID;
            END;
	
        IF ( @EvidenceType IS NOT NULL
             AND @EvidenceType = 'Goal Evidence'
           )
            BEGIN
                SELECT  epe.PlanEvidenceID ,
                        epe.EvidenceID ,
                        epe.PlanID ,
                        epe.EvidenceTypeID ,
                        c.CodeText AS EvidenceType ,
                        e.Description ,
                        e.Rationale ,
                        epe.ForeignID ,
                        e.FileName ,
                        e.FileExt ,
                        e.FileSize ,
                        e.CreatedByID ,
                        e.CreatedByDt ,
                        ( pg.GoalText ) AS tagText ,
                        0 AS standardsortOrder ,
                        0 AS indicatorsortOrder ,
                        ( ctp.CodeText + '  |  ' + clv.CodeText + '  |  '
                          + pg.GoalText ) AS DisplayText ,
                        em.NameLast + ', ' + em.NameFirst + ' '
                        + ISNULL(em.NameMiddle, '') + ' (' + e.CreatedByID
                        + ')' AS CreatedBy
                FROM    dbo.EmplPlanEvidence epe
                        LEFT JOIN dbo.Evidence e ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
                        LEFT JOIN dbo.PlanGoal pg ON pg.GoalID = epe.ForeignID
                                                     AND c.CodeText = @EvidenceType
                        LEFT JOIN dbo.CodeLookUp ctp ON ctp.CodeID = pg.GoalTypeID
                        LEFT JOIN dbo.CodeLookUp clv ON clv.CodeID = pg.GoalLevelID
                        LEFT JOIN dbo.Empl em ( NOLOCK ) ON em.EmplID = e.CreatedByID
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID = ( SELECT   CodeID
                                                   FROM     dbo.CodeLookUp
                                                   WHERE    CodeText = @EvidenceType
                                                            AND CodeType = 'EviType'
                                                 )
                ORDER BY epe.ForeignID ,
                        epe.CreatedByDt DESC;
            END;	
    END;
GO
