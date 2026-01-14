/*
 * ******************************************************************************
 * @file           : oracle_procedures_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Oracle PL/SQL procedures from List 04.
 * ******************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 2
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
