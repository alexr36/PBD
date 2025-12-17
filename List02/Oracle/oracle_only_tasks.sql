/*
 * ******************************************************************************
 * @file           : oracle_only_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : Solutions for tasks from the Oracle part of List02.
 * ******************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 12
--------------------------------------------------------------------------------
SELECT
    k.pseudo          "POLUJE W POLU",
    k.przydzial_myszy "PRZYDZIAL MYSZY",
    b.nazwa           "BANDA"
FROM Kocury k
    INNER JOIN Bandy b ON k.nr_bandy = b.nr_bandy
WHERE
    b.teren IN ('POLE', 'CALOSC')
    AND
    k.przydzial_myszy > 50
ORDER BY
    k.przydzial_myszy DESC;

--------------------------------------------------------------------------------
-- TASK 13
--------------------------------------------------------------------------------
SELECT
    k1.imie                               "IMIE",
    TO_CHAR(k1.w_stadku_od, 'YYYY-MM-DD') "POLUJE OD"
FROM Kocury k1
    INNER JOIN Kocury k2 ON k2.imie = 'JACEK'
WHERE
    k1.w_stadku_od < k2.w_stadku_od
ORDER BY
    k1.w_stadku_od DESC;

--------------------------------------------------------------------------------
-- TASK 14
--------------------------------------------------------------------------------
-- a)
SELECT
    k1.imie           "Imie",
    k1.funkcja        "Funkcja",
    NVL(k2.imie, ' ') "Szef 1",
    NVL(k3.imie, ' ') "Szef 2",
    NVL(k4.imie, ' ') "Szef 3"
FROM Kocury k1
    LEFT JOIN Kocury k2 ON k1.szef = k2.pseudo
    LEFT JOIN Kocury k3 ON k2.szef = k3.pseudo
    LEFT JOIN Kocury k4 ON k3.szef = k4.pseudo
WHERE 
    k1.funkcja IN ('KOT', 'MILUSIA');
    
-- b)
WITH Drzewo AS (
    SELECT
        imie    "Imie",
        funkcja "Funkcja",
        CONNECT_BY_ROOT imie AS szef_podst,
        LEVEL - 1 AS lvl
    FROM Kocury
    WHERE 
        funkcja IN ('KOT', 'MILUSIA')
    CONNECT BY PRIOR pseudo = szef
)
SELECT *
FROM Drzewo
PIVOT (
    MAX(szef_podst)
    FOR lvl IN (1 AS "Szef 1", 2 AS "Szef 2", 3 AS "Szef 3")
);

-- c)
SELECT 
    imie    "Imie", 
    funkcja "Funkcja", 
    LTRIM(
        REVERSE(
            RTRIM(
                SYS_CONNECT_BY_PATH(REVERSE(RPAD(imie, 12, ' ')), ' | '), 
                imie
            )
        ), 
        '| '
    )     "Imiona kolejnych szefow"
FROM Kocury
WHERE 
    funkcja IN ('KOT', 'MILUSIA')
START WITH szef IS NULL
CONNECT BY PRIOR pseudo = szef;

--------------------------------------------------------------------------------
-- TASK 15
--------------------------------------------------------------------------------
SELECT
    k.imie                                   "Imie kotki",
    b.nazwa                                  "Nazwa bandy",
    wk.imie_wroga                            "Imie wroga",
    w.stopien_wrogosci                       "Poziom wroga",
    TO_CHAR(wk.data_incydentu, 'YYYY-MM-DD') "Data inc."
FROM Kocury k
    INNER JOIN Bandy b ON k.nr_bandy = b.nr_bandy
    INNER JOIN Wrogowie_kocurow wk ON k.pseudo = wk.PSEUDO
    INNER JOIN Wrogowie w ON wk.imie_wroga = w.imie_wroga
WHERE
    k.plec = 'D'
    AND
    wk.data_incydentu > '2007-01-01'
ORDER BY 
    k.imie;

--------------------------------------------------------------------------------
-- TASK 16
--------------------------------------------------------------------------------
SELECT
   b.nazwa                  "Nazwa bandy",
   COUNT(DISTINCT k.pseudo) "Koty z wrogami"
FROM Bandy b
    INNER JOIN Kocury k ON k.nr_bandy = b.nr_bandy
    INNER JOIN Wrogowie_kocurow wk ON wk.pseudo = k.pseudo
GROUP BY 
    b.nazwa
ORDER BY
    b.nazwa;

--------------------------------------------------------------------------------
-- TASK 17
--------------------------------------------------------------------------------
SELECT
    k.funkcja "Funkcja",
    k.pseudo  "Pseudonim kota",
    COUNT(*)  "Liczba wrogow"
FROM Kocury k
    INNER JOIN Wrogowie_kocurow wk ON wk.pseudo = k.pseudo
GROUP BY
    k.funkcja, k.pseudo
HAVING
    COUNT(*) > 1;

--------------------------------------------------------------------------------
-- TASK 18
--------------------------------------------------------------------------------
SELECT 
    imie "IMIE",
    12 * (przydzial_myszy + myszy_extra) "DAWKA ROCZNA",
    'powyzej 864' "DAWKA"
FROM Kocury
WHERE 
    myszy_extra IS NOT NULL
    AND 
    12 * (przydzial_myszy + myszy_extra) > 864

UNION

SELECT
    imie                                 "IMIE",
    12 * (przydzial_myszy + myszy_extra) "DAWKA ROCZNA",
    LPAD('864', 11, ' ')                 "DAWKA"
FROM Kocury
WHERE 
    myszy_extra IS NOT NULL
    AND 
    12 * (przydzial_myszy + myszy_extra) = 864

UNION

SELECT
    imie                                 "IMIE",
    12 * (przydzial_myszy + myszy_extra) "DAWKA ROCZNA",
    'ponizej 864'                        "DAWKA"
FROM Kocury
WHERE 
    myszy_extra IS NOT NULL
    AND 
    12 * (przydzial_myszy + myszy_extra) < 864
    
ORDER BY
    "DAWKA ROCZNA" DESC;

--------------------------------------------------------------------------------
-- TASK 19
--------------------------------------------------------------------------------
-- a)
SELECT
    b.nr_bandy "NR BANDY",
    b.nazwa    "NAZWA",
    b.teren    "TEREN"
FROM Bandy b
    LEFT JOIN Kocury k ON k.nr_bandy = b.nr_bandy
WHERE k.nr_bandy IS NULL;

-- b)
SELECT
    nr_bandy "NR BANDY",
    nazwa    "NAZWA",
    teren    "TEREN"
FROM Bandy

MINUS

SELECT
    b.nr_bandy "NR BANDY",
    b.nazwa    "NAZWA",
    b.teren    "TEREN"
FROM Bandy b
    INNER JOIN Kocury k ON k.nr_bandy = b.nr_bandy;

--------------------------------------------------------------------------------
-- TASK 20
--------------------------------------------------------------------------------
WITH Max_przydzial AS (
    SELECT *
    FROM (
        SELECT
            k.przydzial_myszy AS przydzial
        FROM Kocury k
            INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
        WHERE
            k.funkcja = 'MILUSIA'
            /* 
               Aby kwerenda zwracała wynik identyczny jak w przykładzie,
               nalezy pominąc nastepny warunek.
            */ 
            AND
            b.teren = 'SAD'
        ORDER BY
            przydzial DESC
    )
    WHERE
        ROWNUM = 1
)
SELECT 
    k.imie            "IMIE",
    k.funkcja         "FUNKCJA",
    k.przydzial_myszy "PRZYDZIAL MYSZY"
FROM Kocury k
    CROSS JOIN Max_przydzial mp
WHERE
    k.przydzial_myszy >= 3 * mp.przydzial
ORDER BY
    k.przydzial_myszy;

--------------------------------------------------------------------------------
-- TASK 21
--------------------------------------------------------------------------------
WITH Avg_przydzialy AS (
    SELECT
        funkcja,
        AVG(przydzial_myszy + NVL(myszy_extra, 0))                                   AS przydzial,
        DENSE_RANK() OVER (ORDER BY AVG(przydzial_myszy + NVL(myszy_extra, 0)))      AS min_rank,
        DENSE_RANK() OVER (ORDER BY AVG(przydzial_myszy + NVL(myszy_extra, 0)) DESC) AS max_rank 
    FROM Kocury
    WHERE
        funkcja != 'SZEFUNIO' 
    GROUP BY
        funkcja
)
SELECT
    funkcja             "Funkcja",
    ROUND(przydzial, 0) "Srednio najw. i najm. myszy"
FROM Avg_przydzialy
WHERE
    min_rank = 1 
    OR 
    max_rank = 1;

--------------------------------------------------------------------------------
-- TASK 22
--------------------------------------------------------------------------------
-- a)
SELECT
    k1.pseudo                                   "PSEUDO",
    k1.przydzial_myszy + NVL(k1.myszy_extra, 0) "ZJADA"
FROM Kocury k1
WHERE &n >= (
    SELECT
        COUNT(*) AS cnt
    FROM Kocury k2
    WHERE
        k1.przydzial_myszy + NVL(k1.myszy_extra, 0) < k2.przydzial_myszy + NVL(k2.myszy_extra, 0)
)
ORDER BY
    "ZJADA" DESC;

-- b)
WITH Przydzialy AS (
    SELECT DISTINCT 
        przydzial_myszy + NVL(myszy_extra, 0) AS przydz
        FROM Kocury
        ORDER BY 
            przydz DESC
)
SELECT 
    pseudo                                "PSEUDO",
    przydzial_myszy + NVL(myszy_extra, 0) "ZJADA"
FROM Kocury
WHERE 
    przydzial_myszy + NVL(myszy_extra, 0) IN (
        SELECT *
        FROM Przydzialy
        WHERE ROWNUM <= &n
    );

-- c)
SELECT
    k1.pseudo                                        "PSEUDO",
    AVG(k1.przydzial_myszy + NVL(k1.myszy_extra, 0)) "ZJADA"
FROM Kocury k1
    LEFT JOIN Kocury k2 ON k1.przydzial_myszy + NVL(k1.myszy_extra, 0) < k2.przydzial_myszy + NVL(k2.myszy_extra, 0)
GROUP BY
    k1.pseudo
HAVING
    COUNT(*) <= &n
ORDER BY
    "ZJADA" DESC;

-- d)
SELECT
    pseudo   "PSEUDO",
    zjada    "ZJADA"
FROM (
    SELECT
        pseudo,
        przydzial_myszy + NVL(myszy_extra, 0)                                   AS zjada,
        DENSE_RANK() OVER (ORDER BY przydzial_myszy + NVL(myszy_extra, 0) DESC) AS rnk
    FROM Kocury
    ORDER BY 
        zjada DESC
)
WHERE rnk <= &n;

-- Uruchomić aby zresetować wartosc n
UNDEFINE n

--------------------------------------------------------------------------------
-- TASK 23
--------------------------------------------------------------------------------
WITH Lata AS (
    SELECT 
        EXTRACT(YEAR FROM w_stadku_od) AS rok,
        COUNT(*)                       AS liczba
    FROM Kocury
    GROUP BY EXTRACT(YEAR FROM w_stadku_od)
),
Srednia AS (
    SELECT 
        ROUND(AVG(liczba), 7) AS sr 
    FROM Lata
),
-- Najblizsze mniejsze od sredniej
Dol AS (
    SELECT *
    FROM Lata, Srednia
    WHERE 
        liczba < sr
    ORDER BY 
        (sr - liczba)
    FETCH FIRST 1 ROWS WITH TIES
),
-- Najbliższe wieksze od sredniej
Gora AS (
    SELECT *
    FROM Lata, Srednia
    WHERE 
        liczba > sr
    ORDER BY 
        (liczba - sr)
    FETCH FIRST 1 ROWS WITH TIES
)
-- Łączenie wynikowych tabel
SELECT 
    TO_CHAR(rok), 
    liczba 
FROM Dol

UNION ALL

SELECT 
    'Srednia', 
    sr 
FROM Srednia

UNION ALL

SELECT 
    TO_CHAR(rok), 
    liczba 
FROM Gora

ORDER BY 
    liczba;

--------------------------------------------------------------------------------
-- TASK 24
--------------------------------------------------------------------------------
-- a)
SELECT
    k1.imie                                                    "IMIE",
    k1.przydzial_myszy + NVL(k1.myszy_extra, 0)                "ZJADA",
    k1.nr_bandy                                                "NR BANDY",
    ROUND(AVG(k2.przydzial_myszy + NVL(k2.myszy_extra, 0)), 2) "SREDNIA BANDY"
FROM Kocury k1
    INNER JOIN Kocury k2 ON k2.nr_bandy = k1.nr_bandy
WHERE
    k1.plec = 'M'
GROUP BY
    k1.imie, "ZJADA", k1.nr_bandy
HAVING
    "ZJADA" < "SREDNIA BANDY"
ORDER BY
    "SREDNIA BANDY";   

-- b)
SELECT
    k1.imie                                     "IMIE",
    k1.przydzial_myszy + NVL(k1.myszy_extra, 0) "ZJADA",
    k1.nr_bandy                                 "NR BANDY",
    ROUND(k2.sred, 2)                           "SREDNIA BANDY"
FROM Kocury k1
    INNER JOIN (
        SELECT
            nr_bandy,
            AVG(przydzial_myszy + NVL(myszy_extra, 0)) AS sred
        FROM Kocury
        GROUP BY
            nr_bandy
    ) k2 ON k2.nr_bandy = k1.nr_bandy AND k1.przydzial_myszy + NVL(k1.myszy_extra, 0) < k2.sred
WHERE
    k1.plec = 'M'
ORDER BY
    "SREDNIA BANDY";

-- c)
SELECT
    k1.imie                                     "IMIE",
    k1.przydzial_myszy + NVL(k1.myszy_extra, 0) "ZJADA",
    k1.nr_bandy                                 "NR BANDY",
    ROUND((
        SELECT
            AVG(przydzial_myszy + NVL(myszy_extra, 0))
        FROM Kocury
        WHERE
            nr_bandy = k1.nr_bandy
    ), 2) "SREDNIA BANDY"
FROM Kocury k1
WHERE
    k1.plec = 'M'
    AND
    k1.przydzial_myszy + NVL(k1.myszy_extra, 0) < (
        SELECT
            AVG(przydzial_myszy + NVL(myszy_extra, 0))
        FROM Kocury
        WHERE
            nr_bandy = k1.nr_bandy
    )
ORDER BY
    "SREDNIA BANDY";

--------------------------------------------------------------------------------
-- TASK 25
--------------------------------------------------------------------------------
WITH Daty AS (
    SELECT
    imie,
    TO_CHAR(data_wst, 'YYYY-MM-DD') AS data_wst_format,
    nazwa_bandy,
    staz_max,
    staz_min
    FROM (
        SELECT
            k.imie AS imie,
            k.w_stadku_od AS data_wst,
            b.nazwa AS nazwa_bandy,
            MIN(k.w_stadku_od) OVER (PARTITION BY b.nr_bandy) staz_max,
            MAX(k.w_stadku_od) OVER (PARTITION BY b.nr_bandy) staz_min
        FROM Kocury k
            INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
    )
)
-- Kocury ze stazami posrednimi
SELECT
    d.imie            "IMIE",
    d.data_wst_format "WSTAPIL DO STADKA"
FROM Daty d
WHERE
    d.data_wst_format NOT IN (d.staz_max, d.staz_min)
    
UNION
-- Kocury z najmniejszymi stazami
SELECT
    d.imie "IMIE",
    d.data_wst_format || ' <--- NAJMLODSZY STAZEM W BANDZIE ' || d.nazwa_bandy
FROM Daty d
WHERE
    d.data_wst_format = staz_min

UNION
-- Kocury z najwiekszymi stazami
SELECT
    d.imie "IMIE",
    d.data_wst_format || ' <--- NAJSTARSZY STAZEM W BANDZIE ' || d.nazwa_bandy
FROM Daty d
WHERE
    d.data_wst_format = staz_max

ORDER BY
    "IMIE";
