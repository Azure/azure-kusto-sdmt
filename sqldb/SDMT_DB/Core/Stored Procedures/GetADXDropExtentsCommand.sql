CREATE PROCEDURE [Core].[GetADXDropExtentsCommand]
(   
    @SourceSystemName sysname
   ,@Mode             VARCHAR(25) = 'StartedSlices'
)
AS
BEGIN
   
   ;WITH OpenTransfer
   AS
   (
   SELECT *
         ,ROW_NUMBER() OVER (ORDER BY [LastStart], [SourceObject]) AS RowNumber
   FROM [Core].[SlicedImportObject]
       WHERE SourceSystemName = @SourceSystemName
   	  AND ((@Mode = 'StartedSlices' AND [LastStart] IS NOT NULL AND [LastSuccessEnd] IS NULL)
	   OR  (@Mode = 'AllSlices'))
   )
   SELECT 
   		CONCAT(CASE WHEN RowNumber = 1 THEN '.execute database script <| ' + CHAR(13) +  CHAR(10) ELSE '' END 
   		       ,'.drop extents <| .show table ' + DestinationObject + ' extents where tags has ''' + 'ExtentFingerprint:' + [ExtentFingerprint] + '''' + CHAR(13) +  CHAR(10)

   		       ) DropExtends
   FROM OpenTransfer
END