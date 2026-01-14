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
UNDEFINE funkcja_input;

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
UNDEFINE pseudo_input;

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
DECLARE
    CURSOR c_kursor IS 
        SELECT
            k.imie,
            k.pseudo,
            k.przydzial_myszy,
            f.max_myszy
        FROM Kocury k
            INNER JOIN Funkcje f ON f.funkcja = k.funkcja
        ORDER BY
            przydzial_myszy DESC;
    r_kot_dane        c_kursor%ROWTYPE;
    v_zmiany          NUMBER := 0;
    v_suma_przydz     NUMBER := 0;
    v_nowy_przydzial  NUMBER;
BEGIN
    LOOP
        -- Policz aktualna sume przydzialow przez zalawdowanie do zmiennej 
        -- wynikowej wartosci zwracanej przez prosta kwerende.
        SELECT 
            SUM(przydzial_myszy)
        INTO 
            v_suma_przydz
        FROM Kocury;
        EXIT WHEN v_suma_przydz > 1050;

        OPEN c_kursor;

        -- Zaktualizuj przydzialy jesli ich suma nie przekracza 1050; najpierw 
        -- oblicz 110% poprzedniego a nastepnie sprawdz czy nie przekracza 
        -- `max_myszy` dla funkcji kocura i odpowiednio zmien lub zostaw 
        -- obliczona przed chwila wartosc.
        -- Zaktualizuj licznik zmian weryfikujac czy zmiana faktycznie nastapila.
        LOOP
            FETCH c_kursor INTO r_kot_dane;
            EXIT WHEN c_kursor%NOTFOUND;

            v_nowy_przydzial := 1.1 * r_kot_dane.przydzial_myszy;
            IF v_nowy_przydzial > r_kot_dane.max_myszy THEN
                v_nowy_przydzial := r_kot_dane.max_myszy;
            END IF;

            IF v_nowy_przydzial != r_kot_dane.przydzial_myszy THEN
                v_zmiany := v_zmiany + 1;
            END IF;

            UPDATE Kocury SET przydzial_myszy = v_nowy_przydzial WHERE pseudo = r_kot_dane.pseudo;
        END LOOP;

        CLOSE c_kursor;
    END LOOP;

    -- Wypisz sformatowane dane
    DBMS_OUTPUT.PUT_LINE('Calk. przydzial w stadku ' || v_suma_przydz || '  Zmian - ' || v_zmiany);
    DBMS_OUTPUT.NEW_LINE();
    DBMS_OUTPUT.PUT_LINE(RPAD('IMIE', 16) || 'Myszki po podwyzce');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 15, '-') || ' ' || RPAD('-', 18, '-'));

    FOR kot IN (
        SELECT
            imie,
            przydzial_myszy
        FROM Kocury
        ORDER BY
            w_stadku_od
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(kot.imie, 16) || LPAD(kot.przydzial_myszy, 18));
    END LOOP;

    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        ROLLBACK;
END;
/

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
UNDEFINE przelozeni_num_input;

DECLARE
    v_przelozeni_num NUMBER := &przelozeni_num_input;
    v_dynamic_sql    CLOB;
    v_pivot_for      CLOB   := '';
    v_cursor         NUMBER;
    v_column_cnt     NUMBER;
    v_desc_tab       DBMS_SQL.DESC_TAB;
    v_column_val     VARCHAR(4000);
    v_status         NUMBER;
BEGIN
    FOR i IN 1..v_przelozeni_num LOOP
        v_pivot_for := v_pivot_for || i || ' AS "Szef ' || i || '"';
        IF i < v_przelozeni_num THEN
            v_pivot_for := v_pivot_for || ', ';
        END IF;
    END LOOP;

    v_dynamic_sql :=
    '
    SELECT
        *
    FROM (
        SELECT
            CONNECT_BY_ROOT imie "Imie",
            LEVEL - 1                AS lvl,
            imie                     AS imie_szef
        FROM Kocury
        START WITH funkcja IN (''KOT'', ''MILUSIA'')
        CONNECT BY PRIOR szef = pseudo
    ) src
    PIVOT (
        MAX(imie_szef)
        FOR lvl IN (' || v_pivot_for ||')
    ) pvt
    ORDER BY
        "Imie"
    ';

    v_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursor, v_dynamic_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor, v_column_cnt, v_desc_tab);

    FOR i IN 1..v_column_cnt LOOP
        DBMS_SQL.DEFINE_COLUMN(v_cursor, i, v_column_val, 4000);
    END LOOP;

    v_status := DBMS_SQL.EXECUTE(v_cursor);

    FOR i IN 1..v_column_cnt LOOP
        DBMS_OUTPUT.PUT(RPAD(v_desc_tab(i).col_name, 15));
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 15 * v_column_cnt, '-'));

    WHILE DBMS_SQL.FETCH_ROWS(v_cursor) > 0 LOOP
        FOR i IN 1..v_column_cnt LOOP
            DBMS_SQL.COLUMN_VALUE(v_cursor, i, v_column_val);
            DBMS_OUTPUT.PUT(RPAD(NVL(v_column_val, ' '), 15));
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(v_cursor);
END;
/

--------------------------------------------------------------------------------
-- TASK 8
--------------------------------------------------------------------------------
UNDEFINE nr_bandy_input; 
UNDEFINE nazwa_input;
UNDEFINE teren_input;

DECLARE
    v_nr_bandy Bandy.nr_bandy%TYPE := &nr_bandy_input;
    v_nazwa    Bandy.nazwa%TYPE    := UPPER('&nazwa_input');
    v_teren    Bandy.teren%TYPE    := UPPER('&teren_input');
    v_errmsg   VARCHAR(55)         := '';
    v_errcnt   NUMBER              := 0;

    e_invalid_nr_bandy EXCEPTION;
    e_invalid_input    EXCEPTION;
BEGIN
    IF v_nr_bandy <= 0 THEN
        RAISE e_invalid_nr_bandy;
    END IF;

    FOR banda IN (SELECT * FROM Bandy) LOOP
        IF v_nr_bandy = banda.nr_bandy THEN
            v_errmsg := v_errmsg || TO_CHAR(v_nr_bandy);
            v_errcnt := v_errcnt + 1;
        END IF;

        IF v_nazwa = banda.nazwa THEN
            IF v_errcnt > 0 THEN
                v_errmsg := v_errmsg || ', ';
            END IF;
            v_errmsg := v_errmsg || v_nazwa;
            v_errcnt := v_errcnt + 1;
        END IF;

        IF v_teren = banda.teren THEN
            IF v_errcnt > 0 THEN
                v_errmsg := v_errmsg || ', ';
            END IF;
            v_errmsg := v_errmsg || v_teren;
            v_errcnt := v_errcnt + 1;
        END IF;

        IF v_errmsg IS NOT NULL THEN
            RAISE e_invalid_input;
        END IF;
    END LOOP;

    INSERT INTO Bandy VALUES (v_nr_bandy, v_nazwa, v_teren, NULL);
    DBMS_OUTPUT.PUT_LINE('Dodano bande: [' || v_nr_bandy || ', ' || v_nazwa || ', ' || v_teren || ']');
    ROLLBACK;
EXCEPTION
    WHEN e_invalid_nr_bandy THEN
        DBMS_OUTPUT.PUT_LINE('Numer bandy musi byc wiekszy od 0: ' || v_nr_bandy);
    WHEN e_invalid_input THEN
        DBMS_OUTPUT.PUT_LINE(v_errmsg || ': juz istnieje');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        ROLLBACK;
END;
/
