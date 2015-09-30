SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--     EXEC z_SaveCommentEvidenceAllComments
CREATE PROCEDURE [dbo].[z_SaveCommentEvidenceAllComments] 
AS
BEGIN
--SELECT * FROM splitCommentsAll('Thank you for attending this training and further developing your capacity to support our scholars.Commented by -Watson-Harris, Cheryl L. (046587) &amp; On - 1/29/2013Commented by -Watson-Harris, Cheryl L. (046587) & On - 1/29/2013')

DECLARE @stringToSplit nVARCHAR(MAX) --='The central concept for all artifacts is that there is a two interaction that leads to a measurable outcome. This is the first part, but does not show the second.  &nbsp;  PDF of a lesson do not indicate that students have acquired, have used or have understood any lesson objective. A student project based on the lesson that shows that student demonstrated the sound knowledge that you are using as a rationale.  Pre and Post data that shows that your student goals were met. George, a more meaningful artifacts would have been a students assignment that shows that he or she had met these goals.  Commented by -Hopkins, Thomas M. (021927) &amp; On - 2/3/2013  Commented by -Hopkins, Thomas M. (021927) &amp; On - 2/3/2013  &nbsp;  Zip artifacts do not open. I receive a message saying that this is not a valid archive! George, forget the archive and just send the document, it will be a lot easier.Commented by -Hopkins, Thomas M. (021927) & On - 2/12/2013'
 --'The central concept for all artifacts is that there is a two interaction that leads to a measurable outcome. This is the first part, but does not show the second.  &nbsp;  PDF of a lesson do not indicate that students have acquired, have used or have understood any lesson objective. A student project based on the lesson that shows that student demonstrated the sound knowledge that you are using as a rationale.  Pre and Post data that shows that your student goals were met. George, a more meaningful artifacts would have been a students assignment that shows that he or she had met these goals.  Commented by -Hopkins, Thomas M. (021927) &amp; On - 1/1/2013 Commented by -Hopkins, Thomas M. (021927) &amp; On - 2/2/2013'--  &nbsp;  Zip artifacts do not open. I receive a message saying that this is not a valid archive! George, forget the archive and just send the document, it will be a lot easier.Commented by -Hopkins, Thomas M. (021927) & On - 3/3/2013'


DECLARE @tblEvidenceComment table(pkID int NOT NULL IDENTITY (1,1), EvidenceID int,Comment varchar(max),Planid int, EmplID int)
declare @evidenceid int, @planid int, @EmplID nchar(6), @comment varchar(max)
Declare @CodeID int= (select codeid from CodeLookUp where CodeText='Evidence Comment')

	--select EvidenceID , EvalComment,charindex('<div>Commented by',EvalComment), dbo.udf_StripHTML(EvalComment)  [Comments]		
 insert into @tblEvidenceComment
	 select distinct e.EvidenceID,dbo.udf_StripHTML(e.EvalComment)[Comment] ,epe.PlanID,eej.EmplID
		 from Evidence e inner join EmplPlanEvidence epe on e.EvidenceID=epe.EvidenceID 
		 inner join EmplPlan ep on epe.PlanID=ep.PlanID
		 inner join EmplEmplJob eej on ep.EmplJobID =eej.EmplJobID
		 where EvalComment is not null --and  e.EvidenceID=1191
	 union all	 
	 select distinct e.EvidenceID,dbo.udf_StripHTML(e.EmplComment)[Comment] ,epe.PlanID,eej.EmplID
		 from Evidence e inner join EmplPlanEvidence epe on e.EvidenceID=epe.EvidenceID 
		 inner join EmplPlan ep on epe.PlanID=ep.PlanID
		 inner join EmplEmplJob eej on ep.EmplJobID =eej.EmplJobID
		  where EmplComment is not null --and e.EvidenceID=1191
	 
  	Declare @iStart int=1
  	
  	select * from @tblEvidenceComment
  	
	WHILE (@iStart<=(SELECT COUNT(*) from @tblEvidenceComment))
	BEGIN
		select  @evidenceid= cast(EvidenceID as varchar),@comment=Comment, @planid=Planid, 
			@Emplid= (case when LEN(emplid)<6 then RIGHT('00'+ CAST(EmplID AS NCHAR(6)),7) else EmplID end)
		from @tblEvidenceComment  
		where pkID=@iStart
		print '**Employeeid**' 
		print @Emplid 
		set @Emplid= (case when LEN(@Emplid)<6 then RIGHT('00'+ CAST(@Emplid AS NCHAR(6)),7) else @Emplid end)
		print @Emplid
		--print '**RecordCount**' 
		--print @iStart 
				
--		DECLARE @returnCommentList TABLE (pkCID int NOT NULL IDENTITY (1,1), [Name] [nvarchar] (max))		
		DECLARE @returnCommentList TABLE (pkCID int, [Name] [nvarchar] (max))		
		delete from @returnCommentList
		
		INSERT INTO @returnCommentList	
			SELECT * FROM splitCommentsAll(@comment)
		
	--	select * from @returnCommentList
		--******************************INSERT INTO COMMENT STARTS*****************************************************--
			DECLARE @iCount int=1, @NameBoth varchar(max), @commentext nvarchar(max), @blnComment bit, @tmpCommentBy varchar(max)
			DECLARE @iCheckComment int=0
			DECLARE @vInsertComment nvarchar(max), @vInsertCommentDate varchar(9), @vInsertCommentBy varchar(max)
			Declare @CommentedOn datetime, @CommentedBy nchar(6)
			
			--clear all
			set @vInsertComment=''
			set @tmpCommentBy=''
			set @iCheckComment=0
			set @NameBoth=''			
			--clear all end
							
			WHILE (@iCount<=(SELECT COUNT(*) FROM @returnCommentList))
			BEGIN
				SELECT @NameBoth=Name FROM @returnCommentList WHERE pkCID=@iCount
								
					if(CHARINDEX('On -',@NameBoth)>0) --comment by
					begin												
						set @tmpCommentBy =@NameBoth  
					end
					else 
					begin  --comment text						
						PRINT '****START*****'					
						--First save PREVIOUS comment and commentedby if exists
						if(@iCheckComment>0 and len(@vInsertComment)>0 and len(@tmpCommentBy)>0 )
						begin
							--INSERT INTO COMMENT
							PRINT '****FIRST*****'													
							set @CommentedBy = SUBSTRING(@tmpCommentBy,  charindex('(',@tmpCommentBy)+1,6)
							set @CommentedOn= 						
								 CONVERT(datetime, LTRIM(SUBSTRING(@tmpCommentBy,  patindex('%/%/%',@tmpCommentBy)-2, 10 )) ,101)
								 												
							INSERT INTO Comment (PlanID, CommentTypeID, EmplID, 
												CommentDt, CommentText, CreatedByID, 
												LastUpdatedByID,LastUpdatedDt,OtherID)
							VALUES (@PlanID, @CodeID, @EmplID, 
												@CommentedOn, @vInsertComment, @CommentedBy, 
												'000000',GETDATE(),@evidenceid)
							set @tmpCommentBy ='' -- clear this commentby for next iteration							
							set @vInsertComment=''							
						end
						
						set @iCheckComment=@iCheckComment+1; 
						set @vInsertComment=@NameBoth;
						set @blnComment=0
						
					end			
				
				--SAVE LAST COMMENT AND COMMENTEDBY  
				if(@iCount = (SELECT COUNT(*) FROM @returnCommentList))
				begin 										
					if(@iCheckComment>0 and len(@vInsertComment)>0 and len(@tmpCommentBy)>0 )
					begin
						--INSERT INTO COMMENT
						PRINT '****LAST final****'
						set @CommentedOn =''
						set @CommentedBy=''
						
						set @CommentedBy = SUBSTRING(@tmpCommentBy,  charindex('(',@tmpCommentBy)+1,6)
						set @CommentedOn= 						
							 CONVERT(datetime, LTRIM(SUBSTRING(@tmpCommentBy,  patindex('%/%/%',@tmpCommentBy)-2, 10 )) ,101)
							 												
						INSERT INTO Comment (PlanID, CommentTypeID, EmplID, 
											CommentDt, CommentText, CreatedByID, 
											LastUpdatedByID,LastUpdatedDt,OtherID)
						VALUES (@PlanID, @CodeID, @EmplID, 
											@CommentedOn, @vInsertComment, @CommentedBy, 
											'000000',GETDATE(),@evidenceid)
			 			--clear all
							set @vInsertComment=''
							set @tmpCommentBy=''
							set @iCheckComment=0
							set @NameBoth=''
									
						--clear all end
						--PRINT @vInsertComment
						--PRINT @tmpCommentBy
					end
					break;
				end	
				
				Set @iCount=@iCount+1		
				
			END
			
		--******************************INSERT INTO COMMENT ENDS*****************************************************--
		--clear all
			set @vInsertComment=''
			set @tmpCommentBy=''
			set @iCheckComment=0
			set @NameBoth=''
			set @iCount=1				
			delete @returnCommentList
		--clear all end		
		PRINT '*********'	
		PRINT '****EVIDENCEID*****'	
		PRINT @evidenceid
		PRINT '*********'	
		SET @iStart=@iStart+1
	END --WHILE

END
GO
