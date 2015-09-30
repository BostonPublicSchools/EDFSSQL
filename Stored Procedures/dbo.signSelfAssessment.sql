SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara,Krunal
-- Create date: 03/19/2012
-- Description:	Update Plan when self assessment is done.
-- =============================================
CREATE PROCEDURE [dbo].[signSelfAssessment]
	@PlanID int,
	@Signature nvarchar(50),
	@IsSigned bit = 1,
	@UserID nchar(6) = null
	
	--@SignDate datetime = getdate()
	
AS
BEGIN
	SET NOCOUNT ON;
	
	update EmplPlan set IsSignedAsmt = @IsSigned,[SignatureAsmt] =@Signature,DateSignedAsmt= GETDATE(),LastUpdatedByID=@UserID,LastUpdatedDt=GETDATE()
		WHERE PlanID = @PlanID
	
	
		
END

GO
