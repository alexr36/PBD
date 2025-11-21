/*
 * ******************************************************************************
 * @file           : microsoft_only_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : Solutions for tasks from the SQL Server part of List02.
 * ******************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 26
--------------------------------------------------------------------------------
WITH Kotki AS (
    SELECT
        pseudo
    FROM Kocury
    WHERE
        plec = 'D'
),
Incydenty AS (
    SELECT DISTINCT
        k.pseudo AS psd
    FROM Kotki k
        INNER JOIN Wrogowie_kocurow wk ON wk.pseudo = k.pseudo
        INNER JOIN Wrogowie w ON w.imie_wroga = wk.imie_wroga AND w.stopien_wrogosci > 5
)
SELECT
    psd [Zadziorne kotki]
FROM Incydenty
ORDER BY
    psd DESC;

--------------------------------------------------------------------------------
-- TASK 27
--------------------------------------------------------------------------------
WITH Hierarchia AS (
    -- Baza
    SELECT
        1 AS poziom,
        pseudo,
        funkcja,
        nr_bandy,
        plec
    FROM Kocury
    WHERE
        plec = 'M'
        AND
        funkcja = 'BANDZIOR'

    UNION ALL
    -- Rekurencyjne wywolanie
    SELECT
        poziom + 1,
        k.pseudo,
        k.funkcja,
        k.nr_bandy,
        k.plec
    FROM Kocury k
        INNER JOIN Hierarchia h ON h.pseudo = k.szef
)
SELECT
    poziom   [Poziom],
    pseudo   [Pseudonim],
    funkcja  [Funkcja],
    nr_bandy [Nr bandy]
FROM Hierarchia
WHERE 
    plec = 'M'
ORDER BY
    nr_bandy;

--------------------------------------------------------------------------------
-- TASK 28
--------------------------------------------------------------------------------
WITH Hierarchia AS (
    -- Baza
    SELECT
        0 AS poziom,
        szef,
        funkcja,
        pseudo,
        imie
    FROM Kocury
    WHERE
        szef IS NULL
        AND
        myszy_extra IS NOT NULL

    -- Rekurencyjne wywolanie
    UNION ALL

    SELECT
        h.poziom + 1,
        k.szef,
        k.funkcja,
        k.pseudo,
        k.imie
    FROM Kocury k INNER JOIN Hierarchia h ON h.pseudo = k.szef AND k.myszy_extra IS NOT NULL
)
SELECT
    CONCAT(
        REPLICATE('===>', poziom), 
        poziom, 
        REPLICATE(' ', 15 - 4 * poziom), 
        imie
    )                               [Hierarchia],
    ISNULL(szef, 'Sam sobie panem') [Pseudo szefa],
    funkcja                         [Funkcja]
FROM Hierarchia;

--------------------------------------------------------------------------------
-- TASK 29
--------------------------------------------------------------------------------
SELECT
    k1.pseudo [Do przeczolgania],
    b.nazwa  [Nazwa bandy]
FROM Kocury k1
    INNER JOIN Bandy b ON b.nr_bandy = k1.nr_bandy
    INNER JOIN Funkcje f ON f.funkcja = k1.funkcja
WHERE
    NOT EXISTS (
        SELECT *
        FROM Kocury k2
        WHERE
            k2.szef = k1.pseudo
    )
   AND
    EXISTS (
        SELECT *
        FROM Wrogowie_kocurow wk
        WHERE wk.pseudo = k1.pseudo
    )
    AND
    k1.przydzial_myszy > f.min_myszy + (f.max_myszy - f.min_myszy) / 3
ORDER BY
    [Nazwa bandy], [Do przeczolgania];
