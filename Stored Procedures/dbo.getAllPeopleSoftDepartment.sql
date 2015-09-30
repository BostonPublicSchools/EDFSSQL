SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[getAllPeopleSoftDepartment]
AS
BEGIN
	SET NOCOUNT ON; 
	Select 
		DeptID
	    ,DeptDescription
		,SetID
		,LocationCode
		,ImportDate
	From PeopleSoftDepartment

END
GO
