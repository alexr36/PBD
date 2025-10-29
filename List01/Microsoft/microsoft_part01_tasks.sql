--------------------------------------------------------------------------------
-- TASK 1
--------------------------------------------------------------------------------
SELECT 
    imie_wroga     [WROG],
    opis_incydentu [PRZEWINA]
FROM Wrogowie_kocurow
WHERE
    data_incydentu BETWEEN '2009-01-01' AND '2009-12-31';


--------------------------------------------------------------------------------
-- TASK 2
--------------------------------------------------------------------------------
SELECT
    imie [IMIE],
    funkcja [FUNKCJA],
    w_stadku_od [Z NAMI OD]
FROM Kocury
WHERE
    plec = 'D' AND
    w_stadku_od BETWEEN '2005-09-01' AND '2007-07-31';

--------------------------------------------------------------------------------
-- TASK 3
--------------------------------------------------------------------------------
SELECT
    imie_wroga       [WROG],
    gatunek          [GATUNEK],
    stopien_wrogosci [STOPIEN WROGOSCI]
FROM Wrogowie
WHERE lapowka IS NULL
ORDER BY stopien_wrogosci;

--------------------------------------------------------------------------------
-- TASK 4
--------------------------------------------------------------------------------
SELECT CONCAT(
        imie, ' zwany ', pseudo, ' (fun. ', funkcja, ') lowi myszki w bandzie ', 
        nr_bandy, ' od ', FORMAT(w_stadku_od, 'yyyy-MM-dd')
    ) [WSZYSTKO O KOCURACH]
FROM Kocury
ORDER BY w_stadku_od, pseudo;

--------------------------------------------------------------------------------
-- TASK 5
--------------------------------------------------------------------------------
SELECT
    pseudo [PSEUDO],
    STUFF(
        STUFF(pseudo, CHARINDEX('L', pseudo), 1, '%'), 
        CHARINDEX('A', pseudo), 
        1, 
        '#'
    ) [Po wymianie A na # oraz L na %]
FROM Kocury
WHERE 
    pseudo LIKE '%A%' AND
    pseudo LIKE '%L%';

--------------------------------------------------------------------------------
-- TASK 6
--------------------------------------------------------------------------------
SELECT
    imie                              [IMIE],
    FORMAT(w_stadku_od, 'yyyy-MM-dd') [W stadku],
    ROUND(przydzial_myszy / 1.1, 0)   [Zjadal],
    DATEADD(month, 6, w_stadku_od)    [Podwyzka],
    przydzial_myszy                   [Zjada]
FROM Kocury
WHERE
    DATEDIFF(year, w_stadku_od, GETDATE()) >= 15 AND
    MONTH(w_stadku_od) BETWEEN 3 AND 9;

--------------------------------------------------------------------------------
-- TASK 7
--------------------------------------------------------------------------------
SELECT
    imie                       [IMIE],
    3 * przydzial_myszy        [MYSZY KWARTALNIE],
    3 * ISNULL(myszy_extra, 0) [KWARTALNE DODATKI] 
FROM Kocury
WHERE
    przydzial_myszy > 2 * ISNULL(myszy_extra, 0) AND
    przydzial_myszy >= 55
ORDER BY przydzial_myszy DESC;

--------------------------------------------------------------------------------
-- TASK 8
--------------------------------------------------------------------------------
SELECT
    imie [IMIE],
    CASE 
        WHEN 12 * (przydzial_myszy + ISNULL(myszy_extra, 0)) > 660
            THEN CONVERT(VARCHAR, 12 * (przydzial_myszy + ISNULL(myszy_extra, 0)))
        WHEN 12 * (przydzial_myszy + ISNULL(myszy_extra, 0)) = 660
            THEN 'Limit'
        ELSE 'Ponizej 660' 
    END [Zjada rocznie]
FROM Kocury
ORDER BY imie;

--------------------------------------------------------------------------------
-- TASK 9
--------------------------------------------------------------------------------
-- For attribute 'pseudo'
SELECT
    CONCAT(
        pseudo,
        ' - ',
        CASE
            WHEN COUNT(pseudo) = 1
            THEN 'Unikalny'
            ELSE 'nieunikalny'
        END
    ) [Unikalnosc atr. PSEUDO]
FROM Kocury
GROUP BY pseudo
ORDER BY pseudo;

-- For attribute 'szef'
SELECT
    CONCAT(
        szef,
        ' - ',
        CASE
            WHEN COUNT(szef) = 1
                THEN 'Unikalny'
            ELSE 'nieunikalny'
        END
    ) [Unikalnosc atr. SZEF]
FROM Kocury
GROUP BY szef
ORDER BY szef;

--------------------------------------------------------------------------------
-- TASK 10
--------------------------------------------------------------------------------
SELECT
    pseudo        [PSEUDONIM],
    COUNT(pseudo) [Liczba wrogow]
FROM Wrogowie_kocurow
GROUP BY pseudo
HAVING COUNT(pseudo) > 1;
