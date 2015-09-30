SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Gets Available RubricPlanAvilable associated with given RubricPlanTypeID and EndDate Too
				-- IsProvEmplClass is for Developing plan; like IsMultiYear for Sd Plan
				--IsJobChange signifies whether it is job change plan or not. When Jobchange it ignores eval and rating 
				-- Dependent on SP getRubricPlanEndDate
-- =============================================
CREATE PROCEDURE [dbo].[getRubricPlanAvailablePlan_WithEndDate]		
	@RubricPlanTypeID int =null
AS
BEGIN
	SET NOCOUNT ON;
--declare @RubricPlanTypeID int =null
declare @sProvEmplClass nvarchar(10)
select @sProvEmplClass=(
		SUBSTRING((SELECT ',' + RTRIM( CAST(tbl.code AS nvarchar) )
	FROM
		(
			select code from CodeLookUp cdCls where cdCls.CodeType='EmplClass' and cdCls.CodeActive= 1 and Code ='U' union
			select code from CodeLookUp cdCls where cdCls.CodeType='EmplClass' and cdCls.CodeActive= 1 and Code ='V' union
			select code from CodeLookUp cdCls where cdCls.CodeType='EmplClass' and cdCls.CodeActive= 1 and Code ='W' union
			select code from CodeLookUp cdCls where cdCls.CodeType='EmplClass' and cdCls.CodeActive= 1 and Code ='X'
		)tbl
					For XML PATH ('')), 2,99)   )
--print @sProvEmplClass	
Declare @CurrentSchYear varchar(9), @NextSchYear varchar(9) 
Declare @sYearOneDate varchar(4),@sYearTwoDate varchar(4), @sYearThirdDate varchar(max),@sDurationDate varchar(4)

DECLARE @TblRubricEndDate TABLE (ed_PlanEndDateID int,	ed_RubricPlanTypeID	int, ed_RubricID int, ed_EndTypeID int,	ed_EndTypeText varchar(50),	ed_PlanEndDateTypeID int,	ed_PlanEndDateTypeText	varchar(50),ed_DefaultPlanEndDate varchar(6),ed_IsActive bit,ed_RubricName	varchar(50),ed_PlanTypeID int,ed_PlanType varchar(50), ed_DefaultFullPlanEndDate varchar(10),ed_DefaultFormativeValue nchar(5), ed_DefaultFormativeDate varchar(10),ed_DefaultPlanEndDateMax varchar(6), ed_DefaultFullPlanEndDateMax varchar(10) )
INSERT INTO @TblRubricEndDate
	exec getRubricPlanEndDate
--select * from @TblRubricEndDate



SELECT 
	 rpPl.AvailablePlanID	 
	 ,rpt.RubricPlanTypeID
	 ,rpt.RubricID
	 ,rh.RubricName
	 ,rpt.PlanTypeID [RubricPlanID]
	 ,cdRpl.CodeText [RubricPlanType]
	, ISNULL(rpPl.RubricPlanIsMultiYear,0) [RubricPlanIsMultiYear]
	,ISNULL(rpPl.EvalTypeID,'') [EvalTypeID]
	,ISNULL(cdEval.CodeText,'') [EvalType]
	,ISNULL(rpPl.OverallRatingID,'') [OverallRatingID]
	,ISNULL(cdRt.CodeText,'') [OverRallRating]
	,rpPl.IsActive
	,rppl.AvaliablePlanTypeID
	,CdAvPl.CodeText [AvailablePlanType]
	,ISNULL(rpPl.IsMultiYear,0) [AvailableIsMultiYear]
	
	--,ISNULL(rpPl.EmplClassID,'') [EmplClassID]
	--,ISNULL(cdCls.CodeText,'') [EmplClass]
	,(Case when rpPl.IsProvEmplClass='true' then @sProvEmplClass Else ''  End ) [EmplClass]
	,ISNULL(rpPl.IsProvEmplClass ,0) [IsProvEmplClass]
	,ISNULL(rpPl.IsJobChange,'false') [IsJobChange]
	
	,(CASE When rpPl.IsMultiYear=1 And CdAvPl.CodeText='Self-Directed' 
			Then (select top 1 ed_DefaultFullPlanEndDate
					from @TblRubricEndDate dt 
						--inner join CodeLookUp cl on dt.ed_PlanEndDateTypeID=cl.CodeID and cl.CodeType='EndDtType'  and cl.CodeText='End of Year Two'
					where dt.ed_RubricID =rpt.RubricID and cdAvpl.CodeID = dt.ed_PlanTypeID and
						dt.ed_IsActive=1 and dt.ed_EndTypeText ='Select Year' and ed_PlanEndDateTypeText='End of Year Two'  )
			
			When rpPl.IsMultiYear=0 And CdAvPl.CodeText='Self-Directed'
			Then (select top 1 ed_DefaultFullPlanEndDate 
					from @TblRubricEndDate dt 
					--	inner join CodeLookUp cl on dt.PlanEndDateTypeID=cl.CodeID and cl.CodeType='EndDtType' and cl.CodeText='End of Year One'
					where dt.ed_RubricID =rpt.RubricID  and cdAvpl.CodeID = dt.ed_PlanTypeID and
						dt.ed_IsActive=1 and dt.ed_EndTypeText ='Select Year' and ed_PlanEndDateTypeText='End of Year One'  )
		   
		   When Not CdAvPl.CodeText = 'Self-Directed'
			Then (select top 1 ed_DefaultFullPlanEndDate
					from @TblRubricEndDate dt 
						--inner join CodeLookUp cl on dt.PlanEndDateTypeID=cl.CodeID and cl.CodeType='EndDtType'  
--					where dt.IsActive=1 and dt.RubricPlanTypeID=rpt.RubricPlanTypeID and dt.EndTypeID =(select Top 1 CodeID from CodeLookUp cldt where CodeType='EndType') )
					where dt.ed_RubricID =rpt.RubricID and cdAvpl.CodeID = dt.ed_PlanTypeID and
						dt.ed_IsActive=1 )
					
		END ) [DefaultEndDate] 
		,(CASE When CdAvPl.CodeText = 'Directed Growth' or CdAvPl.CodeText = 'Improvement'
				Then  Convert(varchar(10), (select top 1 ed_DefaultFullPlanEndDateMax
					from @TblRubricEndDate dt 						
					where dt.ed_RubricID =rpt.RubricID and cdAvpl.CodeID = dt.ed_PlanTypeID and
						dt.ed_IsActive=1 ) )
				Else
					''
			END ) [DefaultEndDateMax] 
	
		
FROM 
	RubricPlanType rpt
	inner join RubricPlanAvailablePlan rpPl on rpt.RubricPlanTypeID= rpPl.RubricPlanTypeID
	inner join RubricHdr rh on rh.RubricID=rpt.RubricID
	inner join CodeLookUp cdRpl on rpt.PlanTypeID = cdRpl.CodeID and cdRpl.CodeType='PlanType' and cdRpl.CodeActive=1
	left join CodeLookUp cdEval on rpPl.EvalTypeID = cdEval.CodeID and cdEval.CodeType='EvalType' and cdEval.CodeActive=1
	left join CodeLookUp cdRt on rpPl.OverallRatingID= cdRt.CodeID and cdRt.CodeType='EvalRating' and cdRt.CodeActive=1 and cdRt.CodeSubText=rh.RubricName
	inner join CodeLookUp CdAvPl on rpPl.AvaliablePlanTypeID= CdAvPl.CodeID and CdAvPl.CodeType='PlanType' and CdAvPl.CodeActive=1 	
	left join CodeLookUp cdCls on rpPl.EmplClassID= cdCls.CodeID and cdCls.CodeType='EmplClass' and cdCls.CodeActive= 1
	
WHERE 
	rpt.IsActive=1 --AND rpPl.IsActive=1
	--And (rpPl.isNewJob is null or rpPl.isNewJob = 0)
	AND rpPl.RubricPlanTypeID = ( case when @RubricPlanTypeID IS NOT NULL then @RubricPlanTypeID else rpPl.RubricPlanTypeID end )--@RubricPlanTypeID

order by RubricPlanTypeID
END


GO
