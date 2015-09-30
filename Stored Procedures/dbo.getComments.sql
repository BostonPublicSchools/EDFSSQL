SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 02/03/2012
-- Description:	Get comments associated with a plan
--				@PlanID -- Planid
--				@CommentTypeText -- type of comment e.g: goal, actionsteps,
--				@OtherID -- when IS NOT NULL and used in the comment for INDIVIDUAL ARTIFACT, OBSERVATION. For e.g: In artifact, OtherID is EvidenceID 
						 -- when is not null, it checks for commenttype AND then gets the comment according to OtherID 
-- =============================================
CREATE PROCEDURE [dbo].[getComments]
	@PlanID	AS int = NULL
	,@CommentTypeText AS nvarchar(50) = NULL
	,@OtherID AS INT =NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CodeID as int
	
	SELECT
		@CodeID = CodeID
	FROM
		CodeLookUp
	WHERE
		CodeType = 'ComType'
	AND	CodeText = @CommentTypeText		
	
	
	IF (@OtherID IS NULL)
	BEGIN
		SELECT
			c.CommentID
			,c.PlanID
			,c.CommentDt
			,c.CommentTypeID
			,ct.CodeText AS CommentType
			,c.EmplID
			,e.NameLast + ', ' + e.NameFirst AS EmplName
			,c.CommentText
			,c.CreatedByID AS CommentedEmplID
			,ec.NameLast + ', ' + ec.NameFirst AS CommentedEmplName
		FROM
			Comment AS c (NOLOCK)
		JOIN Empl AS e (NOLOCK) ON c.EmplID = e.EmplID
		JOIN CodeLookUp AS ct (NOLOCK) ON c.CommentTypeID = ct.CodeID
		JOIN Empl AS ec (NOLOCK) ON c.CreatedByID= ec.EmplID
		WHERE
			c.PlanID = @PlanID
		AND ct.CodeID = @CodeID
		AND c.IsDeleted = 0
		ORDER BY 
			c.CommentDt DESC
	END
	
	ELSE IF (@OtherID IS NOT NULL 
				AND ( @CommentTypeText='Evidence Comment' OR @CommentTypeText='Evaluator Comment' OR @CommentTypeText='Educator Comment' OR @CommentTypeText='Observation Comment' 
				OR @CommentTypeText='Goal' OR @CommentTypeText='ActionSteps'))
	BEGIN	
		 SELECT
				c.CommentID
				,c.PlanID
				,c.CommentDt
				,c.CommentTypeID
				,ct.CodeText AS CommentType
				,c.EmplID
				,e.NameLast + ', ' + e.NameFirst AS EmplName
				,c.CommentText
				,c.CreatedByID AS CommentedEmplID
				,ec.NameLast + ', ' + ec.NameFirst AS CommentedEmplName
		FROM
			Comment AS c (NOLOCK)
		JOIN Empl AS e (NOLOCK) ON c.EmplID = e.EmplID
		JOIN CodeLookUp AS ct (NOLOCK) ON c.CommentTypeID = ct.CodeID
		JOIN Empl AS ec (NOLOCK) ON c.CreatedByID= ec.EmplID
			WHERE
				c.PlanID = @PlanID
			AND ct.CodeID = @CodeID
			AND c.OtherID=@OtherID
			AND c.IsDeleted = 0
			ORDER BY 
				c.CommentDt DESC
	END
	
	
END

GO
