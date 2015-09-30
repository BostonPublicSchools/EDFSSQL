SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[getRubricStandardAndIndicatorList]
@RubricID as int
AS
BEGIN
select	(rs.StandardID - 101) as  StandardIndiCombine
		,rs.StandardText as StandardIndiText
		,-100000 as ParentID
		,rs.StandardText
		,null as IndicatorText
		,null as ElementText
from RubricStandard rs 
where rs.RubricID = @RubricID
and rs.IsDeleted =0

union 

select	ri.IndicatorID as StandardIndiCombine
		,ri.IndicatorText as StandardIndiText
		,CASE 
		WHEN ri.ParentIndicatorID  =0
			THEN (rs.StandardID -101) 
			ELSE
				ri.ParentIndicatorID
		end as ParentID
		,null as StandardText
		,CASE
			WHEN ri.ParentIndicatorID =0
			THEN ri.IndicatorText
			else
				null
		end as IndicatorText
		,CASE
			WHEN ri.ParentIndicatorID <>0
			THEN ri.IndicatorText
			else null
		end as ElementText
				
from RubricIndicator ri 
left join RubricStandard rs on rs.StandardID = ri.StandardID
where rs.RubricID = @RubricID 
and ri.IsDeleted = 0
END
GO
