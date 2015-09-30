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
CREATE PROCEDURE [dbo].[CheckSDPlanYearNew]
	@CreatedByDt as date --= '01/17/2013'
	,@PlanEndDt as date --='04/01/2015'
	,@IsMultiYearPlan as bit=null OUTPUT -- O FOR FIRST YEAR AND 1 FOR SECOND YEAR
AS
BEGIN
	
	DECLARE @CreatedByDtSchYr as nchar(9) , @PlanEndDtSchYr as nchar(9) = null
	DECLARE @isExistOrAfterInCalendar as int = -1
			
	IF @PlanEndDt IS NOT NULL AND @CreatedByDt IS NOT NULL
	BEGIN	
		SELECT @CreatedByDtSchYr = (Select top 1 SchYear FROM SchoolCalendar where CalendarDate= CAST( @CreatedByDt AS DATE) )	

		SELECT @isExistOrAfterInCalendar =
			(case when exists (select top 1 CalendarDate from dbo.SchoolCalendar where CalendarDate= CAST(@PlanEndDt as date) )
					then 1
				else (case when CAST(@PlanEndDt as date)> (select MAX(CalendarDate) from dbo.SchoolCalendar) then 2 else 0 end)
			end)
		
		if(@isExistOrAfterInCalendar=1)
		begin
			SELECT @PlanEndDtSchYr = (Select top 1 SchYear FROM SchoolCalendar where CalendarDate= CAST( @PlanEndDt AS DATE) )	
			IF @CreatedByDtSchYr=@PlanEndDtSchYr
			begin
				select @IsMultiYearPlan=0
			end
			else
			begin
				DECLARE @tmpyear1 as varchar(4),@tmpyear2 as varchar(4)
				 
				 select @tmpyear1= cast('04-15-'+ SUBSTRING(@CreatedByDtSchYr,CHARINDEX('-',@CreatedByDtSchYr)+1,4) as date) --2013
				 select @tmpyear1= DATEADD(YEAR,1, cast('04-15-'+ SUBSTRING(@CreatedByDtSchYr,CHARINDEX('-',@CreatedByDtSchYr)+1,4) as date) )   --@CreatedByDtSchYr + year 1 --2014
				 select @tmpyear2=cast('04-15-'+ SUBSTRING(@PlanEndDtSchYr,CHARINDEX('-',@PlanEndDtSchYr)+1,4) as date)
				 
				 if CAST(@tmpyear1 as varchar)= cast(@tmpyear2 as varchar)
					select @IsMultiYearPlan = 0
				else
					select @IsMultiYearPlan = 1	

			end
			
		end
		else if(@isExistOrAfterInCalendar=2) --  do not exist But more than calendar date e.g '04/15/2015'
		begin
			select @IsMultiYearPlan = 1
		end
		else if(@isExistOrAfterInCalendar=0)  -- do not exist but less than present calendar date
		begin
			select @IsMultiYearPlan = 0
		end
	END
	
	select @IsMultiYearPlan 
	
END
	

GO
