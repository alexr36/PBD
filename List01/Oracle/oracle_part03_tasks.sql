--------------------------------------------------------------------------------
-- TASK 14
--------------------------------------------------------------------------------
SELECT
    LEVEL    "Poziom",
    pseudo   "Pseudonim",
    funkcja  "Funkcja",
    nr_bandy "Nr bandy"
FROM Kocury
WHERE plec = 'M'
CONNECT BY PRIOR pseudo = szef
START WITH funkcja = 'BANDZIOR';

--------------------------------------------------------------------------------
-- TASK 15
--------------------------------------------------------------------------------
SELECT 
    RPAD(LPAD(TO_CHAR(LEVEL - 1), (LEVEL - 1) * 4 + LENGTH(TO_CHAR(LEVEL - 1)), '===>'), 30, ' ') || imie  "Hierarchia",
    NVL(szef, 'Sam sobie panem') "Pseudo szefa",
    funkcja                      "Funkcja"
FROM Kocury
WHERE myszy_extra > 0
CONNECT BY PRIOR pseudo = szef
START WITH szef IS NULL;

--------------------------------------------------------------------------------
-- TASK 16
--------------------------------------------------------------------------------
SELECT 
    RPAD(' ', (LEVEL - 1) * 4) || pseudo "Droga sluzbowa"
FROM Kocury
CONNECT BY PRIOR szef = pseudo
START WITH 
    MONTHS_BETWEEN(SYSDATE, w_stadku_od) / 12 > 15 AND
    plec = 'M' AND
    myszy_extra IS NULL;
