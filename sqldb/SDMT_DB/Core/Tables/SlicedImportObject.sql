﻿CREATE TABLE [Core].[SlicedImportObject] (
    [SlicedImportObject_Id]   UNIQUEIDENTIFIER CONSTRAINT [Core_SlicedImportObject_id_df] DEFAULT (newsequentialid()) NOT NULL,
    [SlicedImportObject_Nr]   INT              DEFAULT (NEXT VALUE FOR [Core].[Nr]) NOT NULL,
    [SourceSystemName]        [sysname]        NOT NULL,
    [SourceSchema]            [sysname]        NOT NULL,
    [SourceObject]            [sysname]        NOT NULL,
    [DateFilterAttributeName] [sysname]        NULL,
    [GetDataCommand]          NVARCHAR (MAX)   NULL,
    [LowWaterMark]            VARCHAR  (10)    NULL,
    [HighWaterMark]           VARCHAR  (10)    NULL,
    [FilterDataCommand]       NVARCHAR (1024)  NULL,
    [GetDataADXCommand]       NVARCHAR (MAX)   NULL,
    [FilterDataADXCommand]    NVARCHAR (1024)  NULL,
    [DestinationSchema]       [sysname]        NULL,
    [DestinationObject]       [sysname]        NULL,
    [ContainerName]           [sysname]        NULL,
    [DestinationPath]         [sysname]        NULL,
    [DestinationFileName]     [sysname]        NULL,
    [DestinationFileFormat]   VARCHAR (10)     DEFAULT ('.parquet') NOT NULL,
    [MaxRowsPerFile]          INT              NULL,
    [AdditionalContext]       VARCHAR (255)    NULL, -- e.g. for ADX '{"creationTime": "2022.01.01"}'
    [IngestionMappingName]    [sysname]        NULL,
    [Active]                  BIT              DEFAULT ((1)) NOT NULL,
    [PipelineRunId]           VARCHAR(128)     NULL,
    [ExtentFingerprint]       VARCHAR(128)     NULL,
    [LastStart]               DATETIME         NULL,
    [LastSuccessEnd]          DATETIME         NULL,
    [LastErrorEnd]            DATETIME         NULL,
    [RowsTransferred]         INT              NULL,
    [LastErrorMessage]        NVARCHAR (MAX)   NULL,
    [CreatedBy]               [sysname]        CONSTRAINT [Core_SlicedImportObject_createdby_df] DEFAULT (suser_sname()) NOT NULL,
    [ValidFrom]               DATETIME2        GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]                 DATETIME2        GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    CONSTRAINT [Core_SlicedImportObject_pk] PRIMARY KEY CLUSTERED ([SlicedImportObject_Id] ASC),
)WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Core].[SlicedImportObjectHistory])
);
GO

CREATE INDEX [IX_SlicedImportObject_SourceSystemName_SourceSchema_SourceObject] ON [Core].[SlicedImportObject] ([SourceSystemName], [SourceSchema], [SourceObject])