SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Newa,Matina
-- Create date: 05/07/2013
-- Description:	Filters the artifacts. It depends upon the filter criteria- Rubric, goal, standard and indicator tags 
--				exec FilterArtifacts_results @RubricID=1,@StandardFilter='',@IndicatorFilter='',@GoalFilter='7'
-- =============================================
CREATE PROCEDURE [dbo].[FilterArtifacts_Results] 
	@RubricID int=1,
	@StandardFilter varchar(max)= null,
	@IndicatorFilter varchar(max) = null,
	@GoalFilter varchar(max) =null

AS
BEGIN

if @StandardFilter=''
	set @StandardFilter=N'null'
if @IndicatorFilter=''	
	set @IndicatorFilter=N'null'	
if @GoalFilter =''
	set @GoalFilter=N'null'

	
Declare @Sqlcte nvarchar(max)
Declare @SqlResult nvarchar(max)

Set @Sqlcte= 
	N' WITH Evidence_cte AS
    (
		select distinct ev.EvidenceID,epe.PlanID, (e.NameLast +'', '' +e.NameFirst )[Employee]
				,ev.FileName,ev.FileExt, CONVERT(datetime, Convert(varchar(10),ev.CreatedByDt,110),111) [CreatedByDt]
				, (evempl.NameLast +'', '' +evempl.NameFirst )[CreatedBy], ev.CreatedByID
				,ej.EmplJobID, e.EmplID
		from Evidence ev 
		inner join EmplPlanEvidence epe on epe.EvidenceID =ev.EvidenceID 
		inner join EmplPlan ep on ep.PlanID = epe.PlanID and ep.IsInvalid = 0
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
		 
Set @SqlResult=@Sqlcte + N'	
   SELECT * FROM (
	   select distinct ev_outside.EvidenceID,ev_outside.PlanID, ev_outside.Employee, ev_outside.emplID
			,ev_outside.FileName,ev_outside.FileExt,ev_outside.CreatedByDt,ev_outside.CreatedBy,ev_outside.CreatedByID
			, ev_outside.EmplJobID
			,(select stuff((select '', ''+ CAST(StandardText as varchar(max)) --+ CAST(StandardID as varchar(max) ) 
				from EmplPlanEvidence evd_tag inner join RubricStandard rs on evd_tag.ForeignID=rs.StandardID 
				where evd_tag.EvidenceID=ev_outside.EvidenceID and evd_tag.EvidenceTypeID=109 and rs.IsDeleted=0
				order by rs.StandardText
				for xml path ('''')),1,1,'''')
			 ) as StandardTags	 
			,(select stuff((select '', ''+ CAST(ri.IndicatorText as varchar(max)) -- + CAST(ri.IndicatorID as varchar(max) )
				from EmplPlanEvidence evd_tag inner join RubricIndicator ri on evd_tag.ForeignID=ri.IndicatorID 
				where evd_tag.EvidenceID=ev_outside.EvidenceID and evd_tag.EvidenceTypeID=265 and ri.IsDeleted=0
				order by ri.IndicatorText
				for xml path ('''')),1,1,'''')
				
			 ) as IndicatorTags	 
			,(select stuff((select '', ''+ CAST(cl.CodeText as varchar(max)) --+ CAST(cl.CodeID as varchar(max) )
				from EmplPlanEvidence evd_tag inner join plangoal pg on evd_tag.ForeignID=pg.GoalID inner join CodeLookUp cl on pg.GoalTypeID=cl.CodeID
				where evd_tag.EvidenceID=ev_outside.EvidenceID and evd_tag.EvidenceTypeID=108 and pg.IsDeleted=0 and cl.CodeType=''GoalType''
				order by cl.CodeText
				for xml path ('''')),1,1,'''')
			 ) as GoalTags
			
	   from Evidence_cte ev_outside  ) AS MainResult order by EvidenceID desc '
  
--print @SqlResult
--print '##############'

EXEC SP_EXECUTESQL @SqlResult;


END

GO
