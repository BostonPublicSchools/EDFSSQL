SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 12/13/2013
-- Description:	View for brower usage and error analyst
-- =============================================
CREATE VIEW [dbo].[BroswerStats]
AS
	select
		'Usage' as DataType
		,cast(CreatedDt as DATE) as CreateDate 
		,case
			when BrowserInfo = 'InternetExplorer11 InternetExplorer 11.0' then 'IE11 IE 11.0'
			when BrowserInfo = 'Mozilla Mozilla 0.0' then 'IE11 IE 11.0'
			else BrowserInfo
		end as BrowserInfo
		,count(Distinct UserID) as UserCount
	from
		UserLog
	group by
		cast(CreatedDt as DATE)
		,case
			when BrowserInfo = 'InternetExplorer11 InternetExplorer 11.0' then 'IE11 IE 11.0'
			when BrowserInfo = 'Mozilla Mozilla 0.0' then 'IE11 IE 11.0'
			else BrowserInfo
		end
	union
	select
		'Usage'
		,cast(CreatedDt as DATE)
		,'Total for Day'
		,count(Distinct UserID)
	from
		UserLog
	group by
		cast(CreatedDt as DATE)
	union
	select
		'Error'
		,cast(CreatedDt as DATE)
		,case
			when Browser = 'InternetExplorer11 InternetExplorer 11.0' then 'IE11 IE 11.0'
			when Browser = 'Mozilla Mozilla 0.0' then 'IE11 IE 11.0'
			else Browser
		end as Browser
		,COUNT(distinct EmplID)
	from 
		ErrorLog 
	group by 
		cast(CreatedDt as DATE)
		,case
			when Browser = 'InternetExplorer11 InternetExplorer 11.0' then 'IE11 IE 11.0'
			when Browser = 'Mozilla Mozilla 0.0' then 'IE11 IE 11.0'
			else Browser
		end
	union
	select
		'Error'
		,cast(CreatedDt as DATE)
		,'Total for Day'
		,COUNT(distinct EmplID)
	from 
		ErrorLog 
	group by 
		cast(CreatedDt as DATE)
	union
	select
		'New Release'
		,ReleaseDate
		,'New release was put in production'
		,1
	from
		Release
GO
