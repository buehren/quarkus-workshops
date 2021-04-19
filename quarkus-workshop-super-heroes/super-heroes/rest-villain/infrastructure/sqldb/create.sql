\set ON_ERROR_STOP on


CREATE SEQUENCE villain.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE villain.hibernate_sequence OWNER TO service_villain;


CREATE TABLE villain.villain (
    id bigint NOT NULL,
    level integer NOT NULL,
    name character varying(255),
    othername character varying(255),
    picture character varying(255),
    powers text
);

ALTER TABLE villain.villain OWNER TO service_villain;

ALTER TABLE ONLY villain.villain
    ADD CONSTRAINT villain_pkey PRIMARY KEY (id);
