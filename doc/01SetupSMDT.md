

- [More automated setup details to come.](#more-automated-setup-details-to-come)
  - [Big picture](#big-picture)
  - [Meta data database setup](#meta-data-database-setup)
  - [Azure Data Factory/Synapse Pipeline Datasets](#azure-data-factorysynapse-pipeline-datasets)
  - [Linked Services](#linked-services)



## More automated setup details to come.

### Big picture

1. Deploy database project to an (Azure) SQL Server
2. Create/deploy linked server, datasets & pipelines in ADF/Synapse 
3. generate meta data 

... and let it rock.

<br>

### Meta data database setup

The repository contains a database project below the folder `sqldb`. You can take the database project and deploy it to an Azure SQL database or to a SQL Server. The database project contains the required objects to run the sample pipelines. You can also use your own database and objects. 

<br>

### Azure Data Factory/Synapse Pipeline Datasets

The sample pipelines use the following datasets to connect to the different data sources/sinks. You can either create datasets with the same name in your environment of 

| Dataset Name | Parameter | Purpose | Required Permissions |
| ------------ | --------- | ------- | -------------------- |
| SMDT_MetaData | -- | Get meta data | Read, Write, Execute |
| SMDT_SQLSource | DatabaseName | Read the data to be transferred to the destination | Read |
| SMDT_ADX_WithParameter | DatabaseName, TableName | Write (or read) data to(/from) an ADX table | Viewer, Ingestor |
| SMDT_DataLakeParquet | ContainerName, DestinationPath | Read and write parquet files | Storage Blob Data Reader, Storage Blob Data Contributor |

<br>

### Linked Services

The following linked service is used by the sample pipelines.

| Service Name | Parameter | Purpose |
| ------------ | --------- | ------- |
| SMDT_ADX | DatabaseName | Name of the target ADX database |

<br>

You can either create data sets/linked service with the same name or replace the name in the pipeline with your object names.

<br>


