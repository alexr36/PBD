/*
 * *****************************************************************************
 * @file           : microsoft_procedures_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Microsoft T-SQL procedures.
 * *****************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 9
--------------------------------------------------------------------------------
-- Definicja
CREATE OR ALTER PROCEDURE ZmienPrzydzialDlaFunkcji
    @p_funkcja         VARCHAR(10),
    @p_przydzial_myszy INT
AS
BEGIN
    -- Weryfikacja poprawnosci wartosci przydzialu
    IF @p_przydzial_myszy IS NULL OR @p_przydzial_myszy < 0
        THROW 50000, 'Nieprawidlowy przydzial myszy.', 1;

    -- Aktualizacja kocurow o podanej funkcji
    UPDATE Kocury
    SET przydzial_myszy = @p_przydzial_myszy
    WHERE
        funkcja = UPPER(@p_funkcja);

    IF @@ROWCOUNT = 0
        THROW 50001, 'Brak kotow o podanej funkcji.', 1;
END;
GO

-- Wywolanie
DECLARE
    c_kursor CURSOR FOR
        SELECT
            pseudo,
            przydzial_myszy,
            funkcja
        FROM Kocury
        ORDER BY
            funkcja;
DECLARE
    @v_funkcja         VARCHAR(10) = UPPER('lowczy'),
    @v_przydzial_myszy INT         = 22,
    @v_pseudo_temp     VARCHAR(15),
    @v_przydzial_temp  INT,
    @v_funkcja_temp    VARCHAR(10);
BEGIN TRY
    PRINT 'Przed aktualizacja:';

    OPEN c_kursor;
    FETCH NEXT FROM c_kursor
    INTO
        @v_pseudo_temp,
        @v_przydzial_temp,
        @v_funkcja_temp;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT CONCAT(@v_pseudo_temp, ' ', @v_przydzial_temp, ' ', @v_funkcja_temp);
        FETCH NEXT FROM c_kursor
        INTO
            @v_pseudo_temp,
            @v_przydzial_temp,
            @v_funkcja_temp;
    END;
    CLOSE c_kursor;

    BEGIN TRANSACTION;

    EXEC ZmienPrzydzialDlaFunkcji @v_funkcja, @v_przydzial_myszy;

    PRINT '';
    PRINT 'Po aktualizacja dla ' + UPPER(CAST(@v_funkcja AS VARCHAR) + ':');
    OPEN c_kursor;
    FETCH NEXT FROM c_kursor
    INTO
        @v_pseudo_temp,
        @v_przydzial_temp,
        @v_funkcja_temp;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT CONCAT(@v_pseudo_temp, ' ', @v_przydzial_temp, ' ', @v_funkcja_temp);
        FETCH NEXT FROM c_kursor
        INTO
            @v_pseudo_temp,
            @v_przydzial_temp,
            @v_funkcja_temp;
    END;
    CLOSE c_kursor;

    DEALLOCATE c_kursor;
    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;

    PRINT ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- TASK 10
--------------------------------------------------------------------------------
-- Definicja
CREATE OR ALTER FUNCTION PodatekPoglowny (@p_pseudo VARCHAR(15)) RETURNS INT
AS
BEGIN
DECLARE
    @v_podwladni_cnt INT,
    @v_wrogowie_cnt  INT,
    @v_podatek       INT         = 0,
    @v_pseudo        VARCHAR(15) = UPPER(@p_pseudo),
    @v_plec          CHAR(1);

    -- Podatek podstawowy - obliczenie 5% calkowitego przydzialu myszy
    -- dla kota o danym pseudonimie
    SELECT
        @v_podatek = ROUND(0.05 * (przydzial_myszy + ISNULL(myszy_extra, 0)), 0),
        @v_plec    = plec
    FROM Kocury
    WHERE
        pseudo = @v_pseudo;

    -- Podatek od braku podwladnych - policzenie dla ilu kotow kot o danym 
    -- pseudonimie jest szefem
    SELECT
        @v_podwladni_cnt = COUNT(*)
    FROM Kocury
    WHERE
        szef = @v_pseudo;

    IF @v_podwladni_cnt = 0
        SET @v_podatek += 2;

    -- Podatek od braku wrogow - policzenie ile jest wystapien danego
    -- pseudonimu w tabeli `Wrogowie_kocurow`
    SELECT
        @v_wrogowie_cnt = COUNT(*)
    FROM Wrogowie_kocurow
    WHERE
        pseudo = @v_pseudo;

    IF @v_wrogowie_cnt = 0
        SET @v_podatek += 1;
    
    -- Podatek od kocurow (dodany) - podatek w postaci 5 myszy dla kocurow 
    -- (plci meskiej)
    IF @v_plec = 'M'
        SET @v_podatek += 5;

    RETURN @v_podatek;
END;
GO

-- Wywolanie
DECLARE 
    @pseudo_input VARCHAR(15) = 'tygrys';
BEGIN
    BEGIN TRY
        PRINT CONCAT('Podatek dla ', UPPER(@pseudo_input), ': ', dbo.PodatekPoglowny(@pseudo_input), ' myszy');
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

--------------------------------------------------------------------------------
-- TASK 11
--------------------------------------------------------------------------------
-- a)
CREATE OR ALTER FUNCTION GetFunctionCnt () RETURNS INT
AS
BEGIN
    DECLARE
        @v_func_cnt INT;

    SELECT
        @v_func_cnt = COUNT(DISTINCT funkcja)
    FROM Kocury;

    RETURN @v_func_cnt;
END;
GO

CREATE OR ALTER FUNCTION GetSeparatorPodsumowanie (
    @p_func_cnt INT
) RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE
        @v_dynamic_sql      NVARCHAR(MAX) = N'',
        @v_dynamic_func_sep NVARCHAR(MAX) = N'',
        @v_index            INT           = 0;

    WHILE @v_index < @p_func_cnt
    BEGIN
        SET @v_dynamic_func_sep += N'REPLICATE(''-'', 10), '
        SET @v_index += 1
    END

    SELECT
        @v_dynamic_sql = 
        N'
        SELECT
            RIGHT(''Z'' + REPLICATE(''-'', 19), 20),
            REPLICATE(''-'', 6),
            REPLICATE(''-'', 4),
        '
        + @v_dynamic_func_sep +
        N'
            REPLICATE(''-'', 7)

        UNION ALL

        SELECT
            ''ZJADA RAZEM'',
            '' '',
            '' '',
        '
        +
        STRING_AGG(
            N'
                RIGHT(
                    REPLICATE('' '', 10) + 
                        CAST(SUM(CASE 
                                    WHEN funkcja = ''' + funkcja + N''' 
                                    THEN przydzial_myszy + ISNULL(myszy_extra, 0) 
                                    ELSE 0 
                                END) AS VARCHAR(50)), 
                10) [' + funkcja + ']',
            N', '
        ) WITHIN GROUP (ORDER BY funkcja DESC)
        +
        N'
            , RIGHT(SPACE(7) + CAST(SUM(przydzial_myszy + ISNULL(myszy_extra, 0)) AS VARCHAR(50)), 7)
        FROM Kocury
        '
    FROM (
        SELECT DISTINCT
            funkcja
        FROM Kocury
    ) f;

    RETURN @v_dynamic_sql;
END;
GO

CREATE OR ALTER PROCEDURE GetSumaSpozyciaA 
AS
BEGIN
    DECLARE
        @v_dynamic_sql NVARCHAR(MAX);

    SELECT
        @v_dynamic_sql =
        N'
        SELECT
            CASE k.plec
                WHEN ''D'' THEN b.nazwa
                WHEN ''M'' THEN '' ''
            END                                      [NAZWA BANDY],
            CASE k.plec
                WHEN ''D'' THEN ''Kotka''
                WHEN ''M'' THEN ''Kocor''
            END                                      [PLEC],
            RIGHT(REPLICATE('' '', 4) + COUNT(*), 4) [ILE],'
            +
            STRING_AGG(
                N'
                RIGHT(REPLICATE('' '', 10) + 
                CAST(SUM(
                    CASE 
                        WHEN k.funkcja = ''' + funkcja + ''' 
                            THEN k.przydzial_myszy + ISNULL(k.myszy_extra, 0)
                        ELSE 0
                    END
                ) AS VARCHAR), 10) [' + funkcja + ']',
                ', '
            )
            +
            N',
                RIGHT(REPLICATE('' '', 7) + CAST(SUM(k.przydzial_myszy + ISNULL(k.myszy_extra, 0)) AS VARCHAR), 7) [SUMA]
            FROM Kocury k
                INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
            GROUP BY
                b.nazwa,
                k.plec

            UNION ALL
            '
            + dbo.GetSeparatorPodsumowanie(dbo.GetFunctionCnt())
    FROM (
        SELECT DISTINCT 
            funkcja 
        FROM Kocury
    ) f;

    PRINT @v_dynamic_sql;

    EXEC sp_executesql @v_dynamic_sql;
END;
GO

EXEC GetSumaSpozyciaA;
GO

-- b)
CREATE OR ALTER PROCEDURE GetSumaSpozyciaB 
AS
BEGIN
    DECLARE
        @v_dynamic_sql NVARCHAR(MAX);

    SELECT
        @v_dynamic_sql =
        N'
        SELECT
            CASE plec
                WHEN ''D'' THEN nazwa
                WHEN ''M'' THEN '' ''
            END                                                  [NAZWA BANDY],
            CASE plec
                WHEN ''D'' THEN ''Kotka''
                WHEN ''M'' THEN ''Kocor'' 
            END                                                  [PLEC],
            RIGHT(REPLICATE('' '', 4) + CAST(ile AS VARCHAR), 4) [ILE],
        '
        +
        STRING_AGG(
            'RIGHT(REPLICATE('' '', 10) + CAST(ISNULL(' + QUOTENAME(funkcja) + ', 0) AS VARCHAR), 10) ' + QUOTENAME(funkcja),
            ', '
        ) WITHIN GROUP (ORDER BY funkcja)
        +
        ',
            RIGHT(REPLICATE('' '', 7) + CAST(' +
        STRING_AGG('ISNULL(' + funkcja + ', 0)', ' + ') WITHIN GROUP (ORDER BY funkcja) +
        '   AS VARCHAR), 7)                                      [SUMA]
        FROM (
            SELECT
                b.nazwa,
                k.plec,
                k.funkcja,
                k.przydzial_myszy + ISNULL(k.myszy_extra, 0) AS spozycie,
                COUNT(*) OVER (PARTITION BY b.nazwa, k.plec) AS ile
            FROM Kocury k
                INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
        ) src
        PIVOT (
            SUM(spozycie)
            FOR funkcja IN ('
            +
            STRING_AGG(
                QUOTENAME(funkcja),
                ', ' 
            ) WITHIN GROUP (ORDER BY funkcja)
            +
            ')
        ) pvt

        UNION ALL
        '
        + dbo.GetSeparatorPodsumowanie(dbo.GetFunctionCnt())
    FROM (
        SELECT DISTINCT
            funkcja
        FROM Kocury
    ) f;

PRINT @v_dynamic_sql;
    EXEC sp_executesql @v_dynamic_sql;
END;
GO

EXEC GetSumaSpozyciaB;
GO
