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
    @ParentFilterID INT = -1 ,
    @GetAll BIT = 0
AS
    BEGIN
        SET NOCOUNT ON;
        IF @GetAll = 0
            BEGIN
                IF @ParentFilterID <> -1
                    BEGIN
                        SELECT  f.FilterID ,
                                f.ParentFilterID ,
                                f.FilterCode ,
                                f.Filtertext ,
                                f.FilterSubText ,
                                f.SortOrder AS CodeSortOrder
                        FROM    dbo.Filters f ( NOLOCK )
                        WHERE   f.ParentFilterID = @ParentFilterID
                                AND f.IsDeleted = 0
                        ORDER BY f.SortOrder;
                    END;
                ELSE
                    BEGIN
                        SELECT  f.FilterID ,
                                f.ParentFilterID ,
                                f.FilterCode ,
                                f.Filtertext ,
                                f.FilterSubText ,
                                f.SortOrder AS CodeSortOrder
                        FROM    dbo.Filters f ( NOLOCK )
                        WHERE   f.ParentFilterID = 1
                                AND f.IsDeleted = 0
                        ORDER BY f.SortOrder;
                    END;
            END;
        IF @GetAll = 1
            BEGIN
                SELECT  f.FilterID ,
                        f.ParentFilterID ,
                        f.FilterCode ,
                        f.Filtertext ,
                        f.FilterSubText ,
                        f.SortOrder AS CodeSortOrder
                FROM    dbo.Filters f ( NOLOCK )
                WHERE   f.IsDeleted = 0
                ORDER BY f.SortOrder;
            END; 		
    END;
GO
