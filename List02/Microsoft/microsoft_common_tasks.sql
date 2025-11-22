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
DROP VIEW Statystyki_band;
GO

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
GO

CREATE OR ALTER VIEW Najdluzsze_staze (
    pseudonim,
    plec,
    myszy,
    extra,
    num_bandy
) AS
WITH Koty_z_czarni_rycerze AS (
    SELECT TOP(3)
        k.pseudo
    FROM Kocury k
        INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
    WHERE
        b.nazwa = 'CZARNI RYCERZE'
    ORDER BY
        k.w_stadku_od
),
Koty_z_laciaci_mysliwi AS (
    SELECT TOP(3)
        k.pseudo
    FROM Kocury k
        INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
    WHERE
        b.nazwa = 'LACIACI MYSLIWI'
    ORDER BY
        k.w_stadku_od
)
SELECT
    k.pseudo,
    k.plec,
    k.przydzial_myszy,
    k.myszy_extra,
    k.nr_bandy
FROM Kocury k
    LEFT JOIN Koty_z_czarni_rycerze cr ON cr.pseudo = k.pseudo
    LEFT JOIN Koty_z_laciaci_mysliwi lm ON lm.pseudo = k.pseudo
WHERE
    cr.pseudo IS NOT NULL
    OR
    lm.pseudo IS NOT NULL;

GO

-- Przed podwyzkami
SELECT
    pseudonim        [Pseudonim],
    plec             [Plec],
    myszy            [Myszy przed podw.],
    ISNULL(extra, 0) [Extra przed podw.]
FROM Najdluzsze_staze;

-- Podwyzka
BEGIN TRANSACTION;

UPDATE Najdluzsze_staze
SET
    myszy = myszy + 
    CASE 
        WHEN plec = 'D' THEN 0.1 * (SELECT MIN(przydzial_myszy) FROM Kocury) 
        WHEN plec = 'M' THEN 10  
    END,
    extra = ISNULL(extra, 0) + 0.15 * (
        SELECT 
            AVG(ISNULL(k.myszy_extra, 0)) 
        FROM Kocury k
        WHERE
            k.nr_bandy = num_bandy
    );

-- Po podwyzce
SELECT
    pseudonim        [Pseudonim],
    plec             [Plec],
    myszy            [Myszy po podw.],
    ISNULL(extra, 0) [Extra po podw.]
FROM Najdluzsze_staze;

ROLLBACK;

--------------------------------------------------------------------------------
-- TASK 32
--------------------------------------------------------------------------------
--a)


--b)


