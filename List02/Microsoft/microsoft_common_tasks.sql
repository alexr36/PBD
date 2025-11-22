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
GO

-- Statystyki wg band i plci
CREATE OR ALTER VIEW Statystyki_band_plec_A (
    nazwa_bandy,
    plec,
    ile,
    szefunio,
    bandzior,
    lowczy,
    lapacz,
    kot,
    milusia,
    dzielczy,
    suma
) AS
SELECT
    CASE
        WHEN k.plec = 'D' THEN b.nazwa
        WHEN k.plec = 'M' THEN ' '
    END,
    CASE
        WHEN k.plec = 'D' THEN 'Kotka'
        WHEN k.plec = 'M' THEN 'Kocor'
    END,
    COUNT(k.pseudo),
    SUM(CASE
            WHEN k.funkcja = 'SZEFUNIO' THEN k.przydzial_myszy + ISNULL(k.myszy_extra, 0)
            ELSE 0
        END),
    SUM(CASE
            WHEN k.funkcja = 'BANDZIOR' THEN k.przydzial_myszy + ISNULL(k.myszy_extra, 0)
            ELSE 0
        END),
    SUM(CASE
            WHEN k.funkcja = 'LOWCZY' THEN k.przydzial_myszy + ISNULL(k.myszy_extra, 0)
            ELSE 0
        END),
    SUM(CASE
            WHEN k.funkcja = 'LAPACZ' THEN k.przydzial_myszy + ISNULL(k.myszy_extra, 0)
            ELSE 0
        END),
    SUM(CASE
            WHEN k.funkcja = 'KOT' THEN k.przydzial_myszy + ISNULL(k.myszy_extra, 0)
            ELSE 0
        END),
    SUM(CASE
            WHEN k.funkcja = 'MILUSIA' THEN k.przydzial_myszy + ISNULL(k.myszy_extra, 0)
            ELSE 0
        END),
    SUM(CASE
            WHEN k.funkcja = 'DZIELCZY' THEN k.przydzial_myszy + ISNULL(k.myszy_extra, 0)
            ELSE 0
        END),
    SUM(k.przydzial_myszy + ISNULL(k.myszy_extra, 0))
FROM Kocury k
    INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
GROUP BY
    b.nazwa, 
    k.plec;

GO


SELECT
    nazwa_bandy               [NAZWA BANDY],
    plec                      [PLEC],
    CAST(ile AS VARCHAR)      [ILE],
    CAST(szefunio AS VARCHAR) [SZEFUNIO],
    CAST(bandzior AS VARCHAR) [BANDZIOR],
    CAST(lowczy AS VARCHAR)   [LOWCZY],
    CAST(lapacz AS VARCHAR)   [LAPACZ],
    CAST(kot AS VARCHAR)      [KOT],
    CAST(milusia AS VARCHAR)  [MILUSIA],
    CAST(dzielczy AS VARCHAR) [DZIELCZY],
    CAST(suma AS VARCHAR)     [SUMA]
FROM Statystyki_band_plec_A

UNION ALL

-- Separator
SELECT 
    'Z----------------' AS Col1,
    '------'            AS Col2,
    '----'              AS Col3,
    '---------'         AS Col4,
    '---------'         AS Col5,
    '---------'         AS Col6,
    '---------'         AS Col7,
    '---------'         AS Col8,
    '---------'         AS Col9,
    '---------'         AS Col10,
    '-------'           AS Col11

UNION ALL

-- Podsumowanie
SELECT
    'ZJADA RAZEM',
    ' ',
    ' ',
    CAST((SUM([SZEFUNIO])) AS VARCHAR),
    CAST((SUM([BANDZIOR])) AS VARCHAR),
    CAST((SUM([LOWCZY])) AS VARCHAR),
    CAST((SUM([LAPACZ])) AS VARCHAR),
    CAST((SUM([KOT])) AS VARCHAR),
    CAST((SUM([MILUSIA])) AS VARCHAR),
    CAST((SUM([DZIELCZY])) AS VARCHAR),
    CAST((SUM([SUMA])) AS VARCHAR)
FROM Statystyki_band_plec_A;

--b)
-- Widok dla pivota
GO

CREATE OR ALTER VIEW Statystyki_band_plec_B (
    nazwa_bandy,
    plec_kota,
    funkcja_kota,
    spozycie
) AS
SELECT
    b.nazwa,
    k.plec,
    k.funkcja,
    k.przydzial_myszy + ISNULL(k.myszy_extra, 0)
FROM Kocury k
    INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy;

GO

-- Widok do dołączenia - suma spozycia i liczba kotow danej plci w bandach
CREATE OR ALTER VIEW Bandy_sumy_spozycia_per_liczba_kotow (
    nazwa,
    plec,
    liczba_kotow,
    suma_spozycia
) AS
SELECT
    nazwa,
    plec,
    COUNT(pseudo),
    SUM(przydzial_myszy + ISNULL(myszy_extra, 0))
FROM Kocury k1 
    INNER JOIN Bandy b1 ON b1.nr_bandy = k1.nr_bandy
GROUP BY nazwa, plec;

GO

-- Statystyki
SELECT *
FROM (
    SELECT
        CASE 
            WHEN plec_kota = 'D' THEN nazwa_bandy
            WHEN plec_kota = 'M' THEN ' '
        END [NAZWA BANDY],
        CASE 
            WHEN plec_kota = 'D' THEN 'Kotka'  
            WHEN plec_kota = 'M' THEN 'Kocor'
        END [PLEC],
        CAST(liczba_kotow AS VARCHAR)        [ILE],
        CAST(ISNULL(szefunio, 0) AS VARCHAR) [SZEFUNIO],
        CAST(ISNULL(bandzior, 0) AS VARCHAR) [BANDZIOR],
        CAST(ISNULL(lowczy, 0) AS VARCHAR)   [LOWCZY],
        CAST(ISNULL(lapacz, 0) AS VARCHAR)   [LAPACZ],
        CAST(ISNULL(kot, 0) AS VARCHAR)      [KOT],
        CAST(ISNULL(milusia, 0) AS VARCHAR)  [MILUSIA],
        CAST(ISNULL(dzielczy, 0) AS VARCHAR) [DZIELCZY],
        CAST(suma_spozycia AS VARCHAR)       [SUMA]
    FROM Statystyki_band_plec_B
    PIVOT (
        SUM(spozycie) 
        FOR funkcja_kota IN (
            SZEFUNIO, 
            BANDZIOR, 
            LOWCZY, 
            LAPACZ, 
            KOT, 
            MILUSIA,
            DZIELCZY
        )
    ) AS pvt
        INNER JOIN Bandy_sumy_spozycia_per_liczba_kotow 
            ON nazwa = nazwa_bandy AND plec = plec_kota
) AS T

UNION ALL

-- Separator
SELECT 
    'Z----------------' AS Col1,
    '------'            AS Col2,
    '----'              AS Col3,
    '---------'         AS Col4,
    '---------'         AS Col5,
    '---------'         AS Col6,
    '---------'         AS Col7,
    '---------'         AS Col8,
    '---------'         AS Col9,
    '---------'         AS Col10,
    '-------'           AS Col11

UNION ALL

-- Podsumowanie
SELECT
    'ZJADA RAZEM',
    ' ',
    ' ',
    CAST(szefunio AS VARCHAR),
    CAST(bandzior AS VARCHAR),
    CAST(lowczy AS VARCHAR),
    CAST(lapacz AS VARCHAR),
    CAST(kot AS VARCHAR),
    CAST(milusia AS VARCHAR),
    CAST(dzielczy AS VARCHAR),
    CAST(suma AS VARCHAR)
FROM (
    SELECT
        k.funkcja                                 AS funkcja_kota,
        k.przydzial_myszy + ISNULL(k.myszy_extra, 0) AS spozycie
    FROM Kocury k
        INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
) AS dane
PIVOT (
    SUM(spozycie)
    FOR funkcja_kota IN (
        SZEFUNIO, 
        BANDZIOR, 
        LOWCZY, 
        LAPACZ, 
        KOT, 
        MILUSIA, 
        DZIELCZY
    )
) AS pvt
 CROSS JOIN (
    SELECT
        SUM(przydzial_myszy + ISNULL(myszy_extra, 0)) AS suma
    FROM Kocury
) AS sumy;
