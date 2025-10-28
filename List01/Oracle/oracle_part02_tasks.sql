--------------------------------------------------------------------------------
-- TASK 11
--------------------------------------------------------------------------------
-- For 29 oct 2024
SELECT 
    pseudo                             "PSEUDO",
    TO_CHAR(w_stadku_od, 'YYYY-MM-DD') "W STADKU",
    TO_CHAR(CASE
        WHEN
            EXTRACT(DAY FROM w_stadku_od) <= 15
        THEN
            CASE
                WHEN
                    '2024-10-29' <= NEXT_DAY(LAST_DAY('2024-10-29') - 7, 'WEDNESDAY')
                THEN
                    NEXT_DAY(LAST_DAY('2024-10-29') - 7, 'WEDNESDAY')
                ELSE
                    NEXT_DAY(LAST_DAY(ADD_MONTHS('2024-10-29', 1)) - 7, 'WEDNESDAY')
            END
        ELSE
            NEXT_DAY(LAST_DAY(ADD_MONTHS('2024-10-29', 1)) - 7, 'WEDNESDAY')
    END, 'YYYY-MM-DD')                 "WYPLATA"
FROM Kocury
ORDER BY w_stadku_od; 

-- For 31 oct 2024
SELECT 
    pseudo                             "PSEUDO",
    TO_CHAR(w_stadku_od, 'YYYY-MM-DD') "W STADKU",
    TO_CHAR(CASE
        WHEN
            EXTRACT(DAY FROM w_stadku_od) <= 15
        THEN
            CASE
                WHEN
                    '2024-10-31' <= NEXT_DAY(LAST_DAY('2024-10-31') - 7, 'WEDNESDAY')
                THEN
                    NEXT_DAY(LAST_DAY('2024-10-31') - 7, 'WEDNESDAY')
                ELSE
                    NEXT_DAY(LAST_DAY(ADD_MONTHS('2024-10-31', 1)) - 7, 'WEDNESDAY')
            END
        ELSE
            NEXT_DAY(LAST_DAY(ADD_MONTHS('2024-10-31', 1)) - 7, 'WEDNESDAY')
    END, 'YYYY-MM-DD')                 "WYPLATA"
FROM Kocury
ORDER BY w_stadku_od; 

--------------------------------------------------------------------------------
-- TASK 12
--------------------------------------------------------------------------------
SELECT 
    'Liczba kotow= ' || COUNT(*) || ' lowi jako ' || funkcja || ' i zjada max. ' 
    || MAX(przydzial_myszy + NVL(myszy_extra, 0)) || ' myszy miesiecznie' "Miesieczne spozycie"
FROM Kocury
WHERE 
    plec != 'M' AND
    funkcja != 'SZEFUNIO'
GROUP BY funkcja
HAVING AVG(przydzial_myszy + NVL(myszy_extra, 0)) > 50
ORDER BY MAX(przydzial_myszy + NVL(myszy_extra, 0));

--------------------------------------------------------------------------------
-- TASK 13
--------------------------------------------------------------------------------
SELECT 
    nr_bandy "Nr bandy",
    plec "Plec",
    MIN(przydzial_myszy)
FROM Kocury
GROUP BY nr_bandy, plec;
