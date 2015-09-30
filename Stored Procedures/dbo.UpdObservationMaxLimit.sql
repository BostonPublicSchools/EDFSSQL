SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Ganesan,Devi
-- Create date: 11/07/2012	
-- Description:	update the max limit and the class by observation limit.
-- =========================================================
CREATE PROCEDURE [dbo].[UpdObservationMaxLimit]
	@PlanTypeMaxID AS int
	--,@PlanTypeID AS int
	--,@ObservationTypeID AS int
	,@MaxLimit AS int = 0
	,@EmplClass AS nchar(1)
	,@UserID AS nchar(6)
	,@IsDelete AS bit
AS
BEGIN
	SET NOCOUNT ON;
	IF(@IsDelete = 0)
		BEGIN
		UPDATE PlanTypeMaxObservation SET
			MaxLimit = @MaxLimit,
			EmplClass = @EmplClass,
			LastUpdatedByID = @UserID,
			LastUpdatedDt = GETDATE()
		WHERE PlanTypeMaxID = @PlanTypeMaxID
		END
    IF(@IsDelete = 1)
    BEGIN
      DELETE FROM PlanTypeMaxObservation WHERE PlanTypeMaxID = @PlanTypeMaxID
    END
END
GO
