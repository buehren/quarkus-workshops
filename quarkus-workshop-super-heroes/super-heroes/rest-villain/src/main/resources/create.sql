\set ON_ERROR_STOP on


CREATE SEQUENCE public.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE public.hibernate_sequence OWNER TO superbad;


CREATE TABLE public.villain (
    id bigint NOT NULL,
    level integer NOT NULL,
    name character varying(255),
    othername character varying(255),
    picture character varying(255),
    powers text
);

ALTER TABLE public.villain OWNER TO superbad;

ALTER TABLE ONLY public.villain
    ADD CONSTRAINT villain_pkey PRIMARY KEY (id);
