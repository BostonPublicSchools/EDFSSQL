SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Get  ObservationDetail by ObservationID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationDetailByObsvID]
@ObsvID int
	,@UserID as char(6)
	,@EmplRubricID as int
	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ObsvID1 int
	DECLARE @UserID1 char(6)
	DECLARE @EmplRubricID1 as int
	
	SET @ObsvID1 = @ObsvID
	SET @UserID1 = @UserID
	SET @EmplRubricID1 = @EmplRubricID
	
	
	if @ObsvID <>0
	BEGIN
				select	od.ObsvDID
					,od.ObsvID
					,od.IndicatorID
					,od.ObsvDEvidence
					,od.ObsvDFeedBack
					,ri.IndicatorText
					,ri.IndicatorDesc
					,ri.StandardID
					,rs.StandardText
			FROM ObservationDetail od
			left join RubricIndicator ri (NOLOCK)  on ri.IndicatorID = od.IndicatorID
			left join RubricStandard rs (NOLOCK)  on rs.StandardID = ri.StandardID
			WHERE od.ObsvID = @ObsvID1 and od.IsDeleted = 0
			ORDER BY rs.SortOrder, ri.SortOrder, od.CreatedByDt desc
		--SELECT	od.ObsvDID
		--		,od.ObsvID
		--		,ri.IndicatorID
		--		,od.ObsvDEvidence
		--		,od.ObsvDFeedBack
		--		,ri.IndicatorText
		--		,ri.IndicatorDesc
		--		,ri.StandardID
		--FROM RubricIndicator ri 
		--left join ObservationDetail od on ri.IndicatorID = od.IndicatorID and od.ObsvID =704--@ObsvID
		--left join ObservationRubricDefault ord on ord.EmplID = '091852' and ord.IsActive= 1 and ord.IsDeleted=0 and ord.RubricID = 2--@EmplRubricID
		----FROM ObservationDetail od
		----join RubricIndicator ri on ri.IndicatorID = od.IndicatorID and ri.ParentIndicatorID=0
		--WHERE   ( od.ObsvID =704 or ri.IndicatorID = ord.IndicatorID)
		--group by od.ObsvDID,od.ObsvID,ri.IndicatorID,od.ObsvDEvidence,od.ObsvDFeedBack,ri.IndicatorText,ri.IndicatorDesc,ri.StandardID
		--ORDER BY ri.IndicatorText 
	END
	ELSE
	BEGIN
		SELECT	od.ObsvDID
				,od.ObsvID
				,ri.IndicatorID
				,od.ObsvDEvidence
				,od.ObsvDFeedBack
				,ri.IndicatorText
				,ri.IndicatorDesc
				,ri.StandardID
				,rs.StandardText
		FROM RubricIndicator ri 
		left join RubricStandard rs (NOLOCK)  on  rs.StandardID = ri.StandardID
		left join ObservationDetail od (NOLOCK)  on ri.IndicatorID = od.IndicatorID and ObsvID = null
		left join ObservationRubricDefault ord (NOLOCK)  on ord.EmplID =@UserID  and ord.IsActive= 1 and ord.IsDeleted=0
		WHERE 	  ri.IndicatorID = ord.IndicatorID and ord.RubricID =@EmplRubricID1 
		group by od.ObsvDID,od.ObsvID,ri.IndicatorID,od.ObsvDEvidence,od.ObsvDFeedBack,ri.IndicatorText,ri.IndicatorDesc,ri.StandardID,rs.StandardText
		ORDER BY ri.IndicatorText 
	END
	
	
END


GO
