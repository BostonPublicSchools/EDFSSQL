SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author: MATINA NEWA		
-- Create date: 2/21/2013
-- Description:	Get rubric standards/Indicator with Total Count of Evidence of the given PlanID
-- =============================================
CREATE PROCEDURE [dbo].[getRubricStandardsIndicatorsEvidenceCount] @PlanID AS INT
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @myTable TABLE
            (
              pkID INT NOT NULL
                       IDENTITY(1, 1) ,
              EvidenceID INT
            );
        DECLARE @myTableEvidences TABLE
            (
              pkEID INT NOT NULL
                        IDENTITY(1, 1) ,
              EvidenceTypeID INT ,
              EvidenceID INT ,
              PlanID INT ,
              ForeignID INT
            );
        DECLARE @myTableStandard TABLE
            (
              pkIID INT NOT NULL
                        IDENTITY(1, 1) ,
              StandardID INT ,
              StandardText VARCHAR(60)
            ); 
        DECLARE @myTableIndicator TABLE
            (
              pkIID INT NOT NULL
                        IDENTITY(1, 1) ,
              IndicatorID INT ,
              IndicatorDesc VARCHAR(MAX) ,
              IndicatorText VARCHAR(60) ,
              StandardText VARCHAR(60) ,
              StandardID INT ,
              ParentIndicatorID INT ,
              ParentIndicatorText VARCHAR(MAX)
            );

        INSERT  @myTable
                SELECT DISTINCT
                        EvidenceID
                FROM    dbo.EmplPlanEvidence (NOLOCK)
                WHERE   PlanID = @PlanID
                        AND IsDeleted = 0;
	
        DECLARE @iCount INT ,
            @iStart INT;
        SELECT  @iCount = COUNT(pkID)
        FROM    @myTable;
   
        DECLARE @iCountEvi INT ,
            @iStartEvi INT ,
            @iFID INT ,
            @iEvidType INT ,
            @vEvidType VARCHAR(60);
        DECLARE @iEvidenceID INT;

        SET @iStart = 1;
        WHILE @iStart <= @iCount
            BEGIN	
                SELECT  @iEvidenceID = EvidenceID
                FROM    @myTable
                WHERE   pkID = @iStart;	
	
                INSERT  INTO @myTableEvidences --(EvidenceID ,PlanID , ForeignID) 
                        SELECT  ep.EvidenceTypeID ,
                                ep.EvidenceID ,
                                ep.PlanID ,
                                ep.ForeignID
                        FROM    dbo.EmplPlanEvidence ep ( NOLOCK )
                                INNER JOIN dbo.Evidence e ( NOLOCK ) ON ep.EvidenceID = e.EvidenceID
                        WHERE   ep.EvidenceTypeID IN (
                                SELECT  CodeID
                                FROM    dbo.CodeLookUp (NOLOCK)
                                WHERE   CodeText IN ( 'Standard Evidence',
                                                      'Indicator Evidence' ) )
                                AND ep.PlanID = @PlanID
                                AND ep.EvidenceID = @iEvidenceID
                                AND e.IsDeleted = 0
                                AND ep.IsDeleted = 0;
			
	--########START INSERT MISSING STANDARD########--
                INSERT  INTO @myTableStandard
                        SELECT  R.StandardID ,
                                RS.StandardText
                        FROM    ( SELECT    A.EvidenceID ,
                                            A.ForeignID ,
                                            ( CASE WHEN A.EvidenceTypeID = ( SELECT
                                                              CodeID
                                                              FROM
                                                              dbo.CodeLookUp (NOLOCK)
                                                              WHERE
                                                              CodeText IN (
                                                              'Standard Evidence' )
                                                              )
                                                   THEN ( SELECT TOP 1
                                                              StandardID
                                                          FROM
                                                              dbo.RubricIndicator (NOLOCK)
                                                          WHERE
                                                              StandardID = A.ForeignID
                                                        )
                                                   WHEN A.EvidenceTypeID = ( SELECT
                                                              CodeID
                                                              FROM
                                                              dbo.CodeLookUp (NOLOCK)
                                                              WHERE
                                                              CodeText IN (
                                                              'Indicator Evidence' )
                                                              )
                                                   THEN ( SELECT TOP 1
                                                              StandardID
                                                          FROM
                                                              dbo.RubricIndicator (NOLOCK)
                                                          WHERE
                                                              IndicatorID = A.ForeignID
                                                              AND StandardID IN (
                                                              SELECT
                                                              ForeignID
                                                              FROM
                                                              dbo.EmplPlanEvidence (NOLOCK)
                                                              WHERE
                                                              EvidenceID = @iEvidenceID
                                                              AND EvidenceTypeID = ( SELECT
                                                              CodeID
                                                              FROM
                                                              dbo.CodeLookUp (NOLOCK)
                                                              WHERE
                                                              CodeText IN (
                                                              'Standard Evidence' )
                                                              )
                                                              AND IsDeleted = 0
                                                              GROUP BY ForeignID )
                                                        )
                                              END ) pn
                                  FROM      dbo.EmplPlanEvidence A ( NOLOCK )
                                            INNER JOIN dbo.Evidence B ( NOLOCK ) ON A.EvidenceID = B.EvidenceID
                                  WHERE     A.EvidenceTypeID IN (
                                            SELECT  CodeID
                                            FROM    dbo.CodeLookUp (NOLOCK)
                                            WHERE   CodeText IN (
                                                    'Standard Evidence',
                                                    'Indicator Evidence' ) )
                                            AND A.PlanID = @PlanID
                                            AND A.EvidenceID = @iEvidenceID
                                            AND A.IsDeleted = 0
                                            AND B.IsDeleted = 0
                                ) C
                                LEFT JOIN dbo.RubricIndicator R ( NOLOCK ) ON C.ForeignID = R.IndicatorID
                                LEFT JOIN dbo.RubricStandard RS ( NOLOCK ) ON R.StandardID = RS.StandardID
                        WHERE   C.pn IS NULL
                        GROUP BY R.StandardID ,
                                RS.StandardText;
	--######## End insert missing standard########--		
	
                SET @iStart = @iStart + 1;	
            END;

        DECLARE @sStandList VARCHAR(50);

--another loop
        SET @iStartEvi = 1;
        SELECT  @iCountEvi = COUNT(pkEID)
        FROM    @myTableEvidences;
		
        WHILE @iStartEvi <= @iCountEvi
            BEGIN
                SELECT  @iFID = ForeignID
                FROM    @myTableEvidences
                WHERE   pkEID = @iStartEvi;
                SELECT  @iEvidType = EvidenceTypeID
                FROM    @myTableEvidences
                WHERE   pkEID = @iStartEvi;
                SELECT  @vEvidType = CodeText
                FROM    dbo.CodeLookUp (NOLOCK)
                WHERE   CodeID = @iEvidType;
                IF ( @vEvidType = 'Standard Evidence' )
                    BEGIN
                        INSERT  INTO @myTableStandard
                                SELECT  rs.StandardID ,
                                        rs.StandardText
                                FROM    dbo.RubricStandard AS rs ( NOLOCK )
                                        LEFT JOIN dbo.RubricHdr AS ri ON rs.RubricID = ri.RubricID
                                WHERE   rs.StandardID = @iFID;
                    END;
                ELSE
                    IF ( @vEvidType = 'Indicator Evidence' )
                        BEGIN  --indicator + standard
                            INSERT  @myTableIndicator
                                    EXEC dbo.getRubricIndicatorByIndicatorID @IndicatorID = @iFID;
                            SELECT  @sStandList = StandardID
                            FROM    dbo.RubricIndicator (NOLOCK)
                            WHERE   IndicatorID = @iFID;
                        END;	
			
                SET @iStartEvi = @iStartEvi + 1;
            END;

        WITH    cteWithCount
                  AS ( SELECT   COUNT(A.textName) TotalCount ,
                                A.textName StdIndName
                       FROM     --,StandardID,IndicatorID  from
                                ( SELECT    StandardText textName
                                  FROM      @myTableStandard--, StandardID,0 [IndicatorID] 
                                  UNION ALL
                                  SELECT    IndicatorText textName
                                  FROM      @myTableIndicator --, StandardID, IndicatorID 
                                ) A
                       GROUP BY A.textName --,StandardID,IndicatorID  
                     )
            SELECT  cteWithCount.TotalCount ,
                    cteWithCount.StdIndName
            FROM    cteWithCount
            ORDER BY cteWithCount.StdIndName;-- StandardID,IndicatorID
				
    END;
GO
