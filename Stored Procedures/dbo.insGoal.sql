SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/24/2012
-- Description:	Inserts goal into goal table
-- =============================================
CREATE PROCEDURE [dbo].[insGoal]
	@PlanID	AS int = null
	,@GoalYear AS int = null
	,@GoalTypeID AS int = null
	,@GoalLevelID AS int = null
	,@GoalText AS nvarchar(max) = null
	,@GoalTag AS nvarchar(max) = null
	,@UserID AS nchar(6) = null
	--,@GoalTagAcnTypeID as int = 0
	,@GoalID AS int = null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @EmplID AS nchar(6)
			,@MgrID AS nchar(6) --PriMgrid
			,@PriSubEvalID AS nchar(6)
			,@EvalEmplID AS nchar(6)
			,@CodeID AS int
			,@EmplJobID int
			,@AllowInsert bit = 0
	
----Old Code Commented -------------------------------------------------------------------
	--## Get All Manager/Subeval of the empljob belonging to the Educator of this Plan
	-- Reson: other subeval or manager can also insert goal (currently should allow)	
	--SELECT
	--	@EmplID = ej.EmplID
	--	,@MgrID = (CASE WHEN(emplEX.MgrID IS NOT NULL) THEN emplEx.MgrID ELSE ej.MgrID END) 
	--	,@SubEvalID = s.EmplID
	--FROM
	--	EmplEmplJob ej
	--	LEFT OUTER JOIN EmplExceptions emplEx on emplEx.EmplJobID = ej.EmplJobID
	--	left join SubevalAssignedEmplEmplJob sub on ej.EmplJobID = sub.EmplJobID
	--														and sub.isActive = 1
	--														and sub.isDeleted = 0
	--														and sub.isPrimary = 1
	--	left join SubEval s (nolock) on sub.SubEvalID = s.EvalID
	--									and s.EvalActive = 1	
	--WHERE
	--	ej.EmplJobID = (SELECT	
	--						EmplJobID
	--					FROM
	--						EmplPlan
	--					WHERE
	--						PlanID = @PlanID)
	SELECT top 1 @empljobid = EmplJobID from EmplPlan where PlanID=@PlanID	
	SELECT top 1 @EvalEmplID = EmplID from EmplEmplJob where EmplJobID=@EmplJobID	
	
	--DECLARE @ResultSet table (EmplJobID int,IsActive bit,IsDeleted bit,IsPrimary bit, SubEvalID char(6),MgrId char(6),SubEmplName char(50),PrimaryCount int)
	--INSERT INTO @ResultSet (EmplJobID,IsActive,IsDeleted,IsPrimary,SubEvalID,MgrId,SubEmplName,PrimaryCount)
	--	exec getAllSubEvalByEmplJobId @empljobid
	
	--select * from @ResultSet
	SELECT @MgrID = dbo.funcGetPrimaryManagerByEmplID(@EvalEmplID)
	--print @MgrID
	--if ( exists(select SubEvalID from @ResultSet where IsPrimary=0 AND IsDeleted=0 AND IsActive=1 )) AND (@MgrID =@UserID)
	--begin		
	--	set @PriSubEvalID=@UserID	
	--	set @AllowInsert =1	
	--end
	--else if exists(select SubEvalID from @ResultSet where SubEvalID =@UserID and IsPrimary=1 and IsDeleted=0 and IsActive=1 )
	--begin
	--	set @PriSubEvalID=@UserID
	--	set @AllowInsert =1
	--end	
	--else if (@UserID = @EvalEmplID)
	--begin
	--	set @AllowInsert =1
	--end
	
	
------------------------------------------------------------------------------------------	
	
	IF @MgrID = @UserID 	--OR @PriSubEvalID=@UserID
	BEGIN
		SELECT
			@CodeID = CodeID
		FROM
			CodeLookUp
		WHERE
			CodeText = 'In Process' and CodeType = 'GoalStatus'
	END
	--ELSE IF @SubEvalID = @UserID OR (SELECT SubEvalID FROM EmplPlan WHERE PlanID = @PlanID) = @UserID
	--BEGIN
	--	SELECT
	--		@CodeID = CodeID
	--	FROM
	--		CodeLookUp
	--	WHERE
	--		CodeText = 'In Process' and CodeType = 'GoalStatus'
	--END
	ELSE IF  @EvalEmplID = @UserID
	BEGIN
		SELECT
			@CodeID = CodeID
		FROM
			CodeLookUp
		WHERE
			CodeText = 'Not Yet Submitted' and CodeType = 'GoalStatus'
	END
	
	IF (@MgrID = @UserID OR @UserID = @EvalEmplID)
	BEGIN	
			IF(@GoalTag IS NULL OR @GoalTag='')
			Begin 
				SET @GoalID = 0;
				Return
			End
			
		INSERT INTO PlanGoal (PlanID, GoalYear, GoalTypeID, GoalLevelID, GoalStatusID, GoalText, CreatedByID, LastUpdatedByID)
					VALUES (@PlanID, @GoalYear, @GoalTypeID, @GoalLevelID, @CodeID, @GoalText, @UserId, @UserId)
				
		DECLARE @NextString nvarchar(max)
				,@Pos INT
				,@NextPos INT
				,@Delimiter NVARCHAR(40)

		SET @Delimiter = ','
		SET @Pos = charindex(@Delimiter, @GoalTag)
		
		SET @GoalID = SCOPE_IDENTITY();

		WHILE (@pos <> 0)
		BEGIN
			SET @NextString = substring(@GoalTag,1,@Pos - 1)
			INSERT INTO GoalTag (GoalID, GoalTagID, CreatedByID, LastUpdatedByID)
						VALUES (@GoalID, @NextString, @UserId, @UserId)
			SET @GoalTag = substring(@GoalTag,@pos+1,len(@GoalTag))
			SET @pos = charindex(@Delimiter,@GoalTag)
			
		END 
	END
END
GO
