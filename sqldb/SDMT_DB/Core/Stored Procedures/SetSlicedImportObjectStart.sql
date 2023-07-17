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
    SELECT 
	     [SlicedImportObject_Id]
        ,[SourceSystemName] 
	    ,[SourceSchema] 
	    ,[SourceObject] 
	    ,[GetDataCommand] 
	    ,[FilterDataCommand]
        ,[GetDataCommand] + ' ' + [FilterDataCommand] AS [SelectCommand]
        ,'.set-or-append ' + [DestinationObject] + ' with (' + 'creationTime=''' + JSON_VALUE(AdditionalContext, '$.creationTime') + '''' + ', tags=''['
                                                            + '"LoadedAt:' + CONVERT(VARCHAR, GETUTCDATE(), 126) + '"'  
                                                            + ',"SlicedImportObject_Id:' + CONVERT(VARCHAR(64), @SlicedImportObject_Id) + '"'
                                                            + ',"PipelineRun_Id:' + CONVERT(VARCHAR(64), @PipelineRunId) + '"'
                                                            + ',"ExtentFingerprint:' + [ExtentFingerprint] + '"'
                                                            + ',"SourceFunction:' + [GetDataADXCommand] + '"'
                                                            + ']''' + ')'   
            + ' <| ' + [GetDataADXCommand] + '(' + [FilterDataADXCommand] + ')' AS [ADXFetchCommand]

        ,'IF OBJECT_ID(''' + QUOTENAME([DestinationSchema]) + '.' + QUOTENAME([DestinationObject]) + ''') IS NOT NULL DELETE FROM ' + QUOTENAME([DestinationSchema]) + '.' + QUOTENAME([DestinationObject]) + ' ' + [FilterDataCommand] AS [EmptyDestinationSliceCommand]
	    ,[DestinationSchema] 
	    ,[DestinationObject] 
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
    WHERE [SlicedImportObject_Id] = @SlicedImportObject_Id;
	
END;
