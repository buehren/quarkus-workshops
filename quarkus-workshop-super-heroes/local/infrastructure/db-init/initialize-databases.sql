CREATE ROLE super WITH LOGIN PASSWORD 'super';

CREATE ROLE service_hero WITH LOGIN PASSWORD 'service_hero-password' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
GRANT service_hero to postgres;
CREATE DATABASE hero_db;
GRANT ALL PRIVILEGES ON DATABASE hero_db TO service_hero;
GRANT ALL PRIVILEGES ON DATABASE hero_db TO super;
GRANT ALL PRIVILEGES ON DATABASE hero_db TO postgres;
\connect hero_db;
CREATE SCHEMA hero AUTHORIZATION service_hero;
ALTER ROLE service_hero IN DATABASE hero_db SET search_path TO hero;

CREATE ROLE service_villain WITH LOGIN PASSWORD 'service_villain-password' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
GRANT service_villain to postgres;
CREATE DATABASE villain_db;
GRANT ALL PRIVILEGES ON DATABASE villain_db TO service_villain;
GRANT ALL PRIVILEGES ON DATABASE villain_db TO super;
GRANT ALL PRIVILEGES ON DATABASE villain_db TO postgres;
\connect villain_db;
CREATE SCHEMA villain AUTHORIZATION service_villain;
ALTER ROLE service_villain IN DATABASE villain_db SET search_path TO villain;

CREATE ROLE service_fight WITH LOGIN PASSWORD 'service_fight-password' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
GRANT service_fight to postgres;
CREATE DATABASE fight_db;
GRANT ALL PRIVILEGES ON DATABASE fight_db TO service_fight;
GRANT ALL PRIVILEGES ON DATABASE fight_db TO super;
GRANT ALL PRIVILEGES ON DATABASE fight_db TO postgres;
\connect fight_db;
CREATE SCHEMA fight AUTHORIZATION service_fight;
ALTER ROLE service_fight IN DATABASE fight_db SET search_path TO fight;
