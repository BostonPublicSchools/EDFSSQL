SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Newa,Matina
-- Create date: 05/07/2013
-- Description:	Filters the artifacts. It depends upon the filter criteria- Rubric, goal, standard and indicator tags 
--				exec FilterArtifacts_results @RubricID=1,@StandardFilter='',@IndicatorFilter='',@GoalFilter='7'
-- =============================================
CREATE PROCEDURE [dbo].[FilterArtifacts_Results]
    @RubricID INT = 1 ,
    @StandardFilter VARCHAR(MAX) = NULL ,
    @IndicatorFilter VARCHAR(MAX) = NULL ,
    @GoalFilter VARCHAR(MAX) = NULL
AS
    BEGIN

        IF @StandardFilter = ''
            SET @StandardFilter = N'null';
        IF @IndicatorFilter = ''
            SET @IndicatorFilter = N'null';	
        IF @GoalFilter = ''
            SET @GoalFilter = N'null';

	
        DECLARE @Sqlcte NVARCHAR(MAX);
        DECLARE @SqlResult NVARCHAR(MAX);

        WITH    Evidence_cte
                  AS ( SELECT DISTINCT
                                ev.EvidenceID ,
                                epe.PlanID ,
                                ( e.NameLast + ', ' + e.NameFirst ) Employee ,
                                ev.FileName ,
                                ev.FileExt ,
                                CONVERT(DATETIME, CONVERT(VARCHAR(10), ev.CreatedByDt, 110), 111) [CreatedByDt] ,
                                ( evempl.NameLast + ', ' + evempl.NameFirst ) CreatedBy ,
                                ev.CreatedByID ,
                                ej.EmplJobID ,
                                e.EmplID
                       FROM     Evidence ev
                                INNER JOIN EmplPlanEvidence epe ON epe.EvidenceID = ev.EvidenceID
                                INNER JOIN EmplPlan ep ON ep.PlanID = epe.PlanID
                                                          AND ep.IsInvalid = 0
                                INNER JOIN EmplEmplJob ej ON ep.EmplJobID = ej.EmplJobID
                                INNER JOIN Empl e ON ej.EmplID = e.EmplID
                                INNER JOIN Empl evempl ON ev.CreatedByID = evempl.EmplID
                       WHERE    epe.IsDeleted = 0
                                AND ev.IsDeleted = 0
                                AND ej.RubricID = @RubricID
                                AND epe.EvidenceID IN (
                                SELECT DISTINCT
                                        ( evd_stnd.EvidenceID )
                                FROM    EmplPlanEvidence evd_stnd
                                WHERE   ( evd_stnd.EvidenceTypeID IN ( 109 )
                                          AND evd_stnd.IsDeleted = 0
                                          AND evd_stnd.ForeignID IN (
                                          SELECT    Item
                                          FROM      dbo.SplitInts(@StandardFilter,
                                                              ',') )
                                        )
                                        OR ( evd_stnd.EvidenceTypeID = 265
                                             AND evd_stnd.IsDeleted = 0
                                             AND evd_stnd.ForeignID IN (
                                             SELECT Item
                                             FROM   dbo.SplitInts(@IndicatorFilter,
                                                              ',') )
                                           )
                                UNION
                                SELECT DISTINCT
                                        ( evd_goal.EvidenceID )
                                FROM    EmplPlanEvidence evd_goal
                                        INNER JOIN PlanGoal pl ON evd_goal.PlanID = pl.PlanID
                                WHERE   evd_goal.EvidenceTypeID = 108
                                        AND evd_goal.IsDeleted = 0
                                        AND evd_goal.ForeignID = pl.GoalID
                                        AND evd_goal.PlanID = pl.PlanID
                                        AND pl.GoalTypeID IN (
                                        SELECT  Item
                                        FROM    dbo.SplitInts(@GoalFilter, ',') ) )
                     )
            SELECT  MainResult.EvidenceID ,
                    MainResult.PlanID ,
                    MainResult.Employee ,
                    MainResult.EmplID ,
                    MainResult.FileName ,
                    MainResult.FileExt ,
                    MainResult.CreatedByDt ,
                    MainResult.CreatedBy ,
                    MainResult.CreatedByID ,
                    MainResult.EmplJobID ,
                    MainResult.StandardTags ,
                    MainResult.IndicatorTags ,
                    MainResult.GoalTags
            FROM    ( SELECT DISTINCT
                                ev_outside.EvidenceID ,
                                ev_outside.PlanID ,
                                ev_outside.Employee ,
                                ev_outside.EmplID ,
                                ev_outside.FileName ,
                                ev_outside.FileExt ,
                                ev_outside.CreatedByDt ,
                                ev_outside.CreatedBy ,
                                ev_outside.CreatedByID ,
                                ev_outside.EmplJobID ,
                                ( SELECT    STUFF(( SELECT  ', '
                                                            + CAST(StandardText AS VARCHAR(MAX))
                                                    FROM    EmplPlanEvidence evd_tag
                                                            INNER JOIN RubricStandard rs ON evd_tag.ForeignID = rs.StandardID
                                                    WHERE   evd_tag.EvidenceID = ev_outside.EvidenceID
                                                            AND evd_tag.EvidenceTypeID = 109
                                                            AND rs.IsDeleted = 0
                                                    ORDER BY rs.StandardText
                                                  FOR
                                                    XML PATH('')
                                                  ), 1, 1, '')
                                ) AS StandardTags ,
                                ( SELECT    STUFF(( SELECT  ', '
                                                            + CAST(ri.IndicatorText AS VARCHAR(MAX))
                                                    FROM    EmplPlanEvidence evd_tag
                                                            INNER JOIN RubricIndicator ri ON evd_tag.ForeignID = ri.IndicatorID
                                                    WHERE   evd_tag.EvidenceID = ev_outside.EvidenceID
                                                            AND evd_tag.EvidenceTypeID = 265
                                                            AND ri.IsDeleted = 0
                                                    ORDER BY ri.IndicatorText
                                                  FOR
                                                    XML PATH('')
                                                  ), 1, 1, '')
                                ) AS IndicatorTags ,
                                ( SELECT    STUFF(( SELECT  ', '
                                                            + CAST(cl.CodeText AS VARCHAR(MAX))
                                                    FROM    EmplPlanEvidence evd_tag
                                                            INNER JOIN PlanGoal pg ON evd_tag.ForeignID = pg.GoalID
                                                            INNER JOIN CodeLookUp cl ON pg.GoalTypeID = cl.CodeID
                                                    WHERE   evd_tag.EvidenceID = ev_outside.EvidenceID
                                                            AND evd_tag.EvidenceTypeID = 108
                                                            AND pg.IsDeleted = 0
                                                            AND cl.CodeType = 'GoalType'
                                                    ORDER BY cl.CodeText
                                                  FOR
                                                    XML PATH('')
                                                  ), 1, 1, '')
                                ) AS GoalTags
                      FROM      Evidence_cte ev_outside
                    ) AS MainResult
            ORDER BY EvidenceID DESC;
    END;

GO
