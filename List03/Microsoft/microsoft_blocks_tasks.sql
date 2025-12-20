/*
 * *****************************************************************************
 * @file           : microsoft_blocks_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Microsoft T-SQL blocks.
 * *****************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 2
--------------------------------------------------------------------------------
DECLARE @pseudo_input VARCHAR(15) = 'tyGrYs'

DECLARE
    @pseudo                  VARCHAR(15),
    @imie                    VARCHAR(15),
    @nazwa_bandy             VARCHAR(20),
    @czy_ma_wrogow           VARCHAR(3),
    @czy_wiekszy_od_sredniej VARCHAR(3),
    @w_stadku_od             DATE,
    @przydzial_myszy         INT,
    @srednia_bandy           FLOAT;

IF NOT EXISTS (
    SELECT
        pseudo
    FROM Kocury
    WHERE
        pseudo = UPPER(@pseudo_input)
)
BEGIN
    PRINT 'ERROR: Kot o podanym pseudonimie nie istnieje: ' + UPPER(@pseudo_input);
    RETURN;
END;

SELECT
    @pseudo          = k.pseudo,
    @imie            = k.imie,
    @nazwa_bandy     = b.nazwa,
    @w_stadku_od     = k.w_stadku_od,
    @przydzial_myszy = k.przydzial_myszy
FROM Kocury k
    INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
WHERE
    k.pseudo = UPPER(@pseudo_input);

IF EXISTS (
    SELECT
        pseudo
    FROM Wrogowie_kocurow
    WHERE
        pseudo = UPPER(@pseudo_input)
)
    SET @czy_ma_wrogow = 'TAK';
ELSE
    SET @czy_ma_wrogow = 'NIE';

SELECT
    @srednia_bandy = AVG(12.0 * przydzial_myszy)
FROM Kocury
WHERE
    nr_bandy = (
        SELECT
            nr_bandy
        FROM Kocury
        WHERE
            pseudo = UPPER(@pseudo_input)
    );

IF 12 * @przydzial_myszy > @srednia_bandy
    SET @czy_wiekszy_od_sredniej = 'TAK';
ELSE
    SET @czy_wiekszy_od_sredniej = 'NIE';

PRINT 'Pseudo:'                                              + SPACE(46) + @pseudo;
PRINT 'Imie:'                                                + SPACE(48) + @imie;
PRINT 'Nazwa bandy:'                                         + SPACE(41) + @nazwa_bandy;
PRINT 'Czy ma wrogow:'                                       + SPACE(39) + @czy_ma_wrogow;
PRINT 'Czy roczny przydzial jest wiekszy od sredniej bandy:' + SPACE(1)  + @czy_wiekszy_od_sredniej;
PRINT 'Dzien przystapienia do stada:'                        + SPACE(24) + CAST(DAY(@w_stadku_od) AS VARCHAR);
PRINT 'Miesiac przystapienia do stada:'                      + SPACE(22) + DATENAME(month, @w_stadku_od);
PRINT 'Rok przystapienia do stada:'                          + SPACE(26) + CAST(YEAR(@w_stadku_od) AS VARCHAR);

--------------------------------------------------------------------------------
-- TASK 4
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- TASK 5
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- TASK 6
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- TASK 7
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
