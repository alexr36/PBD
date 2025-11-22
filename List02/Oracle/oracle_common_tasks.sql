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
-- Statystyki wg band i plci
CREATE OR REPLACE VIEW Statystyki_band_plec_A (
    "NAZWA BANDY", 
    "PLEC", 
    "ILE", 
    "SZEFUNIO", 
    "BANDZIOR", 
    "LOWCZY", 
    "LAPACZ", 
    "KOT", 
    "MILUSIA", 
    "DZIELCZY", 
    "SUMA"
) AS
SELECT
    DECODE(k.plec, 'D', b.nazwa, 'M', ' '),
    DECODE(k.plec, 'D', 'Kotka', 'M', 'Kocor'),
    TO_CHAR(COUNT(k.pseudo)),
    TO_CHAR(SUM(DECODE(
        k.funkcja,
        'SZEFUNIO', k.przydzial_myszy + NVL(k.myszy_extra, 0),
        0
    ))),
    TO_CHAR(SUM(DECODE(
        k.funkcja,
        'BANDZIOR', k.przydzial_myszy + NVL(k.myszy_extra, 0),
        0
    ))),
    TO_CHAR(SUM(DECODE(
        k.funkcja,
        'LOWCZY', k.przydzial_myszy + NVL(k.myszy_extra, 0),
        0
    ))),
    TO_CHAR(SUM(DECODE(
        k.funkcja,
        'LAPACZ', k.przydzial_myszy + NVL(k.myszy_extra, 0),
        0
    ))),
    TO_CHAR(SUM(DECODE(
        k.funkcja,
        'KOT', k.przydzial_myszy + NVL(k.myszy_extra, 0),
        0
    ))),
    TO_CHAR(SUM(DECODE(
        k.funkcja,
        'MILUSIA', k.przydzial_myszy + NVL(k.myszy_extra, 0),
        0
    ))),
    TO_CHAR(SUM(DECODE(
        k.funkcja,
        'DZIELCZY', k.przydzial_myszy + NVL(k.myszy_extra, 0),
        0
    ))),
    TO_CHAR(SUM(k.przydzial_myszy + NVL(k.myszy_extra, 0)))
FROM Kocury k 
    INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
GROUP BY
    b.nazwa, 
    k.plec
ORDER BY
    b.nazwa;

SELECT * 
FROM Statystyki_band_plec_A

UNION ALL

-- Separator
SELECT 
    'Z----------------', '------', '----', '---------', '---------', '---------', '---------', '---------', '---------', '---------', '-------'
FROM dual

UNION ALL

-- Podsumowanie
SELECT
    'ZJADA RAZEM',
    ' ',
    ' ',
    TO_CHAR(SUM("SZEFUNIO")),
    TO_CHAR(SUM("BANDZIOR")),
    TO_CHAR(SUM("LOWCZY")),
    TO_CHAR(SUM("LAPACZ")),
    TO_CHAR(SUM("KOT")),
    TO_CHAR(SUM("MILUSIA")),
    TO_CHAR(SUM("DZIELCZY")),
    TO_CHAR(SUM("SUMA"))
FROM Statystyki_band_plec_A;

--b)
-- Widok dla pivota
CREATE OR REPLACE VIEW Statystyki_band_plec_B (
    nazwa_bandy,
    plec_kota,
    funkcja_kota,
    spozycie
) AS
SELECT
    b.nazwa,
    k.plec,
    k.funkcja,
    k.przydzial_myszy + NVL(k.myszy_extra, 0)
FROM Kocury k
    INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy;

-- Widok do dołączenia - suma spozycia i liczba kotow danej plci w bandach
CREATE OR REPLACE VIEW Bandy_sumy_spozycia_per_liczba_kotow (
    nazwa,
    plec,
    liczba_kotow,
    suma_spozycia
) AS
SELECT
    nazwa,
    plec,
    COUNT(pseudo),
    SUM(przydzial_myszy + NVL(myszy_extra, 0))
FROM Kocury k1 
    INNER JOIN Bandy b1 ON b1.nr_bandy = k1.nr_bandy
GROUP BY nazwa, plec;

-- Statystyki
SELECT *
FROM (
    SELECT
        DECODE(plec_kota, 'D', nazwa_bandy, 'M', ' ') "NAZWA BANDY",
        DECODE(plec_kota, 'D', 'Kotka', 'M', 'Kocor') "PLEC",
        TO_CHAR(liczba_kotow)                         "ILE",
        TO_CHAR(NVL(szefunio, 0))                     "SZEFUNIO",
        TO_CHAR(NVL(bandzior, 0))                     "BANDZIOR",
        TO_CHAR(NVL(lowczy, 0))                       "LOWCZY",
        TO_CHAR(NVL(lapacz, 0))                       "LAPACZ",
        TO_CHAR(NVL(kot, 0))                          "KOT",
        TO_CHAR(NVL(milusia, 0))                      "MILUSIA",
        TO_CHAR(NVL(dzielczy, 0))                     "DZIELCZY",
        TO_CHAR(suma_spozycia)                        "SUMA"
    FROM Statystyki_band_plec_B
    PIVOT (
        SUM(spozycie) 
        FOR funkcja_kota IN (
            'SZEFUNIO' szefunio, 
            'BANDZIOR' bandzior, 
            'LOWCZY'   lowczy, 
            'LAPACZ'   lapacz, 
            'KOT'      kot, 
            'MILUSIA'  milusia, 
            'DZIELCZY' dzielczy
        )
    )
        INNER JOIN Bandy_sumy_spozycia_per_liczba_kotow 
            ON nazwa = nazwa_bandy AND plec = plec_kota
    ORDER BY
        nazwa_bandy
)

UNION ALL

-- Separator
SELECT
    'Z----------------', '------', '----', '---------', '---------', '---------', '---------', '---------', '---------', '---------', '-------'
FROM dual

UNION ALL

-- Podsumowanie
SELECT
    'ZJADA RAZEM',
    ' ',
    ' ',
    TO_CHAR(szefunio),
    TO_CHAR(bandzior),
    TO_CHAR(lowczy),
    TO_CHAR(lapacz),
    TO_CHAR(kot),
    TO_CHAR(milusia),
    TO_CHAR(dzielczy),
    TO_CHAR(suma)
FROM (
    SELECT
        k.funkcja                                 AS funkcja_kota,
        k.przydzial_myszy + NVL(k.myszy_extra, 0) AS spozycie
    FROM Kocury k
        INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
)
PIVOT (
    SUM(spozycie)
    FOR funkcja_kota IN (
        'SZEFUNIO' szefunio, 
        'BANDZIOR' bandzior, 
        'LOWCZY'   lowczy, 
        'LAPACZ'   lapacz, 
        'KOT'      kot, 
        'MILUSIA'  milusia, 
        'DZIELCZY' dzielczy
    )
)
 CROSS JOIN (
    SELECT
        SUM(przydzial_myszy + NVL(myszy_extra, 0)) AS suma
    FROM Kocury
 );
