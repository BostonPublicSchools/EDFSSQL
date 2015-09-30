SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/12/2012
-- Description:	Insert EmplPlanEvidence 
-- =============================================
CREATE PROCEDURE [dbo].[insEmplPlanEvidence]

	@EvidenceID int
	,@PlanID int
	,@EvidenceTypeID int
	,@ForeignID int
	,@UserID AS nchar(6)
	,@PlanEvidenceID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT @PlanEvidenceID = PlanEvidenceID 
	FROM EmplPlanEvidence 
	WHERE PlanID = @PlanID 
		AND EvidenceTypeID = @EvidenceTypeID
		AND EvidenceID = @EvidenceID
		AND ForeignID = @ForeignID		
		
	
	If @PlanEvidenceID is null
	BEGIN
		INSERT INTO EmplPlanEvidence
					(
						
						EvidenceID
						,PlanID
						,EvidenceTypeID
						,ForeignID
						,IsDeleted
						,CreatedByID
						,CreatedByDt
						,LastUpdatedByID
						,LastUpdatedDt
					)
					VALUES (@EvidenceID,@PlanID,@EvidenceTypeID,@ForeignID,0,@UserID,GETDATE(),@UserID,GETDATE())
		SELECT @PlanEvidenceID = SCOPE_IDENTITY();
	END
	ELSE  -- UPDATE PLANEVIDENCE THAT ARE PREVIOUSLY DELETED
	BEGIN 
		--set isDelete=1 for all @PlanEvidenceID (in case there are multple record: data error)
		UPDATE EmplPlanEvidence
			SET	IsDeleted=1,
				LastUpdatedByID=@UserID,
				LastUpdatedDt=GETDATE()				
		WHERE PlanID = @PlanID 
				AND EvidenceTypeID = @EvidenceTypeID
				AND EvidenceID = @EvidenceID
				AND ForeignID = @ForeignID	 
		
		UPDATE EmplPlanEvidence
			SET	IsDeleted=0,
				LastUpdatedByID=@UserID,
				LastUpdatedDt=GETDATE()				
		WHERE PlanEvidenceID=@PlanEvidenceID -- this update only one record, even if there exists multple
	END
	--INSERT INTO EmplPlan (EmplJobID, PlanYear, PlanTypeID, PlanStartDt, PlanEndDt, PlanActive, PlanEditLock, LastUpdatedByID, CreatedByID)
	--				VALUES (@EmplJobID, @PlanYear, @PlanTypeID, @PlanStartDt, @PlanEndDt, @PlanActive, @PlanEditLock, @UserID, @UserID) 
		
END
GO
