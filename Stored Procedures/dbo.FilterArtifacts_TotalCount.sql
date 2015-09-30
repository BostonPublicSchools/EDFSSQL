SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina
-- Create date: 05/07/2013
-- Description:	Filters the artifacts from the [ArtifactDetail] view depending upon the filter criteria
--				exec FilterArtifacts_TotalCount @RubricID=1,@StandardFilter='5,6,7,8',@IndicatorFilter='8,17,20',@GoalFilter='5,7',@StartRowIndex=1,@MaximumRows=5,@SortExpression='FileName,CreatedByDt'
--				exec FilterArtifacts @StandardFilter='null' ,@IndicatorFilter='5',@GoalFilter='176',@StartRow='15',@EndRow='30'
-- =============================================
CREATE PROCEDURE [dbo].[FilterArtifacts_TotalCount] 
	@RubricID int=1,
	@StandardFilter varchar(max)= null,
	@IndicatorFilter varchar(max) = null,
	@GoalFilter varchar(max) =null,
    @StartRowIndex INT,
    @MaximumRows INT,  
	@SortExpression nvarchar(max)='EvidenceID desc'
AS
BEGIN



if @StandardFilter=''
	set @StandardFilter=N'null'
if @IndicatorFilter=''	
	set @IndicatorFilter=N'null'	
if @GoalFilter =''
	set @GoalFilter=N'null'
	
Declare @Sqlcte nvarchar(max)

Declare @SqlTotalCount nvarchar(max)

Set @Sqlcte= 
	N' WITH Evidence_cte AS
    (
		select distinct ev.EvidenceID,epe.PlanID, (e.NameLast +'', '' +e.NameFirst )[Employee]
				,ev.FileName,ev.FileExt,ev.CreatedByDt, (evempl.NameLast +'', '' +evempl.NameFirst )[CreatedBy], ev.CreatedByID
				,ej.EmplJobID, e.EmplID
		from Evidence ev 
		inner join EmplPlanEvidence epe on epe.EvidenceID =ev.EvidenceID 
		inner join EmplPlan ep on ep.PlanID =epe.PlanID  and ep.IsInvalid = 0
		inner join EmplEmplJob ej on ep.EmplJobID =ej.EmplJobID
		inner join Empl e on ej.EmplID=e.EmplID
		inner join Empl evempl on ev.CreatedByID=evempl.EmplID
		where epe.IsDeleted=0 and ev.IsDeleted=0 and ej.rubricid='+ cast(@RubricID as varchar)+'
		and  epe.EvidenceID in( 
		   select distinct(evd_stnd.EvidenceID) from EmplPlanEvidence evd_stnd
		   where (evd_stnd.EvidenceTypeID in(109) AND evd_stnd.isdeleted=0 AND evd_stnd.ForeignID in('+@StandardFilter+') ) OR 
				(evd_stnd.EvidenceTypeID=265 AND evd_stnd.isdeleted=0 AND evd_stnd.ForeignID in('+@IndicatorFilter+'))	  
		   UNION	   
		   select distinct(evd_goal.EvidenceID) from EmplPlanEvidence evd_goal
				inner join PlanGoal pl on evd_goal.PlanID=pl.PlanID
		   where evd_goal.EvidenceTypeID=108 AND evd_goal.isdeleted=0 AND
				 evd_goal.ForeignID=pl.goalid AND evd_goal.planId=pl.planId AND pl.GoalTypeID in('+@GoalFilter+') )
		 )		-- select distinct * from Evidence_cte order by evidenceid; '

set @SqlTotalCount =@Sqlcte + N'
				SELECT count(distinct EvidenceID) [TotalCount] from Evidence_cte '
print @SqlTotalCount

EXEC SP_EXECUTESQL @SqlTotalCount;


END
GO
