SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Name:	GetSchoolWorkingDate
-- Create date: 12/04/2012
-- Description:	This function calculates the school working date after a 5 number of days 
-- select dbo.GetSchoolWorkingDate('2013/07/01') 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
CREATE FUNCTION [dbo].[GetSchoolWorkingDate] (@Date_from AS date) 
RETURNS smalldatetime
AS
BEGIN 	
	   DECLARE @resultDate Date 
	   
	   SELECT TOP 1 @resultDate= CalendarDate from(
			SELECT TOP 5 * , ROW_NUMBER() OVER(ORDER BY CalendarDate) AS 'RowNum'
			FROM
				SchoolCalendar 
			WHERE CalendarDate > @Date_from  and IsSchoolDay = 1	
				ORDER BY
				CalendarDate 
				) A
		WHERE  A.RowNum = 5
		--print @resultDate
	--return @resultDate
	RETURN CAST(CONVERT(VARCHAR(10), @resultDate, 110) + ' 23:59:59' AS DATETIME)  --@resultDate
END


GO
