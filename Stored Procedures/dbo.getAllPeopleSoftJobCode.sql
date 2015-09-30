SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[getAllPeopleSoftJobCode]
AS
BEGIN
	SET NOCOUNT ON; 
	Select 
		 JobCode
		,JobDesc
		,UnionCode
		,ImportDate
	From PeopleSoftJobCode

END
GO
