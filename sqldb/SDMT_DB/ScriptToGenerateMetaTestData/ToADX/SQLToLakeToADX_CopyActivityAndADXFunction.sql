/* SQL Source


For SQL objects see: SQLtoADX_CopyActivity.sql


*/

/* ADX destination


For ADX object see: LakeToADX_ADXFunction.sql


*/

-- Metadata to fetch data from SQL Server, store it in the data lake slicedimport/multipleFileADX and then read it via external table and the function Source_GetMeasurementFromMultifileSource

    DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
            ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
            ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
            ,@SourceSystemName sysname      = 'SQLToLakeToADX_CopyActivityAndADXFunction'
            ,@ContainerName    sysname      = 'slicedimport'
            ,@MaxRowsPerFile   int          = 1                          -- 1 just for demo purpose. Adjust it in your!


    EXEC [Helper].[GenerateSliceMetaData] 
             @LowWaterMark            = @LowWaterMark
            ,@HigWaterMark            = @HigWaterMark
            ,@Resolution              = @Resolution
            ,@SourceSystemName        = @SourceSystemName
            ,@SourceSchema            = 'Core'
            ,@SourceObject            = 'Measurement'
            ,@GetDataCommand          = 'SELECT [Ts], [SignalName], [MeasurementValue] FROM [Core].[Measurement]'
            ,@GetDataADXCommand       = 'Source_GetMeasurementFromSource_ExternalMeasurementExSQL'
            ,@DateFilterAttributeName = '[Ts]'
            ,@DateFilterAttributeType = 'DATETIME2(3)'                   -- Datatype should match to source table
            ,@DestinationObject       = 'Core_Measurement'
            ,@ContainerName           = @ContainerName
            ,@AlternativeRootFolder   = 'SQLToLakeToADX'
            ,@MaxRowsPerFile          = @MaxRowsPerFile




SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'SQLToLakeToADX_CopyActivityAndADXFunction'
