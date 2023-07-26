
CREATE FUNCTION [Core].[GetADXcreationTimeAndTags] (@AdditionalContext      VARCHAR (255)
							                       ,@SlicedImportObject_Id  UNIQUEIDENTIFIER
							                       ,@PipelineRunId          VARCHAR(128) 
							                       ,@ExtentFingerprint      VARCHAR(128)
							                       ,@GetDataADXCommand      NVARCHAR (MAX)
							                       )
RETURNS NVARCHAR (MAX)
AS
BEGIN

   RETURN  ' with (' + 'creationTime=''' + JSON_VALUE(@AdditionalContext, '$.creationTime') + '''' + ', tags=''['
                                                              + '"LoadedAt:' + CONVERT(VARCHAR, GETUTCDATE(), 126) + '"'  
                                                              + ',"SlicedImportObject_Id:' + CONVERT(VARCHAR(64), @SlicedImportObject_Id) + '"'
                                                              + ',"PipelineRun_Id:' + CONVERT(VARCHAR(64), @PipelineRunId) + '"'
                                                              + ',"ExtentFingerprint:' + @ExtentFingerprint + '"'
                                                              + ',"SourceFunction:' + @GetDataADXCommand + '"'
                                                              + ']''' + ')'   
END