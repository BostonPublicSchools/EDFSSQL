SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Gets Available RubricPlanAvilable associated with given rubricID of the New Job only
-- when IsProvEmplClass is for Developing plan 
--- Here AvailablePlanTypeIs is taken instead of RubricPlanTypeID
-- =============================================
CREATE PROCEDURE [dbo].[getRubricPlanAvailablePlanForNewJob]	
	@RubricID int =null
AS
BEGIN
	SET NOCOUNT ON;
--declare @RubricID int =null
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

DECLARE @TblRubricEndDate TABLE (ed_PlanEndDateID int, ed_RubricPlanTypeID	int, ed_RubricID int, ed_EndTypeID int,	ed_EndTypeText varchar(50),	ed_PlanEndDateTypeID int,	ed_PlanEndDateTypeText	varchar(50),ed_DefaultPlanEndDate varchar(6),ed_IsActive bit,ed_RubricName	varchar(50),ed_PlanTypeID int,ed_PlanType varchar(50), ed_DefaultFullPlanEndDate varchar(10),ed_DefaultFormativeValue nchar(5), ed_DefaultFormativeDate varchar(10),ed_DefaultPlanEndDateMax varchar(6),ed_DefaultFullPlanEndDateMax varchar(10) )
INSERT INTO @TblRubricEndDate
	exec getRubricPlanEndDate null,@RubricID
	
SELECT distinct
	 rpap.AvailablePlanID	 	 
	 ,rpap.NewJobRubricID
	 ,rh.RubricName	
	 ,rpap.IsActive
	,rpap.AvaliablePlanTypeID
	,CdAvPl.CodeText [AvailablePlanType]
	,ISNULL(rpap.IsMultiYear,0) [AvailableIsMultiYear]
	--,(Case when rpap.IsProvEmplClass='true' then @sProvEmplClass Else ''  End ) [EmplClass]
	,(Case 
			when rpap.IsProvEmplClass='true' then ( Select Top 1 EmplClassList from RubricPlanType where RubricID =rpap.NewJobRubricID And PlanTypeID =rpap.AvaliablePlanTypeID )
			Else ''  End ) [EmplClass]
	,ISNULL(rpap.IsProvEmplClass ,0) [IsProvEmplClass]
	,ISNULL(rpap.IsNewJob,'false') [IsNewJob]
	
	,(CASE When rpap.IsMultiYear=1 And CdAvPl.CodeText='Self-Directed' 
			Then (select top 1 ed_DefaultPlanEndDate
					from @TblRubricEndDate dt 						
					where dt.ed_RubricID =rpap.NewJobRubricID and cdAvpl.CodeID = dt.ed_PlanTypeID and
						dt.ed_IsActive=1 and dt.ed_EndTypeText ='Select Year' and ed_PlanEndDateTypeText='End of Year Two'  )
			
			When rpap.IsMultiYear=0 And CdAvPl.CodeText='Self-Directed'
			Then (select top 1 ed_DefaultPlanEndDate 
					from @TblRubricEndDate dt 
					--	inner join CodeLookUp cl on dt.PlanEndDateTypeID=cl.CodeID and cl.CodeType='EndDtType' and cl.CodeText='End of Year One'
					where dt.ed_RubricID =rpap.NewJobRubricID  and cdAvpl.CodeID = dt.ed_PlanTypeID and
						dt.ed_IsActive=1 and dt.ed_EndTypeText ='Select Year' and ed_PlanEndDateTypeText='End of Year One'  )
		   
		   When Not CdAvPl.CodeText = 'Self-Directed'
			Then (select top 1 ed_DefaultPlanEndDate
					from @TblRubricEndDate dt 
					where dt.ed_RubricID =rpap.NewJobRubricID and cdAvpl.CodeID = dt.ed_PlanTypeID and
						dt.ed_IsActive=1 )
					
		END ) [DefaultPlanEndDate]  	
		
		,(CASE When rpap.IsMultiYear=1 And CdAvPl.CodeText='Self-Directed' 
			Then (select top 1 ed_DefaultFullPlanEndDate
					from @TblRubricEndDate dt 						
					where dt.ed_RubricID =rpap.NewJobRubricID and cdAvpl.CodeID = dt.ed_PlanTypeID and
						dt.ed_IsActive=1 and dt.ed_EndTypeText ='Select Year' and ed_PlanEndDateTypeText='End of Year Two'  )
			
			When rpap.IsMultiYear=0 And CdAvPl.CodeText='Self-Directed'
			Then (select top 1 ed_DefaultFullPlanEndDate 
					from @TblRubricEndDate dt 
					--	inner join CodeLookUp cl on dt.PlanEndDateTypeID=cl.CodeID and cl.CodeType='EndDtType' and cl.CodeText='End of Year One'
					where dt.ed_RubricID =rpap.NewJobRubricID  and cdAvpl.CodeID = dt.ed_PlanTypeID and
						dt.ed_IsActive=1 and dt.ed_EndTypeText ='Select Year' and ed_PlanEndDateTypeText='End of Year One'  )
		   
		   When Not CdAvPl.CodeText = 'Self-Directed'
			Then (select top 1 ed_DefaultFullPlanEndDate
					from @TblRubricEndDate dt 
					where dt.ed_RubricID =rpap.NewJobRubricID and cdAvpl.CodeID = dt.ed_PlanTypeID and
						dt.ed_IsActive=1 )
					
		END ) [DefaultFullPlanEndDate]  
		,(CASE When CdAvPl.CodeText = 'Directed Growth' or CdAvPl.CodeText = 'Improvement'
				Then  Convert(varchar(10), (select top 1 ed_DefaultFullPlanEndDateMax
					from @TblRubricEndDate dt 						
					where dt.ed_RubricID =rpap.NewJobRubricID and cdAvpl.CodeID = dt.ed_PlanTypeID and
						dt.ed_IsActive=1 ) )
				Else
					''
			END ) [DefaultFullPlanEndDateMax]
FROM	
	RubricPlanAvailablePlan rpap 
	--inner join RubricPlanType rpt on rpt.RubricPlanTypeID= rpap.AvaliablePlanTypeID	
	inner join RubricHdr rh on rh.RubricID=rpap.NewJobRubricID
	--inner join CodeLookUp cdRpl on rpap.PlanTypeID = cdRpl.CodeID and cdRpl.CodeType='PlanType' and cdRpl.CodeActive=1	
	inner join CodeLookUp CdAvPl on rpap.AvaliablePlanTypeID= CdAvPl.CodeID and CdAvPl.CodeType='PlanType' and CdAvPl.CodeActive=1 	
	left join @TblRubricEndDate t on t.ed_RubricID=rh.RubricID
WHERE 
	rpap.IsActive=1 --AND rpPl.IsActive=1	
	And rpap.IsNewJob=1		
	AND rpap.NewJobRubricID = (CASE WHEN @RubricID IS NOT NULL THEN @RubricID ELSE rpap.NewJobRubricID END)
	and t.ed_DefaultPlanEndDate is not null
	
ORDER BY rpap.NewJobRubricID, rpap.AvaliablePlanTypeID


END


GO
