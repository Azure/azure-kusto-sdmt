/* SQL Source


For SQL objects see: SQLtoADX_CopyActivity.sql


*/


-- Metadata to fetch data from SQL Server, store it in the data lake slicedimport/multipleFileADX and then read it via external table and the function Source_GetMeasurementFromMultifileSource

    DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
            ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
            ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
     	    ,@SourceSystemName sysname      = 'SQLToLake'
     	    ,@ContainerName    sysname      = 'slicedimport'
            ,@MaxRowsPerFile   int          = 1000000 -- example 1M rows per file, should be adjusted to the size of the data (depends on the number of columns and the size of the columns)


    EXEC [Helper].[GenerateSliceMetaData] 
             @LowWaterMark            = @LowWaterMark
            ,@HigWaterMark            = @HigWaterMark
            ,@Resolution              = @Resolution
            ,@SourceSystemName        = @SourceSystemName
     	    ,@SourceSchema            = 'Core'
     		,@SourceObject            = 'Measurement'
     		,@GetDataCommand          = 'SELECT [Ts], [SignalName], [MeasurementValue] FROM [Core].[Measurement]'
     		,@DateFilterAttributeName = '[Ts]'
     		,@DateFilterAttributeType = 'DATETIME2(3)' -- Datatype should match to source table
     		,@ContainerName           = @ContainerName
            ,@AlternativeRootFolder   = 'SQLToLakeToADX'
            ,@MaxRowsPerFile          = @MaxRowsPerFile




SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'SQLToLake'
