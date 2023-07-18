
CREATE VIEW [Helper].[RowNumberList100K]
AS

    WITH BaseList1(n) AS
    (
        SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
        SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
        SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
    ),                                              -- 10
    BaseList2(n) AS (SELECT 1 FROM BaseList1 CROSS JOIN BaseList1 AS b), -- 10 *     10 =     100
    BaseList3(n) AS (SELECT 1 FROM BaseList1 CROSS JOIN BaseList2),      -- 10 *    100 =   1'000
    BaseList4(n) AS (SELECT 1 FROM BaseList1 CROSS JOIN BaseList3),      -- 10 *  1'000 =  10'000
    BaseList5(n) AS (SELECT 1 FROM BaseList1 CROSS JOIN BaseList4)       -- 10 * 10'000 = 100'000
   ,FullList(RowNumber)
    AS (
    SELECT  n = ROW_NUMBER()  OVER (ORDER BY n) -1 -- Zero Based
    FROM BaseList5
    )
	select RowNumber
	from FullList