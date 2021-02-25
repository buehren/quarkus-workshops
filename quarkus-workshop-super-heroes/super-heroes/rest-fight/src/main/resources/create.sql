\set ON_ERROR_STOP on


CREATE SEQUENCE public.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE public.hibernate_sequence OWNER TO superfight;


CREATE TABLE public.fight (
    id bigint NOT NULL,
    fightdate timestamp without time zone,
    loserlevel integer NOT NULL,
    losername character varying(255),
    loserpicture character varying(255),
    loserteam character varying(255),
    winnerlevel integer NOT NULL,
    winnername character varying(255),
    winnerpicture character varying(255),
    winnerteam character varying(255)
);

ALTER TABLE public.fight OWNER TO superfight;

ALTER TABLE ONLY public.fight
    ADD CONSTRAINT fight_pkey PRIMARY KEY (id);
