/* Lake


Json Files with the structure that matches the ADX function -> Both must be adaped to each other.

There will come a simpler way

*/

/* ADX destination




.alter database Demo policy managed_identity ```
[
  {
    "ObjectId": "aa5530a9-146f-4461-a9e0-2c847a2581e6",
    "AllowedUsages": "NativeIngestion, ExternalTable"
  }
]```


.create-or-alter  external table Source_ExternalMeasurement (['timestamp']:long,['values']:dynamic,['EventProcessedUtcTime']:datetime,['PartitionId']:int,['EventEnqueuedUtcTime']:datetime,['IoTHub']:dynamic)
kind=storage 
partition by (FileDate:datetime )
pathformat = (datetime_pattern("yyyy/MM/dd", FileDate))
    dataformat = multijson
    (
        h@'abfss://<container>@<storageAccount>.dfs.core.windows.net/mich-iot-prod-sajob;impersonate'
    )
    with (FileExtension=json, folder='Source')



.create-or-alter function  with (folder='Source', docstring='Get Measurement data from an external table') Source_GetMeasurementFromExternalMeasurement(Ts_Day: string)
{ 
external_table('Source_ExternalMeasurement')
| where FileDate == Ts_Day
| extend msg_IoTHub_ConnectionDeviceId=['IoTHub']['ConnectionDeviceId'], msg_IoTHub_EnqueuedTime=['IoTHub']['EnqueuedTime']
| mv-expand bagexpansion=array values
| extend timestamp, values.id, values.v, values.q, values.t
| project msg_IoTHub_ConnectionDeviceId, msg_IoTHub_EnqueuedTime, timestamp, signalName=trim_start('_AdvancedTags.', tostring(values_id)), values_v, values_q, values_t
| extend messageTimestamp=unixtime_milliseconds_todatetime(tolong(timestamp)), ts=unixtime_milliseconds_todatetime(tolong(values_t)), msg_IoTHub_EnqueuedTime=todatetime(msg_IoTHub_EnqueuedTime)
| project msg_IoTHub_ConnectionDeviceId, signalName, ts, messageTimestamp, msg_IoTHub_EnqueuedTime,  values_v, values_q, measurementType=gettype(values_v)
// one way to handle bool -> text true/false
| extend measurementValue=case(measurementType != "bool", todouble(values_v), double(null))
| extend measurementText= case(isnull(measurementValue), tostring(values_v), tostring(int(null)))
| where toint(values_q) == 1
| extend  company=split(signalName,'_')[0], location=split(signalName,'_')[1]
| extend  signalNameEnd= substring(signalName, strlen(strcat(company, '_', location, '_')), strlen(signalName))
| project-away measurementType, values_v, values_q
| extend Ts=ts
       , Ts_Day=toint(substring(replace_string(tostring(ts),'-',''),0,8))
       , SignalId = toint(rand(1000))
       , MeasurementValue=measurementValue
       , MeasurementText=measurementText
       , MeasurementContext=signalNameEnd
       , CreatedAt=ts
| project Ts, Ts_Day, SignalId,MeasurementValue, MeasurementText, MeasurementContext,CreatedAt       
}



*/

    DECLARE  @LowWaterMark     DATE         = '2023-06-26'   -- GE
            ,@HigWaterMark     DATE         = '2023-06-28'   -- LT   
            ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
     	    ,@SourceSystemName sysname      = 'LakeToADX_ADXFunction'
       

    EXEC [Helper].[GenerateSliceMetaData] 
             @LowWaterMark            = @LowWaterMark
            ,@HigWaterMark            = @HigWaterMark
            ,@Resolution              = @Resolution
            ,@SourceSystemName        = @SourceSystemName
     	    ,@SourceSchema            = 'N/A'
     		,@SourceObject            = 'N/A'
     		,@GetDataADXCommand       = 'Source_GetMeasurementFromExternalMeasurement'
     		,@DestinationObject       = 'Core_Measurement'



SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'LakeToADX_ADXFunction'

