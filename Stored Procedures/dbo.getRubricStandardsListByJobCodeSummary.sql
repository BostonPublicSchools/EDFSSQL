SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author: MATINA NEWA		
-- Create date: 2/21/2013
-- Description:	Get rubric standards rating by JobCode
-- =============================================
CREATE PROCEDURE [dbo].[getRubricStandardsListByJobCodeSummary] @JobCode AS
    NCHAR(6)
AS
    BEGIN
        SET NOCOUNT ON;


        DECLARE @myTable TABLE
            (
              pkID INT NOT NULL
                       IDENTITY(1, 1) ,
              StandardID INT ,
              StandardText VARCHAR(60) ,
              JobCode VARCHAR(60) ,
              StandardDesc VARCHAR(MAX) ,
              RubricID INT ,
              RubricName VARCHAR(60)
            );
        DECLARE @myIndTable TABLE
            (
              pkIID INT NOT NULL
                        IDENTITY(1, 1) ,
              IndicatorID INT ,
              StandardID INT ,
              ParentIndicatorID INT ,
              IndicatorText VARCHAR(MAX) ,
              IndicatorDesc VARCHAR(MAX) ,
              IsDeleted BIT ,
              IsActive BIT ,
              SortOrder INT
            );

        INSERT  @myTable
                EXEC dbo.getRubricStandardsListByJobCode @JobCode = @JobCode;

        DECLARE @iCount INT ,
            @iStart INT;
        DECLARE @iStandard INT ,
            @vStandard VARCHAR(60);
        DECLARE @query VARCHAR(MAX);
        SELECT  @iCount = COUNT(pkID)
        FROM    @myTable;

        SET @iStart = 1;

        WHILE @iStart <= @iCount
            BEGIN
                SELECT  @iStandard = StandardID
                FROM    @myTable
                WHERE   pkID = @iStart;
                SELECT  @vStandard = StandardText
                FROM    @myTable
                WHERE   pkID = @iStart;
                INSERT  @myIndTable
                        ( IndicatorID, StandardID )
                VALUES  ( 0, @iStandard );
                INSERT  @myIndTable
                        EXEC dbo.getRubricIndicators @StandardID = @iStandard; 
                SET @iStart = @iStart + 1;	
            END;

--Result 
        SELECT  A.StandardID ,
                B.StandardText ,
                A.IndicatorID ,
                A.IndicatorText ,
                0 COUNT ,
                ( SELECT    CASE WHEN A.IndicatorID = 0 THEN B.StandardText
                                 ELSE '           ' + A.IndicatorText
                            END
                ) StdIndName ,
                ( SELECT    CASE WHEN A.IndicatorID = 0 THEN B.StandardText
                                 ELSE ''
                            END
                ) StdName ,
                ( SELECT    CASE WHEN A.IndicatorID != 0 THEN A.IndicatorText
                                 ELSE ''
                            END
                ) IndName
        FROM    @myIndTable A ,
                @myTable B
        WHERE   A.StandardID = B.StandardID;
    END;
GO
