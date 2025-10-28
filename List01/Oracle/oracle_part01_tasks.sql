--------------------------------------------------------------------------------
-- TASK 1
--------------------------------------------------------------------------------
SELECT 
    imie_wroga     "WROG", 
    opis_incydentu "PRZEWINA"
FROM Wrogowie_kocurow
WHERE 
    data_incydentu >= '2009.01.01' AND 
    data_incydentu < '2010.01.01';

--------------------------------------------------------------------------------
-- TASK 2
--------------------------------------------------------------------------------
SELECT 
    imie                               "IMIE", 
    funkcja                            "FUNKCJA",
    TO_CHAR(w_stadku_od, 'YYYY-MM-DD') "Z NAMI OD"
FROM Kocury
WHERE 
    plec = 'D' AND 
    w_stadku_od >= '2005.09.01' AND 
    w_stadku_od <= '2007.07.31';

--------------------------------------------------------------------------------
-- TASK 3
--------------------------------------------------------------------------------
SELECT 
    imie_wroga       "WROG", 
    gatunek          "GATUNEK", 
    stopien_wrogosci "STOPIEN WROGOSCI"
FROM Wrogowie
WHERE lapowka IS NULL
ORDER BY stopien_wrogosci;

--------------------------------------------------------------------------------
-- TASK 4
--------------------------------------------------------------------------------
SELECT imie || ' zwany ' || pseudo || ' (fun. ' || funkcja || ') lowi myszki w bandzie ' || 
       nr_bandy || ' od ' || TO_CHAR(w_stadku_od, 'YYYY-MM-DD') "WSZYSTKO O KOCURACH"
FROM Kocury
WHERE plec = 'M'
ORDER BY w_stadku_od DESC, pseudo;

--------------------------------------------------------------------------------
-- TASK 5
--------------------------------------------------------------------------------
SELECT 
    pseudo                                                                 "PSEUDO", 
    REGEXP_REPLACE(REGEXP_REPLACE(pseudo, 'A', '#', 1, 1), 'L', '%', 1, 1) "Po wymianie A na # oraz L na %"
FROM Kocury
WHERE 
    pseudo LIKE '%A%' AND 
    pseudo LIKE '%L%';

--------------------------------------------------------------------------------
-- TASK 6
--------------------------------------------------------------------------------
SELECT 
    imie                                              "IMIE", 
    TO_CHAR(w_stadku_od, 'YYYY-MM-DD')                "W stadku", 
    ROUND(przydzial_myszy / 1.1)                      "Zjadal", 
    TO_CHAR(ADD_MONTHS(w_stadku_od, 6), 'YYYY-MM-DD') "Podwyzka", 
    przydzial_myszy                                   "Zjada"
FROM Kocury
WHERE 
    MONTHS_BETWEEN(SYSDATE, w_stadku_od) / 12 >= 15 AND
    EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9;

--------------------------------------------------------------------------------
-- TASK 7
--------------------------------------------------------------------------------
SELECT
    imie                    "IMIE",
    przydzial_myszy * 3     "MYSZY KWARTALNIE",
    NVL(myszy_extra, 0) * 3 "KWARTALNE DODATKI"
FROM Kocury
WHERE 
    przydzial_myszy > 2 * NVL(myszy_extra, 0) AND
    przydzial_myszy >= 55;

--------------------------------------------------------------------------------
-- TASK 8
--------------------------------------------------------------------------------
SELECT 
    imie "IMIE",
    CASE
        WHEN
            12 * (przydzial_myszy + NVL(myszy_extra, 0)) > 660
        THEN 
            TO_CHAR(12 * (przydzial_myszy + NVL(myszy_extra, 0)))
        WHEN 
            12 * (przydzial_myszy + NVL(myszy_extra, 0)) = 660
        THEN
            'Limit'
        ELSE 
            'Ponizej 660'
    END "Zjada rocznie"
FROM Kocury
ORDER BY imie;

--------------------------------------------------------------------------------
-- TASK 9
--------------------------------------------------------------------------------
-- For attribute 'pseudo'
SELECT
    pseudo || ' - ' || 
    CASE
        WHEN 
            COUNT(*) = 1
        THEN
            'Unikalny'
        ELSE
            'nieunikalny'
    END "Unikalnosc atr. PSEUDO"
FROM Kocury
GROUP BY pseudo
ORDER BY pseudo;

-- For attribute 'szef'
SELECT
    szef || ' - ' ||
    CASE
        WHEN
            COUNT(*) = 1
        THEN
            'Unikalny'
        ELSE
            'nieunikalny'
    END "Unikalnosc atr. SZEF"
FROM Kocury
WHERE szef IS NOT NULL
GROUP BY szef
ORDER BY szef;

--------------------------------------------------------------------------------
-- TASK 10
--------------------------------------------------------------------------------
SELECT
    pseudo "PSEUDO",
    COUNT(pseudo) "Liczba wrogow"
FROM Wrogowie_kocurow
GROUP BY pseudo
HAVING COUNT(pseudo) > 1
ORDER BY pseudo;
