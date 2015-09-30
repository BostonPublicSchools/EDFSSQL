SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 07/25/2012
-- Description:	get the rubrc details and union code 
-- for the empljobid.
-- =============================================
CREATE PROCEDURE [dbo].[getRubricUnionByEmplJobID]
  @emplJobID as int
AS
BEGIN 
SET NOCOUNT ON;

SELECT rh.*, j.UnionCode FROM RubricHdr rh
JOIN EmplEmplJob ej on ej.RubricID = rh.RubricID
JOIN EmplJob j on j.JobCode = ej.JobCode
WHERE ej.EmplJobID = @emplJobID

END
GO
