SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--     EXEC z_SaveCommentEvidenceAllComments
CREATE PROCEDURE [dbo].[z_SaveCommentEvidenceAllComments]
AS
    BEGIN

        DECLARE @stringToSplit NVARCHAR(MAX); --='The central concept for all artifacts is that there is a two interaction that leads to a measurable outcome. This is the first part, but does not show the second.  &nbsp;  PDF of a lesson do not indicate that students have acquired, have used or have understood any lesson objective. A student project based on the lesson that shows that student demonstrated the sound knowledge that you are using as a rationale.  Pre and Post data that shows that your student goals were met. George, a more meaningful artifacts would have been a students assignment that shows that he or she had met these goals.  Commented by -Hopkins, Thomas M. (021927) &amp; On - 2/3/2013  Commented by -Hopkins, Thomas M. (021927) &amp; On - 2/3/2013  &nbsp;  Zip artifacts do not open. I receive a message saying that this is not a valid archive! George, forget the archive and just send the document, it will be a lot easier.Commented by -Hopkins, Thomas M. (021927) & On - 2/12/2013'
 --'The central concept for all artifacts is that there is a two interaction that leads to a measurable outcome. This is the first part, but does not show the second.  &nbsp;  PDF of a lesson do not indicate that students have acquired, have used or have understood any lesson objective. A student project based on the lesson that shows that student demonstrated the sound knowledge that you are using as a rationale.  Pre and Post data that shows that your student goals were met. George, a more meaningful artifacts would have been a students assignment that shows that he or she had met these goals.  Commented by -Hopkins, Thomas M. (021927) &amp; On - 1/1/2013 Commented by -Hopkins, Thomas M. (021927) &amp; On - 2/2/2013'--  &nbsp;  Zip artifacts do not open. I receive a message saying that this is not a valid archive! George, forget the archive and just send the document, it will be a lot easier.Commented by -Hopkins, Thomas M. (021927) & On - 3/3/2013'


        DECLARE @tblEvidenceComment TABLE
            (
              pkID INT NOT NULL
                       IDENTITY(1, 1) ,
              EvidenceID INT ,
              Comment VARCHAR(MAX) ,
              Planid INT ,
              EmplID INT
            );
        DECLARE @evidenceid INT ,
            @planid INT ,
            @EmplID NCHAR(6) ,
            @comment VARCHAR(MAX);
        DECLARE @CodeID INT= ( SELECT   CodeID
                               FROM     dbo.CodeLookUp
                               WHERE    CodeText = 'Evidence Comment'
                             );

        INSERT  INTO @tblEvidenceComment
                SELECT DISTINCT
                        e.EvidenceID ,
						NULL ,
                        epe.PlanID ,
                        eej.EmplID
                FROM    dbo.Evidence e
                        INNER JOIN dbo.EmplPlanEvidence epe ON e.EvidenceID = epe.EvidenceID
                        INNER JOIN dbo.EmplPlan ep ON epe.PlanID = ep.PlanID
                        INNER JOIN dbo.EmplEmplJob eej ON ep.EmplJobID = eej.EmplJobID
                UNION ALL
                SELECT DISTINCT
                        e.EvidenceID ,
						NULL ,
                        epe.PlanID ,
                        eej.EmplID
                FROM    dbo.Evidence e
                        INNER JOIN dbo.EmplPlanEvidence epe ON e.EvidenceID = epe.EvidenceID
                        INNER JOIN dbo.EmplPlan ep ON epe.PlanID = ep.PlanID
                        INNER JOIN dbo.EmplEmplJob eej ON ep.EmplJobID = eej.EmplJobID
	 
        DECLARE @iStart INT= 1;
  	
        SELECT  pkID ,
                EvidenceID ,
                Comment ,
                Planid ,
                EmplID
        FROM    @tblEvidenceComment;
  	
        WHILE ( @iStart <= ( SELECT COUNT(pkID)
                             FROM   @tblEvidenceComment
                           ) )
            BEGIN
                SELECT  @evidenceid = CAST(EvidenceID AS VARCHAR) ,
                        @comment = Comment ,
                        @planid = Planid ,
                        @EmplID = ( CASE WHEN LEN(EmplID) < 6
                                         THEN RIGHT('00'
                                                    + CAST(EmplID AS NCHAR(6)),
                                                    7)
                                         ELSE EmplID
                                    END )
                FROM    @tblEvidenceComment
                WHERE   pkID = @iStart;
                PRINT '**Employeeid**'; 
                PRINT @EmplID; 
                SET @EmplID = ( CASE WHEN LEN(@EmplID) < 6
                                     THEN RIGHT('00'
                                                + CAST(@EmplID AS NCHAR(6)), 7)
                                     ELSE @EmplID
                                END );
                PRINT @EmplID;
		--print '**RecordCount**' 
		--print @iStart 
				
--		DECLARE @returnCommentList TABLE (pkCID int NOT NULL IDENTITY (1,1), [Name] [nvarchar] (max))		
                DECLARE @returnCommentList TABLE
                    (
                      pkCID INT ,
                      Name NVARCHAR(MAX)
                    );		
                DELETE  FROM @returnCommentList;
		
                INSERT  INTO @returnCommentList
                        SELECT  pkCID ,
                                Name
                        FROM    dbo.splitCommentsAll(@comment);
		
		--******************************INSERT INTO COMMENT STARTS*****************************************************--
                DECLARE @iCount INT= 1 ,
                    @NameBoth VARCHAR(MAX) ,
                    @commentext NVARCHAR(MAX) ,
                    @blnComment BIT ,
                    @tmpCommentBy VARCHAR(MAX);
                DECLARE @iCheckComment INT= 0;
                DECLARE @vInsertComment NVARCHAR(MAX) ,
                    @vInsertCommentDate VARCHAR(9) ,
                    @vInsertCommentBy VARCHAR(MAX);
                DECLARE @CommentedOn DATETIME ,
                    @CommentedBy NCHAR(6);
			
			--clear all
                SET @vInsertComment = '';
                SET @tmpCommentBy = '';
                SET @iCheckComment = 0;
                SET @NameBoth = '';			
			--clear all end
							
                WHILE ( @iCount <= ( SELECT COUNT(pkCID)
                                     FROM   @returnCommentList
                                   ) )
                    BEGIN
                        SELECT  @NameBoth = Name
                        FROM    @returnCommentList
                        WHERE   pkCID = @iCount;
								
                        IF ( CHARINDEX('On -', @NameBoth) > 0 ) --comment by
                            BEGIN												
                                SET @tmpCommentBy = @NameBoth;  
                            END;
                        ELSE
                            BEGIN  --comment text						
                                PRINT '****START*****';					
						--First save PREVIOUS comment and commentedby if exists
                                IF ( @iCheckComment > 0
                                     AND LEN(@vInsertComment) > 0
                                     AND LEN(@tmpCommentBy) > 0
                                   )
                                    BEGIN
							--INSERT INTO COMMENT
                                        PRINT '****FIRST*****';													
                                        SET @CommentedBy = SUBSTRING(@tmpCommentBy,
                                                              CHARINDEX('(',
                                                              @tmpCommentBy)
                                                              + 1, 6);
                                        SET @CommentedOn = CONVERT(DATETIME, LTRIM(SUBSTRING(@tmpCommentBy,
                                                              PATINDEX('%/%/%',
                                                              @tmpCommentBy)
                                                              - 2, 10)), 101);
								 												
                                        INSERT  INTO dbo.Comment
                                                ( PlanID ,
                                                  CommentTypeID ,
                                                  EmplID ,
                                                  CommentDt ,
                                                  CommentText ,
                                                  CreatedByID ,
                                                  LastUpdatedByID ,
                                                  LastUpdatedDt ,
                                                  OtherID
                                                )
                                        VALUES  ( @planid ,
                                                  @CodeID ,
                                                  @EmplID ,
                                                  @CommentedOn ,
                                                  @vInsertComment ,
                                                  @CommentedBy ,
                                                  '000000' ,
                                                  GETDATE() ,
                                                  @evidenceid
                                                );
                                        SET @tmpCommentBy = ''; -- clear this commentby for next iteration							
                                        SET @vInsertComment = '';							
                                    END;
						
                                SET @iCheckComment = @iCheckComment + 1; 
                                SET @vInsertComment = @NameBoth;
                                SET @blnComment = 0;
						
                            END;			
				
				--SAVE LAST COMMENT AND COMMENTEDBY  
                        IF ( @iCount = ( SELECT COUNT(pkCID)
                                         FROM   @returnCommentList
                                       ) )
                            BEGIN 										
                                IF ( @iCheckComment > 0
                                     AND LEN(@vInsertComment) > 0
                                     AND LEN(@tmpCommentBy) > 0
                                   )
                                    BEGIN
						--INSERT INTO COMMENT
                                        PRINT '****LAST final****';
                                        SET @CommentedOn = '';
                                        SET @CommentedBy = '';
						
                                        SET @CommentedBy = SUBSTRING(@tmpCommentBy,
                                                              CHARINDEX('(',
                                                              @tmpCommentBy)
                                                              + 1, 6);
                                        SET @CommentedOn = CONVERT(DATETIME, LTRIM(SUBSTRING(@tmpCommentBy,
                                                              PATINDEX('%/%/%',
                                                              @tmpCommentBy)
                                                              - 2, 10)), 101);
							 												
                                        INSERT  INTO dbo.Comment
                                                ( PlanID ,
                                                  CommentTypeID ,
                                                  EmplID ,
                                                  CommentDt ,
                                                  CommentText ,
                                                  CreatedByID ,
                                                  LastUpdatedByID ,
                                                  LastUpdatedDt ,
                                                  OtherID
                                                )
                                        VALUES  ( @planid ,
                                                  @CodeID ,
                                                  @EmplID ,
                                                  @CommentedOn ,
                                                  @vInsertComment ,
                                                  @CommentedBy ,
                                                  '000000' ,
                                                  GETDATE() ,
                                                  @evidenceid
                                                );
			 			--clear all
                                        SET @vInsertComment = '';
                                        SET @tmpCommentBy = '';
                                        SET @iCheckComment = 0;
                                        SET @NameBoth = '';
									
						--clear all end
						--PRINT @vInsertComment
						--PRINT @tmpCommentBy
                                    END;
                                BREAK;
                            END;	
				
                        SET @iCount = @iCount + 1;		
				
                    END;
			
		--******************************INSERT INTO COMMENT ENDS*****************************************************--
		--clear all
                SET @vInsertComment = '';
                SET @tmpCommentBy = '';
                SET @iCheckComment = 0;
                SET @NameBoth = '';
                SET @iCount = 1;				
                DELETE  @returnCommentList;
		--clear all end		
                PRINT '*********';	
                PRINT '****EVIDENCEID*****';	
                PRINT @evidenceid;
                PRINT '*********';	
                SET @iStart = @iStart + 1;
            END; --WHILE

    END;
GO
