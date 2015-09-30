SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Name:	GetSchoolWorkingDate
-- Create date: 07/16/2013
-- Description:	This function calculates the school working date after a 5 number of days 
-- select dbo.GetSchoolWorkingDateNew('2013/07/07') 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
CREATE FUNCTION [dbo].[GetSchoolWorkingDateNew] (@Date_from AS date) 
RETURNS smalldatetime
AS
BEGIN 
	
	--declare @Date_from AS date
	--set @Date_from='2013/04/01'
		
	   Declare @resultDate Date 
	   select top 1 @resultDate= CalendarDate from(
		select top 5 * , ROW_NUMBER() over(order by CalendarDate) as 'RowNum'
		from
			SchoolCalendar 
		where CalendarDate > @Date_from  and IsSchoolDay = 1	
			ORDER BY
			CalendarDate 
			) A
			where  A.RowNum = 5
		--print @resultDate
	
	RETURN @resultDate
END



				
GO
