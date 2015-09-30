SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author: MATINA NEWA		
-- Create date: 4/23/2013
-- Description:	Get rubric standards rating by RubricID for Evidence Count
-- This sp uses other sp: getRubricStandardsByRubricID	, getRubricIndicators
-- =============================================
CREATE PROCEDURE [dbo].[getRubricStandardsListByRubricIDSummary]
	@RubricID as nchar(6)
AS
BEGIN
	SET NOCOUNT ON;

declare @myTable table(pkID int NOT NULL IDENTITY (1,1), StandardID int,StandardText varchar(60), StandardDesc varchar(max),IsDeleted bit, isActive bit, RubricID int)
declare @myIndTable table (pkIID int NOT NULL IDENTITY (1,1),IndicatorID int,StandardID int,StandardText varchar(60),RubricID int, ParentIndicatorID int,IndicatorText varchar(max),IndicatorDesc varchar(max),IsDeleted bit ,IsActive bit,SortOrder int)

insert @myTable 
	exec getRubricStandardsByRubricID @RubricID=@RubricID	

declare @iCount int, @iStart int
declare @iStandard int, @vStandard varchar(60)
declare @query varchar(max)
select @iCount= COUNT(*) from @myTable

set @iStart=1;

while @iStart<=@iCount
begin	
	select @iStandard=StandardID from @myTable where pkID=@iStart  
	select @vStandard=StandardText  from @myTable where pkID=@iStart
	
	INSERT @myIndTable(IndicatorID,StandardID) VALUES(0,@iStandard)
	
	INSERT @myIndTable exec getRubricIndicators @StandardID=@iStandard 
		
	set @iStart=@iStart+1	
end
--select * from @myTable;
--select * from @myIndTable;

--Result 
	select A.StandardID,B.StandardText,A.IndicatorID,A.IndicatorText, 0 [COUNT],
	(select case when A.IndicatorID=0 then B.StandardText else '           ' + A.IndicatorText end  )  [StdIndName],
	(select case when A.IndicatorID=0 then B.StandardText else '' end  )  [StdName],
	(select case when A.IndicatorID!=0 then IndicatorText else '' end  )  [IndName]
	from @myIndTable A, @myTable B
	where A.StandardID=b.StandardID
	and b.IsDeleted=0
	
				
END	



GO
