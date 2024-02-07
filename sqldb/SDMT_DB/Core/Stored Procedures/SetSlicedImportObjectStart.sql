
CREATE PROCEDURE [Core].[SetSlicedImportObjectStart]
    @SlicedImportObject_Id UNIQUEIDENTIFIER 
   ,@PipelineRunId         VARCHAR(128)     
AS
BEGIN
    SET NOCOUNT ON

    -- Update LastStart to the current time
    UPDATE [Core].[SlicedImportObject]
    SET [LastStart]        = GETUTCDATE()
	   ,[PipelineRunId]    = @PipelineRunId
       ,[LastSuccessEnd]   = NULL
	   ,[LastErrorEnd]     = NULL
       ,[LastErrorMessage] = NULL
	   ,[RowsTransferred]  = NULL
    WHERE [SlicedImportObject_Id] = @SlicedImportObject_Id;

    -- Select all attributes for the given SlicedImportObject_Id

	;WITH BaseSliceInfo
	AS
	(
      SELECT 
	     [SlicedImportObject_Id]
        ,[SlicedImportObject_Nr]
        ,[SourceSystemName] 
	    ,[SourceSchema] 
	    ,[SourceObject] 
	    ,[GetDataCommand] 
	    ,[FilterDataCommand]
        ,[GetDataCommand] + ' ' + [FilterDataCommand]       AS [SelectCommand]
        ,[GetDataADXCommand] + ' ' + [FilterDataADXCommand] AS [SelectADXCommand]
		 ,'.set-or-append ' + [DestinationObject] +	[Core].[GetADXcreationTimeAndTags] ([AdditionalContext], @SlicedImportObject_Id, @PipelineRunId, [ExtentFingerprint], [GetDataADXCommand])
		    + ' <| ' + [GetDataADXCommand] + '(' + [LowWaterMark] + ')'                         AS [ADXFetchCommand]
		 ,'.set-or-append ' + [DestinationObject] +	[Core].[GetADXcreationTimeAndTags] ([AdditionalContext], @SlicedImportObject_Id, @PipelineRunId, [ExtentFingerprint], [GetDataADXCommand])
		    + ' <| ' + [GetDataADXCommand] + '("' + [FilterDataCommand] + '")'                          AS [ADXFetchCommandFullWhere]
		 ,'.set-or-append ' + [DestinationObject] +	[Core].[GetADXcreationTimeAndTags] ([AdditionalContext], @SlicedImportObject_Id, @PipelineRunId, [ExtentFingerprint], [GetDataADXCommand])
		    + ' <| ' + [GetDataADXCommand] + '("' + [GetDataCommand] + ' ' + [FilterDataCommand] + '")' AS [ADXFetchCommandFullSQLAndWhere]
        ,'IF OBJECT_ID(''' + QUOTENAME([DestinationSchema]) + '.' + QUOTENAME([DestinationObject]) + ''') IS NOT NULL DELETE FROM ' + QUOTENAME([DestinationSchema]) + '.' + QUOTENAME([DestinationObject]) + ' ' + [FilterDataCommand] AS [EmptyDestinationSliceCommand]

		 ,'.export to table  ' + [DestinationObject] + ' <| ' + [SourceObject] + ' | where startofday(' + [DateFilterAttributeName] + ') >= todatetime(''' + [LowWaterMark] +''') and startofday(' + [DateFilterAttributeName] + ') < todatetime(''' + [HighWaterMark] +''')  ' AS [ADXExportCommand]
	    ,[DestinationSchema] 
	    ,[DestinationObject] 
	    ,[DestinationObject] + '_' + [LowWaterMark] AS [PartitionedDestinationObject] 
		,[ContainerName]
	    ,[DestinationPath] 
	    ,[DestinationFileName] 
	    ,[DestinationFileFormat] 
		,[DestinationFileName] + [DestinationFileFormat] AS [FullDestinationFileName]
		,[MaxRowsPerFile]
		,[ExtentFingerprint]
    	--   //Use in ADX
	    --   .show table <YourTable> extents
        --   | extend  Timestamp = todatetime(extract("LoadedAt='(.*)'", 1, Tags))

        ,JSON_MODIFY(
            JSON_MODIFY(
                JSON_MODIFY(
                    JSON_MODIFY([AdditionalContext], 'append $.tags', 'LoadedAt:' + CONVERT(VARCHAR, GETUTCDATE(), 126))
                                                    ,'append $.tags', 'SlicedImportObject_Id:' + CONVERT(VARCHAR(64), @SlicedImportObject_Id))  
                                                    ,'append $.tags', 'PipelineRun_Id:' + CONVERT(VARCHAR(64), @PipelineRunId))
                                                    ,'append $.tags', 'ExtentFingerprint:' + [ExtentFingerprint])   
                                                                                                                                                                  AS [AdditionalContext]
        ,'.drop extents <| .show table ' + DestinationObject + ' extents where tags has ''' + 'ExtentFingerprint:' + [ExtentFingerprint] + ''''                   AS [ADXDropExtentCommand]
        ,'.show table ' + DestinationObject + ' extents where tags has ''' + 'PipelineRun_Id:'    + CONVERT(VARCHAR(64), @PipelineRunId) 
                                                    + ''' and tags has ''' + 'ExtentFingerprint:' + [ExtentFingerprint] + ''' | summarize RowCount=sum(RowCount)' AS [ADXCountRowsInExtentCommand]
		,[IngestionMappingName]
	    ,[LastStart] 
    FROM [Core].[SlicedImportObject]
    WHERE [SlicedImportObject_Id] = @SlicedImportObject_Id
	)
	SELECT BaseSliceInfo.*
	       , 'DROP TABLE IF EXISTS ' + [DestinationSchema] + '.' + [PartitionedDestinationObject] + '; ' + CHAR(13) + CHAR(10)
		   + 'SELECT * INTO ' + [DestinationSchema] + '.' + [PartitionedDestinationObject] + ' FROM ' + [DestinationSchema] + '.' + [DestinationObject] + ' WHERE 1=2; ' + CHAR(13) + CHAR(10)
		   +  REPLACE(REPLACE([TableIndex]      , '@@TableName@@', [PartitionedDestinationObject]) , '@@SchemName@@', [DestinationSchema] ) +'; ' + CHAR(13) + CHAR(10)
		   +  REPLACE(REPLACE([TableConstraints], '@@TableName@@', [PartitionedDestinationObject]) , '@@SchemName@@', [DestinationSchema] ) +'; ' + CHAR(13) + CHAR(10)
		   +  'ALTER TABLE ' + [DestinationSchema] + '.' + [PartitionedDestinationObject] + ' ADD CONSTRAINT CHECK_PartitionRange_' + [DestinationSchema] + '_' + [PartitionedDestinationObject] + ' CHECK (' + REPLACE([FilterDataCommand],'WHERE ','') + ');'+ CHAR(13) + CHAR(10)
		   +  'SELECT 5 AS DummyResult; ' + CHAR(13) + CHAR(10)
		                                                                                                                                                              AS  [PrecreatePartitionedStageTable]

	       , 'DROP TABLE IF EXISTS ' + [DestinationSchema] + '.' + [PartitionedDestinationObject] + '_OUT; ' + CHAR(13) + CHAR(10)
		   + 'SELECT * INTO ' + [DestinationSchema] + '.' + [PartitionedDestinationObject] + '_out' + ' FROM ' + [DestinationSchema] + '.' + [DestinationObject] + ' WHERE 1=2; ' + CHAR(13) + CHAR(10)
		   +  REPLACE(REPLACE([TableIndex]      , '@@TableName@@', [PartitionedDestinationObject] + '_out') , '@@SchemName@@', [DestinationSchema] ) +'; ' + CHAR(13) + CHAR(10)
		   +  REPLACE(REPLACE([TableConstraints], '@@TableName@@', [PartitionedDestinationObject] + '_out') , '@@SchemName@@', [DestinationSchema] ) +'; ' + CHAR(13) + CHAR(10)
           + 'ALTER TABLE ' + [DestinationSchema] + '.' + [DestinationObject] + ' SWITCH PARTITION $PARTITION.demoPartitionPF('''  + CONVERT(VARCHAR, CONVERT(datetime2(3),[ExtentFingerprint],112)) + ''')    TO ' + [DestinationSchema] + '.' + [PartitionedDestinationObject] + '_OUT; ' + CHAR(13) + CHAR(10)
		   + 'ALTER TABLE ' + [DestinationSchema] + '.' + [PartitionedDestinationObject] + ' SWITCH TO  ' + [DestinationSchema] + '.' + [DestinationObject] + ' PARTITION $PARTITION.demoPartitionPF('''  + CONVERT(VARCHAR, CONVERT(datetime2(3),[ExtentFingerprint],112)) + ''') ' + CHAR(13) + CHAR(10)
		   + 'DROP TABLE IF EXISTS ' + [DestinationSchema] + '.' + [PartitionedDestinationObject] + ';     ' + CHAR(13) + CHAR(10)
		   + 'DROP TABLE IF EXISTS ' + [DestinationSchema] + '.' + [PartitionedDestinationObject] + '_OUT; ' + CHAR(13) + CHAR(10)
		   +  'SELECT 5 AS DummyResult; ' + CHAR(13) + CHAR(10)
		                                                                                                                                                              AS  [SwitchInPartitionedStageTable]

	FROM BaseSliceInfo
	  LEFT OUTER JOIN [Core].[PartitionInfo]
	    ON BaseSliceInfo.[SourceSystemName] = [PartitionInfo].[SourceSystemName]
	   AND BaseSliceInfo.[SourceSchema]     = [PartitionInfo].[SourceSchema]
	   AND BaseSliceInfo.[SourceObject]     = [PartitionInfo].[SourceObject]
	
	
END;
