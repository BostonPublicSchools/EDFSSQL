SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author: MATINA NEWA		
-- Create date: 2/21/2013
-- Description:	Get rubric standards/Indicator with Total Count of Evidence of the given PlanID
-- =============================================
CREATE PROCEDURE [dbo].[getRubricStandardsIndicatorsEvidenceCount]
	@PlanID AS int 
AS
BEGIN
	SET NOCOUNT ON;

declare @myTable table(pkID int NOT NULL IDENTITY (1,1),EvidenceID int)
declare @myTableEvidences table( pkEID int NOT NULL IDENTITY(1,1), EvidenceTypeID int, EvidenceID int,PlanID int, ForeignID int)
declare @myTableStandard table(pkIID int Not NULL IDENTITY(1,1), StandardID int, StandardText varchar(60)) 
declare @myTableIndicator table(pkIID int Not NULL IDENTITY(1,1), IndicatorID int, IndicatorDesc varchar(max),IndicatorText varchar(60),StandardText varchar(60), StandardID int, ParentIndicatorID	int,ParentIndicatorText varchar(max))

--select * from @ResultJobTable

--select distinct EvidenceID from EmplPlanEvidence where PlanID =@PlanID and IsDeleted=0
insert @myTable 
	select DISTINCT EvidenceID from EmplPlanEvidence where PlanID = @PlanID and IsDeleted=0
	
--SELECT * FROM @myTable
declare @iCount int, @iStart int
select @iCount= COUNT(*) from @myTable
   
declare @iCountEvi int, @iStartEvi int,@iFID int , @iEvidType int , @vEvidType varchar(60)
declare @iEvidenceID int

set @iStart=1;
WHILE @iStart<=@iCount
BEGIN	
	select @iEvidenceID=EvidenceID from @myTable where pkID=@iStart	
	--declare @myTableEvidences table( pkEID int NOT NULL IDENTITY(1,1), EvidenceTypeID int, EvidenceID int,PlanID int, ForeignID int)
	
	insert into @myTableEvidences --(EvidenceID ,PlanID , ForeignID) 
		select ep.EvidenceTypeID,ep.EvidenceID ,ep.PlanID, ep.ForeignID from EmplPlanEvidence ep inner join Evidence e on ep.EvidenceID=e.EvidenceID
		where EvidenceTypeID in(select CodeID from CodeLookUp where CodeText  in('Standard Evidence','Indicator Evidence')) and
		PlanID = @PlanID and ep.EvidenceID=@iEvidenceID
		and e.IsDeleted=0 and ep.IsDeleted=0
		--select EvidenceTypeID,EvidenceID ,PlanID, ForeignID from EmplPlanEvidence where EvidenceTypeID in(109,265) and
		--PlanID = @PlanID and IsDeleted=0 and EvidenceID=@iEvidenceID
		
--	select @iEvidenceID  SELECT * from @myTableEvidences 
	
	--########START INSERT MISSING STANDARD########--
		INSERT into @myTableStandard
		select R.StandardID, rs.StandardText from 
		(select A.EvidenceID, A.ForeignID,
		(case WHEN A.EvidenceTypeID= (select CodeID from CodeLookUp where CodeText  in('Standard Evidence')) THEN (select top 1 StandardID from RubricIndicator where StandardID=ForeignID) 
		      WHEN A.EvidenceTypeID = (select CodeID from CodeLookUp where CodeText  in('Indicator Evidence')) THEN (select top 1 StandardID  from RubricIndicator where IndicatorID=ForeignID and 
												StandardID in(select ForeignID from EmplPlanEvidence where  EvidenceID=@iEvidenceID and 
												EvidenceTypeID=(select CodeID from CodeLookUp where CodeText  in('Standard Evidence')) and IsDeleted=0  group by ForeignID ))
		end ) [pn]
		from EmplPlanEvidence A inner join Evidence B on A.EvidenceID=B.EvidenceID 	
		where A.EvidenceTypeID in(select CodeID from CodeLookUp where CodeText  in('Standard Evidence','Indicator Evidence')) and A.PlanID = @PlanID and A.EvidenceID=@iEvidenceID  and A.IsDeleted=0 and B.IsDeleted=0) C 
		left join RubricIndicator R 
		on c.ForeignID =R.IndicatorID
		left join RubricStandard RS on R.StandardID=Rs.StandardID
		where C.pn is null
		group by R.StandardID,rs.StandardText
	--######## End insert missing standard########--		
	
	set @iStart=@iStart+1	
END
--SELECT * FROM @MYTABLEEVIDENCES
declare @sStandList varchar(50);

--another loop
set @iStartEvi=1
	select @iCountEvi=COUNT(*) from @myTableEvidences
		
	while @iStartEvi <=@iCountEvi
	begin
		select @iFID=ForeignID from @myTableEvidences where pkEID=@iStartEvi
		select @iEvidType=EvidenceTypeID from @myTableEvidences where pkEID=@iStartEvi
		select @vEvidType = CodeText from CodeLookUp where CodeID = @iEvidType
		if(@vEvidType='Standard Evidence')
		begin
			INSERT into @myTableStandard
			SELECT rs.StandardID,rs.StandardText FROM RubricStandard AS rs LEFT JOIN  RubricHdr AS ri ON rs.RubricID = ri.RubricID WHERE rs.StandardID =@iFID
		end
		else if(@vEvidType='Indicator Evidence')
		begin  --indicator + standard
			--INSERT into @myTableStandard
			--SELECT rs.StandardID,rs.StandardText FROM RubricStandard AS rs LEFT JOIN  RubricHdr AS ri ON rs.RubricID = ri.RubricID WHERE rs.StandardID =@iFID			
			insert @myTableIndicator exec getRubricIndicatorByIndicatorID @IndicatorID=@iFID
			select @sStandList= StandardID  from RubricIndicator where IndicatorID=@iFID
		end	
			
		set @iStartEvi=@iStartEvi+1
	end	;


--Return table
 --select * from @myTableStandard
 --select * from  @myTableIndicator;
with cteWithCount as
(
	select COUNT(*) [TotalCount] ,[textName] [StdIndName] from --,StandardID,IndicatorID  from
	(	select StandardText [textName] from @myTableStandard--, StandardID,0 [IndicatorID] 
		union all
		select IndicatorText  [textName] from @myTableIndicator --, StandardID, IndicatorID 
	) [A]	
	group by A.textname --,StandardID,IndicatorID  
	
)
select [TotalCount],[StdIndName] from cteWithCount order by [StdIndName]-- StandardID,IndicatorID
				
END	



GO
