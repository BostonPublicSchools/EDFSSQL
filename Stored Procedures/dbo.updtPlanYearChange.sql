SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[updtPlanYearChange]
	@SchYearFirst varchar(9),
	@SchYearSecond varchar(9)	
AS
BEGIN

	SET NOCOUNT ON;
	
	Update PlanYearChangeTable
	Set SchYearValue= @SchYearFirst
	Where SchYearType='First'
	
	Update PlanYearChangeTable
	Set SchYearValue= @SchYearSecond
	Where SchYearType='Second'
  
END
GO
