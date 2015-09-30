SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Avery, Bryc
-- Create date: 12/04/2012
-- Description:	Returns calulated school date
--				Updated By Matina, with dynamic sql
--		@schoolYear: Not used here
--		exec getSchoolCalendarbyDate '2013-2014','2013/09/04',5
-- =============================================
CREATE PROCEDURE [dbo].[getSchoolCalendarbyDate]
	@schoolYear as nchar(9)=null
	,@firstDate as date
	,@numberOfDays as int

AS
BEGIN
	SET NOCOUNT ON;

	Declare @query nvarchar(max)
	Declare @resultDate Date
	
	select @query=' SELECT TOP 1 @resultDate = CalendarDate from('+
			'SELECT TOP ' + CAST(@numberOfDays as nvarchar(4)) + ' CalendarDate , ROW_NUMBER() OVER(ORDER BY CalendarDate) as [RowNum]
			FROM
				SchoolCalendar 
			WHERE CalendarDate > '''+ CAST(@firstDate as nvarchar(12))+'''  and IsSchoolDay = 1	
				ORDER BY
				CalendarDate 
				) A
				WHERE  A.RowNum = '+ CAST(@numberOfDays as nvarchar(4))
				
	
	EXECUTE sp_executesql @query, N'@days int,@resultDate date OUTPUT ', @numberOfDays,@resultDate OUTPUT
	
	SELECT @resultDate AS [ReturnDate]
END

GO
