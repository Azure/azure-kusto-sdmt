## SQL to ADX using the sql_request function

ADX is capable to read data from a remote SQL Server database. The the sql_request function is used to execute a SQL statement on a remote SQL Server database. The function returns a table with the result of the SQL statement. The function is used in the following way:

    sql_request("Server=<server>;Database=<database>;User Id=<user>;Password=<password>", "SELECT * FROM Core.Measurement")
<br>

### Scenario

The following scenario is used to explain the concept. The source database is a SQL database and the destination is an ADX database. The data is transferred in day slices. The data is partitioned by the column `Ts`.
The data is transferred from the source table `Core.Measurement` to the destination table `Core_Measurement`. 

![Senario Overview](./../../doc/assets/sql-to-adx/SMDT_SQLtoADXFunctionScenario.png)

<br>
<br>

You can find a step guide, how to define metadata and deploy the pipeline in [Details](./10SQLToADXCopy.md)

#### Source Files
 * [Required objects (SQL + ADX) and SQL meta data](./../../sqldb/SDMT_DB/ScriptToGenerateMetaTestData/ToADX/SQLToADX_ADXFunction.sql)
 * Pipeline definition 
   * [Pipeline calling ADX function with one string parameter ('YYYYMMDD')]                    (./../../pipeline/toADX/SQL-Copy-ADX/SDMT-SQLorLake-ViaFunctionTo-ADX.json)
   * [Pipeline calling ADX function with one string parameter ('YYYYMMDD'), conditional delete](./../../pipeline/toADX/SQLtoLake-FunctionCall-ADX/SDMT-SQLorLake-ViaFunctionTo-ADX-ConditionalDelete.json)
   * [Pipeline calling ADX function with one string parameter to pass the full where condition, conditional delete](./../../pipeline/toADX/SQLtoLake-FunctionCall-ADX/SDMT-SQL-ViaFullWhereFunctionTo-ADX-ConditionalDelete.json)


