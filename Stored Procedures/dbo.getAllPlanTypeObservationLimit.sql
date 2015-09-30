SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Ganesan,Devi
-- Create date: 11/06/2012	
-- Description:	get all the plan type observation limit.
-- =========================================================
CREATE PROCEDURE [dbo].[getAllPlanTypeObservationLimit]
	
AS
BEGIN
	SET NOCOUNT ON;
	SELECT pl.PlanTypeMaxID, pl.PlanTypeID, cd1.CodeText as PlanType, pl.ObservationTypeID, cd2.CodeText as ObservationType, 
		   pl.MaxLimit, pl.CreatedByID, pl.CreatedByDt,
		   pl.LastUpdatedByID, pl.LastUpdatedDt, pl.EmplClass,  
		   ISNULL(e.NameFirst, '')+ ' ' +ISNULL(e.NameMiddle,'')+ ' '+ISNULL(e.NameLast,'') as CreatedName
	 FROM  PlanTypeMaxObservation pl
	 LEFT JOIN CodeLookUp cd1 ON cd1.CodeID = pl.PlanTypeID
	 LEFT JOIN CodeLookUp cd2 ON cd2.CodeID = pl.ObservationTypeID
	 LEFT JOIN Empl e ON e.EmplID = pl.CreatedByID
END
GO
