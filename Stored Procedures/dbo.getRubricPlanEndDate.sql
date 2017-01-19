SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Gets RubricPlanEndDate associated with given RubricPlanTypeID
-- exec getRubricPlanEndDate
-- exec getRubricPlanEndDate null,3
-- exec getRubricPlanEndDate 1
--add fetaure to work early plan year change
-- =============================================
CREATE PROCEDURE [dbo].[getRubricPlanEndDate]
       @RubricPlanTypeID INT = NULL ,
       @RubricID INT = NULL
AS
       BEGIN
             SET NOCOUNT ON;

             DECLARE @CurrentSchYear VARCHAR(9) ,
                     @NextSchYear VARCHAR(9);  -- 2013-2014, 2014-2015

             SET @CurrentSchYear = (
                                     SELECT DISTINCT RTRIM(SchYear)
                                     FROM   SchoolCalendar
                                     WHERE  CalendarDate = CONVERT(VARCHAR, GETDATE(), 101)
                                   ); 	
             SET @NextSchYear = SUBSTRING(@CurrentSchYear, 6, 4) + '-'
                 + CONVERT(VARCHAR, ( SUBSTRING(@CurrentSchYear, 6, 4) + 1 ));

             IF EXISTS ( SELECT *
                         FROM   dbo.PlanYearChangeTable )
                BEGIN
                      SELECT    @CurrentSchYear = CONVERT(VARCHAR, SchYearValue)
                      FROM      dbo.PlanYearChangeTable
                      WHERE     SchYearType = 'First';
                      SELECT    @NextSchYear = CONVERT(VARCHAR, SchYearValue)
                      FROM      dbo.PlanYearChangeTable
                      WHERE     SchYearType = 'Second';
                END;
--print @CurrentSchYear
--print @NextSchYear
--Note
--declare @tmp varchar(10)='5/15'
----set @tmp = Case when Convert(int, substring(@tmp,1,CHARINDEX('/',@tmp)-1) ) >6 then '7-12' else '1-6' End
--set @tmp = Case when Convert(int, substring(@tmp,1,CHARINDEX('/',@tmp)-1) ) <7 
--					then  @tmp+'/'+SUBSTRING(@NextSchYear,6,4) -- '1-6' 
--				else @tmp+'/'+SUBSTRING(@NextSchYear,1,4) -- '7-12'
--			End
--print @tmp


             SELECT rptedt.PlanEndDateID ,
                    rpt.RubricPlanTypeID ,
                    rpt.RubricID ,
                    rptedt.EndTypeID ,
                    cdE.CodeText [EndTypeText] ,
                    rptedt.PlanEndDateTypeID ,
                    cdEdt.CodeText [PlanEndDateTypeText] ,
                    rptedt.DefaultPlanEndDate ,
                    rptedt.IsActive ,
                    rh.RubricName ,
                    rpt.PlanTypeID ,
                    clRptPl.CodeText [PlanType] ,
                    ( CASE WHEN cdEdt.CodeText = 'End of Year One'
                           THEN ( CASE WHEN CONVERT(INT, SUBSTRING(rptedt.DefaultPlanEndDate,
                                                              1,
                                                              CHARINDEX('/',
                                                              rptedt.DefaultPlanEndDate)
                                                              - 1)) < 7
                                       THEN RTRIM(rptedt.DefaultPlanEndDate)
                                            + '/' + SUBSTRING(@CurrentSchYear,
                                                              6, 4) -- '1-6' 
                                       ELSE RTRIM(rptedt.DefaultPlanEndDate)
                                            + '/' + SUBSTRING(@CurrentSchYear,
                                                              1, 4) -- '7-12'
                                  END )
                           WHEN cdEdt.CodeText = 'End of Year Two'
                           THEN ( CASE WHEN CONVERT(INT, SUBSTRING(rptedt.DefaultPlanEndDate,
                                                              1,
                                                              CHARINDEX('/',
                                                              rptedt.DefaultPlanEndDate)
                                                              - 1)) < 7
                                       THEN RTRIM(rptedt.DefaultPlanEndDate)
                                            + '/' + SUBSTRING(@NextSchYear, 6,
                                                              4) -- '1-6' 
                                       ELSE RTRIM(rptedt.DefaultPlanEndDate)
                                            + '/' + SUBSTRING(@NextSchYear, 1,
                                                              4) -- '7-12'
                                  END )
			--When cdEdt.CodeText = 'Duration Greater than' Then Convert(Varchar,1+ DATEADD(dd,CONVERT(int, rptedt.DefaultPlanEndDate),getdate() ),101 )			
                           WHEN cdEdt.CodeText = 'Duration Greater than'
                           THEN (
                                  SELECT TOP 1
                                            CalendarDate
                                  FROM      SchoolCalendar
                                  WHERE     CalendarDate >= CONVERT(VARCHAR, 1
                                            + DATEADD(dd,
                                                      CONVERT(INT, rptedt.DefaultPlanEndDate),
                                                      GETDATE()), 101)
                                            AND IsSchoolDay = 1
                                  ORDER BY  CalendarDate
                                )
                      END ) AS DefaultFullPlanEndDate ,
                    rptedt.DefaultFormativeValue ,
                    ( CASE WHEN ( rptedt.DefaultFormativeValue != ''
                                  OR rptedt.DefaultFormativeValue IS NOT NULL
                                )
                                AND ( cdEdt.CodeText = 'End of Year One'
                                      OR cdEdt.CodeText = 'End of Year Two'
                                    )
                           THEN ( CASE WHEN CONVERT(INT, SUBSTRING(rptedt.DefaultPlanEndDate,
                                                              1,
                                                              CHARINDEX('/',
                                                              rptedt.DefaultFormativeValue)
                                                              - 1)) < 7
                                       THEN RTRIM(rptedt.DefaultFormativeValue)
                                            + '/' + SUBSTRING(@CurrentSchYear,
                                                              6, 4) -- '1-6' 
                                       ELSE RTRIM(rptedt.DefaultFormativeValue)
                                            + '/' + SUBSTRING(@CurrentSchYear,
                                                              1, 4) -- '7-12'
                                  END )
                           ELSE ISNULL(rptedt.DefaultFormativeValue, '')
                      END ) AS DefaultFormativeDate ,
                    ISNULL(rptedt.DefaultPlanEndDateMax, '') DefaultPlanEndDateMax ,
                    ( CASE WHEN cdEdt.CodeText = 'Duration Greater than'
                                AND rptedt.DefaultPlanEndDateMax IS NOT NULL
                           THEN CONVERT(VARCHAR(10), ISNULL((
                                                              SELECT TOP 1
                                                              CalendarDate
                                                              FROM
                                                              SchoolCalendar
                                                              WHERE
                                                              CalendarDate >= CONVERT(VARCHAR, 1
                                                              + DATEADD(dd,
                                                              CONVERT(INT, rptedt.DefaultPlanEndDateMax),
                                                              GETDATE()), 101)
                                                              AND IsSchoolDay = 1
                                                              ORDER BY CalendarDate
                                                            ),
                                                            (
                                                              SELECT
                                                              CONVERT(VARCHAR, 1
                                                              + DATEADD(dd,
                                                              CONVERT(INT, rptedt.DefaultPlanEndDateMax),
                                                              GETDATE()), 101)
                                                            )--(Select top 1 CalendarDate from schoolcalendar where isSchoolday=1 order by calendardate desc)
											  ))
                      END ) AS DefaultFullPlanEndDateMax	-- TAKES MAX DATE 364days OF CALENDAR IF DATE IS NOT IN CALENDAR
             FROM   RubricPlanType rpt
             INNER JOIN RubricPlanTypeEndDate rptedt ON rpt.RubricPlanTypeID = rptedt.RubricPlanTypeID
             INNER JOIN CodeLookUp cdEdt ON rptedt.PlanEndDateTypeID = cdEdt.CodeID
                                            AND cdEdt.CodeType = 'EndDtType'
                                            AND cdEdt.CodeActive = 1
             INNER JOIN CodeLookUp cdE ON rptedt.EndTypeID = cdE.CodeID
                                          AND cdE.CodeType = 'EndType'
                                          AND cdE.CodeActive = 1
             INNER JOIN RubricHdr rh ON rh.RubricID = rpt.RubricID
             LEFT JOIN CodeLookUp clRptPl ON clRptPl.CodeID = rpt.PlanTypeID
                                             AND clRptPl.CodeType = 'PlanType'
             WHERE  rpt.IsActive = 1 --AND rptedt.IsActive=1	
                    AND rptedt.RubricPlanTypeID = ( CASE WHEN @RubricPlanTypeID IS NOT NULL
                                                         THEN @RubricPlanTypeID
                                                         ELSE rptedt.RubricPlanTypeID
                                                    END )
                    AND rpt.RubricID = ( CASE WHEN @RubricID IS NOT NULL
                                              THEN @RubricID
                                              ELSE rpt.RubricID
                                         END );
	
       END;


GO
