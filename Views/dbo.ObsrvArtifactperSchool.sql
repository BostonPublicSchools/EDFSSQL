SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 06/12/2013
-- Description:	Observations and artifact counts per school
-- =============================================
CREATE VIEW [dbo].[ObsrvArtifactperSchool]
AS
	with 
		cte (PlanID, DeptID, EmplJobId, JobCode, EmplId)
	as
	(
		SELECT
			P.PlanID, ej.DeptID, ej.EmplJobID, ej.JobCode, ej.EmplId 
		FROM
				EmplEmplJob AS ej (NOLOCK)
			JOIN EmplJob AS j (NOLOCK) ON ej.JobCode = j.JobCode
			JOIN EmplPlan AS p (NOLOCK) ON ej.EmplJobID = p.EmplJobID AND P.IsInvalid = 0
	)
	select
		d.DeptID
		,d.DeptName
		,(select 
				COUNT(o.ObsvID)
			from
				ObservationHeader as o
			join (SELECT 
						DeptID
						,PlanID
					FROM
						cte
					WHERE
						PlanID IS NOT NULL) as c on o.PlanID = c.PlanID
			where
				o.IsDeleted = 0
			and o.ObsvRelease = 1				
			and o.ObsvDt >= '2012-09-01'
			and c.DeptID = d.DeptID) as ObsrvCount
		,(select 
				COUNT(distinct e.EvidenceID)
			from
				dbo.EmplPlanEvidence as e
			join (SELECT 
						DeptID
						,PlanID
					FROM
						cte
					WHERE
						PlanID IS NOT NULL) as c on e.PlanID = c.PlanID
			where
				e.IsDeleted = 0
			and e.CreatedByDt >= '2012-09-01'
			and c.DeptID = d.DeptID) as ArtifactCount			 
	from
		department as d
GO
