SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[getAllPeopleSoftEmplEmployee] @EmplID NCHAR(6)
AS
    BEGIN
	
        SET NOCOUNT ON;
	
        SELECT  EmplID ,
                EmplRCD ,
                EffectiveDate ,
                EffectiveSequence ,
                Name ,
                AddressLine1 ,
                AddressLine2 ,
                City ,
                State ,
                PostalCode ,
                HomePhone ,
                WorkPhone ,
                NationalID ,
                OriginalStartDate ,
                Gender ,
                DateOfBirth ,
                EthnicGroup ,
                DisabledVeteran ,
                MilitaryStatus ,
                ExpectedReturnDate ,
                TeminationDate ,
                UnionCode ,
                UnionSeniorityDate ,
                Department ,
                DepartmentName ,
                JobCode ,
                JobTitle ,
                PayrollStatus ,
                Action ,
                ActionDate ,
                ReasonCode ,
                LocationCode ,
                PositonNumber ,
                PayGroup ,
                CompensationRate ,
                CompensationFrequency ,
                SalaryGrade ,
                Step ,
                SalaryAdministrationPlan ,
                AnnualRate ,
                ServiceDate ,
                FTE ,
                ImportDate
        FROM    dbo.PeopleSoftEmployee
        WHERE   EmplID = @EmplID;
   
    END;
GO
