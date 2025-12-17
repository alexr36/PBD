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


--------------------------------------------------------------------------------
-- TASK 5
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- TASK 6
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- TASK 7
--------------------------------------------------------------------------------
-- b)


--------------------------------------------------------------------------------
-- TASK 8
--------------------------------------------------------------------------------

