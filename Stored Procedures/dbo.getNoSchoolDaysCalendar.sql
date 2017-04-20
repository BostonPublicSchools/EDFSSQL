SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getNoSchoolDaysCalendar]
AS
    BEGIN
        SELECT  CalendarDate ,
                IsSchoolDay ,
                SchYear
        FROM    dbo.SchoolCalendar (NOLOCK)
        WHERE   IsSchoolDay = 0
                AND REPLACE(SchYear, '-', '') >= ( SELECT  DISTINCT
                                                            REPLACE(SchYear,
                                                              '-', '')
                                                   FROM     dbo.SchoolCalendar  (NOLOCK)
                                                   WHERE    CalendarDate = ( SELECT
                                                              DATEADD(dd, 0,
                                                              DATEDIFF(dd, 0,
                                                              GETDATE()))
                                                              )
                                                 )
        ORDER BY CalendarDate;
    END;
GO
