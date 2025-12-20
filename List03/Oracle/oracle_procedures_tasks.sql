/*
 * *****************************************************************************
 * @file           : microsoft_procedures_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Oracle PL/SQL procedures.
 * *****************************************************************************
 */

-- Run to make output visible
SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- TASK 9
--------------------------------------------------------------------------------
UNDEFINE funkcja_input;
UNDEFINE przydzial_myszy_input;

-- Definicja
CREATE OR REPLACE PROCEDURE ZmienPrzydzialDlaFunkcji (
    p_funkcja         IN Kocury.funkcja%TYPE,
    p_przydzial_myszy IN Kocury.przydzial_myszy%TYPE
) IS
BEGIN
    -- Weryfikacja poprawnosci wartosci przydzialu
    IF p_przydzial_myszy IS NULL OR p_przydzial_myszy < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nieprawidlowy przydzial myszy: ' || p_przydzial_myszy);
    END IF;

    -- Aktualizacja kocurow o podanej funkcji
    UPDATE Kocury 
    SET przydzial_myszy = p_przydzial_myszy
    WHERE
        funkcja = UPPER(p_funkcja);

    -- Sprawdzenie czy kocury o podanej funkcji istnialy
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Brak kotow o funkcji: ' || p_funkcja);
    END IF;
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Nieprawidlowy typ danych.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
END ZmienPrzydzialDlaFunkcji;
/

-- Wywolanie
DECLARE
    CURSOR c_kursor IS
        SELECT
            pseudo,
            przydzial_myszy,
            funkcja
        FROM Kocury
        ORDER BY
            funkcja;

    v_funkcja         Kocury.funkcja%TYPE         := '&funkcja_input';
    v_przydzial_myszy Kocury.przydzial_myszy%TYPE := &przydzial_myszy_input;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Przed aktualizacja:');
    FOR kot IN c_kursor LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(kot.pseudo, 15) || ' ' || LPAD(kot.przydzial_myszy, 3) || ' ' || RPAD(kot.funkcja, 10));
    END LOOP;

    ZmienPrzydzialDlaFunkcji(v_funkcja, v_przydzial_myszy);
    DBMS_OUTPUT.NEW_LINE();

    DBMS_OUTPUT.PUT_LINE('Po aktualizacji dla ' || UPPER(v_funkcja) || ':');
    FOR kot IN c_kursor LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(kot.pseudo, 15) || ' ' || LPAD(kot.przydzial_myszy, 3) || ' ' || RPAD(kot.funkcja, 10));
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        ROLLBACK;
END;
/

-- Explicit rollback 
UPDATE Kocury SET przydzial_myszy = 65 WHERE pseudo = 'RAFA';
UPDATE Kocury SET przydzial_myszy = 65 WHERE pseudo = 'SZYBKA';
UPDATE Kocury SET przydzial_myszy = 67 WHERE pseudo = 'PLACEK';
UPDATE Kocury SET przydzial_myszy = 61 WHERE pseudo = 'KURKA';

--------------------------------------------------------------------------------
-- TASK 10
--------------------------------------------------------------------------------
UNDEFINE pseudo_input;

-- Definicja
CREATE OR REPLACE FUNCTION PodatekPoglowny (p_pseudo IN Kocury.pseudo%TYPE) RETURN NUMBER 
IS
    TYPE r_dane IS RECORD (podwladni_cnt NUMBER, wrogowie_cnt NUMBER, plec Kocury.plec%TYPE, pseudo Kocury.pseudo%TYPE);
    v_dane    r_dane;
    v_podatek NUMBER := 0;
BEGIN
    v_dane.pseudo := UPPER(p_pseudo);

    -- Podatek podstawowy - obliczenie 5% calkowitego przydzialu myszy
    -- dla kota o danym pseudonimie
    SELECT 
        ROUND(0.05 * (przydzial_myszy+ NVL(myszy_extra, 0)), 0),
        plec
    INTO
        v_podatek,
        v_dane.plec
    FROM Kocury
    WHERE
        pseudo = v_dane.pseudo;

    -- Podatek od braku podwladnych - policzenie dla ilu kotow kot o danym 
    -- pseudonimie jest szefem
    SELECT
        COUNT(*)
    INTO
        v_dane.podwladni_cnt
    FROM Kocury
    WHERE
        szef = v_dane.pseudo;

    IF v_dane.podwladni_cnt = 0 THEN
        v_podatek := v_podatek + 2;
    END IF;

    -- Podatek od braku wrogow - policzenie ile jest wystapien danego
    -- pseudonimu w tabeli `Wrogowie_kocurow`
    SELECT
        COUNT(*)
    INTO
        v_dane.wrogowie_cnt
    FROM Wrogowie_kocurow
    WHERE
        pseudo = v_dane.pseudo;

    IF v_dane.wrogowie_cnt = 0 THEN
        v_podatek := v_podatek + 1;
    END IF;

    -- Podatek od kocurow (dodany) - podatek w postaci 5 myszy dla kocurow 
    -- (plci meskiej)
    IF v_dane.plec = 'M' THEN
        v_podatek := v_podatek + 5;
    END IF;
    
    RETURN v_podatek;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota o podanym pseudonimie: ' || v_dane.pseudo);
        RAISE;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
END PodatekPoglowny;
/

-- Wywolanie
DECLARE
    v_pseudo Kocury.pseudo%TYPE := '&pseudo_input';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Podatek dla ' || UPPER(v_pseudo) || ': ' || PodatekPoglowny(v_pseudo) || ' myszy');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota o podanym pseudonimie.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

--------------------------------------------------------------------------------
-- TASK 11
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION GetFunctionCnt RETURN NUMBER
IS
    v_func_cnt NUMBER := 0;
BEGIN
    SELECT
        COUNT(DISTINCT funkcja)
    INTO
        v_func_cnt
    FROM
        Kocury;

    RETURN v_func_cnt;
END;
/

CREATE OR REPLACE FUNCTION GetSeparatorPodsumowanie (
    p_func_cnt IN NUMBER DEFAULT 0
) RETURN CLOB
IS
    v_dynamic_sql      CLOB;
    v_dynamic_func_sep CLOB   := '';
    v_index            NUMBER := 0;
BEGIN
    WHILE v_index < p_func_cnt LOOP
        v_dynamic_func_sep := CONCAT(v_dynamic_func_sep, 'RPAD(''-'', 10, ''-''),');
        v_index := v_index + 1;
    END LOOP;

    SELECT
    '
    SELECT
        RPAD(''Z'', 20, ''-''),
        RPAD(''-'', 6, ''-''),
        RPAD(''-'', 4, ''-''),
    '
    || v_dynamic_func_sep ||
    '
        RPAD(''-'', 7, ''-'')
    FROM dual

    UNION ALL

    SELECT
        ''ZJADA RAZEM'',
        '' '',
        '' '',
        '
    ||
    LISTAGG(
    '
        LPAD(SUM(DECODE(
            funkcja, ''' || funkcja || ''', przydzial_myszy + NVL(myszy_extra, 0), 0
        )), 10)',
        ', '
    ) WITHIN GROUP (ORDER BY funkcja DESC) 
    ||
    '
        , LPAD(SUM(przydzial_myszy + NVL(myszy_extra, 0)), 7)
    FROM Kocury
    '
    INTO
        v_dynamic_sql
    FROM (
        SELECT DISTINCT
            funkcja
        FROM Kocury
    );

    RETURN v_dynamic_sql;
END GetSeparatorPodsumowanie;
/

-- a)
CREATE OR REPLACE PROCEDURE GetSumaSpozyciaA (
    p_rc OUT SYS_REFCURSOR
)
IS
    v_dynamic_sql CLOB;
BEGIN
    SELECT
        '
        SELECT
            RPAD(DECODE(k.plec, ''D'', b.nazwa, ''M'', '' ''), 20)      "NAZWA BANDY",
            RPAD(DECODE(k.plec, ''D'', ''Kotka'', ''M'', ''Kocor''), 6) "PLEC",
            LPAD(COUNT(*), 4)                                           "ILE",
        ' 
        ||
        LISTAGG(
            '
            LPAD(SUM(DECODE(
                k.funkcja, '''
                || funkcja || ''', k.przydzial_myszy + NVL(k.myszy_extra, 0), 
                0
            )), 10) AS ' || funkcja, ', '
        ) WITHIN GROUP (ORDER BY funkcja DESC)
        ||
        '
        ,
            LPAD(SUM(k.przydzial_myszy + NVL(k.myszy_extra, 0)), 7)     "SUMA"
        FROM Kocury k
            INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
        GROUP BY
            b.nazwa,
            k.plec

        UNION ALL'

        || GetSeparatorPodsumowanie(GetFunctionCnt)        
    INTO
        v_dynamic_sql
    FROM (
        SELECT DISTINCT 
            funkcja 
        FROM Kocury
    );

    OPEN p_rc FOR v_dynamic_sql;
END GetSumaSpozyciaA;
/

VAR rc REFCURSOR
EXEC GetSumaSpozyciaA(:rc)
PRINT rc;


-- b)
CREATE OR REPLACE PROCEDURE GetSumaSpozyciaB (
    p_rc OUT SYS_REFCURSOR
)
IS
    v_dynamic_sql CLOB;
BEGIN
    SELECT
        '
        SELECT 
            RPAD(DECODE(plec, ''D'', nazwa, ''M'', '' ''), 20)         "NAZWA BANDY",
            RPAD(DECODE(plec, ''D'', ''Kotka'', ''M'', ''Kocor''), 6)  "PLEC",
            LPAD(ile, 4)                                               "ILE",
            '
            ||
            LISTAGG('LPAD(NVL(' || funkcja || ', 0), 10) AS ' || funkcja, ', ') WITHIN GROUP (ORDER BY funkcja)
            ||
            ', LPAD(' 
            ||
            LISTAGG('NVL(' || funkcja || ', 0)', ' + ') WITHIN GROUP (ORDER BY funkcja)
            ||
            ', 7)    "SUMA"
        FROM (
            SELECT
                b.nazwa,
                k.plec,
                k.funkcja,
                k.przydzial_myszy + NVL(k.myszy_extra, 0) AS spozycie,
                COUNT(*) OVER (PARTITION BY nazwa, plec)  AS ile
            FROM Kocury k
                INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
        )
        PIVOT (
            SUM(spozycie)
            FOR funkcja IN ('
            ||
            LISTAGG(
                '''' || funkcja || ''' AS ' || funkcja, 
                ', '
            ) WITHIN GROUP (ORDER BY funkcja)
            ||
            ')
        )

        UNION ALL
        '
        || GetSeparatorPodsumowanie(GetFunctionCnt)
    INTO
        v_dynamic_sql
    FROM (
        SELECT DISTINCT 
            funkcja
        FROM Kocury
    );

    OPEN p_rc FOR v_dynamic_sql;
END GetSumaSpozyciaB;
/

VAR rc REFCURSOR
EXEC GetSumaSpozyciaB(:rc)
PRINT rc;
