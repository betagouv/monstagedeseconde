SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

-- COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

-- COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

-- COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: agreement_signatory_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agreement_signatory_role AS ENUM (
    'employer',
    'school_manager',
    'other',
    'cpe',
    'admin_officer',
    'teacher',
    'main_teacher'
);


--
-- Name: school_category; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.school_category AS ENUM (
    'college',
    'lycee',
    'college_lycee'
);


--
-- Name: targeted_grades; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.targeted_grades AS ENUM (
    'seconde_only',
    'troisieme_only',
    'quatrieme_only',
    'troisieme_or_quatrieme',
    'seconde_troisieme_or_quatrieme'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'school_manager',
    'teacher',
    'main_teacher',
    'other',
    'cpe',
    'admin_officer'
);


--
-- Name: french_nostopwords; Type: TEXT SEARCH DICTIONARY; Schema: public; Owner: -
--

CREATE TEXT SEARCH DICTIONARY public.french_nostopwords (
    TEMPLATE = pg_catalog.snowball,
    language = 'french' );


--
-- Name: config_internship_offer_keywords; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords
    ADD MAPPING FOR asciiword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords
    ADD MAPPING FOR word WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords
    ADD MAPPING FOR hword_part WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords
    ADD MAPPING FOR hword_asciipart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords
    ADD MAPPING FOR asciihword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords
    ADD MAPPING FOR hword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords
    ADD MAPPING FOR "int" WITH simple;


--
-- Name: config_search_keyword; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION public.config_search_keyword (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION public.config_search_keyword
    ADD MAPPING FOR asciiword WITH public.unaccent, french_stem;

ALTER TEXT SEARCH CONFIGURATION public.config_search_keyword
    ADD MAPPING FOR word WITH public.unaccent, french_stem;

ALTER TEXT SEARCH CONFIGURATION public.config_search_keyword
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.config_search_keyword
    ADD MAPPING FOR hword_part WITH public.unaccent, french_stem;

ALTER TEXT SEARCH CONFIGURATION public.config_search_keyword
    ADD MAPPING FOR hword_asciipart WITH public.unaccent, french_stem;

ALTER TEXT SEARCH CONFIGURATION public.config_search_keyword
    ADD MAPPING FOR asciihword WITH public.unaccent, french_stem;

ALTER TEXT SEARCH CONFIGURATION public.config_search_keyword
    ADD MAPPING FOR hword WITH public.unaccent, french_stem;

ALTER TEXT SEARCH CONFIGURATION public.config_search_keyword
    ADD MAPPING FOR "int" WITH simple;


--
-- Name: fr; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION public.fr (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR asciiword WITH public.french_nostopwords;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR word WITH public.unaccent, public.french_nostopwords;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR hword_part WITH public.unaccent, public.french_nostopwords;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR hword_asciipart WITH public.french_nostopwords;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR asciihword WITH public.french_nostopwords;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR hword WITH public.unaccent, public.french_nostopwords;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR uint WITH simple;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: academies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.academies (
    id bigint NOT NULL,
    name character varying(40),
    email_domain character varying(100),
    academy_region_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: academies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.academies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: academies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.academies_id_seq OWNED BY public.academies.id;


--
-- Name: academy_regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.academy_regions (
    id bigint NOT NULL,
    name character varying(40),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: academy_regions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.academy_regions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: academy_regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.academy_regions_id_seq OWNED BY public.academy_regions.id;


--
-- Name: action_text_rich_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.action_text_rich_texts (
    id bigint NOT NULL,
    name character varying NOT NULL,
    body text,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.action_text_rich_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.action_text_rich_texts_id_seq OWNED BY public.action_text_rich_texts.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp without time zone NOT NULL,
    service_name character varying NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: area_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.area_notifications (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    internship_offer_area_id bigint NOT NULL,
    notify boolean DEFAULT true,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: area_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.area_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: area_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.area_notifications_id_seq OWNED BY public.area_notifications.id;


--
-- Name: class_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.class_rooms (
    id bigint NOT NULL,
    name character varying(50),
    school_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    class_size integer,
    grade_id bigint
);


--
-- Name: class_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.class_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: class_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.class_rooms_id_seq OWNED BY public.class_rooms.id;


--
-- Name: coded_crafts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coded_crafts (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    ogr_code integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    detailed_craft_id bigint NOT NULL,
    search_tsv tsvector
);


--
-- Name: coded_crafts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.coded_crafts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coded_crafts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.coded_crafts_id_seq OWNED BY public.coded_crafts.id;


--
-- Name: craft_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.craft_fields (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    letter character varying(1) NOT NULL
);


--
-- Name: craft_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.craft_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: craft_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.craft_fields_id_seq OWNED BY public.craft_fields.id;


--
-- Name: crafts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crafts (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    number character varying(5) NOT NULL,
    craft_field_id bigint NOT NULL
);


--
-- Name: crafts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crafts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crafts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crafts_id_seq OWNED BY public.crafts.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments (
    id bigint NOT NULL,
    code character varying(5),
    name character varying(40),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    academy_id integer
);


--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: departments_operators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments_operators (
    department_id bigint NOT NULL,
    operator_id bigint NOT NULL
);


--
-- Name: detailed_crafts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.detailed_crafts (
    id bigint NOT NULL,
    name character varying(120) NOT NULL,
    number character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    craft_id bigint NOT NULL
);


--
-- Name: detailed_crafts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.detailed_crafts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: detailed_crafts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.detailed_crafts_id_seq OWNED BY public.detailed_crafts.id;


--
-- Name: entreprises; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entreprises (
    id bigint NOT NULL,
    siret character varying(14),
    is_public boolean DEFAULT false NOT NULL,
    employer_name character varying(150) NOT NULL,
    employer_chosen_name character varying(150),
    entreprise_coordinates public.geography(Point,4326),
    group_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    internship_occupation_id bigint,
    entreprise_full_address character varying(200),
    sector_id bigint NOT NULL,
    updated_entreprise_full_address boolean DEFAULT false,
    workspace_conditions text DEFAULT ''::text,
    workspace_accessibility text DEFAULT ''::text,
    internship_address_manual_enter boolean DEFAULT false,
    contact_phone character varying(20)
);


--
-- Name: entreprises_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entreprises_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entreprises_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entreprises_id_seq OWNED BY public.entreprises.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id bigint NOT NULL,
    user_id bigint,
    internship_offer_id bigint
);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorites_id_seq OWNED BY public.favorites.id;


--
-- Name: flipper_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flipper_features (
    id bigint NOT NULL,
    key character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: flipper_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flipper_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flipper_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flipper_features_id_seq OWNED BY public.flipper_features.id;


--
-- Name: flipper_gates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flipper_gates (
    id bigint NOT NULL,
    feature_key character varying NOT NULL,
    key character varying NOT NULL,
    value text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: flipper_gates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flipper_gates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flipper_gates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flipper_gates_id_seq OWNED BY public.flipper_gates.id;


--
-- Name: grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grades (
    id bigint NOT NULL,
    name character varying(40) NOT NULL,
    short_name character varying(30) NOT NULL,
    school_year_end_month character varying(2) NOT NULL,
    school_year_end_day character varying(2) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grades_id_seq OWNED BY public.grades.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    is_public boolean,
    name character varying(150),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    is_paqte boolean,
    visible boolean DEFAULT true
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: hosting_info_weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hosting_info_weeks (
    id bigint NOT NULL,
    hosting_info_id bigint,
    week_id bigint,
    total_applications_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: hosting_info_weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hosting_info_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hosting_info_weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hosting_info_weeks_id_seq OWNED BY public.hosting_info_weeks.id;


--
-- Name: hosting_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hosting_infos (
    id bigint NOT NULL,
    max_candidates integer,
    school_id integer,
    employer_id integer,
    last_date date,
    weeks_count integer DEFAULT 0 NOT NULL,
    hosting_info_weeks_count integer DEFAULT 0 NOT NULL,
    daily_hours jsonb DEFAULT '{}'::jsonb,
    daily_lunch_break jsonb DEFAULT '{}'::jsonb,
    weekly_hours text[] DEFAULT '{}'::text[],
    weekly_lunch_break text,
    max_students_per_group integer DEFAULT 1 NOT NULL,
    remaining_seats_count integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    period integer DEFAULT 0 NOT NULL
);


--
-- Name: hosting_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hosting_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hosting_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hosting_infos_id_seq OWNED BY public.hosting_infos.id;


--
-- Name: identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identities (
    id bigint NOT NULL,
    user_id bigint,
    first_name character varying(82),
    last_name character varying(82),
    school_id bigint,
    class_room_id bigint,
    birth_date date,
    gender character varying DEFAULT 'np'::character varying,
    token character varying(50),
    anonymized boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    grade_id bigint
);


--
-- Name: identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.identities_id_seq OWNED BY public.identities.id;


--
-- Name: internship_agreements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_agreements (
    id bigint NOT NULL,
    date_range character varying(210) NOT NULL,
    aasm_state character varying,
    internship_application_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    organisation_representative_full_name character varying(140),
    school_representative_full_name character varying(120),
    student_full_name character varying(100),
    student_class_room character varying(50),
    student_school character varying(150),
    tutor_full_name character varying(275),
    doc_date date,
    school_manager_accept_terms boolean DEFAULT false,
    employer_accept_terms boolean DEFAULT false,
    weekly_hours text[] DEFAULT '{}'::text[],
    daily_hours jsonb DEFAULT '{}'::jsonb,
    main_teacher_accept_terms boolean DEFAULT false,
    school_delegation_to_sign_delivered_at date,
    daily_lunch_break jsonb DEFAULT '{}'::jsonb,
    weekly_lunch_break text,
    siret character varying(14),
    tutor_role character varying(150),
    tutor_email character varying(85),
    organisation_representative_role character varying(150),
    student_address character varying(170),
    student_phone character varying(20),
    school_representative_phone character varying(20),
    student_refering_teacher_phone character varying(20),
    student_legal_representative_email character varying(100),
    student_refering_teacher_email character varying(100),
    student_legal_representative_full_name character varying(180),
    student_refering_teacher_full_name character varying(100),
    student_legal_representative_phone character varying(20),
    student_legal_representative_2_full_name character varying(100),
    student_legal_representative_2_email character varying(100),
    student_legal_representative_2_phone character varying(20),
    school_representative_role character varying(100),
    school_representative_email character varying(100),
    discarded_at timestamp(6) without time zone,
    lunch_break text,
    organisation_representative_email character varying(70),
    legal_status character varying(20),
    delegation_date date,
    internship_address character varying(500),
    employer_name character varying(180),
    employer_contact_email character varying(71),
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    activity_scope text,
    activity_preparation text,
    activity_learnings text,
    activity_rating text,
    skills_observe text,
    skills_communicate text,
    skills_understand text,
    skills_motivation text,
    entreprise_address character varying,
    student_birth_date date,
    pai_project boolean,
    pai_trousse_family boolean
);


--
-- Name: internship_agreements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_agreements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_agreements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_agreements_id_seq OWNED BY public.internship_agreements.id;


--
-- Name: internship_application_state_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_application_state_changes (
    id bigint NOT NULL,
    internship_application_id bigint NOT NULL,
    author_type character varying,
    author_id bigint,
    from_state character varying,
    to_state character varying NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: internship_application_state_changes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_application_state_changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_application_state_changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_application_state_changes_id_seq OWNED BY public.internship_application_state_changes.id;


--
-- Name: internship_application_weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_application_weeks (
    id bigint NOT NULL,
    week_id bigint NOT NULL,
    internship_application_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: internship_application_weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_application_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_application_weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_application_weeks_id_seq OWNED BY public.internship_application_weeks.id;


--
-- Name: internship_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_applications (
    id bigint NOT NULL,
    user_id bigint,
    internship_offer_week_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aasm_state character varying(100),
    approved_at timestamp without time zone,
    rejected_at timestamp without time zone,
    convention_signed_at timestamp without time zone,
    submitted_at timestamp without time zone,
    expired_at timestamp without time zone,
    pending_reminder_sent_at timestamp without time zone,
    canceled_at timestamp without time zone,
    type character varying(100) DEFAULT 'InternshipApplications::WeeklyFramed'::character varying,
    internship_offer_id bigint NOT NULL,
    applicable_type character varying(100),
    internship_offer_type character varying(50) NOT NULL,
    week_id bigint,
    student_phone character varying(20),
    student_email character varying(100),
    read_at timestamp(6) without time zone,
    examined_at timestamp(6) without time zone,
    validated_by_employer_at timestamp(6) without time zone,
    dunning_letter_count integer DEFAULT 0,
    magic_link_tracker integer DEFAULT 0,
    access_token character varying(20),
    transfered_at timestamp(6) without time zone,
    student_address character varying(300),
    student_legal_representative_full_name character varying(150),
    student_legal_representative_email character varying(109),
    student_legal_representative_phone character varying(50),
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    motivation text,
    rejected_message text,
    canceled_by_employer_message text,
    canceled_by_student_message text,
    approved_message text,
    restored_at timestamp(6) without time zone,
    restored_message text
);


--
-- Name: internship_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_applications_id_seq OWNED BY public.internship_applications.id;


--
-- Name: internship_occupations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_occupations (
    id bigint NOT NULL,
    title character varying(150) NOT NULL,
    description character varying(1500) NOT NULL,
    street character varying(200) NOT NULL,
    zipcode character varying(5) NOT NULL,
    city character varying(50) NOT NULL,
    department character varying(40) DEFAULT ''::character varying NOT NULL,
    coordinates public.geography(Point,4326),
    employer_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    ia_score integer
);


--
-- Name: internship_occupations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_occupations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_occupations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_occupations_id_seq OWNED BY public.internship_occupations.id;


--
-- Name: internship_offer_areas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offer_areas (
    id bigint NOT NULL,
    employer_type character varying(50),
    employer_id bigint,
    name character varying(150),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: internship_offer_areas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offer_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offer_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offer_areas_id_seq OWNED BY public.internship_offer_areas.id;


--
-- Name: internship_offer_grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offer_grades (
    id bigint NOT NULL,
    grade_id bigint NOT NULL,
    internship_offer_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: internship_offer_grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offer_grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offer_grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offer_grades_id_seq OWNED BY public.internship_offer_grades.id;


--
-- Name: internship_offer_info_weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offer_info_weeks (
    id bigint NOT NULL,
    internship_offer_info_id bigint,
    week_id bigint,
    total_applications_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: internship_offer_info_weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offer_info_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offer_info_weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offer_info_weeks_id_seq OWNED BY public.internship_offer_info_weeks.id;


--
-- Name: internship_offer_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offer_infos (
    id bigint NOT NULL,
    title character varying(150),
    description text,
    max_candidates integer,
    school_id integer,
    employer_id bigint NOT NULL,
    type character varying(50),
    sector_id bigint,
    last_date date,
    weeks_count integer DEFAULT 0 NOT NULL,
    internship_offer_info_weeks_count integer DEFAULT 0 NOT NULL,
    weekly_hours text[] DEFAULT '{}'::text[],
    daily_hours text[] DEFAULT '{}'::text[],
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    new_daily_hours jsonb DEFAULT '{}'::jsonb,
    daily_lunch_break jsonb DEFAULT '{}'::jsonb,
    weekly_lunch_break text,
    max_students_per_group integer DEFAULT 1 NOT NULL,
    remaining_seats_count integer DEFAULT 0
);


--
-- Name: internship_offer_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offer_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offer_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offer_infos_id_seq OWNED BY public.internship_offer_infos.id;


--
-- Name: internship_offer_keywords; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offer_keywords (
    id bigint NOT NULL,
    word text NOT NULL,
    ndoc integer NOT NULL,
    nentry integer NOT NULL,
    searchable boolean DEFAULT true NOT NULL,
    word_nature character varying(200) DEFAULT NULL::character varying
);


--
-- Name: internship_offer_keywords_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offer_keywords_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offer_keywords_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offer_keywords_id_seq OWNED BY public.internship_offer_keywords.id;


--
-- Name: internship_offer_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offer_stats (
    id bigint NOT NULL,
    internship_offer_id bigint NOT NULL,
    remaining_seats_count integer DEFAULT 0,
    blocked_weeks_count integer DEFAULT 0,
    total_applications_count integer DEFAULT 0,
    approved_applications_count integer DEFAULT 0,
    submitted_applications_count integer DEFAULT 0,
    rejected_applications_count integer DEFAULT 0,
    view_count integer DEFAULT 0,
    total_male_applications_count integer DEFAULT 0,
    total_female_applications_count integer DEFAULT 0,
    total_male_approved_applications_count integer DEFAULT 0,
    total_female_approved_applications_count integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: internship_offer_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offer_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offer_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offer_stats_id_seq OWNED BY public.internship_offer_stats.id;


--
-- Name: internship_offer_student_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offer_student_infos (
    id bigint NOT NULL,
    max_candidates integer,
    school_id integer,
    employer_id integer,
    last_date date,
    weeks_count integer DEFAULT 0 NOT NULL,
    internship_offer_student_info_weeks_count integer DEFAULT 0 NOT NULL,
    daily_hours jsonb DEFAULT '{}'::jsonb,
    weekly_hours text[] DEFAULT '{}'::text[],
    weekly_lunch_break text,
    max_students_per_group integer DEFAULT 1 NOT NULL,
    remaining_seats_count integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: internship_offer_student_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offer_student_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offer_student_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offer_student_infos_id_seq OWNED BY public.internship_offer_student_infos.id;


--
-- Name: internship_offer_weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offer_weeks (
    id bigint NOT NULL,
    internship_offer_id bigint,
    week_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    blocked_applications_count integer DEFAULT 0 NOT NULL
);


--
-- Name: internship_offer_weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offer_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offer_weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offer_weeks_id_seq OWNED BY public.internship_offer_weeks.id;


--
-- Name: internship_offers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offers (
    id bigint NOT NULL,
    title character varying(150),
    description character varying(1500),
    max_candidates integer DEFAULT 1 NOT NULL,
    internship_offer_weeks_count integer DEFAULT 0 NOT NULL,
    tutor_name character varying(150),
    tutor_phone character varying(20),
    tutor_email character varying(100),
    employer_website character varying(560),
    street character varying(500),
    zipcode character varying(5),
    city character varying(50),
    is_public boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    coordinates public.geography(Point,4326),
    employer_name character varying(150),
    employer_id bigint,
    school_id bigint,
    employer_description character varying(1500),
    sector_id bigint,
    blocked_weeks_count integer DEFAULT 0 NOT NULL,
    total_applications_count integer DEFAULT 0 NOT NULL,
    approved_applications_count integer DEFAULT 0 NOT NULL,
    employer_type character varying(30),
    department character varying(40) DEFAULT ''::character varying NOT NULL,
    academy character varying(50) DEFAULT ''::character varying NOT NULL,
    total_male_applications_count integer DEFAULT 0 NOT NULL,
    remote_id character varying(60),
    permalink character varying(200),
    view_count integer DEFAULT 0 NOT NULL,
    submitted_applications_count integer DEFAULT 0 NOT NULL,
    rejected_applications_count integer DEFAULT 0 NOT NULL,
    published_at timestamp without time zone,
    total_male_approved_applications_count integer DEFAULT 0,
    group_id bigint,
    first_date date NOT NULL,
    last_date date NOT NULL,
    type character varying(40),
    search_tsv tsvector,
    aasm_state character varying(100),
    internship_offer_info_id bigint,
    organisation_id bigint,
    weekly_hours text[] DEFAULT '{}'::text[],
    tutor_id bigint,
    new_daily_hours jsonb DEFAULT '{}'::jsonb,
    daterange daterange GENERATED ALWAYS AS (daterange(first_date, last_date)) STORED,
    siret character varying(14),
    daily_lunch_break jsonb DEFAULT '{}'::jsonb,
    total_female_applications_count integer DEFAULT 0 NOT NULL,
    total_female_approved_applications_count integer DEFAULT 0,
    max_students_per_group integer DEFAULT 1 NOT NULL,
    internship_address_manual_enter boolean DEFAULT false,
    tutor_role character varying(150),
    remaining_seats_count integer DEFAULT 0,
    hidden_duplicate boolean DEFAULT false,
    daily_hours jsonb,
    hosting_info_id bigint,
    practical_info_id bigint,
    internship_offer_area_id bigint,
    lunch_break text,
    contact_phone character varying(20),
    handicap_accessible boolean DEFAULT false,
    school_year integer DEFAULT 0 NOT NULL,
    internship_occupation_id bigint,
    entreprise_id bigint,
    planning_id bigint,
    employer_chosen_name character varying(150),
    entreprise_full_address character varying(200),
    entreprise_coordinates public.geography(Point,4326),
    rep boolean DEFAULT false,
    qpv boolean DEFAULT false,
    workspace_conditions text DEFAULT ''::text,
    workspace_accessibility text DEFAULT ''::text,
    period integer DEFAULT 0 NOT NULL,
    mother_id bigint,
    targeted_grades public.targeted_grades DEFAULT 'seconde_only'::public.targeted_grades,
    ia_score integer
);


--
-- Name: internship_offers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offers_id_seq OWNED BY public.internship_offers.id;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitations (
    id bigint NOT NULL,
    sent_at timestamp without time zone,
    email character varying(70),
    first_name character varying(60),
    last_name character varying(60),
    role character varying(50),
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invitations_id_seq OWNED BY public.invitations.id;


--
-- Name: ministry_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ministry_groups (
    id bigint NOT NULL,
    group_id bigint,
    email_whitelist_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ministry_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ministry_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ministry_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ministry_groups_id_seq OWNED BY public.ministry_groups.id;


--
-- Name: months; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.months (
    date date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: operators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operators (
    id bigint NOT NULL,
    name character varying(80),
    target_count integer DEFAULT 0,
    logo character varying(250),
    website character varying(250),
    created_at timestamp without time zone DEFAULT '2021-05-06 08:22:40.377616'::timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT '2021-05-06 08:22:40.384734'::timestamp without time zone NOT NULL,
    api_full_access boolean DEFAULT false,
    realized_count json DEFAULT '{}'::json,
    masked_data boolean DEFAULT false
);


--
-- Name: operators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.operators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: operators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.operators_id_seq OWNED BY public.operators.id;


--
-- Name: organisations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organisations (
    id bigint NOT NULL,
    employer_name character varying(150) NOT NULL,
    street character varying(200) NOT NULL,
    zipcode character varying(5) NOT NULL,
    city character varying(50) NOT NULL,
    employer_website character varying(560),
    employer_description character varying(250),
    coordinates public.geography(Point,4326),
    department character varying(40) DEFAULT ''::character varying NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    group_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    employer_id integer,
    siren character varying(9),
    siret character varying(14),
    is_paqte boolean,
    manual_enter boolean DEFAULT false
);


--
-- Name: organisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organisations_id_seq OWNED BY public.organisations.id;


--
-- Name: planning_grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planning_grades (
    id bigint NOT NULL,
    grade_id bigint NOT NULL,
    planning_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: planning_grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planning_grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planning_grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planning_grades_id_seq OWNED BY public.planning_grades.id;


--
-- Name: planning_weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planning_weeks (
    id bigint NOT NULL,
    planning_id bigint NOT NULL,
    week_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: planning_weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planning_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planning_weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planning_weeks_id_seq OWNED BY public.planning_weeks.id;


--
-- Name: plannings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plannings (
    id bigint NOT NULL,
    max_candidates integer DEFAULT 1 NOT NULL,
    max_students_per_group integer DEFAULT 1 NOT NULL,
    remaining_seats_count integer DEFAULT 0,
    weekly_hours character varying(400)[] DEFAULT '{}'::character varying[],
    daily_hours jsonb DEFAULT '{}'::jsonb,
    daily_lunch_break jsonb DEFAULT '{}'::jsonb,
    entreprise_id bigint,
    school_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    employer_id bigint,
    lunch_break character varying(250),
    internship_weeks_number integer DEFAULT 1,
    rep boolean DEFAULT false,
    qpv boolean DEFAULT false
);


--
-- Name: plannings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plannings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plannings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plannings_id_seq OWNED BY public.plannings.id;


--
-- Name: practical_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.practical_infos (
    id bigint NOT NULL,
    employer_id integer,
    street character varying(470) NOT NULL,
    zipcode character varying(5) NOT NULL,
    city character varying(50) NOT NULL,
    coordinates public.geography(Point,4326),
    department character varying(40) DEFAULT ''::character varying NOT NULL,
    daily_hours jsonb DEFAULT '{}'::jsonb,
    daily_lunch_break jsonb DEFAULT '{}'::jsonb,
    weekly_hours text[] DEFAULT '{}'::text[],
    weekly_lunch_break text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    lunch_break text,
    contact_phone character varying(20)
);


--
-- Name: practical_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.practical_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: practical_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.practical_infos_id_seq OWNED BY public.practical_infos.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: school_internship_weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school_internship_weeks (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    week_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: school_internship_weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.school_internship_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: school_internship_weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.school_internship_weeks_id_seq OWNED BY public.school_internship_weeks.id;


--
-- Name: schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schools (
    id bigint NOT NULL,
    name character varying(150) DEFAULT ''::character varying NOT NULL,
    city character varying(50) DEFAULT ''::character varying NOT NULL,
    zipcode character varying(5),
    code_uai character varying(10),
    coordinates public.geography(Point,4326),
    street character varying(200),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    city_tsv tsvector,
    rep_kind character varying(50),
    visible boolean DEFAULT true,
    internship_agreement_online boolean DEFAULT false,
    fetched_school_phone character varying(20),
    fetched_school_address character varying(300),
    fetched_school_email character varying(100),
    legal_status character varying(20),
    delegation_date date,
    is_public boolean DEFAULT true,
    contract_code character varying(3),
    department_id bigint,
    agreement_conditions text,
    school_type public.school_category DEFAULT 'college'::public.school_category NOT NULL,
    voie_generale boolean,
    voie_techno boolean,
    full_imported boolean DEFAULT false,
    qpv boolean DEFAULT false
);


--
-- Name: schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schools_id_seq OWNED BY public.schools.id;


--
-- Name: sectors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sectors (
    id bigint NOT NULL,
    name character varying(50),
    external_url character varying(200) DEFAULT ''::character varying NOT NULL,
    uuid character varying(50) DEFAULT ''::character varying NOT NULL
);


--
-- Name: sectors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sectors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sectors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sectors_id_seq OWNED BY public.sectors.id;


--
-- Name: signatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.signatures (
    id bigint NOT NULL,
    signatory_ip character varying(40) NOT NULL,
    signature_date timestamp(6) without time zone NOT NULL,
    internship_agreement_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    signatory_role public.agreement_signatory_role,
    signature_phone_number character varying,
    user_id bigint
);


--
-- Name: signatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.signatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: signatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.signatures_id_seq OWNED BY public.signatures.id;


--
-- Name: task_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_records (
    version character varying NOT NULL
);


--
-- Name: task_registers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_registers (
    task_name character varying(250),
    used_environment character varying(150),
    played_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    id bigint NOT NULL
);


--
-- Name: task_registers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_registers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_registers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_registers_id_seq OWNED BY public.task_registers.id;


--
-- Name: team_member_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_member_invitations (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    inviter_id bigint NOT NULL,
    member_id bigint,
    invitation_email character varying(150) NOT NULL,
    invitation_refused_at timestamp(6) without time zone,
    aasm_state character varying(100) DEFAULT 'pending_invitation'::character varying
);


--
-- Name: team_member_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_member_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_member_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_member_invitations_id_seq OWNED BY public.team_member_invitations.id;


--
-- Name: tutors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tutors (
    id bigint NOT NULL,
    tutor_name character varying(120) NOT NULL,
    tutor_email character varying(100) NOT NULL,
    tutor_phone character varying(20) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    employer_id bigint NOT NULL,
    tutor_role character varying(250)
);


--
-- Name: tutors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tutors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tutors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tutors_id_seq OWNED BY public.tutors.id;


--
-- Name: url_shrinkers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.url_shrinkers (
    id bigint NOT NULL,
    original_url character varying(650),
    url_token character varying(6),
    click_count integer DEFAULT 0,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: url_shrinkers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.url_shrinkers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: url_shrinkers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.url_shrinkers_id_seq OWNED BY public.url_shrinkers.id;


--
-- Name: user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_groups (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    group_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_groups_id_seq OWNED BY public.user_groups.id;


--
-- Name: user_schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_schools (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    school_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_schools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_schools_id_seq OWNED BY public.user_schools.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying(70) DEFAULT ''::character varying,
    encrypted_password character varying(60) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(64),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(15),
    last_sign_in_ip character varying(15),
    confirmation_token character varying(20),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(70),
    phone character varying(20),
    first_name character varying(85),
    last_name character varying(85),
    operator_name character varying(50),
    type character varying(50),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    school_id bigint,
    birth_date date,
    gender character varying(2),
    class_room_id bigint,
    operator_id bigint,
    api_token character varying(36),
    accept_terms boolean DEFAULT false NOT NULL,
    discarded_at timestamp without time zone,
    department character varying(2),
    role character varying(50),
    phone_token character varying(4),
    phone_token_validity timestamp without time zone,
    phone_password_reset_count integer DEFAULT 0,
    last_phone_password_reset timestamp without time zone,
    anonymized boolean DEFAULT false NOT NULL,
    banners jsonb DEFAULT '{}'::jsonb,
    targeted_offer_id integer,
    signature_phone_token character varying(10),
    signature_phone_token_expires_at timestamp(6) without time zone,
    signature_phone_token_checked_at timestamp(6) without time zone,
    employer_role character varying(150),
    subscribed_to_webinar_at timestamp(6) without time zone DEFAULT NULL::timestamp without time zone,
    agreement_signatorable boolean DEFAULT true,
    created_by_teacher boolean DEFAULT false,
    survey_answered boolean DEFAULT false,
    current_area_id bigint,
    statistician_validation boolean DEFAULT false,
    academy_id integer,
    academy_region_id integer,
    address character varying(300),
    legal_representative_full_name character varying(100),
    legal_representative_email character varying(109),
    legal_representative_phone character varying(50),
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying(64),
    locked_at timestamp(6) without time zone,
    resume_educational_background text,
    resume_other text,
    resume_languages text,
    grade_id bigint,
    ine character varying(15),
    active_at timestamp(6) without time zone,
    school_ids text[] DEFAULT '{}'::text[],
    user_info jsonb DEFAULT '{}'::jsonb,
    fim_user_info jsonb
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_internship_offers_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_internship_offers_histories (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    internship_offer_id bigint NOT NULL,
    application_clicks integer DEFAULT 0,
    views integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_internship_offers_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_internship_offers_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_internship_offers_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_internship_offers_histories_id_seq OWNED BY public.users_internship_offers_histories.id;


--
-- Name: users_search_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_search_histories (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    keywords character varying(255),
    latitude double precision,
    longitude double precision,
    city character varying(165),
    radius integer,
    results_count integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_search_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_search_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_search_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_search_histories_id_seq OWNED BY public.users_search_histories.id;


--
-- Name: waiting_list_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.waiting_list_entries (
    id bigint NOT NULL,
    email character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: waiting_list_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.waiting_list_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: waiting_list_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.waiting_list_entries_id_seq OWNED BY public.waiting_list_entries.id;


--
-- Name: weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weeks (
    id bigint NOT NULL,
    number integer,
    year integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.weeks_id_seq OWNED BY public.weeks.id;


--
-- Name: academies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academies ALTER COLUMN id SET DEFAULT nextval('public.academies_id_seq'::regclass);


--
-- Name: academy_regions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academy_regions ALTER COLUMN id SET DEFAULT nextval('public.academy_regions_id_seq'::regclass);


--
-- Name: action_text_rich_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts ALTER COLUMN id SET DEFAULT nextval('public.action_text_rich_texts_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: area_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.area_notifications ALTER COLUMN id SET DEFAULT nextval('public.area_notifications_id_seq'::regclass);


--
-- Name: class_rooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_rooms ALTER COLUMN id SET DEFAULT nextval('public.class_rooms_id_seq'::regclass);


--
-- Name: coded_crafts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coded_crafts ALTER COLUMN id SET DEFAULT nextval('public.coded_crafts_id_seq'::regclass);


--
-- Name: craft_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.craft_fields ALTER COLUMN id SET DEFAULT nextval('public.craft_fields_id_seq'::regclass);


--
-- Name: crafts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crafts ALTER COLUMN id SET DEFAULT nextval('public.crafts_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: detailed_crafts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detailed_crafts ALTER COLUMN id SET DEFAULT nextval('public.detailed_crafts_id_seq'::regclass);


--
-- Name: entreprises id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entreprises ALTER COLUMN id SET DEFAULT nextval('public.entreprises_id_seq'::regclass);


--
-- Name: favorites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: flipper_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_features ALTER COLUMN id SET DEFAULT nextval('public.flipper_features_id_seq'::regclass);


--
-- Name: flipper_gates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_gates ALTER COLUMN id SET DEFAULT nextval('public.flipper_gates_id_seq'::regclass);


--
-- Name: grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades ALTER COLUMN id SET DEFAULT nextval('public.grades_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: hosting_info_weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosting_info_weeks ALTER COLUMN id SET DEFAULT nextval('public.hosting_info_weeks_id_seq'::regclass);


--
-- Name: hosting_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosting_infos ALTER COLUMN id SET DEFAULT nextval('public.hosting_infos_id_seq'::regclass);


--
-- Name: identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identities ALTER COLUMN id SET DEFAULT nextval('public.identities_id_seq'::regclass);


--
-- Name: internship_agreements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_agreements ALTER COLUMN id SET DEFAULT nextval('public.internship_agreements_id_seq'::regclass);


--
-- Name: internship_application_state_changes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_application_state_changes ALTER COLUMN id SET DEFAULT nextval('public.internship_application_state_changes_id_seq'::regclass);


--
-- Name: internship_application_weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_application_weeks ALTER COLUMN id SET DEFAULT nextval('public.internship_application_weeks_id_seq'::regclass);


--
-- Name: internship_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_applications ALTER COLUMN id SET DEFAULT nextval('public.internship_applications_id_seq'::regclass);


--
-- Name: internship_occupations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_occupations ALTER COLUMN id SET DEFAULT nextval('public.internship_occupations_id_seq'::regclass);


--
-- Name: internship_offer_areas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_areas ALTER COLUMN id SET DEFAULT nextval('public.internship_offer_areas_id_seq'::regclass);


--
-- Name: internship_offer_grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_grades ALTER COLUMN id SET DEFAULT nextval('public.internship_offer_grades_id_seq'::regclass);


--
-- Name: internship_offer_info_weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_info_weeks ALTER COLUMN id SET DEFAULT nextval('public.internship_offer_info_weeks_id_seq'::regclass);


--
-- Name: internship_offer_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_infos ALTER COLUMN id SET DEFAULT nextval('public.internship_offer_infos_id_seq'::regclass);


--
-- Name: internship_offer_keywords id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_keywords ALTER COLUMN id SET DEFAULT nextval('public.internship_offer_keywords_id_seq'::regclass);


--
-- Name: internship_offer_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_stats ALTER COLUMN id SET DEFAULT nextval('public.internship_offer_stats_id_seq'::regclass);


--
-- Name: internship_offer_student_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_student_infos ALTER COLUMN id SET DEFAULT nextval('public.internship_offer_student_infos_id_seq'::regclass);


--
-- Name: internship_offer_weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_weeks ALTER COLUMN id SET DEFAULT nextval('public.internship_offer_weeks_id_seq'::regclass);


--
-- Name: internship_offers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers ALTER COLUMN id SET DEFAULT nextval('public.internship_offers_id_seq'::regclass);


--
-- Name: invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations ALTER COLUMN id SET DEFAULT nextval('public.invitations_id_seq'::regclass);


--
-- Name: ministry_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ministry_groups ALTER COLUMN id SET DEFAULT nextval('public.ministry_groups_id_seq'::regclass);


--
-- Name: operators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operators ALTER COLUMN id SET DEFAULT nextval('public.operators_id_seq'::regclass);


--
-- Name: organisations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisations ALTER COLUMN id SET DEFAULT nextval('public.organisations_id_seq'::regclass);


--
-- Name: planning_grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planning_grades ALTER COLUMN id SET DEFAULT nextval('public.planning_grades_id_seq'::regclass);


--
-- Name: planning_weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planning_weeks ALTER COLUMN id SET DEFAULT nextval('public.planning_weeks_id_seq'::regclass);


--
-- Name: plannings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plannings ALTER COLUMN id SET DEFAULT nextval('public.plannings_id_seq'::regclass);


--
-- Name: practical_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_infos ALTER COLUMN id SET DEFAULT nextval('public.practical_infos_id_seq'::regclass);


--
-- Name: school_internship_weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_internship_weeks ALTER COLUMN id SET DEFAULT nextval('public.school_internship_weeks_id_seq'::regclass);


--
-- Name: schools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools ALTER COLUMN id SET DEFAULT nextval('public.schools_id_seq'::regclass);


--
-- Name: sectors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sectors ALTER COLUMN id SET DEFAULT nextval('public.sectors_id_seq'::regclass);


--
-- Name: signatures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signatures ALTER COLUMN id SET DEFAULT nextval('public.signatures_id_seq'::regclass);


--
-- Name: task_registers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_registers ALTER COLUMN id SET DEFAULT nextval('public.task_registers_id_seq'::regclass);


--
-- Name: team_member_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member_invitations ALTER COLUMN id SET DEFAULT nextval('public.team_member_invitations_id_seq'::regclass);


--
-- Name: tutors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutors ALTER COLUMN id SET DEFAULT nextval('public.tutors_id_seq'::regclass);


--
-- Name: url_shrinkers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.url_shrinkers ALTER COLUMN id SET DEFAULT nextval('public.url_shrinkers_id_seq'::regclass);


--
-- Name: user_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups ALTER COLUMN id SET DEFAULT nextval('public.user_groups_id_seq'::regclass);


--
-- Name: user_schools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_schools ALTER COLUMN id SET DEFAULT nextval('public.user_schools_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_internship_offers_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_internship_offers_histories ALTER COLUMN id SET DEFAULT nextval('public.users_internship_offers_histories_id_seq'::regclass);


--
-- Name: users_search_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_search_histories ALTER COLUMN id SET DEFAULT nextval('public.users_search_histories_id_seq'::regclass);


--
-- Name: waiting_list_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waiting_list_entries ALTER COLUMN id SET DEFAULT nextval('public.waiting_list_entries_id_seq'::regclass);


--
-- Name: weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks ALTER COLUMN id SET DEFAULT nextval('public.weeks_id_seq'::regclass);


--
-- Name: academies academies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academies
    ADD CONSTRAINT academies_pkey PRIMARY KEY (id);


--
-- Name: academy_regions academy_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academy_regions
    ADD CONSTRAINT academy_regions_pkey PRIMARY KEY (id);


--
-- Name: action_text_rich_texts action_text_rich_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts
    ADD CONSTRAINT action_text_rich_texts_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: area_notifications area_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.area_notifications
    ADD CONSTRAINT area_notifications_pkey PRIMARY KEY (id);


--
-- Name: class_rooms class_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_rooms
    ADD CONSTRAINT class_rooms_pkey PRIMARY KEY (id);


--
-- Name: coded_crafts coded_crafts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coded_crafts
    ADD CONSTRAINT coded_crafts_pkey PRIMARY KEY (id);


--
-- Name: craft_fields craft_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.craft_fields
    ADD CONSTRAINT craft_fields_pkey PRIMARY KEY (id);


--
-- Name: crafts crafts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crafts
    ADD CONSTRAINT crafts_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: detailed_crafts detailed_crafts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detailed_crafts
    ADD CONSTRAINT detailed_crafts_pkey PRIMARY KEY (id);


--
-- Name: entreprises entreprises_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entreprises
    ADD CONSTRAINT entreprises_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: flipper_features flipper_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_features
    ADD CONSTRAINT flipper_features_pkey PRIMARY KEY (id);


--
-- Name: flipper_gates flipper_gates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_gates
    ADD CONSTRAINT flipper_gates_pkey PRIMARY KEY (id);


--
-- Name: grades grades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: hosting_info_weeks hosting_info_weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosting_info_weeks
    ADD CONSTRAINT hosting_info_weeks_pkey PRIMARY KEY (id);


--
-- Name: hosting_infos hosting_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosting_infos
    ADD CONSTRAINT hosting_infos_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: internship_agreements internship_agreements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_agreements
    ADD CONSTRAINT internship_agreements_pkey PRIMARY KEY (id);


--
-- Name: internship_application_state_changes internship_application_state_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_application_state_changes
    ADD CONSTRAINT internship_application_state_changes_pkey PRIMARY KEY (id);


--
-- Name: internship_application_weeks internship_application_weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_application_weeks
    ADD CONSTRAINT internship_application_weeks_pkey PRIMARY KEY (id);


--
-- Name: internship_applications internship_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_applications
    ADD CONSTRAINT internship_applications_pkey PRIMARY KEY (id);


--
-- Name: internship_occupations internship_occupations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_occupations
    ADD CONSTRAINT internship_occupations_pkey PRIMARY KEY (id);


--
-- Name: internship_offer_areas internship_offer_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_areas
    ADD CONSTRAINT internship_offer_areas_pkey PRIMARY KEY (id);


--
-- Name: internship_offer_grades internship_offer_grades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_grades
    ADD CONSTRAINT internship_offer_grades_pkey PRIMARY KEY (id);


--
-- Name: internship_offer_info_weeks internship_offer_info_weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_info_weeks
    ADD CONSTRAINT internship_offer_info_weeks_pkey PRIMARY KEY (id);


--
-- Name: internship_offer_infos internship_offer_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_infos
    ADD CONSTRAINT internship_offer_infos_pkey PRIMARY KEY (id);


--
-- Name: internship_offer_keywords internship_offer_keywords_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_keywords
    ADD CONSTRAINT internship_offer_keywords_pkey PRIMARY KEY (id);


--
-- Name: internship_offer_stats internship_offer_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_stats
    ADD CONSTRAINT internship_offer_stats_pkey PRIMARY KEY (id);


--
-- Name: internship_offer_student_infos internship_offer_student_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_student_infos
    ADD CONSTRAINT internship_offer_student_infos_pkey PRIMARY KEY (id);


--
-- Name: internship_offer_weeks internship_offer_weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_weeks
    ADD CONSTRAINT internship_offer_weeks_pkey PRIMARY KEY (id);


--
-- Name: internship_offers internship_offers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT internship_offers_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: ministry_groups ministry_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ministry_groups
    ADD CONSTRAINT ministry_groups_pkey PRIMARY KEY (id);


--
-- Name: operators operators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operators
    ADD CONSTRAINT operators_pkey PRIMARY KEY (id);


--
-- Name: organisations organisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: planning_grades planning_grades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planning_grades
    ADD CONSTRAINT planning_grades_pkey PRIMARY KEY (id);


--
-- Name: planning_weeks planning_weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planning_weeks
    ADD CONSTRAINT planning_weeks_pkey PRIMARY KEY (id);


--
-- Name: plannings plannings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plannings
    ADD CONSTRAINT plannings_pkey PRIMARY KEY (id);


--
-- Name: practical_infos practical_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_infos
    ADD CONSTRAINT practical_infos_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: school_internship_weeks school_internship_weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_internship_weeks
    ADD CONSTRAINT school_internship_weeks_pkey PRIMARY KEY (id);


--
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: sectors sectors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sectors
    ADD CONSTRAINT sectors_pkey PRIMARY KEY (id);


--
-- Name: signatures signatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signatures
    ADD CONSTRAINT signatures_pkey PRIMARY KEY (id);


--
-- Name: task_registers task_registers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_registers
    ADD CONSTRAINT task_registers_pkey PRIMARY KEY (id);


--
-- Name: team_member_invitations team_member_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member_invitations
    ADD CONSTRAINT team_member_invitations_pkey PRIMARY KEY (id);


--
-- Name: tutors tutors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutors
    ADD CONSTRAINT tutors_pkey PRIMARY KEY (id);


--
-- Name: url_shrinkers url_shrinkers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.url_shrinkers
    ADD CONSTRAINT url_shrinkers_pkey PRIMARY KEY (id);


--
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (id);


--
-- Name: user_schools user_schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_schools
    ADD CONSTRAINT user_schools_pkey PRIMARY KEY (id);


--
-- Name: users_internship_offers_histories users_internship_offers_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_internship_offers_histories
    ADD CONSTRAINT users_internship_offers_histories_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_search_histories users_search_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_search_histories
    ADD CONSTRAINT users_search_histories_pkey PRIMARY KEY (id);


--
-- Name: waiting_list_entries waiting_list_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waiting_list_entries
    ADD CONSTRAINT waiting_list_entries_pkey PRIMARY KEY (id);


--
-- Name: weeks weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks
    ADD CONSTRAINT weeks_pkey PRIMARY KEY (id);


--
-- Name: idx_on_internship_application_id_085823fd89; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_internship_application_id_085823fd89 ON public.internship_application_state_changes USING btree (internship_application_id);


--
-- Name: idx_on_internship_application_id_created_at_42571d8745; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_internship_application_id_created_at_42571d8745 ON public.internship_application_state_changes USING btree (internship_application_id, created_at);


--
-- Name: idx_on_internship_application_id_e95b0b9dbb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_internship_application_id_e95b0b9dbb ON public.internship_application_weeks USING btree (internship_application_id);


--
-- Name: index_action_text_rich_texts_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_action_text_rich_texts_uniqueness ON public.action_text_rich_texts USING btree (record_type, record_id, name);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_area_notifications_on_internship_offer_area_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_area_notifications_on_internship_offer_area_id ON public.area_notifications USING btree (internship_offer_area_id);


--
-- Name: index_area_notifications_on_user_and_area; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_area_notifications_on_user_and_area ON public.area_notifications USING btree (user_id, internship_offer_area_id);


--
-- Name: index_area_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_area_notifications_on_user_id ON public.area_notifications USING btree (user_id);


--
-- Name: index_class_rooms_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_class_rooms_on_grade_id ON public.class_rooms USING btree (grade_id);


--
-- Name: index_class_rooms_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_class_rooms_on_school_id ON public.class_rooms USING btree (school_id);


--
-- Name: index_coded_crafts_on_detailed_craft_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_coded_crafts_on_detailed_craft_id ON public.coded_crafts USING btree (detailed_craft_id);


--
-- Name: index_coded_crafts_on_ogr_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_coded_crafts_on_ogr_code ON public.coded_crafts USING btree (ogr_code);


--
-- Name: index_coded_crafts_on_search_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_coded_crafts_on_search_tsv ON public.coded_crafts USING gin (search_tsv);


--
-- Name: index_craft_fields_on_letter; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_craft_fields_on_letter ON public.craft_fields USING btree (letter);


--
-- Name: index_crafts_on_craft_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_crafts_on_craft_field_id ON public.crafts USING btree (craft_field_id);


--
-- Name: index_departments_on_academy_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_departments_on_academy_id ON public.departments USING btree (academy_id);


--
-- Name: index_departments_operators_on_department_id_and_operator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_departments_operators_on_department_id_and_operator_id ON public.departments_operators USING btree (department_id, operator_id);


--
-- Name: index_departments_operators_on_operator_id_and_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_departments_operators_on_operator_id_and_department_id ON public.departments_operators USING btree (operator_id, department_id);


--
-- Name: index_detailed_crafts_on_craft_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_detailed_crafts_on_craft_id ON public.detailed_crafts USING btree (craft_id);


--
-- Name: index_entreprises_on_entreprise_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entreprises_on_entreprise_coordinates ON public.entreprises USING gist (entreprise_coordinates);


--
-- Name: index_entreprises_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entreprises_on_group_id ON public.entreprises USING btree (group_id);


--
-- Name: index_entreprises_on_internship_occupation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entreprises_on_internship_occupation_id ON public.entreprises USING btree (internship_occupation_id);


--
-- Name: index_entreprises_on_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entreprises_on_sector_id ON public.entreprises USING btree (sector_id);


--
-- Name: index_favorites_on_internship_offer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_internship_offer_id ON public.favorites USING btree (internship_offer_id);


--
-- Name: index_favorites_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_user_id ON public.favorites USING btree (user_id);


--
-- Name: index_favorites_on_user_id_and_internship_offer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_favorites_on_user_id_and_internship_offer_id ON public.favorites USING btree (user_id, internship_offer_id);


--
-- Name: index_flipper_features_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_flipper_features_on_key ON public.flipper_features USING btree (key);


--
-- Name: index_flipper_gates_on_feature_key_and_key_and_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_flipper_gates_on_feature_key_and_key_and_value ON public.flipper_gates USING btree (feature_key, key, value);


--
-- Name: index_groups_on_visible; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_visible ON public.groups USING btree (visible);


--
-- Name: index_hosting_info_weeks_on_hosting_info_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosting_info_weeks_on_hosting_info_id ON public.hosting_info_weeks USING btree (hosting_info_id);


--
-- Name: index_hosting_info_weeks_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosting_info_weeks_on_week_id ON public.hosting_info_weeks USING btree (week_id);


--
-- Name: index_hosting_infos_on_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosting_infos_on_period ON public.hosting_infos USING btree (period);


--
-- Name: index_identities_on_class_room_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identities_on_class_room_id ON public.identities USING btree (class_room_id);


--
-- Name: index_identities_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identities_on_grade_id ON public.identities USING btree (grade_id);


--
-- Name: index_identities_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identities_on_school_id ON public.identities USING btree (school_id);


--
-- Name: index_identities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identities_on_user_id ON public.identities USING btree (user_id);


--
-- Name: index_internship_agreements_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_agreements_on_discarded_at ON public.internship_agreements USING btree (discarded_at);


--
-- Name: index_internship_agreements_on_internship_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_agreements_on_internship_application_id ON public.internship_agreements USING btree (internship_application_id);


--
-- Name: index_internship_agreements_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_internship_agreements_on_uuid ON public.internship_agreements USING btree (uuid);


--
-- Name: index_internship_application_state_changes_on_author; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_application_state_changes_on_author ON public.internship_application_state_changes USING btree (author_type, author_id);


--
-- Name: index_internship_application_weeks_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_application_weeks_on_week_id ON public.internship_application_weeks USING btree (week_id);


--
-- Name: index_internship_applications_on_aasm_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_applications_on_aasm_state ON public.internship_applications USING btree (aasm_state);


--
-- Name: index_internship_applications_on_internship_offer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_applications_on_internship_offer_id ON public.internship_applications USING btree (internship_offer_id);


--
-- Name: index_internship_applications_on_internship_offer_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_applications_on_internship_offer_week_id ON public.internship_applications USING btree (internship_offer_week_id);


--
-- Name: index_internship_applications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_applications_on_user_id ON public.internship_applications USING btree (user_id);


--
-- Name: index_internship_applications_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_internship_applications_on_uuid ON public.internship_applications USING btree (uuid);


--
-- Name: index_internship_applications_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_applications_on_week_id ON public.internship_applications USING btree (week_id);


--
-- Name: index_internship_occupations_on_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_occupations_on_coordinates ON public.internship_occupations USING gist (coordinates);


--
-- Name: index_internship_occupations_on_employer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_occupations_on_employer_id ON public.internship_occupations USING btree (employer_id);


--
-- Name: index_internship_offer_areas_on_employer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_areas_on_employer ON public.internship_offer_areas USING btree (employer_type, employer_id);


--
-- Name: index_internship_offer_grades_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_grades_on_grade_id ON public.internship_offer_grades USING btree (grade_id);


--
-- Name: index_internship_offer_grades_on_internship_offer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_grades_on_internship_offer_id ON public.internship_offer_grades USING btree (internship_offer_id);


--
-- Name: index_internship_offer_info_weeks_on_internship_offer_info_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_info_weeks_on_internship_offer_info_id ON public.internship_offer_info_weeks USING btree (internship_offer_info_id);


--
-- Name: index_internship_offer_info_weeks_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_info_weeks_on_week_id ON public.internship_offer_info_weeks USING btree (week_id);


--
-- Name: index_internship_offer_infos_on_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_infos_on_sector_id ON public.internship_offer_infos USING btree (sector_id);


--
-- Name: index_internship_offer_keywords_on_word; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_internship_offer_keywords_on_word ON public.internship_offer_keywords USING btree (word);


--
-- Name: index_internship_offer_stats_on_blocked_weeks_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_stats_on_blocked_weeks_count ON public.internship_offer_stats USING btree (blocked_weeks_count);


--
-- Name: index_internship_offer_stats_on_internship_offer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_stats_on_internship_offer_id ON public.internship_offer_stats USING btree (internship_offer_id);


--
-- Name: index_internship_offer_stats_on_remaining_seats_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_stats_on_remaining_seats_count ON public.internship_offer_stats USING btree (remaining_seats_count);


--
-- Name: index_internship_offer_stats_on_total_applications_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_stats_on_total_applications_count ON public.internship_offer_stats USING btree (total_applications_count);


--
-- Name: index_internship_offer_weeks_on_blocked_applications_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_weeks_on_blocked_applications_count ON public.internship_offer_weeks USING btree (blocked_applications_count);


--
-- Name: index_internship_offer_weeks_on_internship_offer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_weeks_on_internship_offer_id ON public.internship_offer_weeks USING btree (internship_offer_id);


--
-- Name: index_internship_offer_weeks_on_internship_offer_id_and_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_weeks_on_internship_offer_id_and_week_id ON public.internship_offer_weeks USING btree (internship_offer_id, week_id);


--
-- Name: index_internship_offer_weeks_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_weeks_on_week_id ON public.internship_offer_weeks USING btree (week_id);


--
-- Name: index_internship_offers_on_academy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_academy ON public.internship_offers USING btree (academy);


--
-- Name: index_internship_offers_on_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_coordinates ON public.internship_offers USING gist (coordinates);


--
-- Name: index_internship_offers_on_daterange; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_daterange ON public.internship_offers USING gist (daterange);


--
-- Name: index_internship_offers_on_department; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_department ON public.internship_offers USING btree (department);


--
-- Name: index_internship_offers_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_discarded_at ON public.internship_offers USING btree (discarded_at);


--
-- Name: index_internship_offers_on_employer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_employer_id ON public.internship_offers USING btree (employer_id);


--
-- Name: index_internship_offers_on_entreprise_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_entreprise_coordinates ON public.internship_offers USING gist (entreprise_coordinates);


--
-- Name: index_internship_offers_on_entreprise_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_entreprise_id ON public.internship_offers USING btree (entreprise_id);


--
-- Name: index_internship_offers_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_group_id ON public.internship_offers USING btree (group_id);


--
-- Name: index_internship_offers_on_hosting_info_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_hosting_info_id ON public.internship_offers USING btree (hosting_info_id);


--
-- Name: index_internship_offers_on_internship_occupation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_internship_occupation_id ON public.internship_offers USING btree (internship_occupation_id);


--
-- Name: index_internship_offers_on_internship_offer_area_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_internship_offer_area_id ON public.internship_offers USING btree (internship_offer_area_id);


--
-- Name: index_internship_offers_on_internship_offer_info_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_internship_offer_info_id ON public.internship_offers USING btree (internship_offer_info_id);


--
-- Name: index_internship_offers_on_mother_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_mother_id ON public.internship_offers USING btree (mother_id);


--
-- Name: index_internship_offers_on_organisation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_organisation_id ON public.internship_offers USING btree (organisation_id);


--
-- Name: index_internship_offers_on_planning_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_planning_id ON public.internship_offers USING btree (planning_id);


--
-- Name: index_internship_offers_on_practical_info_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_practical_info_id ON public.internship_offers USING btree (practical_info_id);


--
-- Name: index_internship_offers_on_published_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_published_at ON public.internship_offers USING btree (published_at);


--
-- Name: index_internship_offers_on_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_remote_id ON public.internship_offers USING btree (remote_id);


--
-- Name: index_internship_offers_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_school_id ON public.internship_offers USING btree (school_id);


--
-- Name: index_internship_offers_on_search_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_search_tsv ON public.internship_offers USING gin (search_tsv);


--
-- Name: index_internship_offers_on_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_sector_id ON public.internship_offers USING btree (sector_id);


--
-- Name: index_internship_offers_on_targeted_grades; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_targeted_grades ON public.internship_offers USING btree (targeted_grades);


--
-- Name: index_internship_offers_on_tutor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_tutor_id ON public.internship_offers USING btree (tutor_id);


--
-- Name: index_internship_offers_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_type ON public.internship_offers USING btree (type);


--
-- Name: index_invitations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invitations_on_user_id ON public.invitations USING btree (user_id);


--
-- Name: index_ministry_groups_on_email_whitelist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ministry_groups_on_email_whitelist_id ON public.ministry_groups USING btree (email_whitelist_id);


--
-- Name: index_ministry_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ministry_groups_on_group_id ON public.ministry_groups USING btree (group_id);


--
-- Name: index_organisations_on_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organisations_on_coordinates ON public.organisations USING gist (coordinates);


--
-- Name: index_organisations_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organisations_on_group_id ON public.organisations USING btree (group_id);


--
-- Name: index_planning_grades_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planning_grades_on_grade_id ON public.planning_grades USING btree (grade_id);


--
-- Name: index_planning_grades_on_planning_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planning_grades_on_planning_id ON public.planning_grades USING btree (planning_id);


--
-- Name: index_planning_weeks_on_planning_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planning_weeks_on_planning_id ON public.planning_weeks USING btree (planning_id);


--
-- Name: index_planning_weeks_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planning_weeks_on_week_id ON public.planning_weeks USING btree (week_id);


--
-- Name: index_plannings_on_employer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_plannings_on_employer_id ON public.plannings USING btree (employer_id);


--
-- Name: index_plannings_on_entreprise_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_plannings_on_entreprise_id ON public.plannings USING btree (entreprise_id);


--
-- Name: index_plannings_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_plannings_on_school_id ON public.plannings USING btree (school_id);


--
-- Name: index_practical_infos_on_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_practical_infos_on_coordinates ON public.practical_infos USING gist (coordinates);


--
-- Name: index_school_internship_weeks_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_school_internship_weeks_on_school_id ON public.school_internship_weeks USING btree (school_id);


--
-- Name: index_school_internship_weeks_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_school_internship_weeks_on_week_id ON public.school_internship_weeks USING btree (week_id);


--
-- Name: index_schools_on_city_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schools_on_city_tsv ON public.schools USING gin (city_tsv);


--
-- Name: index_schools_on_code_uai; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schools_on_code_uai ON public.schools USING btree (code_uai);


--
-- Name: index_schools_on_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schools_on_coordinates ON public.schools USING gist (coordinates);


--
-- Name: index_schools_on_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schools_on_department_id ON public.schools USING btree (department_id);


--
-- Name: index_signatures_on_internship_agreement_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_signatures_on_internship_agreement_id ON public.signatures USING btree (internship_agreement_id);


--
-- Name: index_signatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_signatures_on_user_id ON public.signatures USING btree (user_id);


--
-- Name: index_team_member_invitations_on_inviter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_member_invitations_on_inviter_id ON public.team_member_invitations USING btree (inviter_id);


--
-- Name: index_team_member_invitations_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_member_invitations_on_member_id ON public.team_member_invitations USING btree (member_id);


--
-- Name: index_url_shrinkers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_url_shrinkers_on_user_id ON public.url_shrinkers USING btree (user_id);


--
-- Name: index_user_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_groups_on_group_id ON public.user_groups USING btree (group_id);


--
-- Name: index_user_groups_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_groups_on_user_id ON public.user_groups USING btree (user_id);


--
-- Name: index_user_schools_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_schools_on_school_id ON public.user_schools USING btree (school_id);


--
-- Name: index_user_schools_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_schools_on_user_id ON public.user_schools USING btree (user_id);


--
-- Name: index_user_schools_on_user_id_and_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_schools_on_user_id_and_school_id ON public.user_schools USING btree (user_id, school_id);


--
-- Name: index_users_internship_offers_histories_on_internship_offer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_internship_offers_histories_on_internship_offer_id ON public.users_internship_offers_histories USING btree (internship_offer_id);


--
-- Name: index_users_internship_offers_histories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_internship_offers_histories_on_user_id ON public.users_internship_offers_histories USING btree (user_id);


--
-- Name: index_users_on_academy_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_academy_id ON public.users USING btree (academy_id);


--
-- Name: index_users_on_academy_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_academy_region_id ON public.users USING btree (academy_region_id);


--
-- Name: index_users_on_api_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_api_token ON public.users USING btree (api_token);


--
-- Name: index_users_on_class_room_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_class_room_id ON public.users USING btree (class_room_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_current_area_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_current_area_id ON public.users USING btree (current_area_id);


--
-- Name: index_users_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_discarded_at ON public.users USING btree (discarded_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_grade_id ON public.users USING btree (grade_id);


--
-- Name: index_users_on_ine; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_ine ON public.users USING btree (ine);


--
-- Name: index_users_on_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_phone ON public.users USING btree (phone);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_role ON public.users USING btree (role);


--
-- Name: index_users_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_school_id ON public.users USING btree (school_id);


--
-- Name: index_users_on_school_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_school_ids ON public.users USING gin (school_ids);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_users_search_histories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_search_histories_on_user_id ON public.users_search_histories USING btree (user_id);


--
-- Name: index_weeks_on_number_and_year; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_weeks_on_number_and_year ON public.weeks USING btree (number, year);


--
-- Name: index_weeks_on_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_weeks_on_year ON public.weeks USING btree (year);


--
-- Name: internship_offer_keywords_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX internship_offer_keywords_trgm ON public.internship_offer_keywords USING gin (word public.gin_trgm_ops);


--
-- Name: not_blocked_by_weeks_count_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX not_blocked_by_weeks_count_index ON public.internship_offers USING btree (internship_offer_weeks_count, blocked_weeks_count);


--
-- Name: uniq_applications_per_internship_offer_week; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_applications_per_internship_offer_week ON public.internship_applications USING btree (user_id, internship_offer_week_id);


--
-- Name: coded_crafts sync_coded_crafts_tsv; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sync_coded_crafts_tsv BEFORE INSERT OR UPDATE ON public.coded_crafts FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('search_tsv', 'public.fr', 'name');


--
-- Name: internship_offers sync_internship_offers_tsv; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sync_internship_offers_tsv BEFORE INSERT OR UPDATE ON public.internship_offers FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('search_tsv', 'public.config_search_keyword', 'title', 'description', 'employer_description');


--
-- Name: schools sync_schools_city_tsv; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sync_schools_city_tsv BEFORE INSERT OR UPDATE ON public.schools FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('city_tsv', 'public.fr', 'city', 'name');


--
-- Name: users fk_rails_010513c2c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_010513c2c7 FOREIGN KEY (academy_id) REFERENCES public.academies(id);


--
-- Name: internship_applications fk_rails_064e6512b0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_applications
    ADD CONSTRAINT fk_rails_064e6512b0 FOREIGN KEY (week_id) REFERENCES public.weeks(id);


--
-- Name: plannings fk_rails_06c56a2d59; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plannings
    ADD CONSTRAINT fk_rails_06c56a2d59 FOREIGN KEY (employer_id) REFERENCES public.users(id);


--
-- Name: school_internship_weeks fk_rails_07f908dbef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_internship_weeks
    ADD CONSTRAINT fk_rails_07f908dbef FOREIGN KEY (week_id) REFERENCES public.weeks(id);


--
-- Name: hosting_info_weeks fk_rails_0ab0d03d1c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosting_info_weeks
    ADD CONSTRAINT fk_rails_0ab0d03d1c FOREIGN KEY (week_id) REFERENCES public.weeks(id);


--
-- Name: entreprises fk_rails_0c4a513d70; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entreprises
    ADD CONSTRAINT fk_rails_0c4a513d70 FOREIGN KEY (internship_occupation_id) REFERENCES public.internship_occupations(id);


--
-- Name: url_shrinkers fk_rails_15905c8f80; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.url_shrinkers
    ADD CONSTRAINT fk_rails_15905c8f80 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: team_member_invitations fk_rails_16e04ba94e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member_invitations
    ADD CONSTRAINT fk_rails_16e04ba94e FOREIGN KEY (inviter_id) REFERENCES public.users(id);


--
-- Name: user_schools fk_rails_176db57c4b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_schools
    ADD CONSTRAINT fk_rails_176db57c4b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: internship_offers fk_rails_184cd765dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_184cd765dd FOREIGN KEY (mother_id) REFERENCES public.internship_offers(id);


--
-- Name: signatures fk_rails_19164d1054; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signatures
    ADD CONSTRAINT fk_rails_19164d1054 FOREIGN KEY (internship_agreement_id) REFERENCES public.internship_agreements(id);


--
-- Name: internship_offers fk_rails_1cb061229c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_1cb061229c FOREIGN KEY (internship_occupation_id) REFERENCES public.internship_occupations(id);


--
-- Name: area_notifications fk_rails_2194cad748; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.area_notifications
    ADD CONSTRAINT fk_rails_2194cad748 FOREIGN KEY (internship_offer_area_id) REFERENCES public.internship_offer_areas(id);


--
-- Name: team_member_invitations fk_rails_21c6860154; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member_invitations
    ADD CONSTRAINT fk_rails_21c6860154 FOREIGN KEY (member_id) REFERENCES public.users(id);


--
-- Name: users_internship_offers_histories fk_rails_24c68739d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_internship_offers_histories
    ADD CONSTRAINT fk_rails_24c68739d8 FOREIGN KEY (internship_offer_id) REFERENCES public.internship_offers(id);


--
-- Name: user_schools fk_rails_2a059e4b44; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_schools
    ADD CONSTRAINT fk_rails_2a059e4b44 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: internship_offer_grades fk_rails_2cc542d77a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_grades
    ADD CONSTRAINT fk_rails_2cc542d77a FOREIGN KEY (internship_offer_id) REFERENCES public.internship_offers(id);


--
-- Name: planning_grades fk_rails_30cc61e8d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planning_grades
    ADD CONSTRAINT fk_rails_30cc61e8d2 FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- Name: planning_weeks fk_rails_31376ce004; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planning_weeks
    ADD CONSTRAINT fk_rails_31376ce004 FOREIGN KEY (planning_id) REFERENCES public.plannings(id);


--
-- Name: internship_occupations fk_rails_31384619d4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_occupations
    ADD CONSTRAINT fk_rails_31384619d4 FOREIGN KEY (employer_id) REFERENCES public.users(id);


--
-- Name: internship_applications fk_rails_32ed157946; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_applications
    ADD CONSTRAINT fk_rails_32ed157946 FOREIGN KEY (internship_offer_week_id) REFERENCES public.internship_offer_weeks(id);


--
-- Name: internship_offers fk_rails_34bc8b9f6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_34bc8b9f6c FOREIGN KEY (employer_id) REFERENCES public.users(id);


--
-- Name: internship_offers fk_rails_3cef9bdd89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_3cef9bdd89 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: internship_application_weeks fk_rails_3d493b87c4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_application_weeks
    ADD CONSTRAINT fk_rails_3d493b87c4 FOREIGN KEY (week_id) REFERENCES public.weeks(id);


--
-- Name: departments fk_rails_3f7cf55cd4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT fk_rails_3f7cf55cd4 FOREIGN KEY (academy_id) REFERENCES public.academies(id);


--
-- Name: hosting_info_weeks fk_rails_49834d059e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosting_info_weeks
    ADD CONSTRAINT fk_rails_49834d059e FOREIGN KEY (hosting_info_id) REFERENCES public.hosting_infos(id);


--
-- Name: class_rooms fk_rails_49ae717ca2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_rooms
    ADD CONSTRAINT fk_rails_49ae717ca2 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: users fk_rails_535539e4e8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_535539e4e8 FOREIGN KEY (operator_id) REFERENCES public.operators(id);


--
-- Name: identities fk_rails_5373344100; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identities
    ADD CONSTRAINT fk_rails_5373344100 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: internship_offer_weeks fk_rails_5b8648c95e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_weeks
    ADD CONSTRAINT fk_rails_5b8648c95e FOREIGN KEY (week_id) REFERENCES public.weeks(id);


--
-- Name: school_internship_weeks fk_rails_61db9e054c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_internship_weeks
    ADD CONSTRAINT fk_rails_61db9e054c FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: internship_offer_infos fk_rails_65006c3093; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_infos
    ADD CONSTRAINT fk_rails_65006c3093 FOREIGN KEY (employer_id) REFERENCES public.users(id);


--
-- Name: internship_application_weeks fk_rails_664e7390e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_application_weeks
    ADD CONSTRAINT fk_rails_664e7390e4 FOREIGN KEY (internship_application_id) REFERENCES public.internship_applications(id);


--
-- Name: users fk_rails_6bdbc6c887; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_6bdbc6c887 FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- Name: user_groups fk_rails_6d478d2f65; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_rails_6d478d2f65 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: entreprises fk_rails_6efe4d9b92; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entreprises
    ADD CONSTRAINT fk_rails_6efe4d9b92 FOREIGN KEY (sector_id) REFERENCES public.sectors(id);


--
-- Name: internship_applications fk_rails_75752a1ac2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_applications
    ADD CONSTRAINT fk_rails_75752a1ac2 FOREIGN KEY (internship_offer_id) REFERENCES public.internship_offers(id);


--
-- Name: internship_offers fk_rails_77a64a8062; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_77a64a8062 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: entreprises fk_rails_7d5f22629a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entreprises
    ADD CONSTRAINT fk_rails_7d5f22629a FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: users fk_rails_804d743d22; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_804d743d22 FOREIGN KEY (current_area_id) REFERENCES public.internship_offer_areas(id);


--
-- Name: internship_offers fk_rails_8ab6b60f07; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_8ab6b60f07 FOREIGN KEY (hosting_info_id) REFERENCES public.hosting_infos(id);


--
-- Name: internship_application_state_changes fk_rails_8ab7e06756; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_application_state_changes
    ADD CONSTRAINT fk_rails_8ab7e06756 FOREIGN KEY (internship_application_id) REFERENCES public.internship_applications(id);


--
-- Name: plannings fk_rails_91fffc9efc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plannings
    ADD CONSTRAINT fk_rails_91fffc9efc FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: users_search_histories fk_rails_9338fd3660; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_search_histories
    ADD CONSTRAINT fk_rails_9338fd3660 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: internship_applications fk_rails_93579c3ede; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_applications
    ADD CONSTRAINT fk_rails_93579c3ede FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: planning_weeks fk_rails_993020ef1f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planning_weeks
    ADD CONSTRAINT fk_rails_993020ef1f FOREIGN KEY (week_id) REFERENCES public.weeks(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: internship_offers fk_rails_9bcd71f8ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_9bcd71f8ef FOREIGN KEY (internship_offer_area_id) REFERENCES public.internship_offer_areas(id);


--
-- Name: internship_offer_info_weeks fk_rails_9d43a53fc8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_info_weeks
    ADD CONSTRAINT fk_rails_9d43a53fc8 FOREIGN KEY (internship_offer_info_id) REFERENCES public.internship_offer_infos(id);


--
-- Name: internship_offers fk_rails_aaa97f3a41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_aaa97f3a41 FOREIGN KEY (sector_id) REFERENCES public.sectors(id);


--
-- Name: identities fk_rails_ab66e55058; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identities
    ADD CONSTRAINT fk_rails_ab66e55058 FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- Name: area_notifications fk_rails_ab915cf6e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.area_notifications
    ADD CONSTRAINT fk_rails_ab915cf6e4 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: detailed_crafts fk_rails_ac5911bdc8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detailed_crafts
    ADD CONSTRAINT fk_rails_ac5911bdc8 FOREIGN KEY (craft_id) REFERENCES public.crafts(id);


--
-- Name: internship_offers fk_rails_ae76931d64; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_ae76931d64 FOREIGN KEY (practical_info_id) REFERENCES public.practical_infos(id);


--
-- Name: tutors fk_rails_af56aa365a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutors
    ADD CONSTRAINT fk_rails_af56aa365a FOREIGN KEY (employer_id) REFERENCES public.users(id);


--
-- Name: plannings fk_rails_b32215a275; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plannings
    ADD CONSTRAINT fk_rails_b32215a275 FOREIGN KEY (entreprise_id) REFERENCES public.entreprises(id);


--
-- Name: user_groups fk_rails_c298be7f8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_rails_c298be7f8b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: users fk_rails_d23d91f0e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_d23d91f0e6 FOREIGN KEY (class_room_id) REFERENCES public.class_rooms(id);


--
-- Name: internship_offers fk_rails_d33020d0b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_d33020d0b1 FOREIGN KEY (planning_id) REFERENCES public.plannings(id);


--
-- Name: users fk_rails_d5a5bff5c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_d5a5bff5c3 FOREIGN KEY (academy_region_id) REFERENCES public.academy_regions(id);


--
-- Name: users_internship_offers_histories fk_rails_da8186a772; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_internship_offers_histories
    ADD CONSTRAINT fk_rails_da8186a772 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: internship_offer_stats fk_rails_e13d61cd66; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_stats
    ADD CONSTRAINT fk_rails_e13d61cd66 FOREIGN KEY (internship_offer_id) REFERENCES public.internship_offers(id);


--
-- Name: internship_offer_grades fk_rails_e960458274; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_grades
    ADD CONSTRAINT fk_rails_e960458274 FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- Name: schools fk_rails_e97840dde7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT fk_rails_e97840dde7 FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: internship_offer_info_weeks fk_rails_e9c5c89c26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_info_weeks
    ADD CONSTRAINT fk_rails_e9c5c89c26 FOREIGN KEY (week_id) REFERENCES public.weeks(id);


--
-- Name: planning_grades fk_rails_eae037a466; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planning_grades
    ADD CONSTRAINT fk_rails_eae037a466 FOREIGN KEY (planning_id) REFERENCES public.plannings(id);


--
-- Name: coded_crafts fk_rails_ee4381e499; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coded_crafts
    ADD CONSTRAINT fk_rails_ee4381e499 FOREIGN KEY (detailed_craft_id) REFERENCES public.detailed_crafts(id);


--
-- Name: crafts fk_rails_efc358dba3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crafts
    ADD CONSTRAINT fk_rails_efc358dba3 FOREIGN KEY (craft_field_id) REFERENCES public.craft_fields(id);


--
-- Name: internship_offers fk_rails_efcf9ec504; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_efcf9ec504 FOREIGN KEY (entreprise_id) REFERENCES public.entreprises(id);


--
-- Name: organisations fk_rails_f1474651e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisations
    ADD CONSTRAINT fk_rails_f1474651e9 FOREIGN KEY (employer_id) REFERENCES public.users(id);


--
-- Name: internship_offer_weeks fk_rails_f36a7226ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_weeks
    ADD CONSTRAINT fk_rails_f36a7226ee FOREIGN KEY (internship_offer_id) REFERENCES public.internship_offers(id);


--
-- Name: class_rooms fk_rails_f67c7bff3c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_rooms
    ADD CONSTRAINT fk_rails_f67c7bff3c FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250526084703'),
('20250516153906'),
('20250516101824'),
('20250509153105'),
('20250424000000'),
('20250423092552'),
('20250422100745'),
('20250415143650'),
('20250414094208'),
('20250402090857'),
('20250402083055'),
('20250321164727'),
('20250320155003'),
('20250313105632'),
('20250304162138'),
('20250225122347'),
('20250221090138'),
('20250213110533'),
('20250209100322'),
('20250206101850'),
('20250205085007'),
('20250203163502'),
('20250128213823'),
('20250124164746'),
('20250120101004'),
('20250120090347'),
('20250115174742'),
('20250114094329'),
('20250107105855'),
('20250107100940'),
('20250106175910'),
('20241223095629'),
('20241220134854'),
('20241217104101'),
('20241213131559'),
('20241204173244'),
('20241115093512'),
('20241113151423'),
('20241105172654'),
('20241105171942'),
('20241105092317'),
('20241101100649'),
('20241031131640'),
('20241031101009'),
('20241024080025'),
('20241024075951'),
('20241022161032'),
('20241022094733'),
('20241016134457'),
('20241015085210'),
('20241010085334'),
('20241009115015'),
('20241009091909'),
('20241009082550'),
('20241007094016'),
('20241007083702'),
('20240927075929'),
('20240925100635'),
('20240923090303'),
('20240918144248'),
('20240916160037'),
('20240827145706'),
('20240808094927'),
('20240801000000'),
('20240719095729'),
('20240712080757'),
('20240711083454'),
('20240704093707'),
('20240703143657'),
('20240701155626'),
('20240701150709'),
('20240701075037'),
('20240628150306'),
('20240627152436'),
('20240626133711'),
('20240624201910'),
('20240620123704'),
('20240612074103'),
('20240606131313'),
('20240531101222'),
('20240531100023'),
('20240527081911'),
('20240526141500'),
('20240514132852'),
('20240513094706'),
('20240417085118'),
('20240417084757'),
('20240410120927'),
('20240410115028'),
('20240410114806'),
('20240410114637'),
('20240405101512'),
('20240405094938'),
('20240404071148'),
('20240403131643'),
('20240403131625'),
('20240403131231'),
('20240402150446'),
('20240326113043'),
('20240321160820'),
('20240321000000'),
('20240320170403'),
('20240316135712'),
('20240315100413'),
('20240315090504'),
('20240314133947'),
('20240314133856'),
('20240312165403'),
('20240311153638'),
('20240228155130'),
('20240221143107'),
('20240216100020'),
('20240205142849'),
('20240125102153'),
('20240111081028'),
('20231211143502'),
('20231211084232'),
('20231204104224'),
('20231130102047'),
('20231124105509'),
('20231104093416'),
('20231030141148'),
('20231019200634'),
('20231011094938'),
('20230915131604'),
('20230915094313'),
('20230828084430'),
('20230818072958'),
('20230816221101'),
('20230724113109'),
('20230712074733'),
('20230711161600'),
('20230707083923'),
('20230707082704'),
('20230703155408'),
('20230703102042'),
('20230703093100'),
('20230629141931'),
('20230628133149'),
('20230620115539'),
('20230616164423'),
('20230616143933'),
('20230616143729'),
('20230607115359'),
('20230607101323'),
('20230531094449'),
('20230517092159'),
('20230516193352'),
('20230516162131'),
('20230512082329'),
('20230511100934'),
('20230510145714'),
('20230502164246'),
('20230426161001'),
('20230420095232'),
('20230412082826'),
('20230404154158'),
('20230321104203'),
('20230307200802'),
('20230302162952'),
('20230223102039'),
('20221223100742'),
('20221219144134'),
('20221124170052'),
('20221123101159'),
('20221121103636'),
('20221119132335'),
('20221118075029'),
('20221118074333'),
('20221112100533'),
('20221104100047'),
('20221104091520'),
('20221031083556'),
('20221028100721'),
('20221026142333'),
('20221021094345'),
('20221013162104'),
('20221010071105'),
('20220816105807'),
('20220811103937'),
('20220804155217'),
('20220803143024'),
('20220803140408'),
('20220803131022'),
('20220726123520'),
('20220722081417'),
('20220711083028'),
('20220704132020'),
('20220626074601'),
('20220624092113'),
('20220621105148'),
('20220616131010'),
('20220603100433'),
('20220511152205'),
('20220511152204'),
('20220511152203'),
('20220408084653'),
('20220329131926'),
('20211228162749'),
('20211207163238'),
('20211110133150'),
('20211027130402'),
('20211026200850'),
('20211020160439'),
('20210910142500'),
('20210825150743'),
('20210825145759'),
('20210820140527'),
('20210708094334'),
('20210628172603'),
('20210622105914'),
('20210615113123'),
('20210604144318'),
('20210604095934'),
('20210602171315'),
('20210602142914'),
('20210601154254'),
('20210517145027'),
('20210506143015'),
('20210506142429'),
('20210430083329'),
('20210422145040'),
('20210408113406'),
('20210326100435'),
('20210310173554'),
('20210225164349'),
('20210224160904'),
('20210129121617'),
('20210128162938'),
('20210121172155'),
('20210121171025'),
('20210113140604'),
('20210112164129'),
('20201203153154'),
('20201116085327'),
('20201109145559'),
('20201106143850'),
('20201105143719'),
('20201104123113'),
('20201021131419'),
('20200930155341'),
('20200929081733'),
('20200928150637'),
('20200928145102'),
('20200928145005'),
('20200928143259'),
('20200928134336'),
('20200928122922'),
('20200928102905'),
('20200924093439'),
('20200923164419'),
('20200918165533'),
('20200911160718'),
('20200911153501'),
('20200911153500'),
('20200909134849'),
('20200909065612'),
('20200904083343'),
('20200902145712'),
('20200902143358'),
('20200805195040'),
('20200730144039'),
('20200729071625'),
('20200728094217'),
('20200722141350'),
('20200721150028'),
('20200721124215'),
('20200717134317'),
('20200715144451'),
('20200709135354'),
('20200709111802'),
('20200709111801'),
('20200709111800'),
('20200709110316'),
('20200709105933'),
('20200709081408'),
('20200708120719'),
('20200629133744'),
('20200627095219'),
('20200625154637'),
('20200622080019'),
('20200622074942'),
('20200620134004'),
('20200618141221'),
('20200615113918'),
('20200612075359'),
('20200605093223'),
('20200529045148'),
('20200526133956'),
('20200526133419'),
('20200520140800'),
('20200520140525'),
('20200429115934'),
('20200422123045'),
('20200421145109'),
('20200421142949'),
('20200409122859'),
('20200407142759'),
('20200402140231'),
('20200325143659'),
('20200325143658'),
('20200325143657'),
('20200322093818'),
('20200312131954'),
('20200227162157'),
('20200218163758'),
('20200210135720'),
('20200129085225'),
('20200122144920'),
('20200115164034'),
('20200114164236'),
('20200114164134'),
('20200114163210'),
('20200114163150'),
('20191212090431'),
('20191211145010'),
('20191127144843'),
('20191120184442'),
('20191120184441'),
('20191105104039'),
('20191105104038'),
('20191030141809'),
('20191015142231'),
('20191004151418'),
('20191004132428'),
('20190927140816'),
('20190926131324'),
('20190919131236'),
('20190918140641'),
('20190918101306'),
('20190911134144'),
('20190911132109'),
('20190911091821'),
('20190911091325'),
('20190909092332'),
('20190830082420'),
('20190830080035'),
('20190828130418'),
('20190828090307'),
('20190821200207'),
('20190821145025'),
('20190814152258'),
('20190814124142'),
('20190814075600'),
('20190807122943'),
('20190802163449'),
('20190802142452'),
('20190802140943'),
('20190802130601'),
('20190731084620'),
('20190627210748'),
('20190626093643'),
('20190615210642'),
('20190614130950'),
('20190606151156'),
('20190606145310'),
('20190606144929'),
('20190524153049'),
('20190524092527'),
('20190524091853'),
('20190524051545'),
('20190524051223'),
('20190523144837'),
('20190523072433'),
('20190522120310'),
('20190522083217'),
('20190518064711'),
('20190516145246'),
('20190509131202'),
('20190509125437'),
('20190426075049'),
('20190424115311'),
('20190424085503'),
('20190424085502'),
('20190419142003'),
('20190419082459'),
('20190417084501'),
('20190417084500'),
('20190412202203'),
('20190412143905'),
('20190412143018'),
('20190412140608'),
('20190412140509'),
('20190411151038'),
('20190405113421'),
('20190405113420'),
('20190405095801'),
('20190405081101'),
('20190404142124'),
('20190404133601'),
('20190404120942'),
('20190403155105'),
('20190403153507'),
('20190403104915'),
('20190403101319'),
('20190403101116'),
('20190402120207'),
('20190402083217'),
('20190402074125'),
('20190329142701'),
('20190329104358'),
('20190329003048'),
('20190329002736'),
('20190328235707'),
('20190328231657'),
('20190328190416'),
('20190324172606'),
('20190322092608'),
('20190321142430'),
('20190320180942'),
('20190320141522'),
('20190320105347'),
('20190319144452'),
('20190315164204'),
('20190315155431'),
('20190315134228'),
('20190313104908'),
('20190313093340'),
('20190308164116'),
('20190307102151'),
('20190307101119'),
('20190306110023'),
('20190306110022'),
('20190306105656'),
('20190306105437'),
('20190306095302'),
('20190305141531'),
('20190305103435'),
('20190301090235'),
('20190222170419'),
('20190222163308'),
('20190222105911'),
('20190222073540'),
('20190221092730'),
('20190221091804'),
('20190215094300'),
('20190215093600'),
('20190215091447'),
('20190215085241'),
('20190215085127'),
('20190212163331'),
('20190207111844');