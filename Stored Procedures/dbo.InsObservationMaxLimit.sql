SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Ganesan,Devi
-- Create date: 11/06/2012	
-- Description:	insert the observation limit for the planType.
-- =========================================================
CREATE PROCEDURE [dbo].[InsObservationMaxLimit]
	@PlanTypeID AS int
	,@ObservationTypeID AS int
	,@MaxLimit AS int
	,@EmplClass AS nchar(1)
	,@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO PlanTypeMaxObservation(PlanTypeID, ObservationTypeID, MaxLimit, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt,EmplClass)
	VALUES(@PlanTypeID, @ObservationTypeID, @MaxLimit, @UserID, GETDATE(), @UserID, GETDATE(), @EmplClass)
	
END
GO
