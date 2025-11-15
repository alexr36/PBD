--------------------------------------------------------------------------------
-- TASK 1
--------------------------------------------------------------------------------
SELECT 
    k1.imie [W stadzie przed szefem lub bez incydentu]
FROM Kocury k1
    LEFT JOIN Wrogowie_kocurow wk ON k1.pseudo = wk.pseudo
    INNER JOIN Kocury k2 ON k1.szef = k2.pseudo
WHERE
    k1.w_stadku_od < k2.w_stadku_od
    OR
    wk.data_incydentu IS NULL
ORDER BY k1.imie;
    
--------------------------------------------------------------------------------
-- TASK 2
--------------------------------------------------------------------------------
SELECT
    k.pseudo          [Kotka],
    wk.imie_wroga     [jej wrog],
    wk.opis_incydentu [Przewina wroga]
FROM Kocury K
    INNER JOIN Wrogowie_kocurow wk ON k.pseudo = wk.pseudo
WHERE 
    k.plec = 'D'
ORDER BY k.pseudo;

--------------------------------------------------------------------------------
-- TASK 3
--------------------------------------------------------------------------------
SELECT 
    k.pseudo   [Szpieg],
    k.nr_bandy [Banda]
FROM Kocury k
    INNER JOIN Bandy b ON k.pseudo = b.szef_bandy
WHERE 
    k.szef = 'TYGRYS';
    
--------------------------------------------------------------------------------
-- TASK 4
--------------------------------------------------------------------------------
SELECT
    ISNULL(k1.pseudo, 'Brak przelozonego') [Przelozony],
    ISNULL(k2.pseudo, 'Brak podwladnego')  [Podwladny]
FROM Kocury k1
    FULL JOIN Kocury k2 ON k1.pseudo = k2.szef
WHERE
    ISNULL(k1.plec, 'M') = 'M' 
    AND 
    ISNULL(k2.plec, 'M') = 'M'
ORDER BY 'Przelozony';

--------------------------------------------------------------------------------
-- TASK 5
--------------------------------------------------------------------------------
SELECT DISTINCT
    k.pseudo                                                                                  [PSEUDO],
    k.przydzial_myszy                                                                         [PRZYDZIAL_MYSZY],
    SUM(k.przydzial_myszy) OVER (PARTITION BY k.nr_bandy)                                     [SUM_W_BANDZIE],
    ROUND(k.przydzial_myszy * 100 / SUM(k.przydzial_myszy) OVER (PARTITION BY k.nr_bandy), 0) [PROC_W_BANDZIE]
FROM Kocury k
    INNER JOIN Wrogowie_kocurow wk ON k.pseudo = wk.pseudo
    INNER JOIN Wrogowie w ON wk.imie_wroga = w.imie_wroga
    INNER JOIN Bandy b ON k.nr_bandy = b.nr_bandy
WHERE
    w.stopien_wrogosci > 5
    AND
    b.teren IN ('POLE', 'CALOSC')
GROUP BY
    k.pseudo,
    k.przydzial_myszy,
    k.nr_bandy;

