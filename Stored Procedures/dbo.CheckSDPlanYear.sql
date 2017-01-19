SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Newa,Matina
-- Create date: June 18, 2013
-- Description:	check if the Plan exists in first or next year. 
--				Output[@IsMultiYearPlan]: O FOR FIRST YEAR AND 1 FOR SECOND YEAR
--				This stored precodure is for Self Directed Plan Only.
--				This checks plan year from Plan Created Data and Plan End Date.
-- =============================================
CREATE PROCEDURE [dbo].[CheckSDPlanYear]
    @CreatedByDt AS DATE --= '01/17/2013'
    ,
    @PlanEndDt AS DATE --='04/01/2015'
    ,
    @IsMultiYearPlan AS BIT = NULL OUTPUT -- O FOR FIRST YEAR AND 1 FOR SECOND YEAR
AS
    BEGIN
        DECLARE @CreatedYearDt AS DATE ,
            @PlanEndYearDt AS DATE;  -- start date 
	--DECLARE @CreatedByDt as date = '2013-01-16 09:12:04.857' -- '05/10/2013'-- '07/01/2013'
	--DECLARE @PlanEndDt as date ='2013-06-30 00:00:00.000' --'05/15/2015'
			
        IF @PlanEndDt IS NOT NULL
            AND @CreatedByDt IS NOT NULL
            BEGIN	
	
	--######### check with PlanYearChangeTable and manipulate coz sometime early plan is filpped before April 15 and not 30 days before april 15, 
	-- Here assumtion is craeted date is before 04/16/XXXX		
                DECLARE @varNowSchYear VARCHAR(9);
                SELECT  @varNowSchYear = SchYear
                FROM    dbo.SchoolCalendar
                WHERE   CalendarDate = @CreatedByDt;
		--select @varNowSchYear
                IF NOT EXISTS ( SELECT  SchYearType ,
                                        SchYearValue
                                FROM    dbo.PlanYearChangeTable
                                WHERE   SchYearValue = @varNowSchYear )
                    BEGIN			
                        DECLARE @NewAddingYear VARCHAR(4); --2014
                        SELECT TOP 1
                                @NewAddingYear = SchYearValue
                        FROM    dbo.PlanYearChangeTable
                        WHERE   SchYearType = 'First';
			--print @NewAddingYear
                        IF DATEDIFF(DAY, @CreatedByDt,
                                    CONVERT(DATETIME, '04/15/'
                                    + @NewAddingYear, 111)) > 0
                            AND DATEDIFF(DAY, @CreatedByDt,
                                         CONVERT(DATETIME, '04/15/'
                                         + @NewAddingYear, 111)) < 30
                            SET @CreatedByDt = '04/16/' + @NewAddingYear;
			--print @CreatedByDt
			--print @CreatedByDt
                    END;
	--#########
	
                DECLARE @sConcatCreatedDt VARCHAR(4) = RIGHT('00'
                                                             + CAST(DATEPART(MM,
                                                              @CreatedByDt) AS VARCHAR(2)),
                                                             2) + RIGHT('00'
                                                              + CAST(DATEPART(dd,
                                                              @CreatedByDt) AS VARCHAR(2)),
                                                              2);
		--PRINT @sConcatCreatedDt
		
                IF CAST(@sConcatCreatedDt AS INT) > 415 --if after April 15- consider goes to next year
                    BEGIN
			--print 'change'			
                        SET @CreatedByDt = '07/01/'
                            + CAST(DATEPART(yyyy, @CreatedByDt) AS VARCHAR(4));
                    END; 
	--Now get calendar start date of Plan Created Date
                SELECT  @CreatedYearDt = CASE WHEN DATEPART(MM, @CreatedByDt) >= 7
                                              THEN '07/01/'
                                                   + CAST(DATEPART(YYYY,
                                                              @CreatedByDt) AS VARCHAR(4))
                                              ELSE '07/01/'
                                                   + CAST(( DATEPART(YYYY,
                                                              @CreatedByDt)
                                                            - 1 ) AS VARCHAR(4))
                                         END;
	--And Now get calendar start date of Plan End Date
                SELECT  @PlanEndYearDt = CASE WHEN DATEPART(MM, @PlanEndDt) >= 7
                                              THEN '07/01/'
                                                   + CAST(DATEPART(YYYY,
                                                              @PlanEndDt) AS VARCHAR(4))
                                              ELSE '07/01/'
                                                   + CAST(( DATEPART(YYYY,
                                                              @PlanEndDt) - 1 ) AS VARCHAR(4))
                                         END;	
		
	--print @CreatedYearDt
	--print @PlanEndYearDt	
	
                DECLARE @dtdiff AS INT ,
                    @iOutput AS VARCHAR(5);
	--set @dtdiff= DATEDIFF(yy,@CreatedYearDt,@PlanEndYearDt)
                PRINT DATEDIFF(yy, @CreatedYearDt, @PlanEndYearDt);
                SET @dtdiff = CAST(DATEPART(YYYY, @PlanEndYearDt) AS INT)
                    - CAST(DATEPART(YYYY, @CreatedYearDt) AS INT); --+1
                IF ( @dtdiff >= 1 )
                    BEGIN
                        SET @iOutput = '2yr';
                        SELECT  @IsMultiYearPlan = 1;
                    END;
                ELSE
                    BEGIN
                        SET @iOutput = '1yr';
                        SELECT  @IsMultiYearPlan = 0;
                    END;
	--print @dtdiff 
	--print @iOutput

            END;
		
        SELECT  @IsMultiYearPlan; 
	
    END;

	
	
GO
