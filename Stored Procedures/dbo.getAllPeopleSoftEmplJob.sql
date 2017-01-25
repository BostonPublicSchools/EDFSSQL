SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[getAllPeopleSoftEmplJob] @EmplID NCHAR(6)
AS
    BEGIN
	
        SET NOCOUNT ON;
	
        SELECT  EmplID ,
                EmplRCD ,
                EffectiveDate ,
                EffectiveSequence ,
                Department ,
                JobCode ,
                JobEntryDate ,
                PostionNumber ,
                PayrollStatus ,
                Action ,
                ActionDate ,
                ReasonCode ,
                LocationCode ,
                EmplClass ,
                FTE ,
                PayGroup ,
                CompensationRate ,
                CompensationFrequency ,
                SalaryGrade ,
                Step ,
                SalaryAdministrationPlan ,
                AnnualRate ,
                UnionSeniortyDate ,
                StandardHours ,
                UnionCode ,
                JobIndicator ,
                StepEntryDate ,
                ImportDate
        FROM    dbo.PeopleSoftJob
        WHERE   EmplID = @EmplID;
   
    END;
GO
