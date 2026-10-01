-- requête qui porte sur au moins trois tables 
-- les utilisateurs et le nombre de défis collectifs auxquels ils sont en train de participer 
SELECT u.nom, u.prenom, COUNT(p.id_defi) AS nb_defis_collectifs
FROM utilisateur u
JOIN participer p ON u.id_user = p.id_user
JOIN defi d ON p.id_defi = d.id_defi
WHERE d.type_defi = 'collectif' AND d.date_fin >= CURRENT_DATE
GROUP BY u.nom, u.prenom
ORDER BY nb_defis_collectifs;

-- ’auto jointure’ ou ’jointure réflexive’ (jointure de deux copies d’une même table)
-- récupérer les buddies
SELECT s1.id_follower, s1.id_followed FROM suivre s1
JOIN suivre s2 
ON s1.id_follower = s2.id_followed AND s1.id_followed = s2.id_follower
WHERE s1.id_follower < s1.id_followed;  -- pour éviter les répétitions

-- même requête mais récupérer les noms et prénoms
SELECT u1.nom || ' ' || u1.prenom AS utilisateur_1, u2.nom || ' ' || u2.prenom AS utilisateur_2
FROM suivre s1 JOIN suivre s2
ON s1.id_follower = s2.id_followed AND s1.id_followed = s2.id_follower
JOIN utilisateur u1  -- pour pouvoir affiher les noms et prénoms
ON s1.id_follower = u1.id_user
JOIN utilisateur u2
ON s1.id_followed = u2.id_user
WHERE s1.id_follower < s1.id_followed;

-- sous-requête corrélée
-- les utilisateurs qui ont fait un défi avec un buddy
SELECT u.prenom, u.nom
FROM utilisateur u
WHERE EXISTS (
    SELECT *
    FROM suivre s1
    JOIN suivre s2 ON s1.id_follower = s2.id_followed AND s1.id_followed = s2.id_follower
    JOIN participer p1 ON p1.id_user = u.id_user
    JOIN participer p2 ON p2.id_user = s1.id_followed AND p2.id_defi = p1.id_defi
    WHERE s1.id_follower = u.id_user
);

-- sous-requête dans le FROM
-- utilisateurs ayant envoyé plus de 5 invitations
SELECT *
FROM (SELECT id_expediteur, COUNT(*) AS nb_invitations
    FROM invitation GROUP BY id_expediteur) AS stats
WHERE nb_invitations > 5 ;

--utilisateur qui ont participé à au moins 2 défis individuels
SELECT *
FROM (SELECT p.id_user, COUNT(*) AS nb_defis
    FROM participer p
    JOIN defi d ON p.id_defi = d.id_defi
    WHERE d.type_defi = 'individuel'
    GROUP BY p.id_user) AS stats
WHERE nb_defis >= 2;

-- nb de défis créés pour chaque catégorie de sport
SELECT *
FROM ( SELECT id_categorie, COUNT(*) AS nb_defis
    FROM concerner GROUP BY id_categorie) AS stats;

-- sous-requête dans le WHERE
-- utilisateurs qui ont gagné le badge "feu aux fesses"
SELECT nom, prenom
FROM utilisateur
WHERE id_user IN(
    SELECT id_user
    FROM remporter_badge rb
    JOIN badge b ON rb.id_badge = b.id_badge
    WHERE b.nom = 'Feu aux fesses'
);

-- agrégats nécessitant GROUP BY et HAVING
-- utilisateurs ayant fait au moins 3 séances
SELECT u.nom, u.prenom, COUNT(pr.id_seance) AS nb_seances
FROM utilisateur u
JOIN pratiquer pr ON u.id_user = pr.id_user
GROUP BY u.nom, u.prenom
HAVING COUNT(pr.id_seance)>=3; 

-- id, nom, prénom et vitesse moyenne, et nb de séances faites des utilisateurs qui ont une vitesse moyenne (moyenne sur toutes leurs séances) d'au moins 20
SELECT u.id_user, u.nom, u.prenom, AVG(s.vitesse_moy) AS moyenne_vitesse, COUNT(*) AS nb_seances
FROM utilisateur u
JOIN pratiquer p ON u.id_user = p.id_user
JOIN seance s ON p.id_seance = s.id_seance
GROUP BY u.id_user, u.nom, u.prenom
HAVING AVG(s.vitesse_moy) >= 20 ;  --au moins 20

-- requête impliquant le calcul de deux agrégats (par exemple, les moyennes d’un ensemble de maximums)
-- utilisateurs qui ont créé les défis les plus populaires
SELECT u.id_user, u.nom, u.prenom, AVG(stats.nb_participants) AS moyenne_participants, COUNT(stats.id_defi) AS nb_defis_crees,
    AVG(stats.nb_participants) * COUNT(stats.id_defi) AS score_popularite
FROM utilisateur u
JOIN (SELECT c.id_user, d.id_defi, COUNT(p.id_user) AS nb_participants  --recup le nb de participants pour chaque défi
    FROM creer c
    JOIN defi d ON c.id_defi = d.id_defi
    LEFT JOIN participer p ON d.id_defi = p.id_defi
    GROUP BY c.id_user, d.id_defi) stats
ON u.id_user = stats.id_user
GROUP BY u.id_user, u.nom, u.prenom
ORDER BY score_popularite DESC; --rangé par score + élevé

-- jointure externe (LEFT JOIN)
--tous les hashtag avec les défis qui les utilisent
SELECT h.nom, d.descriptif
FROM hashtag h
LEFT JOIN taguer_defi td ON h.id_hashtag = td.id_hashtag
LEFT JOIN defi d ON td.id_defi = d.id_defi
ORDER BY h.nom;

-- jointure externe (RIGHT JOIN)
-- tous les défis avec le nombre d'utilisateurs qui y participent (même ceux qui n'ont aucun participant)
SELECT d.id_defi, d.descriptif, COUNT(p.id_user) AS nb_participants
FROM participer p
RIGHT JOIN defi d ON p.id_defi = d.id_defi
GROUP BY d.id_defi, d.descriptif
ORDER BY nb_participants;


--deux requêtes équivalentes exprimant une condition de totalité, l’une avec des sous requêtes corrélées et l’autre avec de l’agrégation

--les utilisateurs qui ont participé à toutes les catégories sportives
-- version avec aggrégation
SELECT u.id_user, u.nom, u.prenom
FROM utilisateur u
JOIN pratiquer p ON u.id_user = p.id_user
JOIN correspond c ON p.id_seance = c.id_seance
GROUP BY u.id_user, u.nom, u.prenom
HAVING COUNT(DISTINCT c.id_categorie) = (
    SELECT COUNT(*) FROM categorie_sport);

--version sous-req corrélée
SELECT u.id_user, u.nom, u.prenom
FROM utilisateur u
WHERE NOT EXISTS (
    SELECT *
    FROM categorie_sport cs
    WHERE NOT EXISTS (
        SELECT *
        FROM pratiquer p
        JOIN correspond c on p.id_seance = c.id_seance
        WHERE p.id_user = u.id_user AND c.id_categorie = cs.id_categorie
    )
);

-- requêtes qui renverraient le même résultat si vos tables ne contenaient pas de nulls, mais qui renvoient des résultats différents ici 
-- (vos données devront donc contenir quelques nulls), vous
-- proposerez également de petites modifications de vos requêtes (dans l’esprit de ce qui sera présenté
-- dans le cours sur l’information incomplète) afin qu’elles retournent le même résultat 

-- RENVOIENT DES RESULTATS DIFFERENTS
-- 1 : nb d'utilisateurs qui ont une photo de profil (ignore les NULL)
SELECT COUNT(photo_profil) FROM utilisateur;
-- 2 : nb total d'utilisateurs (compte les NULL)
SELECT COUNT(*) FROM utilisateur;

--RENVOIENT LES MEMES RESULTATS (les users avec une photo)
-- 1
SELECT COUNT(photo_profil) FROM utilisateur;
-- 2
SELECT COUNT(*) FROM utilisateur WHERE photo_profil IS NOT NULL;

-- requêtes qui renverraient le même résultat si vos tables ne contenaient pas de nulls, mais qui renvoient des résultats différents ici 
-- (vos données devront donc contenir quelques nulls), vous
-- proposerez également de petites modifications de vos requêtes (dans l’esprit de ce qui sera présenté
-- dans le cours sur l’information incomplète) afin qu’elles retournent le même résultat 

-- requête récursive (par exemple, une requête pour calculer le dernier jour sans entraînement,
-- ou bien une requête pour calculer le plus court chemin reliant deux utilisateurs via la relation "buddy".) 
-- trouve les utilisateurs que Yannick Noah peut atteindre via ses abonnés
WITH RECURSIVE chaine_abonnements AS(
    SELECT id_followed AS utilisateur, 1 AS distance
    FROM suivre
    WHERE id_follower = 1

    UNION

    SELECT s.id_followed, ca.distance + 1
    FROM chaine_abonnements ca
    JOIN suivre s ON ca.utilisateur = s.id_follower
    WHERE ca.distance < 5
)
SELECT utilisateur, MIN(distance) AS distance_minimale
FROM chaine_abonnements
GROUP BY utilisateur
ORDER BY distance_minimale, utilisateur;

-- requête utilisant du fenêtrage (par exemple, identifier, pour chaque utilisateur, ses 3 nouveaux
-- PR (records personnels) les plus récents par type d’activité et par distance, en filtrant sur les derniers 90 jours)

--classement des utilisateurs par distances totales parcourues rangé par catégorie
WITH distances_tot AS (  --recup les distances totales parcourues par catégorie
    SELECT u.id_user, u.prenom, u.nom, c.nom AS sport, SUM(s.distance) AS d_totale
    FROM utilisateur u
    JOIN pratiquer p ON u.id_user = p.id_user
    JOIN seance s ON p.id_seance = s.id_seance
    JOIN correspond co on s.id_seance = co.id_seance
    JOIN categorie_sport c ON c.id_categorie = co.id_categorie
    GROUP BY u.id_user, u.prenom, u.nom, c.nom
)
SELECT prenom, nom, sport, d_totale, DENSE_RANK() OVER(  --classement
    PARTITION BY sport ORDER BY d_totale DESC ) AS rang
    FROM distances_tot
    ORDER BY sport, rang;

--evolution de l'utilisateur au fil des séances (distance)
SELECT id_user, debut AS heure_debut, (fin - debut) as duree_seance, distance, sum(distance) OVER(
    PARTITION BY id_user ORDER BY debut) AS d_cumulee
FROM seance
JOIN pratiquer ON seance.id_seance = pratiquer.id_seance;