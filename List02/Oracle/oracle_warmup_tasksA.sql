--------------------------------------------------------------------------------
-- TASK 1
--------------------------------------------------------------------------------
SELECT k1.imie "W stadzie przed szefem lub bez incydentu"
FROM Kocury k1 
    LEFT JOIN Wrogowie_kocurow wk ON k1.pseudo = wk.pseudo
    INNER JOIN Kocury k2 ON k1.szef = k2.pseudo
WHERE
    k1.w_stadku_od < k2.w_stadku_od
    OR
    wk.pseudo IS NULL
ORDER BY k1.imie;

--------------------------------------------------------------------------------
-- TASK 2
--------------------------------------------------------------------------------
SELECT 
    k.pseudo          "Kotka",
    wk.imie_wroga     "jej wrog",
    wk.opis_incydentu "Przewina wroga"
FROM Kocury k 
    INNER JOIN Wrogowie_kocurow wk ON k.pseudo = wk.pseudo
WHERE k.plec = 'D'
ORDER BY k.pseudo;

--------------------------------------------------------------------------------
-- TASK 3
--------------------------------------------------------------------------------
SELECT
    k.pseudo "Szpieg",
    k.nr_bandy "Banda"
FROM Kocury k
    INNER JOIN Bandy b ON k.nr_bandy = b.NR_BANDY
WHERE
    k.szef != b.szef_bandy
    AND
    k.szef = 'TYGRYS';
    
--------------------------------------------------------------------------------
-- TASK 4
--------------------------------------------------------------------------------
SELECT
    NVL(k1.pseudo, 'Brak przelozonego') "Przelozony",
    NVL(k2.pseudo, 'Brak podwladnego')  "Podwladny"
FROM Kocury k1
    FULL JOIN Kocury k2 
    ON k1.pseudo = k2.szef 
WHERE 
    NVL(k1.plec, 'M') = 'M' 
    AND 
    NVL(k2.plec, 'M') = 'M'
ORDER BY "Przelozony";

--------------------------------------------------------------------------------
-- TASK 5
--------------------------------------------------------------------------------
