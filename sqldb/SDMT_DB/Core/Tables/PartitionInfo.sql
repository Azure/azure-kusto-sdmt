CREATE TABLE [Core].[PartitionInfo] (
    [PartitionInfo_Id]   UNIQUEIDENTIFIER CONSTRAINT [Core_PartitionInfo_id_df] DEFAULT (newsequentialid()) NOT NULL,
    [PartitionInfo_Nr]   INT              DEFAULT (NEXT VALUE FOR [Core].[Nr]) NOT NULL,
    [SourceSystemName]        [sysname]        NOT NULL,
    [SourceSchema]            [sysname]        NOT NULL,
    [SourceObject]            [sysname]        NOT NULL,
    [TableIndex]              NVARCHAR (MAX)   NULL,
    [TableConstraints]        NVARCHAR (MAX)   NULL,
    [PartitionFunctionName]   [sysname]        NULL, 
    CONSTRAINT [AK_PartitionInfo] UNIQUE ([SourceSystemName], [SourceSchema], [SourceObject]),
);



