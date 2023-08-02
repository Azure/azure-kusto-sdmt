
/* This data structure work with the sample meta data


ADX table with the original data:

.create table Core_Measurement (Ts: datetime, SignalName: string, MeasurementValue: real) with (folder = "Core")

ADX external table to export data to:

.create-or-alter  external table Export_ExternaMeasurement (Ts:datetime,SignalName:string ,MeasurementValue:real)
kind=storage 
partition by (FileDate:datetime=startofday(Ts) )
pathformat = (datetime_pattern("yyyy/MM/dd", FileDate))
dataformat=parquet
    (
        h@'abfss://<ContainerName>@<StorageAccount>.dfs.core.windows.net/Export/Core/Measurement;managed_identity=system'
    )
    with (FileExtension=parquet, folder='Export')


*/



DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
        ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
        ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
        ,@SourceSystemName sysname      = 'ADX_ExportToLake'
   
EXEC [Helper].[GenerateSliceMetaData] 
         @LowWaterMark            = @LowWaterMark
        ,@HigWaterMark            = @HigWaterMark
        ,@Resolution              = @Resolution
        ,@SourceSystemName        = @SourceSystemName
        ,@SourceObject            = 'Core_Measurement'
        ,@DateFilterAttributeName = 'Ts'
        ,@DestinationObject       = 'Export_ExternaMeasurement'

GO


-- check meta data

SELECT 	*
FROM   [Core].[SlicedImportObject]
WHERE  SourceSystemName  like  'ADX_ExportToLake'
