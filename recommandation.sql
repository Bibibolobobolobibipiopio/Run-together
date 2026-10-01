-- exemples de requêtes de recommandation

-- recommandation de follow : personnes qui sont suivies par des abonnements
--plus ces personnes sont suivies par des followed plus elles vont être recommendées
SELECT s2.id_followed AS id_recommande, COUNT(s2.id_follower) AS abonnements_commun
FROM suivre s1
JOIN suivre s2 ON s1.id_followed = s2.id_follower
WHERE s1.id_follower = 1 AND s2.id_followed != 1 --recommendation pour l'utilisateur 1
AND s2.id_followed NOT IN (
    SELECT id_followed FROM suivre WHERE id_follower = 1
) GROUP BY s2.id_followed
ORDER BY abonnements_commun DESC;


-- recommandation par niveau sportif
--pratique le même sport
--à peu près la même distance
WITH moy_sport AS (
    SELECT p.id_user, c.nom AS sport, SUM(s.distance) AS distances_tot
    FROM pratiquer p
    JOIN seance s ON p.id_seance = s.id_seance
    JOIN correspond co ON s.id_seance = co.id_seance
    JOIN categorie_sport c ON c.id_categorie = co.id_categorie
    GROUP BY p.id_user, c.nom
)
SELECT autres.id_user, autres.sport, autres.distances_tot AS distance_autre, u1.distances_tot AS ma_distance
FROM moy_sport u1
JOIN moy_sport autres ON u1.sport = autres.sport
WHERE u1.id_user = 1  --recommendation pour l'utilisateur 1
AND autres.id_user != 1
AND autres.distances_tot BETWEEN (u1.distances_tot * 0.8) AND (u1.distances_tot * 1.2) --distance totale à peu près les mêmes pour les deux
AND autres.id_user NOT IN (SELECT id_followed FROM suivre WHERE id_follower = 1); --sans profils déjà suivis


--recommander des utilisateurs qui ont tagué leurs séances avec les mêmes tags
SELECT p_u.id_user AS id_recommande, COUNT(DISTINCT ts_u.id_hashtag) AS hashtag_commun
FROM pratiquer p
JOIN taguer_seance ts ON p.id_seance = ts.id_seance
JOIN taguer_seance ts_u ON ts_u.id_hashtag = ts.id_hashtag
JOIN pratiquer p_u ON ts_u.id_seance = ts.id_seance
WHERE p.id_user = 1 AND p_u.id_user != 1 --recommandation pour 1
AND p_u.id_user NOT IN (SELECT id_followed FROM suivre WHERE id_follower = 1)
GROUP BY p_u.id_user
ORDER BY  hashtag_commun DESC ;


-- requêtes de critères 

--critère sur le niveau de l'utilisateur
WITH habitude_utilisateur AS (
    SELECT COALESCE(AVG(s.distance), 0) AS distance_moy --COALESCE pr éviter les null
    FROM pratiquer p
    JOIN seance s ON p.id_seance = s.id_seance
    WHERE p.id_user = 1--habitude du user 1
)
SELECT d.id_defi, d.descriptif, d.obj_val AS objectif_defi, h.distance_moy, 
    --écart proche de 0 = défi adapté
    ABS(d.obj_val - (h.distance_moy * 4)) AS ecart_niveau
FROM defi d, habitude_utilisateur h
WHERE d.date_fin >= CURRENT_DATE AND d.obj_type = 'distance' ; --la plupart des obj sont la distance

--critère sur les habitudes de l'utilisateur (sport préféré)
SELECT cat.nom AS sport, COUNT(*) AS nb_seances
FROM pratiquer p
JOIN seance s ON p.id_seance = s.id_seance
JOIN correspond co ON s.id_seance = co.id_seance
JOIN categorie_sport cat ON co.id_categorie = cat.id_categorie
WHERE p.id_user = 1
GROUP BY cat.nom
ORDER BY nb_seances DESC
LIMIT 1;

--critère sur les abonnements de l'utilisateur qui participe déjà au défi
SELECT d.id_defi, d.descriptif, COUNT(p.id_user) AS inscrits_connus
FROM defi d
LEFT JOIN participer p ON d.id_defi = p.id_defi
WHERE p.id_user IN (
    SELECT id_followed FROM suivre WHERE id_follower = 1 --recommandation pr l'user 1
) AND d.date_fin >= CURRENT_DATE
GROUP BY d.id_defi, d.descriptif;

--critère nouvel utilisateur : on lui propose les 3 défis les plus populaires
SELECT d.id_defi, d.descriptif, COUNT(p.id_user) AS nb_participants
FROM defi d
LEFT JOIN participer p ON d.id_defi = p.id_defi
WHERE d.date_fin >= CURRENT_DATE
GROUP BY d.id_defi, d.descriptif
ORDER BY nb_participants DESC
LIMIT 3;