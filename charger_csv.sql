\copy utilisateur (nom, prenom, mdp, email, abonnements, abonnes, visibilite, photo_profil) FROM 'nv_csv/utilisateur.csv' DELIMITER ',' CSV HEADER;

\copy seance (debut, fin, distance, denivele, vitesse_moy, vitesse_max) FROM 'nv_csv/seance.csv' DELIMITER ',' CSV HEADER;

\copy categorie_sport (nom, parent_id) FROM 'nv_csv/categorie_sport.csv' DELIMITER ',' CSV HEADER;

\copy defi (descriptif, date_debut, date_fin, type_defi, obj_type, obj_val, capacite_max) FROM 'nv_csv/defi.csv' DELIMITER ',' CSV HEADER;

\copy hashtag (nom) FROM 'nv_csv/hashtag.csv' DELIMITER ',' CSV HEADER;

\copy badge (nom, icone, condition_obtention) FROM 'nv_csv/badge.csv' DELIMITER ',' CSV HEADER;

\copy points (raison, valeur) FROM 'nv_csv/points.csv' DELIMITER ',' CSV HEADER;

\copy suivre FROM 'nv_csv/suivre.csv' DELIMITER ',' CSV HEADER;

\copy correspond FROM 'nv_csv/correspond.csv' DELIMITER ',' CSV HEADER;

\copy pratiquer FROM 'nv_csv/pratiquer.csv' DELIMITER ',' CSV HEADER;

\copy concerner FROM 'nv_csv/concerner.csv' DELIMITER ',' CSV HEADER;

\copy creer FROM 'nv_csv/creer.csv' DELIMITER ',' CSV HEADER;

\copy participer FROM 'nv_csv/participer.csv' DELIMITER ',' CSV HEADER;

\copy taguer_seance FROM 'nv_csv/taguer_seance.csv' DELIMITER ',' CSV HEADER;

\copy taguer_defi FROM 'nv_csv/taguer_defi.csv' DELIMITER ',' CSV HEADER;

\copy invitation (statut, id_expediteur, id_destinataire, id_defi) FROM 'nv_csv/invitation.csv' DELIMITER ',' CSV HEADER;

\copy remporter_badge FROM 'nv_csv/remporter_badge.csv' DELIMITER ',' CSV HEADER;

\copy gagner_points FROM 'nv_csv/gagner_points.csv' DELIMITER ',' CSV HEADER;
