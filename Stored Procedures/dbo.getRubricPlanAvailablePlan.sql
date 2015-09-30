SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Gets Available RubricPlanAvilable associated with given RubricPlanTypeID
-- when IsProvEmplClass is for Developing plan.
-- =============================================
CREATE PROCEDURE [dbo].[getRubricPlanAvailablePlan]		
	@RubricPlanTypeID int =null
	,@RubricID int =null
AS
BEGIN
	SET NOCOUNT ON;

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
SELECT 
	 rpPl.AvailablePlanID	 
	 ,rpt.RubricPlanTypeID
	 ,rpt.RubricID
	 ,rh.RubricName
	 ,rpt.PlanTypeID [RubricPlanID]
	 ,cdRpl.CodeText [RubricPlanType]
	 ,rpt.EmplClassList 
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
	And (rpPl.isNewJob is null or rpPl.isNewJob = 0)
	AND rpPl.RubricPlanTypeID = ( case when @RubricPlanTypeID IS NOT NULL then @RubricPlanTypeID else rpPl.RubricPlanTypeID end )--@RubricPlanTypeID
	AND rpt.RubricID = (CASE WHEN @RubricID IS NOT NULL THEN @RubricID ELSE rpt.RubricID END)
	
ORDER BY rpPl.IsProvEmplClass,cdRpl.CodeSortOrder,rpPl.RubricPlanIsMultiYear, cdEval.CodeSortOrder,cdRt.CodeSortOrder,CdAvPl.CodeSortOrder

END


GO
