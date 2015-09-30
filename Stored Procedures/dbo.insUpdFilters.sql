SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Newa,Matina>
-- Create date: <03/13/2013>
-- Description:	<Add and Update Filters- Filter Management>
-- =============================================
CREATE PROCEDURE [dbo].[insUpdFilters]
	@FilterID int=NULL,
	@ParentFilterID int =-1,
	@Filtertext varchar(100),
	@FilterCode varchar(10),
	@FilterSubText varchar(max),
	@SortOrder int,
	@LastUpdatedByID nchar(6)	
AS
BEGIN	
	SET NOCOUNT ON;
		
	IF EXISTS(SELECT FILTERID FROM FILTERS WHERE FilterID=@FilterID)
		UPDATE FILTERS SET FILTERCode=@FilterCode,Filtertext=@Filtertext, FilterSubText = @FilterSubText,SortOrder=@SortOrder, LastUpdatedByID=@LastUpdatedByID, LastUpdatedDt=GETDATE()
		WHERE FILTERID=@FilterID
	ELSE
		INSERT INTO FILTERS(ParentFilterID,Filtertext,FilterCode,FilterSubText,SortOrder,CreatedByID,CreatedByDt)
			VALUES (@ParentFilterID,@Filtertext,@FilterCode,@FilterSubText,@SortOrder,@LastUpdatedByID,GETDATE())
	
END

GO
