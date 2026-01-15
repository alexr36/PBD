/*
 * ******************************************************************************
 * @file           : oracle_triggers_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Oracle PL/SQL triggers from List 04.
 * ******************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 3
--------------------------------------------------------------------------------
-- Definicja
CREATE OR REPLACE TRIGGER trig_autonum_bandy
BEFORE INSERT ON Bandy
FOR EACH ROW
BEGIN
    SELECT
        MAX(nr_bandy) + 1
    INTO
        :NEW.nr_bandy
    FROM Bandy;
END;
/

-- Wywołanie
INSERT INTO Bandy VALUES (0, 'Nowa banda', 'Wybrzeze', 'MALA');

SELECT * FROM Bandy;

ROLLBACK;

--------------------------------------------------------------------------------
-- TASK 4
--------------------------------------------------------------------------------
-- Definicja relacji
CREATE TABLE Przekroczenia_przydzialow (
    kto      VARCHAR2(15),
    kiedy    DATE,
    komu     VARCHAR(15),
    operacja VARCHAR(6)
);

-- Definicja wyzwalacza
CREATE OR REPLACE TRIGGER trig_guard_przydzialy
BEFORE INSERT OR UPDATE ON Kocury
FOR EACH ROW
DECLARE
    v_funkcja_min Funkcje.min_myszy%TYPE;
    v_funkcja_max Funkcje.max_myszy%TYPE;
    v_operacja    VARCHAR(6) := 'INSERT';
BEGIN
    IF UPDATING THEN
        v_operacja := 'UPDATE';
    END IF;

    SELECT
        min_myszy,
        max_myszy
    INTO
        v_funkcja_min,
        v_funkcja_max
    FROM Funkcje
    WHERE
        funkcja = :NEW.funkcja;

    IF :NEW.przydzial_myszy NOT BETWEEN v_funkcja_min AND v_funkcja_max THEN
        INSERT INTO Przekroczenia_przydzialow VALUES (SYS.LOGIN_USER, SYSDATE, :NEW.pseudo, v_operacja);
        :NEW.przydzial_myszy := :OLD.przydzial_myszy;
    END IF;
END;
/ 

-- Wywołanie
UPDATE Kocury
SET przydzial_myszy = 600
WHERE 
    pseudo IN ('RAFA', 'ZERO');

SELECT
    kto,
    TO_CHAR(kiedy, 'YYYY-MM-DD') "KIEDY",
    komu,
    operacja
FROM Przekroczenia_przydzialow;

SELECT
    pseudo,
    przydzial_myszy
FROM Kocury
WHERE
    pseudo IN ('RAFA', 'ZERO');

DROP TABLE Przekroczenia_przydzialow;

ROLLBACK;

--------------------------------------------------------------------------------
-- TASK 5
--------------------------------------------------------------------------------
-- a)


-- b)


--------------------------------------------------------------------------------
-- TASK 6
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- TASK 7
--------------------------------------------------------------------------------
-- a)


-- b)


