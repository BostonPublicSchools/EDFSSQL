SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Newa,Matina
-- Create date: June 18, 2013
-- Description:	check if the Plan exists in first or next year. 
--				Output[@IsMultiYearPlan]: O FOR FIRST YEAR AND 1 FOR SECOND YEAR
--				This stored precodure is for Self Directed Plan Only.
--				This checks plan year from Plan Created Data and Plan End Date.
-- =============================================
CREATE PROCEDURE [dbo].[CheckSDPlanYear]
	@CreatedByDt as date --= '01/17/2013'
	,@PlanEndDt as date --='04/01/2015'
	,@IsMultiYearPlan as bit=null OUTPUT -- O FOR FIRST YEAR AND 1 FOR SECOND YEAR
AS
BEGIN
	DECLARE @CreatedYearDt as date, @PlanEndYearDt as date  -- start date 
	--DECLARE @CreatedByDt as date = '2013-01-16 09:12:04.857' -- '05/10/2013'-- '07/01/2013'
	--DECLARE @PlanEndDt as date ='2013-06-30 00:00:00.000' --'05/15/2015'
			
	IF @PlanEndDt IS NOT NULL AND @CreatedByDt IS NOT NULL
	BEGIN	
	
	--######### check with PlanYearChangeTable and manipulate coz sometime early plan is filpped before April 15 and not 30 days before april 15, 
	-- Here assumtion is craeted date is before 04/16/XXXX		
		Declare @varNowSchYear varchar(9)
		select @varNowSchYear = SchYear from SchoolCalendar where CalendarDate=@CreatedByDt
		--select @varNowSchYear
		if not exists(select * from PlanYearChangeTable where schyearvalue =@varNowSchYear)
		begin			
			Declare @NewAddingYear varchar(4) --2014
			select top 1 @NewAddingYear= schYearValue  from PlanYearChangeTable where schYearType='First'
			--print @NewAddingYear
			IF DateDiff(day,@CreatedByDt, CONVERT(datetime, '04/15/'+@NewAddingYear,111) ) >0 AND
				DateDiff(day,@CreatedByDt, CONVERT(datetime, '04/15/'+@NewAddingYear,111) ) <30
				Set @CreatedByDt='04/16/'+@NewAddingYear
			--print @CreatedByDt
			--print @CreatedByDt
		end
	--#########
	
		DECLARE @sConcatCreatedDt varchar(4) =RIGHT('00'+ cast(DATEPART(MM,@CreatedByDt) as varchar(2)),2) + RIGHT('00'+cast(DATEPART(dd,@CreatedByDt) as varchar(2)) ,2)
		--PRINT @sConcatCreatedDt
		
		IF CAST(@sConcatCreatedDt as int)>415 --if after April 15- consider goes to next year
		begin
			--print 'change'			
			set @CreatedByDt= '07/01/'+cast(DATEPART(yyyy,@CreatedByDt) as varchar(4))
		end 
	--Now get calendar start date of Plan Created Date
		SELECT @CreatedYearDt= CASE WHEN DATEPART(MM,@CreatedByDt)>=7
					THEN '07/01/'+ CAST(DATEPART(YYYY,@CreatedByDt) as varchar(4))
				ELSE '07/01/'+  cast((DATEPART(YYYY,@CreatedByDt)-1) as varchar(4))
		END
	--And Now get calendar start date of Plan End Date
		SELECT @PlanEndYearDt= CASE WHEN DATEPART(MM,@PlanEndDt)>=7
					THEN '07/01/'+ CAST(DATEPART(YYYY,@PlanEndDt) as varchar(4))
				ELSE '07/01/'+  cast((DATEPART(YYYY,@PlanEndDt)-1) as varchar(4))
		END	
		
	--print @CreatedYearDt
	--print @PlanEndYearDt	
	
	declare @dtdiff as int, @iOutput as varchar(5)
	--set @dtdiff= DATEDIFF(yy,@CreatedYearDt,@PlanEndYearDt)
	print DATEDIFF(yy,@CreatedYearDt,@PlanEndYearDt)
	set @dtdiff = CAST( DATEPART(YYYY,@PlanEndYearDt) as int) - CAST( DATEPART(YYYY,@CreatedYearDt) as int) --+1
	if(@dtdiff>=1)
		begin
			set @iOutput='2yr'
			select @IsMultiYearPlan = 1
		end
	else
		begin
			set @iOutput='1yr'
			select @IsMultiYearPlan = 0
		end
	--print @dtdiff 
	--print @iOutput

	END
		
	select @IsMultiYearPlan 
	
END

	
	
GO
