SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 02/07/2012
-- Description:	Inserts initiative into initiative table, 
-- SchYear: associated with School wide goal
-- =============================================
CREATE PROCEDURE [dbo].[insInitiative]
	@MgrID AS nchar(6) = null
	,@IntiativeTypeID AS int = null
	,@IntiativeStatusID AS int = null
	,@IntiativeText AS nvarchar(max) = null
	,@IntiativeTag AS nvarchar(max) = null
	,@SchYear As nvarchar(9)=null
	,@InitiativeID AS int = null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO Initiative (MgrID, IntiativeTypeID, IntiativeText, IntiativeStatusID,SchYear, CreatedByID,LastUpdatedByID)
				VALUES (@MgrID, @IntiativeTypeID, @IntiativeText, @IntiativeStatusID,@SchYear, @MgrID, @MgrID)
	
	DECLARE @NextString nvarchar(max)
			,@Pos INT
			,@NextPos INT
			,@Delimiter NVARCHAR(40)

	SET @Delimiter = ','
	SET @Pos = charindex(@Delimiter, @IntiativeTag)
		
	SET @InitiativeID = SCOPE_IDENTITY();

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
