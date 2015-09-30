SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author: MATINA NEWA		
-- Create date: 2/21/2013
-- Description:	Get rubric standards rating by JobCode
-- =============================================
CREATE PROCEDURE [dbo].[getRubricStandardsListByJobCodeSummary]
	@JobCode as nchar(6)
AS
BEGIN
	SET NOCOUNT ON;


declare @myTable table(pkID int NOT NULL IDENTITY (1,1), StandardID int,StandardText varchar(60),JobCode varchar(60),StandardDesc varchar(max),RubricID int,RubricName varchar(60))
declare @myIndTable table (pkIID int NOT NULL IDENTITY (1,1),IndicatorID int,StandardID int,ParentIndicatorID int,IndicatorText varchar(max),IndicatorDesc varchar(max),IsDeleted bit ,IsActive bit,SortOrder int
						  )

insert @myTable 
	exec getRubricStandardsListByJobCode @JobCode=@JobCode

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
	insert @myIndTable exec getRubricIndicators @StandardID=@iStandard 
	set @iStart=@iStart+1	
end

--Result 
	select A.StandardID,StandardText,A.IndicatorID,A.IndicatorText, 0 [COUNT],
	(select case when A.IndicatorID=0 then StandardText else '           ' + A.IndicatorText end  )  [StdIndName],
	(select case when A.IndicatorID=0 then StandardText else '' end  )  [StdName],
	(select case when A.IndicatorID!=0 then IndicatorText else '' end  )  [IndName]
	from @myIndTable A, @myTable B
	where A.StandardID=b.StandardID
	
				
END	

-- exec [getRubricStandardsListByJobCodeSummary] @JobCode='S20315'
GO
