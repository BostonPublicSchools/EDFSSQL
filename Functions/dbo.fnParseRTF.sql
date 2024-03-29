SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnParseRTF]
(
@rtf VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
DECLARE @Stage TABLE
(
Chr CHAR(1),
Pos INT
)

INSERT @Stage
(
Chr,
Pos
)
SELECT SUBSTRING(@rtf, Number, 1),
Number
FROM master..spt_values
WHERE Type = 'p'
AND SUBSTRING(@rtf, Number, 1) IN ('{', '}')

DECLARE @Pos1 INT,
@Pos2 INT

SELECT @Pos1 = MIN(Pos),
@Pos2 = MAX(Pos)
FROM @Stage

DELETE
FROM @Stage
WHERE Pos IN (@Pos1, @Pos2)

WHILE 1 = 1
BEGIN
SELECT TOP 1 @Pos1 = s1.Pos,
@Pos2 = s2.Pos
FROM @Stage AS s1
INNER JOIN @Stage AS s2 ON s2.Pos > s1.Pos
WHERE s1.Chr = '{'
AND s2.Chr = '}'
ORDER BY s2.Pos - s1.Pos

IF @@ROWCOUNT = 0
BREAK

DELETE
FROM @Stage
WHERE Pos IN (@Pos1, @Pos2)

UPDATE @Stage
SET Pos = Pos - @Pos2 + @Pos1 - 1
WHERE Pos > @Pos2

SET @rtf = STUFF(@rtf, @Pos1, @Pos2 - @Pos1 + 1, '')
END

SET @Pos1 = PATINDEX('%\cf[0123456789][0123456789 ]%', @rtf)

WHILE @Pos1 > 0
SELECT @Pos2 = CHARINDEX(' ', @rtf, @Pos1 + 1),
@rtf = STUFF(@rtf, @Pos1, @Pos2 - @Pos1 + 1, ''),
@Pos1 = PATINDEX('%\cf[0123456789][0123456789 ]%', @rtf)

SELECT @rtf = REPLACE(@rtf, '\pard', ''),
@rtf = REPLACE(@rtf, '\par', ''),
@rtf = LEFT(@rtf, LEN(@rtf) - 1)

SELECT @rtf = REPLACE(@rtf, '\b0 ', ''),
@rtf = REPLACE(@rtf, '\b ', '')

SELECT @rtf = STUFF(@rtf, 1, CHARINDEX(' ', @rtf), '')

RETURN @rtf
END
GO
