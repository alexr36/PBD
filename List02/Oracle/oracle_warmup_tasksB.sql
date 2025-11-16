--------------------------------------------------------------------------------
-- TASK 6
--------------------------------------------------------------------------------
WITH Kocury_typy AS (
    SELECT 
        pseudo,
        przydzial_myszy,
        nr_bandy,
        CASE 
            WHEN przydzial_myszy > AVG(przydzial_myszy) OVER () 
                THEN 'Prominent'
            WHEN przydzial_myszy = MIN(przydzial_myszy) OVER (PARTITION BY nr_bandy)
                THEN 'Szarak'
        END "Typ"
    FROM Kocury
)
SELECT
    pseudo          "Pseudonim",
    przydzial_myszy "Zjada",
    nr_bandy        "Banda",
    "Typ"
FROM
    Kocury_typy
WHERE
    "Typ" IS NOT NULL
ORDER BY
    "Typ", nr_bandy;

--------------------------------------------------------------------------------
-- TASK 7
--------------------------------------------------------------------------------
WITH Kocury_sr_przydz AS (
    SELECT
        pseudo,
        AVG(przydzial_myszy) OVER (PARTITION BY nr_bandy) "Srednio w bandzie",
        plec
    FROM Kocury
)
SELECT
    pseudo "Kot",
    "Srednio w bandzie"
FROM Kocury_sr_przydz 
WHERE 
    plec = 'M';

--------------------------------------------------------------------------------
-- TASK 8
--------------------------------------------------------------------------------
-- Wersja z wyswietlaniem przedzialu
SELECT
    b.nr_bandy             "Lepsze bandy",
    AVG(k.przydzial_myszy) "Sredni przydzial w bandzie",
    sr_wszys."Sredni przydzial"
FROM Bandy b
    INNER JOIN Kocury k ON b.nr_bandy = k.nr_bandy
    CROSS JOIN (
        SELECT AVG(przydzial_myszy) "Sredni przydzial"
        FROM Kocury
    ) sr_wszys
GROUP BY 
    b.nr_bandy,
    sr_wszys."Sredni przydzial"
HAVING "Sredni przydzial w bandzie" > sr_wszys."Sredni przydzial";

-- Wersja bez wyswietlania przedzialu
SELECT
    b.nr_bandy             "Lepsze bandy",
    AVG(k.przydzial_myszy) "Sredni przydzial w bandzie"
FROM Bandy b
    INNER JOIN Kocury k ON b.nr_bandy = k.nr_bandy
GROUP BY b.nr_bandy
HAVING "Sredni przydzial w bandzie" > (SELECT AVG(przydzial_myszy) FROM Kocury);

--------------------------------------------------------------------------------
-- TASK 9
--------------------------------------------------------------------------------
SELECT
    UPPER(TO_CHAR(w_stadku_od, 'Month')) "Miesiac",
    COUNT(*)                             "Liczba rekrutow"
FROM Kocury
GROUP BY
    EXTRACT(MONTH FROM w_stadku_od),
    TO_CHAR(w_stadku_od, 'Month')
ORDER BY
    EXTRACT(MONTH FROM w_stadku_od);

--------------------------------------------------------------------------------
-- TASK 10
--------------------------------------------------------------------------------
SELECT
    f.funkcja "FUNKCJA",
    SUM (
        CASE
            WHEN b.nazwa = 'CZARNI RYCERZE'
                THEN k.przydzial_myszy + NVL(k.myszy_extra, 0)
        END
    ) "Banda CZARNI RYCERZE",
    SUM(
        CASE

            WHEN b.nazwa = 'BIALI LOWCY'
                THEN k.przydzial_myszy + NVL(k.myszy_extra, 0)
        END
    ) "Banda BIALI LOWCY"
FROM Funkcje f
    INNER JOIN Kocury k ON f.funkcja = k.funkcja
    LEFT JOIN Bandy b ON k.nr_bandy = b.nr_bandy
WHERE 
    f.funkcja != 'SZEFUNIO'
GROUP BY f.funkcja
ORDER BY f.funkcja;

--------------------------------------------------------------------------------
-- TASK 11
--------------------------------------------------------------------------------
SELECT
    f.funkcja "FUNKCJA",
    k.plec    "P",
    SUM (
        CASE
            WHEN b.nazwa = 'CZARNI RYCERZE'
                THEN k.przydzial_myszy + NVL(k.myszy_extra, 0)
        END
    ) "Banda CZARNI RYCERZE",
    SUM(
        CASE

            WHEN b.nazwa = 'BIALI LOWCY'
                THEN k.przydzial_myszy + NVL(k.myszy_extra, 0)
        END
    ) "Banda BIALI LOWCY",
    COUNT(*) "Liczba kotow"
FROM Funkcje f
    INNER JOIN Kocury k ON f.funkcja = k.funkcja
    LEFT JOIN Bandy b ON k.nr_bandy = b.nr_bandy
WHERE 
    f.funkcja != 'SZEFUNIO'
GROUP BY 
    f.funkcja, 
    k.plec
ORDER BY 
    f.funkcja;
