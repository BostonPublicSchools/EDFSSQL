SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Name:	GetSchoolWorkingDays
-- Create date: 12/04/2012
-- Description:	This function calculates the number of school working days for two given dates
-- 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
CREATE FUNCTION [dbo].[GetSchoolWorkingDays] ( @SchYear as nchar(9), @Date_from AS smalldatetime,  @Date_to AS smalldatetime ) 
RETURNS int
AS
BEGIN 
	Declare 
			@fday int
			,@tday int
			,@fSchYear as nchar(9)
			,@tSchYear as nchar(9)

    select TOP 1
		@fday = SchoolDayNum
		,@fSchYear = SchYear
	from
		SchoolCalendar 
	where 
		CalendarDate >= @Date_from
	and IsSchoolDay = 1

	if cast(left(@SchYear, 4) as int) < cast(left(@fSchYear, 4) as int)
	begin
		set @fday = @fday + 180
	end

	if cast(left(@SchYear, 4) as int) > cast(left(@fSchYear, 4) as int)
	begin
		set @fday = @fday - 180
	end
	
    select TOP 1
		@tday = SchoolDayNum
		,@tSchYear = SchYear
	from
		SchoolCalendar 
	where 
		CalendarDate >= @Date_to 
	and IsSchoolDay = 1	

	if not @SchYear = @tSchYear
	begin
		set @tday = @tday + 180
	end
	
    RETURN (@tday - @fday)
END

GO
