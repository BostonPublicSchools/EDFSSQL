SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[splitCommentsAll]
    (
      @stringToSplit VARCHAR(MAX)
    )
RETURNS @returnList TABLE
    (
      pkCID INT NOT NULL
                IDENTITY(1, 1) ,
      Name NVARCHAR(MAX)
    )
AS
    BEGIN

 --DECLARE @stringToSplit nVARCHAR(MAX) ='The central concept for all artifacts is that there is a two interaction that leads to a measurable outcome. This is the first part, but does not show the second.  &nbsp;  PDF of a lesson do not indicate that students have acquired, have used or have understood any lesson objective. A student project based on the lesson that shows that student demonstrated the sound knowledge that you are using as a rationale.  Pre and Post data that shows that your student goals were met. George, a more meaningful artifacts would have been a students assignment that shows that he or she had met these goals.  Commented by -Hopkins, Thomas M. (021927) &amp; On - 2/3/2013  Commented by -Hopkins, Thomas M. (021927) &amp; On - 2/3/2013  &nbsp;  Zip artifacts do not open. I receive a message saying that this is not a valid archive! George, forget the archive and just send the document, it will be a lot easier.Commented by -Hopkins, Thomas M. (021927) & On - 2/12/2013'
 --'The central concept for all artifacts is that there is a two interaction that leads to a measurable outcome. This is the first part, but does not show the second.  &nbsp;  PDF of a lesson do not indicate that students have acquired, have used or have understood any lesson objective. A student project based on the lesson that shows that student demonstrated the sound knowledge that you are using as a rationale.  Pre and Post data that shows that your student goals were met. George, a more meaningful artifacts would have been a students assignment that shows that he or she had met these goals.  Commented by -Hopkins, Thomas M. (021927) &amp; On - 1/1/2013 Commented by -Hopkins, Thomas M. (021927) &amp; On - 2/2/2013'--  &nbsp;  Zip artifacts do not open. I receive a message saying that this is not a valid archive! George, forget the archive and just send the document, it will be a lot easier.Commented by -Hopkins, Thomas M. (021927) & On - 3/3/2013'
 --DECLARE @returnList TABLE ([Name] [nvarchar] (max))
        DECLARE @name NVARCHAR(MAX) ,
            @name1 NVARCHAR(MAX) ,
            @name2 NVARCHAR(MAX);
        DECLARE @pos INT ,
            @pos1 INT;

        WHILE CHARINDEX('Commented by -', @stringToSplit) > 0
            BEGIN
                SELECT  @pos = CHARINDEX('Commented by -', @stringToSplit);  
                SELECT  @name = SUBSTRING(@stringToSplit, 1, @pos - 1);

                SET @pos1 = CHARINDEX('/2013', @name);--+LEN('/2013')
	--print 'after:/2013'+ cast(@pos1 as varchar)
                IF ( @pos1 > 0 )
                    BEGIN
                        SET @name1 = SUBSTRING(@name, 0, @pos1 + LEN('/2013')); 
                        SET @name2 = LTRIM(SUBSTRING(@name,
                                                     @pos1 + LEN('/2013'),
                                                     LEN(@name)));
		--print'***name1pos****'+ cast(len(@name1) as varchar);print 'Name1'+@name1   print'***name1pos****'+ cast(len(@name2) as varchar);	print 'Name2'+ @name2  
                    END;	
                IF ( LEN(@name2) > 1 )
                    BEGIN		
                        INSERT  INTO @returnList
                                SELECT  @name1;
                        INSERT  INTO @returnList
                                SELECT  @name2;
                    END;
                ELSE
                    BEGIN
		--print'outside' +@name
                        INSERT  INTO @returnList
                                SELECT  @name;
                    END;
  
                SELECT  @stringToSplit = SUBSTRING(@stringToSplit,
                                                   @pos + LEN('Commented by -'),
                                                   LEN(@stringToSplit));
            END;

--print'outer'
        INSERT  INTO @returnList
                SELECT  @stringToSplit;

        RETURN;
    END;

GO
