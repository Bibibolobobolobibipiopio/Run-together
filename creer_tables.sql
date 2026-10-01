DROP TABLE IF EXISTS
    suivre,
    gagner_points,
    remporter_badge,
    taguer_defi,
    participer,
    creer,
    concerner,
    taguer_seance,
    pratiquer,
    correspond,
    invitation,
    points,
    badge,
    hashtag,
    defi,
    categorie_sport,
    seance,
    utilisateur
CASCADE;

CREATE TABLE utilisateur(
    id_user SERIAL PRIMARY KEY,
    nom VARCHAR(20) NOT NULL,
    prenom VARCHAR (20) NOT NULL,
    mdp VARCHAR (50) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    abonnements INT DEFAULT 0 CHECK (abonnements >= 0),
    abonnes INT DEFAULT 0 CHECK (abonnes >= 0),
    visibilite VARCHAR(10) CHECK (visibilite IN('publique', 'prive', 'buddies')),
    photo_profil TEXT
);

CREATE TABLE seance(
    id_seance SERIAL PRIMARY KEY,
    debut TIMESTAMP NOT NULL,
    fin TIMESTAMP NOT NULL,
    distance DECIMAL(10,2) CHECK (distance >= 0),
    denivele DECIMAL(10,2),
    vitesse_max DECIMAL(10,2) CHECK (vitesse_max >= 0),
    vitesse_moy DECIMAL(10,2) CHECK (vitesse_moy >= 0),

    CONSTRAINT chk_duree_seance CHECK (fin > debut),
    CONSTRAINT chk_vitesses CHECK (vitesse_max >= vitesse_moy)
);

CREATE TABLE categorie_sport(
    id_categorie SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    parent_id INT REFERENCES categorie_sport(id_categorie)
);

CREATE TABLE defi(
    id_defi SERIAL PRIMARY KEY,
    descriptif TEXT,
    date_debut DATE,
    date_fin DATE,
    type_defi VARCHAR(10) CHECK (type_defi IN('individuel', 'collectif')),
    obj_type VARCHAR(20) CHECK (obj_type IN('denivele', 'distance','vitesse')),
    obj_val INT NOT NULL CHECK (obj_val > 0),
    capacite_max INT CHECK (capacite_max > 0),

    CONSTRAINT chk_duree_defi CHECK (date_fin >= date_debut)
);

CREATE TABLE hashtag(
    id_hashtag SERIAL PRIMARY KEY,
    nom VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE badge(
    id_badge SERIAL PRIMARY KEY,
    nom VARCHAR(50),
    icone TEXT,
    condition_obtention TEXT
);

CREATE TABLE invitation(
    id_invitation SERIAL PRIMARY KEY,
    statut VARCHAR(20) CHECK (statut IN('acceptee', 'refusee', 'sans reponse')),
    id_expediteur INT NOT NULL REFERENCES utilisateur(id_user),
    id_destinataire INT NOT NULL REFERENCES utilisateur(id_user),
    id_defi INT NOT NULL REFERENCES defi(id_defi),
    CHECK (id_expediteur != id_destinataire)
);

CREATE TABLE points(
    id_point SERIAL PRIMARY KEY,
    raison VARCHAR(50) CHECK(raison IN('completer defi', 'creer defi', 'valider defi', 'recommander profil')),
    valeur INT NOT NULL CHECK (valeur>0)
);

CREATE TABLE correspond( --sport correspond à séance
    id_seance INT REFERENCES seance(id_seance),
    id_categorie INT REFERENCES categorie_sport(id_categorie),
    PRIMARY KEY(id_seance, id_categorie)
);

CREATE TABLE pratiquer( --utilisateur pratique séance
    id_user INT REFERENCES utilisateur(id_user),
    id_seance INT REFERENCES seance(id_seance),
    PRIMARY KEY(id_user, id_seance)
);

CREATE TABLE taguer_seance(
    id_seance INT REFERENCES seance(id_seance),
    id_hashtag INT REFERENCES hashtag(id_hashtag),
    PRIMARY KEY(id_seance, id_hashtag)
);

CREATE TABLE concerner( --le défi concerne quelle catégorie de sport
    id_defi INT REFERENCES defi(id_defi),
    id_categorie INT REFERENCES categorie_sport(id_categorie),
    PRIMARY KEY(id_defi, id_categorie)
);

CREATE TABLE creer( --utilisateur crée défi
    id_user INT REFERENCES utilisateur(id_user),
    id_defi INT REFERENCES defi(id_defi),
    PRIMARY KEY(id_user, id_defi) 
);

CREATE TABLE participer( --utilisateur particpe à défi
    id_user INT REFERENCES utilisateur(id_user),
    id_defi INT REFERENCES defi(id_defi),
    PRIMARY KEY(id_user, id_defi) 
);

CREATE TABLE taguer_defi(
    id_defi INT REFERENCES defi(id_defi),
    id_hashtag INT REFERENCES hashtag(id_hashtag),
    PRIMARY KEY(id_defi, id_hashtag)
);

CREATE TABLE remporter_badge(
    id_user INT REFERENCES utilisateur(id_user),
    id_badge INT REFERENCES badge(id_badge),
    PRIMARY KEY(id_user, id_badge)
);

CREATE TABLE gagner_points(
    id_user INT REFERENCES utilisateur(id_user),
    id_point INT REFERENCES points(id_point),
    PRIMARY KEY(id_user, id_point)
);

CREATE TABLE suivre(
    id_follower INT REFERENCES utilisateur(id_user),
    id_followed INT REFERENCES utilisateur(id_user),
    date_suivi DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY(id_follower, id_followed),
    CHECK (id_follower != id_followed)
);