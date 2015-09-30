SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/24/2012
-- Description:	Updates a goal
-- =============================================
CREATE PROCEDURE [dbo].[updInitative]
	@MgrID AS nchar(6)
	,@InitiativeID AS int
	,@IntiativeTypeID AS int
	,@IntiativeStatusID AS int
	,@IntiativeText AS nvarchar(max)
	,@IntiativeTag AS nvarchar(max)
	,@SchYear As nvarchar(9)
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Initiative
	SET
		IntiativeTypeID = @IntiativeTypeID
		,IntiativeStatusID = @IntiativeStatusID
		,IntiativeText = @IntiativeText
		,SchYear = @SchYear
	WHERE
		InitiativeID = @InitiativeID

		
	--Future enhancement don't delete goal tags but validate changes and update only those that are needed.
	DELETE 
	FROM 
		InitiativeTag
	WHERE
		IntiativeID = @InitiativeID
		
	DECLARE @NextString nvarchar(max)
	DECLARE @Pos INT
	DECLARE @NextPos INT
	DECLARE @Delimiter NVARCHAR(40)

	SET @Delimiter = ', '
	SET @Pos = charindex(@Delimiter, @IntiativeTag)

	WHILE (@pos <> 0)
	BEGIN
		SET @NextString = substring(@IntiativeTag,1,@Pos - 1)
		INSERT INTO InitiativeTag (IntiativeID, GoalTagID, CreatedByID, LastUpdatedByID)
					VALUES (@InitiativeID, @NextString, @MgrID, @MgrID)
		SET @IntiativeTag = substring(@IntiativeTag,@pos+1,len(@IntiativeTag))
		SET @pos = charindex(@Delimiter,@IntiativeTag)
		
	END		

END
GO
