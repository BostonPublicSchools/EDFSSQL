SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Newa,Matina	
-- Create date: 10/09/2013
-- Description:	Returns last day of the school calendar
-- =============================================
CREATE PROCEDURE [dbo].[getSchoolCalendarFinalDay]
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @resultDate Date
	
	select Top 1 @resultDate=  CalendarDate from schoolcalendar
	order by calendardate desc

	SELECT @resultDate AS [ReturnDate]

End
GO
