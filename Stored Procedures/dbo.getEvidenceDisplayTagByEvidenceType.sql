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
                        epe.ForeignID ,
                        rsi.StandardText AS DisplayText
                FROM    dbo.EmplPlanEvidence epe ( NOLOCK )
                        LEFT JOIN dbo.Evidence e ( NOLOCK ) ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
                        LEFT JOIN dbo.RubricIndicator ri ( NOLOCK ) ON ( c.CodeText = 'Indicator Evidence' )
                                                              AND ri.IndicatorID = epe.ForeignID
                        LEFT JOIN dbo.RubricIndicator rii ( NOLOCK ) ON rii.IndicatorID = ri.IndicatorID
                        LEFT JOIN dbo.RubricStandard rsi ( NOLOCK ) ON rsi.StandardID = rii.StandardID
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp (NOLOCK)
                        WHERE   ( CodeText = 'Indicator Evidence' )
                                AND CodeType = 'EviType' )
                UNION
                SELECT	DISTINCT
                        epe.ForeignID ,
                        rsi.StandardText AS DisplayText
                FROM    dbo.EmplPlanEvidence epe ( NOLOCK )
                        LEFT JOIN dbo.Evidence e ( NOLOCK ) ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
                        LEFT JOIN dbo.RubricStandard rsi ( NOLOCK ) ON ( c.CodeText = 'Standard Evidence' )
                                                              AND rsi.StandardID = epe.ForeignID
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp (NOLOCK)
                        WHERE   ( c.CodeText = 'Standard Evidence' )
                                AND CodeType = 'EviType' ); 			
            END;
	
	
        IF ( @EvidenceType IS NOT NULL
             AND ( @EvidenceType = 'Prescription Evidence' )
           )
            BEGIN			
                SELECT	DISTINCT
                        epe.ForeignID ,
                        rs.StandardText AS DisplayText
                FROM    dbo.EmplPlanEvidence epe
                        LEFT JOIN dbo.Evidence e ( NOLOCK ) ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
                        LEFT JOIN dbo.RubricStandard rs ( NOLOCK ) ON c.CodeText = 'Standard Evidence'
                                                              AND rs.StandardID = epe.ForeignID
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID IN (
                        SELECT  CodeID
                        FROM    dbo.CodeLookUp (NOLOCK)
                        WHERE   ( CodeText = 'Standard Evidence' )
                                AND CodeType = 'EviType' )
                ORDER BY epe.ForeignID;
            END;
	
        IF ( @EvidenceType IS NOT NULL
             AND @EvidenceType = 'Goal Evidence'
           )
            BEGIN
                SELECT	DISTINCT
                        epe.ForeignID ,
                        ( ctp.CodeText + '  |  ' + clv.CodeText + '  |  '
                          + pg.GoalText ) AS DisplayText
                FROM    dbo.EmplPlanEvidence epe ( NOLOCK )
                        LEFT JOIN dbo.Evidence e ( NOLOCK ) ON e.EvidenceID = epe.EvidenceID
                        JOIN dbo.CodeLookUp c ( NOLOCK ) ON c.CodeID = epe.EvidenceTypeID
                        LEFT JOIN dbo.PlanGoal pg ( NOLOCK ) ON c.CodeText = @EvidenceType
                                                              AND pg.GoalID = epe.ForeignID
                        LEFT JOIN dbo.CodeLookUp ctp ( NOLOCK ) ON ctp.CodeID = pg.GoalTypeID
                        LEFT JOIN dbo.CodeLookUp clv ( NOLOCK ) ON clv.CodeID = pg.GoalLevelID
                WHERE   epe.PlanID = @PlanID
                        AND epe.IsDeleted = 0
                        AND epe.EvidenceTypeID = ( SELECT   CodeID
                                                   FROM     dbo.CodeLookUp (NOLOCK)
                                                   WHERE    CodeText = @EvidenceType
                                                            AND CodeType = 'EviType'
                                                 )
                ORDER BY epe.ForeignID;
            END;	
    END;
GO
