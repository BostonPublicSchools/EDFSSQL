SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[getEmplNameById]
@EmplID as nchar(6)
AS
SELECT e.NameFirst + ' ' + ISNULL(e.NameMiddle, '')+ ' ' + e.NameLast  as EmplName
FROM Empl e
WHERE e.EmplID = @EmplID
GO
