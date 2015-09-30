SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/30/2012
-- Description:	insert new employee
-- =============================================
CREATE PROCEDURE [dbo].[insNewEmployee]
	@EmplID as nchar(6),
	@FirstName as nvarchar(32),
	@LastName as nvarchar(32),
	@MiddleName as nvarchar(32),
	@EmplActive as bit,
	@UserID as nchar(6),
	@IsAdmin as bit,
	@Sex as char(1),
	@BirthDt as DateTime,
	@Race as nchar(6),
	@IsContractor as bit,
	@JobCode as nchar(6),
	@EmplRcdNo as char(3),
	@MgrID as nchar(6),
	@SubEvalID as nchar(6), 
	@DepartmentID as nchar(6),
	@EmplPositionID as varchar(10),
	@EmplClass as nchar(1), 
	@EmplJobActive as bit,
	@EmplEffectiveDate as DateTime
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO EMPL(EmplID, NameLast, NameFirst, NameMiddle, EmplActive, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IsAdmin, Sex, BirthDt, Race, IsContractor)	
	VALUES(@EmplID, @LastName, @FirstName, case WHEN @MiddleName = '' OR @MiddleName = NULL
										   THEN NULL
										   ELSE @MiddleName END, @EmplActive, @UserID, GETDATE(), @UserID, GETDATE(), @IsAdmin, @Sex, @BirthDt, @Race, @IsContractor)
	
	INSERT INTO EmplEmplJob(JobCode, EmplID, EmplRcdNo, MgrID, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, DeptID, 
							PositionNo, EffectiveDt, EmplClass, IsActive,RubricID)
	VALUES(@JobCode, @EmplID, @EmplRcdNo, @MgrID, @UserID, GETDATE(), @UserID, GETDATE(), @DepartmentID,
				 (CASE WHEN @EmplPositionID = '' OR @EmplPositionID = NULL
				       THEN NULL ELSE @EmplPositionID END) ,
				 (CASE WHEN @EmplEffectiveDate = '' OR @EmplEffectiveDate = NULL
					   THEN NULL ELSE @EmplEffectiveDate END),
				 (CASE WHEN @EmplClass = '' OR @EmplClass = NULL
				       THEN NULL ELSE @EmplClass END), @EmplJobActive, 
				(Select top 1 RubricID from EmplJob where JobCode=@JobCode)  )
		
END
GO
