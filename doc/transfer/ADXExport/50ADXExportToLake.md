




# Transfer data from an ADX table to the data lake via an external table

## Table of Contents

- [Transfer data from an ADX table to the data lake via an external table](#transfer-data-from-an-adx-table-to-the-data-lake-via-an-external-table)
  - [Table of Contents](#table-of-contents)
    - [Scenario](#scenario)
      - [Source Files](#source-files)


<br>


<br>

### Scenario

This pipeline can be used to export data from an ADX table to the lake via an external table.

<br>

The loop in the sample pipeline is defined a sequential. If you have a cluster with more resources, you can change the loop to parallel.


<br>
<br>

You can find a step guide, how to define metadata and deploy the pipeline in [Details](./10SQLToADXCopy.md)

#### Source Files
 * [Required objects (SQL + ADX) and SQL meta data](./../../../sqldb/MT_DB/ScriptToGenerateMetaTestData/ADXExport/ADX_ExportToLake.sql)
 * Pipeline definition 
   * [Pipeline calling ADX function with one string parameter ('YYYYMMDD')](./../../../pipeline/ToADX/SQLtoLake-FunctionCall-ADX/SDMT-SQL-Lake-ADX-ViaFunctionTo-ADX-ConditionalDelete.json)
   

