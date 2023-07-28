/* Lake

Parquet Files -> folder sampleFiles


Copy the files in sampleFiles/SQLToLakeToADX to your storage account/container listed below.

*/

/* ADX destination



.alter database SDMT_Demo policy managed_identity ```
[
  {
    "ObjectId": "<YourObjectId>",
    "AllowedUsages": "NativeIngestion, ExternalTable"
  }
]```


.create-or-alter  external table Source_ExternalMeasurementExSQL (Ts:datetime,SignalName:string ,MeasurementValue:decimal)
kind=storage 
partition by (FileDate:datetime )
pathformat = (datetime_pattern("yyyy/MM/dd", FileDate))
dataformat=parquet
    (
        h@'abfss://<ContainerName>@<StorageAccount>.dfs.core.windows.net/SQLToLakeToADX/Core/Measurement;managed_identity=system'
    )
    with (FileExtension=parquet, folder='Source')


external_table('Source_ExternalMeasurementExSQL')
 


.create-or-alter function with (docstring = "Get Measurement data from external table Source_ExternalMeasurementExSQL and allows filtering on a specific day"
                               ,folder = "Source") Source_GetMeasurementFromSource_ExternalMeasurementExSQL(Ts_Day:string) { 
  external_table('Source_ExternalMeasurementExSQL')
  | where FileDate == Ts_Day
  | extend MeasurementValue=toreal(MeasurementValue)
  | project-away FileDate
}


*/

    DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
            ,@HigWaterMark     DATE         = '2021-11-28'   -- LT
            ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
            ,@SourceSystemName sysname      = 'LakeToADX_ADXFunction'
       

    EXEC [Helper].[GenerateSliceMetaData] 
             @LowWaterMark            = @LowWaterMark
            ,@HigWaterMark            = @HigWaterMark
            ,@Resolution              = @Resolution
            ,@SourceSystemName        = @SourceSystemName
            ,@SourceSchema            = 'N/A'
            ,@SourceObject            = 'N/A'
            ,@GetDataADXCommand       = 'Source_GetMeasurementFromSource_ExternalMeasurementExSQL'
            ,@DestinationObject       = 'Core_Measurement'



SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'LakeToADX_ADXFunction'

