SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 02/27/2012
-- Description:	List of available intiative statuses
-- =============================================
CREATE PROCEDURE [dbo].[getFilters]
@ParentFilterID int = -1
,@GetAll bit = 0
AS
BEGIN
	SET NOCOUNT ON;
	IF @GetAll =0
	BEGIN
		IF @ParentFilterID <> -1 
		BEGIN
			SELECT	f.filterID
					,f.ParentFilterID
					,f.FilterCode
					,f.FilterText
					,f.FilterSubText
					,f.SortOrder as CodeSortOrder					
			FROM Filters f
			WHERE ParentFilterID = @ParentFilterID and IsDeleted = 0
			ORDER BY f.SortOrder
		END
		ELSE
		BEGIN
			SELECT f.filterID
					,f.ParentFilterID
					,f.FilterCode
					,f.FilterText
					,f.FilterSubText
					,f.SortOrder as CodeSortOrder					
			FROM Filters f 
			WHERE ParentFilterID =1 and IsDeleted = 0
			Order by f.SortOrder
		END
	END
	if @GetAll = 1
	BEGIN
	SELECT f.filterID
				,f.ParentFilterID
				,f.FilterCode
				,f.FilterText
				,f.FilterSubText
				,f.SortOrder as CodeSortOrder				
		FROM Filters f 
		WHERE IsDeleted = 0		
		Order by f.SortOrder
	END 		
END
GO
