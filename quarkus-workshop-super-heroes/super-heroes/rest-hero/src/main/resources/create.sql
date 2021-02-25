\set ON_ERROR_STOP on


CREATE SEQUENCE public.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE public.hibernate_sequence OWNER TO superman;


CREATE TABLE public.hero (
    id bigint NOT NULL,
    level integer NOT NULL,
    name character varying(50) NOT NULL,
    othername character varying(255),
    picture character varying(255),
    powers text,
    CONSTRAINT hero_level_check CHECK ((level >= 1))
);

ALTER TABLE public.hero OWNER TO superman;

ALTER TABLE ONLY public.hero
    ADD CONSTRAINT hero_pkey PRIMARY KEY (id);
