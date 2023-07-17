
CREATE PROCEDURE [Core].[SetSlicedImportObjectEnd]
     @SlicedImportObject_Id uniqueidentifier
    ,@RowsTransferred int
AS
BEGIN
  SET NOCOUNT ON

    -- Update LastStart to the current time
    UPDATE [Core].[SlicedImportObject]
    SET [LastSuccessEnd]   = GETUTCDATE()
       ,[RowsTransferred]  = @RowsTransferred
    WHERE [SlicedImportObject_Id] = @SlicedImportObject_Id;

    -- Select all attributes for the given SlicedImportObject_Id
    SELECT 'DONE' [ForPipeline];
END;