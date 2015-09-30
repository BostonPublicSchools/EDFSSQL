SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
--procedure to extract school calendar from aspen
-- =============================================
Create PROCEDURE [dbo].[ExtractSchoolCalendarAspen]

AS
BEGIN
	SET NOCOUNT ON;
	
DECLARE @tempCalendar table(calDatea Date, SchYear nvarchar(10), IsSchoolDay bit, DayNum int null)

INSERT INTO @tempCalendar
        ( calDatea ,
          SchYear ,
          IsSchoolDay ,
          DayNum
        )     
select CAL_DATE AS CalDate, CTX_CONTEXT_ID AS SchYear, ISNULL(CAL_IN_SESSION_IND, 0) AS IsSchoolDay, 0 AS 'DayNum' 
FROM BPSData.ExtractAspen.dbo.CALENDAR 
JOIN BPSData.ExtractAspen.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT on CTX_OID = CAL_CTX_OID and CTX_CONTEXT_ID in ('2012-2013','2013-2014','2014-2015')

UPDATE tc  SET tc.DayNum = ISNULL(temp2Cal.DayNum, 0)
FROM @tempCalendar tc
INNER JOIN (
SELECT   
   scUpdate.SchYear,   
   scUpdate.calDatea,   
   COUNT(*) AS 'DayNum' -- Number of school days less than or equal to cur day is what day it is in the calendar.  
  FROM @tempCalendar scUpdate  
  INNER JOIN @tempCalendar scLarger   
   ON scLarger.SchYear = scUpdate.SchYear  
   AND scLarger.isSchoolDay = 1  
   AND scLarger.calDatea <= scUpdate.calDatea   
  WHERE scUpdate.isSchoolDay = 1  
  AND scUpdate.schyear COLLATE SQL_Latin1_General_CP1_CS_AS IN  
  (  
   SELECT CTX_CONTEXT_ID  
   FROM BPSData.ExtractAspen.dbo.CALENDAR   
   INNER JOIN BPSData.ExtractAspen.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT ON CTX_OID = CAL_CTX_OID  and CTX_CONTEXT_ID in ('2012-2013','2013-2014','2014-2015')
   GROUP BY CTX_CONTEXT_ID  
   HAVING COUNT(*) > 175  
  )  
  GROUP BY scUpdate.SchYear, scUpdate.calDatea  ) AS temp2Cal ON temp2Cal.calDatea = tc.calDatea AND temp2Cal.SchYear = tc.SchYear

SELECT * FROM @tempCalendar

		
END
GO
