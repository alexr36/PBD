/*
 * ******************************************************************************
 * @file           : oracle_common_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : Solutions for tasks from the common part of List02 
                     in Oracle SQ:.
 * ******************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 30
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Statystyki_band (
    "NAZWA BANDY", 
    "SRE_SPOZ", 
    "MAX_SPOZ", 
    "MIN_SPOZ", 
    "KOTY", 
    "KOTY_Z_DOD"
) AS
SELECT
    b.nazwa                AS nazwa,
    AVG(k.przydzial_myszy) AS sre_spoz,
    MAX(k.przydzial_myszy) AS max_spoz,
    MIN(k.przydzial_myszy) AS min_spoz,
    COUNT(k.pseudo)        AS koty,
    COUNT(k.myszy_extra)   AS koty_z_dod
FROM Bandy b
    INNER JOIN Kocury k ON k.nr_bandy = b.nr_bandy
GROUP BY
    nazwa
ORDER BY
    max_spoz DESC;

-- Zawartosc perspektywy
SELECT *
FROM Statystyki_band;

-- Zapytanie dla kota wskazanego przez uzytkownika
SELECT
    k.pseudo                                      "PSEUDONIM",
    k.imie                                        "IMIE",
    k.funkcja                                     "FUNKCJA",
    k.przydzial_myszy                             "ZJADA",
    'OD ' || sb.min_spoz || ' DO ' || sb.max_spoz "GRANICE SPOZYCIA",
    TO_CHAR(k.w_stadku_od, 'YYYY-MM-DD')          "LOWI OD"
FROM Kocury k
    INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
    INNER JOIN Statystyki_band sb ON sb."NAZWA BANDY" = b.nazwa
WHERE
    k.pseudo = UPPER(&pseudo_input);

UNDEFINE pseudo_input;

--------------------------------------------------------------------------------
-- TASK 31
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Najdluzsze_staze (
    pseudonim, 
    plec,
    myszy, 
    extra,
    num_bandy
) AS
WITH Koty_z_czarni_rycerze AS (
    SELECT
        k.pseudo
    FROM Kocury k
        INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
    WHERE
        b.nazwa = 'CZARNI RYCERZE'
    ORDER BY
        k.w_stadku_od
    FETCH FIRST 3 ROWS ONLY
),
Koty_z_laciaci_mysliwi AS (
    SELECT
        k.pseudo
    FROM Kocury k
        INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
    WHERE
        b.nazwa = 'LACIACI MYSLIWI'
    ORDER BY
        k.w_stadku_od
    FETCH FIRST 3 ROWS ONLY
)
SELECT
    k.pseudo,
    k.plec,
    k.przydzial_myszy,
    k.myszy_extra,
    k.nr_bandy
FROM Kocury k
    LEFT JOIN Koty_z_czarni_rycerze cr ON k.pseudo = cr.pseudo
    LEFT JOIN Koty_z_laciaci_mysliwi lm ON k.pseudo = lm.pseudo
WHERE
    cr.pseudo IS NOT NULL
    OR
    lm.pseudo IS NOT NULL;

-- Przed podywzkami
SELECT
    pseudonim "Pseudonim",
    plec      "Plec",
    myszy     "Myszy przed podw.",
    extra     "Extra przed podw."
FROM Najdluzsze_staze;

-- Podwyzka
UPDATE Najdluzsze_staze
SET 
    myszy = myszy + DECODE(
        plec,
        'D', 0.1 * (SELECT MIN(przydzial_myszy) FROM Kocury),
        'M', 10
    ),
    extra = NVL(extra, 0) + 0.15 * (
        SELECT 
            AVG(NVL(k.myszy_extra, 0) )
        FROM Kocury k
        WHERE
            k.nr_bandy = num_bandy
    );

-- Po podwyzce
SELECT
    pseudonim "Pseudonim",
    plec      "Plec",
    myszy     "Myszy po podw.",
    extra     "Extra po podw."
FROM Najdluzsze_staze;

ROLLBACK;

--------------------------------------------------------------------------------
-- TASK 32
--------------------------------------------------------------------------------
--a)


--b)

