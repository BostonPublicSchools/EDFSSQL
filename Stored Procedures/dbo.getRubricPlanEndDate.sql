SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Gets RubricPlanEndDate associated with given RubricPlanTypeID
-- exec getRubricPlanEndDate
-- exec getRubricPlanEndDate null,3
-- exec getRubricPlanEndDate 1
--add fetaure to work early plan year change
-- =============================================
CREATE PROCEDURE [dbo].[getRubricPlanEndDate]		
	@RubricPlanTypeID int =null
	,@RubricID int =null
AS
BEGIN
	SET NOCOUNT ON;

Declare @CurrentSchYear varchar(9), @NextSchYear varchar(9)  -- 2013-2014, 2014-2015

set @CurrentSchYear = (select rtrim(SchYear) from SchoolCalendar where CalendarDate = convert(varchar,GETDATE(),101) ) 	
set @NextSchYear = SUBSTRING(@CurrentSchYear,6,4)+'-'+Convert(varchar,( SUBSTRING(@CurrentSchYear,6,4) +1))

if exists(select * from dbo.PlanYearChangeTable)
Begin
	Select @CurrentSchYear = CONVERT(varchar,SchYearValue) from dbo.PlanYearChangeTable where SchYearType='First'
	Select @NextSchYear = CONVERT(varchar,SchYearValue) from dbo.PlanYearChangeTable where SchYearType='Second'
End
--print @CurrentSchYear
--print @NextSchYear
--Note
--declare @tmp varchar(10)='5/15'
----set @tmp = Case when Convert(int, substring(@tmp,1,CHARINDEX('/',@tmp)-1) ) >6 then '7-12' else '1-6' End
--set @tmp = Case when Convert(int, substring(@tmp,1,CHARINDEX('/',@tmp)-1) ) <7 
--					then  @tmp+'/'+SUBSTRING(@NextSchYear,6,4) -- '1-6' 
--				else @tmp+'/'+SUBSTRING(@NextSchYear,1,4) -- '7-12'
--			End
--print @tmp


SELECT 
	 rptedt.PlanEndDateID
	,rpt.RubricPlanTypeID
	,rpt.RubricID
	,rptedt.EndTypeID
	,cdE.CodeText [EndTypeText]
	,rptedt.PlanEndDateTypeID
	,cdEdt.CodeText [PlanEndDateTypeText]
	,rptedt.DefaultPlanEndDate		
	,rptedt.IsActive 
	,rh.RubricName	
	,rpt.PlanTypeID
	,clRptPl.CodeText [PlanType]
	,(Case	
			When cdEdt.CodeText='End of Year One' Then (Case when Convert(int, substring(rptedt.DefaultPlanEndDate,1,CHARINDEX('/',rptedt.DefaultPlanEndDate)-1) ) <7 
																then  RTrim(rptedt.DefaultPlanEndDate)+'/'+SUBSTRING(@CurrentSchYear,6,4) -- '1-6' 
															else RTrim(rptedt.DefaultPlanEndDate)+'/'+SUBSTRING(@CurrentSchYear,1,4) -- '7-12'
														End)
			When cdEdt.CodeText='End of Year Two' Then (Case when Convert(int, substring(rptedt.DefaultPlanEndDate,1,CHARINDEX('/',rptedt.DefaultPlanEndDate)-1) ) <7 
																then  RTrim(rptedt.DefaultPlanEndDate)+'/'+SUBSTRING(@NextSchYear,6,4) -- '1-6' 
															else RTrim(rptedt.DefaultPlanEndDate)+'/'+SUBSTRING(@NextSchYear,1,4) -- '7-12'
														End)
			--When cdEdt.CodeText = 'Duration Greater than' Then Convert(Varchar,1+ DATEADD(dd,CONVERT(int, rptedt.DefaultPlanEndDate),getdate() ),101 )			
			When cdEdt.CodeText = 'Duration Greater than' 
				Then  ( select top 1 calendarDate from schoolcalendar where calendardate >=
					Convert(Varchar,1+ DATEADD(dd,CONVERT(int, rptedt.DefaultPlanEndDate),getdate() ),101 )
						and isSchoolday=1 order by calendardate)
		End ) as DefaultFullPlanEndDate
	, rptedt.DefaultFormativeValue
	,(Case	
			When (rptedt.DefaultFormativeValue!='' or rptedt.DefaultFormativeValue is not null) and (  cdEdt.CodeText='End of Year One' or cdEdt.CodeText='End of Year Two' )
				Then (Case when Convert(int, substring(rptedt.DefaultPlanEndDate,1,CHARINDEX('/',rptedt.DefaultFormativeValue)-1) ) <7 
																then  RTrim(rptedt.DefaultFormativeValue)+'/'+SUBSTRING(@CurrentSchYear,6,4) -- '1-6' 
															else RTrim(rptedt.DefaultFormativeValue)+'/'+SUBSTRING(@CurrentSchYear,1,4) -- '7-12'
														End)
				else ISNULL(rptedt.DefaultFormativeValue,'')
	   End) as DefaultFormativeDate	
	,Isnull(rptedt.DefaultPlanEndDateMax,'') DefaultPlanEndDateMax
	,(Case					
		When cdEdt.CodeText = 'Duration Greater than' And rptedt.DefaultPlanEndDateMax is not null
			Then Convert(Varchar(10), ISNULL( (select top 1 calendarDate from schoolcalendar where calendardate >=
												Convert(Varchar,1+ DATEADD(dd,CONVERT(int, rptedt.DefaultPlanEndDateMax),getdate() ),101 )
													and isSchoolday=1 order by calendardate) 
											  , (Select Convert(Varchar,1+ DATEADD(dd,CONVERT(int, rptedt.DefaultPlanEndDateMax),getdate() ),101) ) --(Select top 1 CalendarDate from schoolcalendar where isSchoolday=1 order by calendardate desc)
											  )
					 )
	End ) as DefaultFullPlanEndDateMax	-- TAKES MAX DATE 364days OF CALENDAR IF DATE IS NOT IN CALENDAR
 
 
FROM 
	RubricPlanType rpt
	inner join RubricPlanTypeEndDate rptedt on rpt.RubricPlanTypeID= rptedt.RubricPlanTypeID
	inner join CodeLookUp cdEdt on rptedt.PlanEndDateTypeID = cdEdt.CodeID and cdEdt.CodeType='EndDtType' and cdEdt.CodeActive=1
	inner join CodeLookUp cdE on rptedt.EndTypeID = cdE.CodeID and cdE.CodeType='EndType' and cdE.CodeActive=1
	inner join RubricHdr rh on rh.RubricID=rpt.RubricID
	left join CodeLookUp clRptPl on clRptPl.CodeID =rpt.PlanTypeID and clRptPl.CodeType='PlanType'
	
WHERE 
	rpt.IsActive=1 --AND rptedt.IsActive=1	
	AND rptedt.RubricPlanTypeID = ( case when @RubricPlanTypeID IS NOT NULL then @RubricPlanTypeID else rptedt.RubricPlanTypeID end )
	AND rpt.RubricID = (CASE WHEN @RubricID IS NOT NULL THEN @RubricID ELSE rpt.RubricID END)
	
END


GO
