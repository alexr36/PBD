/*
 * ******************************************************************************
 * @file           : microsoft_procedures_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Microsoft T-SQL procedures from List 04.
 * ******************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 11
--------------------------------------------------------------------------------
-- a)
CREATE OR ALTER FUNCTION GetFunctionCnt () RETURNS INT
AS
BEGIN
    DECLARE
        @v_func_cnt INT;

    SELECT
        @v_func_cnt = COUNT(DISTINCT funkcja)
    FROM Kocury;

    RETURN @v_func_cnt;
END;
GO

CREATE OR ALTER FUNCTION GetSeparatorPodsumowanie (
    @p_func_cnt INT
) RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE
        @v_dynamic_sql      NVARCHAR(MAX) = N'',
        @v_dynamic_func_sep NVARCHAR(MAX) = N'',
        @v_index            INT           = 0;

    WHILE @v_index < @p_func_cnt
    BEGIN
        SET @v_dynamic_func_sep += N'REPLICATE(''-'', 10), '
        SET @v_index += 1
    END

    SELECT
        @v_dynamic_sql = 
        N'
        SELECT
            RIGHT(''Z'' + REPLICATE(''-'', 19), 20),
            REPLICATE(''-'', 6),
            REPLICATE(''-'', 4),
        '
        + @v_dynamic_func_sep +
        N'
            REPLICATE(''-'', 7)

        UNION ALL

        SELECT
            ''ZJADA RAZEM'',
            '' '',
            '' '',
        '
        +
        STRING_AGG(
            N'
                RIGHT(
                    REPLICATE('' '', 10) + 
                        CAST(SUM(CASE 
                                    WHEN funkcja = ''' + funkcja + N''' 
                                    THEN przydzial_myszy + ISNULL(myszy_extra, 0) 
                                    ELSE 0 
                                END) AS VARCHAR(50)), 
                10) [' + funkcja + ']',
            N', '
        ) WITHIN GROUP (ORDER BY funkcja DESC)
        +
        N'
            , RIGHT(SPACE(7) + CAST(SUM(przydzial_myszy + ISNULL(myszy_extra, 0)) AS VARCHAR(50)), 7)
        FROM Kocury
        '
    FROM (
        SELECT DISTINCT
            funkcja
        FROM Kocury
    ) f;

    RETURN @v_dynamic_sql;
END;
GO

CREATE OR ALTER PROCEDURE GetSumaSpozyciaA 
AS
BEGIN
    DECLARE
        @v_dynamic_sql NVARCHAR(MAX);

    SELECT
        @v_dynamic_sql =
        N'
        SELECT
            CASE k.plec
                WHEN ''D'' THEN b.nazwa
                WHEN ''M'' THEN '' ''
            END                                      [NAZWA BANDY],
            CASE k.plec
                WHEN ''D'' THEN ''Kotka''
                WHEN ''M'' THEN ''Kocor''
            END                                      [PLEC],
            RIGHT(REPLICATE('' '', 4) + COUNT(*), 4) [ILE],'
            +
            STRING_AGG(
                N'
                RIGHT(REPLICATE('' '', 10) + 
                CAST(SUM(
                    CASE 
                        WHEN k.funkcja = ''' + funkcja + ''' 
                            THEN k.przydzial_myszy + ISNULL(k.myszy_extra, 0)
                        ELSE 0
                    END
                ) AS VARCHAR), 10) [' + funkcja + ']',
                ', '
            )
            +
            N',
                RIGHT(REPLICATE('' '', 7) + CAST(SUM(k.przydzial_myszy + ISNULL(k.myszy_extra, 0)) AS VARCHAR), 7) [SUMA]
            FROM Kocury k
                INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
            GROUP BY
                b.nazwa,
                k.plec

            UNION ALL
            '
            + dbo.GetSeparatorPodsumowanie(dbo.GetFunctionCnt())
    FROM (
        SELECT DISTINCT 
            funkcja 
        FROM Kocury
    ) f;

    PRINT @v_dynamic_sql;

    EXEC sp_executesql @v_dynamic_sql;
END;
GO

EXEC GetSumaSpozyciaA;
GO

-- b)
CREATE OR ALTER PROCEDURE GetSumaSpozyciaB 
AS
BEGIN
    DECLARE
        @v_dynamic_sql NVARCHAR(MAX);

    SELECT
        @v_dynamic_sql =
        N'
        SELECT
            CASE plec
                WHEN ''D'' THEN nazwa
                WHEN ''M'' THEN '' ''
            END                                                  [NAZWA BANDY],
            CASE plec
                WHEN ''D'' THEN ''Kotka''
                WHEN ''M'' THEN ''Kocor'' 
            END                                                  [PLEC],
            RIGHT(REPLICATE('' '', 4) + CAST(ile AS VARCHAR), 4) [ILE],
        '
        +
        STRING_AGG(
            'RIGHT(REPLICATE('' '', 10) + CAST(ISNULL(' + QUOTENAME(funkcja) + ', 0) AS VARCHAR), 10) ' + QUOTENAME(funkcja),
            ', '
        ) WITHIN GROUP (ORDER BY funkcja)
        +
        ',
            RIGHT(REPLICATE('' '', 7) + CAST(' +
        STRING_AGG('ISNULL(' + funkcja + ', 0)', ' + ') WITHIN GROUP (ORDER BY funkcja) +
        '   AS VARCHAR), 7)                                      [SUMA]
        FROM (
            SELECT
                b.nazwa,
                k.plec,
                k.funkcja,
                k.przydzial_myszy + ISNULL(k.myszy_extra, 0) AS spozycie,
                COUNT(*) OVER (PARTITION BY b.nazwa, k.plec) AS ile
            FROM Kocury k
                INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
        ) src
        PIVOT (
            SUM(spozycie)
            FOR funkcja IN ('
            +
            STRING_AGG(
                QUOTENAME(funkcja),
                ', ' 
            ) WITHIN GROUP (ORDER BY funkcja)
            +
            ')
        ) pvt

        UNION ALL
        '
        + dbo.GetSeparatorPodsumowanie(dbo.GetFunctionCnt())
    FROM (
        SELECT DISTINCT
            funkcja
        FROM Kocury
    ) f;

PRINT @v_dynamic_sql;
    EXEC sp_executesql @v_dynamic_sql;
END;
GO

EXEC GetSumaSpozyciaB;
GO
