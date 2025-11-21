/*
 * ******************************************************************************
 * @file           : microsoft_common_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : Solutions for tasks from the common part of List02 
                     in Transact-SQL.
 * ******************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 30
--------------------------------------------------------------------------------
CREATE OR ALTER VIEW Statystyki_band (
    [NAZWA_BANDY],
    [SRE_SPOZ],
    [MAX_SPOZ],
    [MIN_SPOZ],
    [KOTY],
    [KOTY_Z_DOD]
) AS
SELECT
    b.nazwa                AS nazwa, 
    AVG(k.przydzial_myszy) AS sre_spoz,
    MAX(k.przydzial_myszy) AS max_spoz,
    MIN(k.przydzial_myszy) AS min_spoz,
    COUNT(k.pseudo)        AS koty,
    COUNT(k.myszy_extra)   AS koty_z_dod
FROM Kocury k
    INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
GROUP BY
    nazwa;
GO

-- Zawartosc perspektywy
SELECT * 
FROM Statystyki_band;

-- Zapytanie dla kota wskazanego przez uzytkownika
DECLARE @pseudo_input VARCHAR(15);
SET @pseudo_input = 'PLACEK'

SELECT
    k.pseudo                                            [PSEUDONIM],
    k.imie                                              [IMIE],
    k.funkcja                                           [FUNKCJA],
    k.przydzial_myszy                                   [ZJADA],
    CONCAT('OD ', sb.[MIN_SPOZ], ' DO ', sb.[MAX_SPOZ]) [GRANICE SPOZYCIA],
    k.w_stadku_od                                       [LOWI OD]
FROM Kocury k
    INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
    INNER JOIN Statystyki_band sb ON sb.[NAZWA_BANDY] = b.nazwa
WHERE
    k.pseudo = UPPER(@pseudo_input);

--------------------------------------------------------------------------------
-- TASK 31
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- TASK 32
--------------------------------------------------------------------------------
--a)


--b)


