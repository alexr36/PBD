/*
 * *****************************************************************************
 * @file           : oracle_blocks.tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Oracle PL/SQL blocks.
 * *****************************************************************************
 */

-- Run to make output visible
SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- TASK 1
--------------------------------------------------------------------------------
UNDEFINE funkcja_input

DECLARE
    v_funkcja_kocura Kocury.funkcja%TYPE;
BEGIN
    SELECT
        funkcja 
    INTO 
        v_funkcja_kocura
    FROM Kocury
    WHERE
        funkcja = UPPER('&funkcja_input')
    FETCH FIRST 1 ROWS ONLY;

    DBMS_OUTPUT.PUT_LINE('Znaleziono: ' || v_funkcja_kocura);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

--------------------------------------------------------------------------------
-- TASK 3
--------------------------------------------------------------------------------
UNDEFINE pseudo_input

DECLARE
    v_przydzial_myszy Kocury.przydzial_myszy%TYPE;
    v_myszy_extra     Kocury.myszy_extra%TYPE;
    v_imie_kota       Kocury.imie%TYPE;
    v_w_stadku_od     Kocury.w_stadku_od%TYPE;
BEGIN
    SELECT
        przydzial_myszy,
        NVL(myszy_extra, 0),
        imie,
        w_stadku_od
    INTO
        v_przydzial_myszy,
        v_myszy_extra,
        v_imie_kota,
        v_w_stadku_od
    FROM Kocury
    WHERE
        pseudo = UPPER('&pseudo_input');
    
    IF 12 * (v_przydzial_myszy + v_myszy_extra) > 700 THEN
        DBMS_OUTPUT.PUT_LINE('calkowity roczny przydzial myszy >700');
    
    ELSIF v_imie_kota LIKE '%A%' THEN
        DBMS_OUTPUT.PUT_LINE('imię zawiera litere A');
    
    ELSIF EXTRACT(MONTH FROM v_w_stadku_od) = 5 THEN
        DBMS_OUTPUT.PUT_LINE('maj jest miesiacem przystapienia do stada');

    ELSE
        DBMS_OUTPUT.PUT_LINE('nie odpowiada kryteriom');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

--------------------------------------------------------------------------------
-- TASK 4
--------------------------------------------------------------------------------
DECLARE
    TYPE r_kot_dane IS RECORD (pseudo Kocury.pseudo%TYPE, nr_bandy Kocury.nr_bandy%TYPE, staz NUMBER);
    TYPE t_tabela_kocury IS TABLE OF r_kot_dane INDEX BY PLS_INTEGER;
    t_kocury t_tabela_kocury;
    e_brak_rekordow EXCEPTION;
BEGIN
    -- Zbierz dane
    WITH Minimalne_staze AS (
        SELECT
            nr_bandy,
            SYSDATE - MAX(w_stadku_od) AS staz
        FROM Kocury
        GROUP BY
            nr_bandy
    )
    -- Zaladuj dane do tabeli
    SELECT
        k.pseudo,
        k.nr_bandy,
        ROUND(ms.staz, 0)
    BULK COLLECT INTO
        t_kocury
    FROM Kocury k
        INNER JOIN Minimalne_staze ms ON ms.nr_bandy = k.nr_bandy
    GROUP BY
        k.pseudo,
        k.nr_bandy,
        ms.staz
    HAVING
        SYSDATE - MAX(k.w_stadku_od) = ms.staz;

    -- Wypisz na ekran
    FOR i IN t_kocury.FIRST..t_kocury.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD('Pseudo:',   10) || t_kocury(i).pseudo);
        DBMS_OUTPUT.PUT_LINE(RPAD('Nr bandy:', 10) || t_kocury(i).nr_bandy);
        DBMS_OUTPUT.PUT_LINE(RPAD('Staz:',     10) || t_kocury(i).staz || ' dni');
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
EXCEPTION
    WHEN e_brak_rekordow THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Brak rekordow do wyswietlenia.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

--------------------------------------------------------------------------------
-- TASK 5
--------------------------------------------------------------------------------

ROLLBACK;

--------------------------------------------------------------------------------
-- TASK 6
--------------------------------------------------------------------------------
DECLARE
    v_numer NUMBER := 1;
BEGIN
    -- Naglowek
    DBMS_OUTPUT.PUT_LINE(RPAD('Nr', 4) || RPAD('Pseudonim', 11) || 'Zjada');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 20, '-'));

    -- Zawartosc w petli z kursorem
    FOR rekord IN (
        SELECT
            pseudo,
            przydzial_myszy + NVL(myszy_extra, 0) AS zjada
        FROM Kocury
        ORDER BY
            zjada DESC
        FETCH FIRST 5 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(v_numer, 4) || RPAD(rekord.pseudo, 11) || RPAD(LPAD(rekord.zjada, 4), 5));
        v_numer := v_numer + 1;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

--------------------------------------------------------------------------------
-- TASK 7
--------------------------------------------------------------------------------
-- b)


--------------------------------------------------------------------------------
-- TASK 8
--------------------------------------------------------------------------------

