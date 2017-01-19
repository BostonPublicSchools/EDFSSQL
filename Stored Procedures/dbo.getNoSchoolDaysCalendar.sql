SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getNoSchoolDaysCalendar]
AS
BEGIN
	select CalendarDate,IsSchoolDay,schyear 
	FROM SchoolCalendar
	WHERE IsSchoolDay=0
	and  replace(SchYear,'-','') >=(select  distinct replace(SchYear,'-','') from SchoolCalendar where CalendarDate =(  SELECT DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))))
	ORDER BY CalendarDate
END
GO
