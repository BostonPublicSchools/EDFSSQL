SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[getEdfsSchoolYear]

AS
BEGIN

	SET NOCOUNT ON;
	
	Select 
		SchYearType,
		SchYearValue
	From PlanYearChangeTable
  
END
GO
