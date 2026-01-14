/*
 * ******************************************************************************
 * @file           : microsoft_blocks_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Microsoft T-SQL blocks from List 04.
 * ******************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 1
--------------------------------------------------------------------------------
-- a)
DECLARE
    @przelozeni_num INT = 2,
    @dynamic_sql    NVARCHAR(MAX),
    @index          INT = 1,
    @index_nvarchar NVARCHAR(3);

-- Poczatek kwerendy
SET @dynamic_sql = 'SELECT k0.imie AS Imie';

-- Wyznaczenie danych do wypisania
WHILE @index <= @przelozeni_num
BEGIN
    SET @index_nvarchar = CAST(@index AS NVARCHAR);
    SET @dynamic_sql += N', ISNULL(k' + @index_nvarchar + N'.imie, '''') AS [Szef ' + @index_nvarchar + N']';
    SET @index += 1;
END;

SET @dynamic_sql += N' FROM Kocury k0';

SET @index = 1;

-- Wyznaczenie zlaczen
WHILE @index <= @przelozeni_num
BEGIN
    SET @index_nvarchar = CAST(@index AS NVARCHAR);
    SET @dynamic_sql += N' LEFT JOIN Kocury k' + @index_nvarchar + N' ON k' + @index_nvarchar 
                      + N'.pseudo = k' + CAST(@index - 1 AS NVARCHAR) + N'.szef';

    SET @index += 1;
END;

-- Dodanie warunkow poczatkowych i porzadku
SET @dynamic_sql += N'
    WHERE 
        k0.funkcja IN (''KOT'', ''MILUSIA'')
    ORDER BY 
        k0.imie;
    ';

-- Wywolanie
EXEC sp_executesql @dynamic_sql;
