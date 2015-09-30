SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:	Matina Newa
-- Create date: 12/03/2013
-- Description:	This checks if Rubric is associated in any EmplemplJob or emplPlan 
--  Returns 1 when cannot be inactive, 2 when cannot be deleted else null
-- =============================================
CREATE PROCEDURE [dbo].[CheckRubricStatus] 	
	@RubricID AS int
	,@Type as char(10)
	,@CanUpdate AS int = null OUTPUT
	
AS
BEGIN

	SET NOCOUNT ON;
	
	if exists(
		select top 1 RubricID from EmplEmplJob where RubricID=@RubricID 
		union all
		select top 1 RubricID from EmplPlan  where RubricID=@RubricID 
		) And @Type='Delete'
	Begin
		Set @CanUpdate=2;
	End
	
	if exists(
		select top 1 RubricID from EmplEmplJob where RubricID=@RubricID and IsActive=1
		union all
		select top 1 RubricID from EmplPlan  where RubricID=@RubricID and PlanActive=1
		) And @Type='InActive'
	Begin
		Set @CanUpdate=1;
	End
	

	
print @CanUpdate

END


GO
