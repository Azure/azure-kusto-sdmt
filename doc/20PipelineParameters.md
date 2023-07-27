


#### Common Pipeline Parameters

All sample pipelines have the following parameters:


| Parameter           | Type   | Default Value   | Remark |
|---------------------|--------|-----------------| ---|
| SourceSystemName    | string | SQLtoADX_CopyActivity | Link to the records in the table `[Core].[SlicedImportObject]`
| Mode                | string | REGULAR             | Specifies the mode of retrieval. Possible values are: 'REGULAR', 'RESTART', or 'ALL'. <br>    If set to `REGULAR`, the procedure will only retrieve sliced import objects where the `LastStart` column is null. </br> If set to `RESTART`, it will only retrieve sliced import objects where the `LastStart` column is not null and the `LastSuccessEnd` column is null. </br> If set to `ALL`, it will retrieve all sliced import objects regardless of their status.
| DropTargetExtent    | bool   | true            | Can be used to influence the behaviour of the pipeline. If set to true, an activity that drops the target extent before the data is transferred can be executed. This is useful if you would like to restart the data transfer the data again and you would like to make sure, that no data left back from the previous run. <br> If set to `false`, the data will be appended to the target extent. <br>Not all of the sample pipelines support honor switch. Simple pipelines execute the drop code independant of the setting. |
| SourceSchema        | string | %               | If specified, then only slices of objects within the specified schema will be retrieved. |
| SourceObject        | string | %               | If specified, then only slices of the specified object (table/view) will be retrieved. |
| SlicedImportObject_Id | string | %               | If specified, then only slices of the specified object (table/view) will be retrieved. |
| ADX_DatabaseName    | string | SDMT_Demo       | Name of the ADX database |


In most scenario you just specify the `SourceSystemName` and the `Mode` parameter. The other parameters are used to control the behaviour of the pipeline. 
<br>
If you just execute pipeline tests, then it is handy to set the `Mode` parameter to `ALL`. This will retrieve all slices from the table `[Core].[SlicedImportObject]` independant of their load status.
<br>
In production you usually start with  `Mode` set to `REGULAR`. This will retrieve all slices from the table `[Core].[SlicedImportObject]` where the `LastStart` column is null. This means that the slice has not been loaded before.
<br> If some of the slices fail to load, then you can restart the pipeline wiht  `Mode` set to `RESTART`. This will retrieve all slices from the table `[Core].[SlicedImportObject]` where the `LastStart` column is not null and the `LastSuccessEnd` column is null. This means that the slice has been loaded before, but the load was not successful.

