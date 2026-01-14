/*
 * ******************************************************************************
 * @file           : oracle_blocks_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Oracle PL/SQL blocks from List 04.
 * ******************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 1
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