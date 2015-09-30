SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 03/26/2012
-- Description:	Inserts Sub evaluator and manager id's 
-- =============================================
Create PROCEDURE [dbo].[insSubEval]
	@EmplID AS nchar(6) = NULL
	,@MgrID AS nchar(6) = NULL 
	,@UserID as nchar(6) = NULL
	,@EvalActive bit 
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @EvalID int
	
	set @EvalID = 0
	
	SELECT 
		@EvalID = isnull(EvalID,0) 
	from 
		SubEval 
	where 
		MgrID = @MgrID
	and EmplID = @EmplID
	and EvalActive = 1
	
	If @EvalID = 0
	BEGIN
		insert into SubEval(MgrID,EmplID,EvalActive,CreatedByID,CreatedByDt,LastUpdatedByID,LastUpdatedDt) 
		values(@MgrID,@EmplID,@EvalActive,@UserID,GETDATE(),@UserID,GETDATE())
	END
	
IF NOT Exists(SELECT ObsRubricId FROM ObservationRubricDefault WHERE EmplID = @EmplID)	
	BEGIN
		INSERT INTO ObservationRubricDefault (EmplID, RubricID, IndicatorID, IsActive, IsDeleted, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
		SELECT 
			@EmplID
			,rh.RubricID
			,ri.IndicatorID
			,1
			,0
			,'000000'
			,GETDATE()
			,'000000'
			,GETDATE()	
		FROM 
			RubricIndicator AS ri 
		JOIN RubricStandard AS rs ON ri.StandardID = rs.StandardID
									AND (rs.StandardText like 'II.%' OR rs.StandardText like 'II:%')
									AND rs.IsActive = 1
									AND rs.IsDeleted = 0
		JOIN RubricHdr AS rh ON rs.RubricID = rh.RubricID
								AND rh.IsActive = 1
								AND rh.IsDeleted = 0
		WHERE 
			ri.ParentIndicatorID = 0
		ORDER BY
		 rh.RubricID, rs.StandardID, ri.IndicatorID
	END	

IF @EvalActive = 0 AND (select COUNT(EvalID) from SubEval where EmplID = @EmplID and EvalActive = 1) < 1
	BEGIN
		DELETE FROM ObservationRubricDefault WHERE EmplID = @EmplID
	END

IF(@EvalActive = 0)
	BEGIN
		UPDATE SubEval 
		SET EvalActive = @EvalActive,
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE()
		WHERE EmplID = @EmplID AND MgrID = @MgrID
		
		IF @EvalID != 0
		BEGIN
			UPDATE SubevalAssignedEmplEmplJob 
			SET IsActive = @EvalActive,
				IsDeleted = @EvalActive,
				LastUpdatedByID = @UserID,
				LastUpdatedDt = GETDATE()
			WHERE SubEvalID = @EvalID
		END
	END	
END
GO
