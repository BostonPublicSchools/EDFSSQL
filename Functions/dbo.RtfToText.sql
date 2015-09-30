SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[RtfToText]
(
@rtf VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS

BEGIN

if @Rtf is NULL Return Null
if len(@Rtf)=0 Return Null
If left(@Rtf,1)<>'{' Return @Rtf

DECLARE @Stage TABLE(Chr CHAR(1),Pos INT)

INSERT @Stage(Chr,Pos)
SELECT SUBSTRING(@rtf, Number, 1),Number FROM master..spt_values
WHERE Type = 'p' AND SUBSTRING(@rtf, Number, 1) IN ('{', '}')

DECLARE @Pos1 INT
DECLARE @Pos2 INT

SELECT @Pos1 = MIN(Pos),@Pos2 = MAX(Pos) FROM @Stage
DELETE FROM @Stage WHERE Pos IN (@Pos1, @Pos2)

WHILE 1 = 1
BEGIN
SELECT TOP 1 @Pos1 = s1.Pos, @Pos2 = s2.Pos
FROM @Stage AS s1 INNER JOIN @Stage AS s2 ON s2.Pos > s1.Pos
WHERE s1.Chr = '{' AND s2.Chr = '}'
ORDER BY s2.Pos - s1.Pos

IF @@ROWCOUNT = 0
BREAK

DELETE FROM @Stage
WHERE Pos IN (@Pos1, @Pos2)

UPDATE @Stage SET Pos = Pos - @Pos2 + @Pos1 - 1
WHERE Pos > @Pos2

SET @rtf = STUFF(@rtf, @Pos1, @Pos2 - @Pos1 + 1, '')
END

SELECT @rtf = STUFF(@rtf, 1, CHARINDEX(' ', @rtf), '')

Declare @CurrPosn Int
Declare @FinishPosn Int
Declare @BlankOut Bit
Declare @StrToRepl varchar(20)
Declare @CurrChar Char(1)
Set @CurrPosn=PatIndex('%\%',@Rtf)
While @CurrPosn>0 Begin
Set @StrToRepl=Substring(@Rtf,@CurrPosn,1)
Set @FinishPosn=@CurrPosn+1
While @FinishPosn = 0 Begin
Set @CurrChar=Substring(@Rtf,@FinishPosn,1)
if @CurrChar=' ' Begin
Set @StrToRepl=@StrToRepl + ' '
Set @FinishPosn=0
End
Else Begin
Set @FinishPosn=@FinishPosn+1
Set @StrToRepl=@StrToRepl + @CurrChar
End 
End 
Set @Rtf=Replace(@Rtf,@StrToRepl,'')
Set @CurrPosn=PatIndex('%\%',@Rtf)
End

RETURN @rtf
END
GO
