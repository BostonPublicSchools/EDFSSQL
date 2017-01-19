CREATE TABLE [dbo].[EmplPlanEvidence_backup]
(
[PlanEvidenceID] [int] NOT NULL IDENTITY(1, 1),
[EvidenceID] [int] NOT NULL,
[PlanID] [int] NOT NULL,
[EvidenceTypeID] [int] NOT NULL,
[ForeignID] [int] NOT NULL,
[IsDeleted] [bit] NOT NULL,
[CreatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByDt] [datetime] NOT NULL,
[LastUpdatedByID] [nchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
