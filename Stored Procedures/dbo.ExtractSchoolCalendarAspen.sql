SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
--procedure to extract school calendar from aspen
-- =============================================
CREATE PROCEDURE [dbo].[ExtractSchoolCalendarAspen]
AS
    BEGIN
        SET NOCOUNT ON;
	
        DECLARE @tempCalendar TABLE
            (
              calDatea DATE ,
              SchYear NVARCHAR(10) ,
              IsSchoolDay BIT ,
              DayNum INT NULL
            );

        INSERT  INTO @tempCalendar
                ( calDatea ,
                  SchYear ,
                  IsSchoolDay ,
                  DayNum
                )
                SELECT  CAL_DATE AS CalDate ,
                        CTX_CONTEXT_ID AS SchYear ,
                        ISNULL(CAL_IN_SESSION_IND, 0) AS IsSchoolDay ,
                        0 AS 'DayNum'
                FROM    [SISSQL-01].x2data.dbo.CALENDAR
                        JOIN [SISSQL-01].x2data.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT ON CTX_OID = CAL_CTX_OID
                                                              AND CTX_CONTEXT_ID IN (
                                                              '2012-2013',
                                                              '2013-2014',
                                                              '2014-2015' );

        UPDATE  tc
        SET     tc.DayNum = ISNULL(temp2Cal.DayNum, 0)
        FROM    @tempCalendar tc
                INNER JOIN ( SELECT scUpdate.SchYear ,
                                    scUpdate.calDatea ,
                                    COUNT(*) AS 'DayNum' -- Number of school days less than or equal to cur day is what day it is in the calendar.  
                             FROM   @tempCalendar scUpdate
                                    INNER JOIN @tempCalendar scLarger ON scLarger.SchYear = scUpdate.SchYear
                                                              AND scLarger.IsSchoolDay = 1
                                                              AND scLarger.calDatea <= scUpdate.calDatea
                             WHERE  scUpdate.IsSchoolDay = 1
                                    AND scUpdate.SchYear COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                                    SELECT  CTX_CONTEXT_ID
                                    FROM    [SISSQL-01].x2data.dbo.CALENDAR
                                            INNER JOIN [SISSQL-01].x2data.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT ON CTX_OID = CAL_CTX_OID
                                                              AND CTX_CONTEXT_ID IN (
                                                              '2012-2013',
                                                              '2013-2014',
                                                              '2014-2015' )
                                    GROUP BY CTX_CONTEXT_ID
                                    HAVING  COUNT(*) > 175 )
                             GROUP BY scUpdate.SchYear ,
                                    scUpdate.calDatea
                           ) AS temp2Cal ON temp2Cal.calDatea = tc.calDatea
                                            AND temp2Cal.SchYear = tc.SchYear;

        SELECT  calDatea ,
                SchYear ,
                IsSchoolDay ,
                DayNum
        FROM    @tempCalendar;

		
    END;
GO
