SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[getAllEmpl]
AS
    SELECT  EmplID ,
            NameLast ,
            NameFirst ,
            NameMiddle ,
            EmplActive ,
            CreatedByID ,
            CreatedByDt ,
            LastUpdatedByID ,
            LastUpdatedDt ,
            IsAdmin ,
            Sex ,
            BirthDt ,
            Race ,
            IsContractor ,
            PrimaryEvalID ,
            HasReadOnlyAccess ,
            ExpectedReturnDate ,
            OriginalHireDate ,
            EmplActiveDt ,
            EmplPWord
    FROM    dbo.Empl;
GO
