--
-- PostgreSQL database dump
--

-- Dumped from database version 15.5
-- Dumped by pg_dump version 15.7 (Ubuntu 15.7-1.pgdg22.04+1)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: ht_db_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO ht_db_user;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: ht_db_user
--

COMMENT ON SCHEMA public IS '';


--
-- Name: enum_HT_FollowupStatusQuestionChoices_type; Type: TYPE; Schema: public; Owner: ht_db_user
--

CREATE TYPE public."enum_HT_FollowupStatusQuestionChoices_type" AS ENUM (
    'Positive Impact',
    'No Impact',
    'Made Worse',
    'Potential Positive Impact',
    'No Potential Impact',
    'Plan To Continue',
    'Dont Plan To Continue',
    'Will Start',
    'Will Not Start',
    'Have Replaced',
    'Will Replace',
    'Will Not Replace'
);


ALTER TYPE public."enum_HT_FollowupStatusQuestionChoices_type" OWNER TO ht_db_user;

--
-- Name: enum_HT_accounts_accessType; Type: TYPE; Schema: public; Owner: ht_db_user
--

CREATE TYPE public."enum_HT_accounts_accessType" AS ENUM (
    'THRIVE_SCALE',
    'FOSTER_SHARE',
    'BOTH'
);


ALTER TYPE public."enum_HT_accounts_accessType" OWNER TO ht_db_user;

--
-- Name: enum_HT_assessments_followUpStatus; Type: TYPE; Schema: public; Owner: ht_db_user
--

CREATE TYPE public."enum_HT_assessments_followUpStatus" AS ENUM (
    '',
    'Pending',
    'Completed'
);


ALTER TYPE public."enum_HT_assessments_followUpStatus" OWNER TO ht_db_user;

--
-- Name: enum_HT_childConsents_consentStatus; Type: TYPE; Schema: public; Owner: ht_db_user
--

CREATE TYPE public."enum_HT_childConsents_consentStatus" AS ENUM (
    'ACCEPTED',
    'DECLINED'
);


ALTER TYPE public."enum_HT_childConsents_consentStatus" OWNER TO ht_db_user;

--
-- Name: user_deactivation_triger(); Type: FUNCTION; Schema: public; Owner: ht_db_user
--

CREATE FUNCTION public.user_deactivation_triger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
		
		BEGIN
		IF NEW."isActive" <> OLD."isActive" THEN
			IF NEW."isActive" = false THEN
				UPDATE "HT_children"
				SET "HTChildOldPlacementStatusId" = "HTChildPlacementStatusId",
					"isActive" = false,
					"HTChildPlacementStatusId" = 6
				FROM "HT_cases"
				WHERE "HT_cases"."HTChildId" = "HT_children"."id"
					AND "HT_cases"."HTUserId" = OLD.id;

				UPDATE "HT_cases"
				SET "isActive" = false
				WHERE "HTUserId" = OLD.id;

			ELSE
				UPDATE "HT_children"
				SET "isActive" = true,
					"HTChildPlacementStatusId" = "HTChildOldPlacementStatusId",
					"HTChildOldPlacementStatusId" = null
				FROM "HT_cases"
				WHERE "HT_cases"."HTChildId" = "HT_children"."id"
					AND "HT_cases"."HTUserId" = OLD.id;

				UPDATE "HT_cases"
				SET "isActive" = true
				WHERE "HTUserId" = OLD.id;

				END IF;
				END IF;
				RETURN OLD;
			END;			


	

		$$;


ALTER FUNCTION public.user_deactivation_triger() OWNER TO ht_db_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: HT_FollowUpProgresses; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_FollowUpProgresses" (
    id bigint NOT NULL,
    "followupStatusDetail" character varying(255) DEFAULT ''::character varying,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTQuestionDomainId" bigint,
    "HTQuestionId" bigint,
    "HTChoiceId" bigint,
    "HTAssessmentId" bigint,
    "HTFollowUpStatusId" bigint NOT NULL,
    "HTFollowupStatusQuestionId" bigint NOT NULL,
    "HTFollowupStatusQuestionChoiceId" bigint NOT NULL
);


ALTER TABLE public."HT_FollowUpProgresses" OWNER TO ht_db_user;

--
-- Name: HT_FollowUpProgresses_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_FollowUpProgresses_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_FollowUpProgresses_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_FollowUpProgresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_FollowUpProgresses_id_seq" OWNED BY public."HT_FollowUpProgresses".id;


--
-- Name: HT_FollowUpStatuses; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_FollowUpStatuses" (
    id bigint NOT NULL,
    status character varying(255) DEFAULT ''::character varying,
    "helperText" character varying(255) DEFAULT ''::character varying,
    "isActive" boolean DEFAULT true,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."HT_FollowUpStatuses" OWNER TO ht_db_user;

--
-- Name: HT_FollowUpStatuses_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_FollowUpStatuses_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_FollowUpStatuses_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_FollowUpStatuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_FollowUpStatuses_id_seq" OWNED BY public."HT_FollowUpStatuses".id;


--
-- Name: HT_FollowupStatusQuestionChoices; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_FollowupStatusQuestionChoices" (
    id bigint NOT NULL,
    choice character varying(255) DEFAULT ''::character varying,
    "isActive" boolean DEFAULT true,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTFollowupStatusQuestionId" bigint,
    type text
);


ALTER TABLE public."HT_FollowupStatusQuestionChoices" OWNER TO ht_db_user;

--
-- Name: HT_FollowupStatusQuestionChoices_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_FollowupStatusQuestionChoices_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_FollowupStatusQuestionChoices_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_FollowupStatusQuestionChoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_FollowupStatusQuestionChoices_id_seq" OWNED BY public."HT_FollowupStatusQuestionChoices".id;


--
-- Name: HT_FollowupStatusQuestions; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_FollowupStatusQuestions" (
    id bigint NOT NULL,
    question character varying(255) DEFAULT ''::character varying,
    "isActive" boolean DEFAULT true,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTFollowUpStatusId" bigint
);


ALTER TABLE public."HT_FollowupStatusQuestions" OWNER TO ht_db_user;

--
-- Name: HT_FollowupStatusQuestions_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_FollowupStatusQuestions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_FollowupStatusQuestions_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_FollowupStatusQuestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_FollowupStatusQuestions_id_seq" OWNED BY public."HT_FollowupStatusQuestions".id;


--
-- Name: HT_IntegrationOptionLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_IntegrationOptionLangMaps" (
    id bigint NOT NULL,
    "integrationOption" text,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTIntegrationOptionId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_IntegrationOptionLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_IntegrationOptionLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_IntegrationOptionLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_IntegrationOptionLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_IntegrationOptionLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_IntegrationOptionLangMaps_id_seq" OWNED BY public."HT_IntegrationOptionLangMaps".id;


--
-- Name: HT_IntegrationOptions; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_IntegrationOptions" (
    id bigint NOT NULL,
    "integrationOption" character varying(255),
    "isRedFlag" boolean DEFAULT false,
    "isCaseCloseOption" boolean DEFAULT false,
    "isActive" boolean DEFAULT true,
    "order" integer NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTFormId" bigint,
    "integrationOptionLang" json
);


ALTER TABLE public."HT_IntegrationOptions" OWNER TO ht_db_user;

--
-- Name: HT_IntegrationOptions_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_IntegrationOptions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_IntegrationOptions_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_IntegrationOptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_IntegrationOptions_id_seq" OWNED BY public."HT_IntegrationOptions".id;


--
-- Name: HT_InterventionFollowUps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_InterventionFollowUps" (
    id bigint NOT NULL,
    "interventionChoiceIds" integer[] DEFAULT ARRAY[]::integer[],
    "interventionDetail" character varying(255) DEFAULT ''::character varying,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTAssessmentId" bigint NOT NULL,
    "HTQuestionDomainId" bigint NOT NULL,
    "HTQuestionId" bigint NOT NULL
);


ALTER TABLE public."HT_InterventionFollowUps" OWNER TO ht_db_user;

--
-- Name: HT_InterventionFollowUps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_InterventionFollowUps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_InterventionFollowUps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_InterventionFollowUps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_InterventionFollowUps_id_seq" OWNED BY public."HT_InterventionFollowUps".id;


--
-- Name: HT_UserSocketConnectionMappings; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_UserSocketConnectionMappings" (
    id bigint NOT NULL,
    "connectionId" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTUserId" text
);


ALTER TABLE public."HT_UserSocketConnectionMappings" OWNER TO ht_db_user;

--
-- Name: HT_UserSocketConnectionMappings_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_UserSocketConnectionMappings_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_UserSocketConnectionMappings_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_UserSocketConnectionMappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_UserSocketConnectionMappings_id_seq" OWNED BY public."HT_UserSocketConnectionMappings".id;


--
-- Name: HT_accountLinkings; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_accountLinkings" (
    id bigint NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "AccountId" text,
    "LinkedAccountId" text,
    "HTAccountId" text
);


ALTER TABLE public."HT_accountLinkings" OWNER TO ht_db_user;

--
-- Name: HT_accountLinkings_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_accountLinkings_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_accountLinkings_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_accountLinkings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_accountLinkings_id_seq" OWNED BY public."HT_accountLinkings".id;


--
-- Name: HT_accountTypes; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_accountTypes" (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "nameLang" json,
    "descriptionLang" json
);


ALTER TABLE public."HT_accountTypes" OWNER TO ht_db_user;

--
-- Name: HT_accounts; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_accounts" (
    id text NOT NULL,
    "accountName" character varying(1234) NOT NULL,
    "addressLine1" text NOT NULL,
    "addressLine2" text,
    "zipCode" character varying(255) NOT NULL,
    "phoneNumber" character varying(255),
    email character varying(255),
    city character varying(255) NOT NULL,
    website character varying(255),
    "isDCPUOrg" boolean DEFAULT false,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "injectiondocId" character varying(255),
    "dbRegion" character varying(255) NOT NULL,
    "consentRequired" boolean DEFAULT true,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTAccountTypeId" bigint,
    "HTCountryId" bigint,
    "HTStateId" bigint,
    "HTDistrictId" bigint,
    "accountCode" integer,
    "deactivationReason" text,
    "accessType" public."enum_HT_accounts_accessType"
);


ALTER TABLE public."HT_accounts" OWNER TO ht_db_user;

--
-- Name: HT_acntTypLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_acntTypLangMaps" (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTAccountTypeId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_acntTypLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_acntTypLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_acntTypLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_acntTypLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_acntTypLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_acntTypLangMaps_id_seq" OWNED BY public."HT_acntTypLangMaps".id;


--
-- Name: HT_answerTypes; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_answerTypes" (
    id bigint NOT NULL,
    "typeName" character varying(255) NOT NULL,
    description text,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."HT_answerTypes" OWNER TO ht_db_user;

--
-- Name: HT_answerTypes_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_answerTypes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_answerTypes_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_answerTypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_answerTypes_id_seq" OWNED BY public."HT_answerTypes".id;


--
-- Name: HT_assessmentImages; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_assessmentImages" (
    id bigint NOT NULL,
    "s3BucketName" character varying(255) NOT NULL,
    "objectKey" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTAssessmentId" bigint
);


ALTER TABLE public."HT_assessmentImages" OWNER TO ht_db_user;

--
-- Name: HT_assessmentImages_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_assessmentImages_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_assessmentImages_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_assessmentImages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_assessmentImages_id_seq" OWNED BY public."HT_assessmentImages".id;


--
-- Name: HT_assessmentIntegrationOptionMappings; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_assessmentIntegrationOptionMappings" (
    id bigint NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTAssessmentId" bigint,
    "HTIntegrationOptionId" bigint
);


ALTER TABLE public."HT_assessmentIntegrationOptionMappings" OWNER TO ht_db_user;

--
-- Name: HT_assessmentIntegrationOptionMappings_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_assessmentIntegrationOptionMappings_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_assessmentIntegrationOptionMappings_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_assessmentIntegrationOptionMappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_assessmentIntegrationOptionMappings_id_seq" OWNED BY public."HT_assessmentIntegrationOptionMappings".id;


--
-- Name: HT_assessmentInterventionTextResponses; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_assessmentInterventionTextResponses" (
    id bigint NOT NULL,
    "interventionDetails" text,
    "otherDetails" text,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTQuestionId" bigint,
    "HTAssessmentId" bigint
);


ALTER TABLE public."HT_assessmentInterventionTextResponses" OWNER TO ht_db_user;

--
-- Name: HT_assessmentInterventionTextResponses_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_assessmentInterventionTextResponses_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_assessmentInterventionTextResponses_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_assessmentInterventionTextResponses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_assessmentInterventionTextResponses_id_seq" OWNED BY public."HT_assessmentInterventionTextResponses".id;


--
-- Name: HT_assessmentReintegrationTypes; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_assessmentReintegrationTypes" (
    id bigint NOT NULL,
    "reIntegrationType" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "reIntegrationTypeLang" json
);


ALTER TABLE public."HT_assessmentReintegrationTypes" OWNER TO ht_db_user;

--
-- Name: HT_assessmentReintegrationTypes_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_assessmentReintegrationTypes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_assessmentReintegrationTypes_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_assessmentReintegrationTypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_assessmentReintegrationTypes_id_seq" OWNED BY public."HT_assessmentReintegrationTypes".id;


--
-- Name: HT_assessmentScores; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_assessmentScores" (
    id bigint NOT NULL,
    score numeric,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTAssessmentId" bigint,
    "HTQuestionDomainId" bigint
);


ALTER TABLE public."HT_assessmentScores" OWNER TO ht_db_user;

--
-- Name: HT_assessmentScores_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_assessmentScores_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_assessmentScores_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_assessmentScores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_assessmentScores_id_seq" OWNED BY public."HT_assessmentScores".id;


--
-- Name: HT_assessmentVisitTypes; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_assessmentVisitTypes" (
    id bigint NOT NULL,
    "visitType" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "visitTypeLang" json
);


ALTER TABLE public."HT_assessmentVisitTypes" OWNER TO ht_db_user;

--
-- Name: HT_assessmentVisitTypes_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_assessmentVisitTypes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_assessmentVisitTypes_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_assessmentVisitTypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_assessmentVisitTypes_id_seq" OWNED BY public."HT_assessmentVisitTypes".id;


--
-- Name: HT_assessments; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_assessments" (
    id bigint NOT NULL,
    "meetWithChild" boolean DEFAULT false,
    "dateOfAssessment" timestamp with time zone NOT NULL,
    "isComplete" boolean DEFAULT false,
    "formRevisionNumber" integer,
    "otherReIntegrationTypeValue" character varying(255),
    "currentPagePosition" integer,
    "lastIndex" integer,
    "placementThoughtsOfChild" text,
    "placementThoughtsOfFamily" text,
    "otherData" text,
    "specifyReason" text,
    "overallObservation" text,
    "totalScore" numeric,
    "schedulingOption" character varying(255),
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "assessmentStartsAt" timestamp with time zone,
    "assessmentEndsAt" timestamp with time zone,
    "isOffline" boolean,
    "deviceType" character varying(255) DEFAULT 'UNKNOWN'::character varying,
    "followUpRequired" boolean DEFAULT false,
    "followUpStatus" public."enum_HT_assessments_followUpStatus" DEFAULT ''::public."enum_HT_assessments_followUpStatus",
    "followUpStartedOn" timestamp with time zone,
    "followUpCompletedOn" timestamp with time zone,
    "interventionFollowupStep" integer DEFAULT 0,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTFormId" bigint,
    "HTCaseId" bigint,
    "HTAssessmentVisitTypeId" bigint,
    "HTAssessmentReintegrationTypeId" bigint
);


ALTER TABLE public."HT_assessments" OWNER TO ht_db_user;

--
-- Name: HT_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_assessments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_assessments_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_assessments_id_seq" OWNED BY public."HT_assessments".id;


--
-- Name: HT_assmntReintegrationTypeLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_assmntReintegrationTypeLangMaps" (
    id bigint NOT NULL,
    "reIntegrationType" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTAssessmentReintegrationTypeId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_assmntReintegrationTypeLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_assmntReintegrationTypeLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_assmntReintegrationTypeLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_assmntReintegrationTypeLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_assmntReintegrationTypeLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_assmntReintegrationTypeLangMaps_id_seq" OWNED BY public."HT_assmntReintegrationTypeLangMaps".id;


--
-- Name: HT_assmntVisitTypeLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_assmntVisitTypeLangMaps" (
    id bigint NOT NULL,
    "visitType" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTAssessmentVisitTypeId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_assmntVisitTypeLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_assmntVisitTypeLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_assmntVisitTypeLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_assmntVisitTypeLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_assmntVisitTypeLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_assmntVisitTypeLangMaps_id_seq" OWNED BY public."HT_assmntVisitTypeLangMaps".id;


--
-- Name: HT_auditLogs; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_auditLogs" (
    id bigint NOT NULL,
    entity text NOT NULL,
    oldvalue character varying(255),
    newvalue character varying(255),
    "updateGroupId" character varying(255),
    "moduleType" character varying(255),
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTChildId" bigint,
    "HTCaseId" bigint,
    "HTFamilyId" bigint,
    "HTFamilyMemberId" bigint,
    "HTUserId" text,
    "HTAccountId" text,
    "HTAssessmentId" bigint,
    "updatedUserId" text
);


ALTER TABLE public."HT_auditLogs" OWNER TO ht_db_user;

--
-- Name: HT_auditLogs_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_auditLogs_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_auditLogs_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_auditLogs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_auditLogs_id_seq" OWNED BY public."HT_auditLogs".id;


--
-- Name: HT_cases; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_cases" (
    id bigint NOT NULL,
    "startDate" timestamp with time zone,
    "endDate" timestamp with time zone,
    "caseStatus" character varying(255) DEFAULT 'Open'::character varying,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTChildId" bigint,
    "HTUserId" text
);


ALTER TABLE public."HT_cases" OWNER TO ht_db_user;

--
-- Name: HT_cases_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_cases_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_cases_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_cases_id_seq" OWNED BY public."HT_cases".id;


--
-- Name: HT_childCareGiverMappings; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_childCareGiverMappings" (
    id bigint NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTFamilyMemberId" bigint,
    "HTChildId" bigint
);


ALTER TABLE public."HT_childCareGiverMappings" OWNER TO ht_db_user;

--
-- Name: HT_childCareGiverMappings_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_childCareGiverMappings_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_childCareGiverMappings_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_childCareGiverMappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_childCareGiverMappings_id_seq" OWNED BY public."HT_childCareGiverMappings".id;


--
-- Name: HT_childConsentLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_childConsentLangMaps" (
    id bigint NOT NULL,
    "consentLanguageText" text NOT NULL,
    "consentLanguageStatus" boolean NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_childConsentLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_childConsentLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_childConsentLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_childConsentLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_childConsentLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_childConsentLangMaps_id_seq" OWNED BY public."HT_childConsentLangMaps".id;


--
-- Name: HT_childConsents; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_childConsents" (
    id bigint NOT NULL,
    "primaryCareGiver" text NOT NULL,
    "consentStatus" public."enum_HT_childConsents_consentStatus" NOT NULL,
    "dateOfEntry" timestamp with time zone NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTFamilyRelationId" bigint,
    "HTChildId" bigint,
    "HTUserId" text
);


ALTER TABLE public."HT_childConsents" OWNER TO ht_db_user;

--
-- Name: HT_childConsents_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_childConsents_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_childConsents_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_childConsents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_childConsents_id_seq" OWNED BY public."HT_childConsents".id;


--
-- Name: HT_childCurrentPlacementStatuses; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_childCurrentPlacementStatuses" (
    id bigint NOT NULL,
    "currentPlacementStatus" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "currentPlacementStatusLang" json
);


ALTER TABLE public."HT_childCurrentPlacementStatuses" OWNER TO ht_db_user;

--
-- Name: HT_childCurrentPlacementStatuses_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_childCurrentPlacementStatuses_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_childCurrentPlacementStatuses_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_childCurrentPlacementStatuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_childCurrentPlacementStatuses_id_seq" OWNED BY public."HT_childCurrentPlacementStatuses".id;


--
-- Name: HT_childEducationLevels; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_childEducationLevels" (
    id bigint NOT NULL,
    "educationLevel" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "educationLevelLang" json
);


ALTER TABLE public."HT_childEducationLevels" OWNER TO ht_db_user;

--
-- Name: HT_childEducationLevels_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_childEducationLevels_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_childEducationLevels_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_childEducationLevels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_childEducationLevels_id_seq" OWNED BY public."HT_childEducationLevels".id;


--
-- Name: HT_childHistories; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_childHistories" (
    id bigint NOT NULL,
    "fromDate" timestamp with time zone NOT NULL,
    "toDate" timestamp with time zone NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTChildId" bigint,
    "HTFamilyId" bigint,
    "HTFamilyMemberId" bigint
);


ALTER TABLE public."HT_childHistories" OWNER TO ht_db_user;

--
-- Name: HT_childHistories_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_childHistories_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_childHistories_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_childHistories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_childHistories_id_seq" OWNED BY public."HT_childHistories".id;


--
-- Name: HT_childPlacementStatuses; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_childPlacementStatuses" (
    id bigint NOT NULL,
    "placementStatus" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "placementStatusLang" json
);


ALTER TABLE public."HT_childPlacementStatuses" OWNER TO ht_db_user;

--
-- Name: HT_childPlacementStatuses_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_childPlacementStatuses_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_childPlacementStatuses_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_childPlacementStatuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_childPlacementStatuses_id_seq" OWNED BY public."HT_childPlacementStatuses".id;


--
-- Name: HT_childStatuses; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_childStatuses" (
    id bigint NOT NULL,
    status character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "statusLang" json
);


ALTER TABLE public."HT_childStatuses" OWNER TO ht_db_user;

--
-- Name: HT_childStatuses_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_childStatuses_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_childStatuses_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_childStatuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_childStatuses_id_seq" OWNED BY public."HT_childStatuses".id;


--
-- Name: HT_children; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_children" (
    id bigint NOT NULL,
    "firstName" character varying(255) NOT NULL,
    "lastName" character varying(255),
    "addressLine1" text,
    "addressLine2" text,
    "zipCode" character varying(255),
    city character varying(255),
    "highestEducationLevel" character varying(255),
    "birthDate" timestamp with time zone NOT NULL,
    "dateOfEntry" timestamp with time zone,
    "dateOfExit" timestamp with time zone,
    gender character varying(255) NOT NULL,
    "phoneNumber" character varying(255),
    email character varying(255),
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "injectiondocId" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTFamilyId" bigint,
    "HTAccountId" text,
    "HTLanguageId" bigint,
    "HTChildEducationLevelId" bigint,
    "HTCountryId" bigint,
    "HTStateId" bigint,
    "HTDistrictId" bigint,
    "HTChildPlacementStatusId" bigint,
    "HTChildStatusId" bigint,
    "HTChildCurrentPlacementStatusId" bigint,
    "HTChildOldPlacementStatusId" bigint
);


ALTER TABLE public."HT_children" OWNER TO ht_db_user;

--
-- Name: HT_children_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_children_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_children_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_children_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_children_id_seq" OWNED BY public."HT_children".id;


--
-- Name: HT_chldCurntPlmtStsLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_chldCurntPlmtStsLangMaps" (
    id bigint NOT NULL,
    "currentPlacementStatus" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTChildCurrentPlacementStatusId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_chldCurntPlmtStsLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_chldCurntPlmtStsLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_chldCurntPlmtStsLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_chldCurntPlmtStsLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_chldCurntPlmtStsLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_chldCurntPlmtStsLangMaps_id_seq" OWNED BY public."HT_chldCurntPlmtStsLangMaps".id;


--
-- Name: HT_chldEdnLvlLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_chldEdnLvlLangMaps" (
    id bigint NOT NULL,
    "educationLevel" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTChildEducationLevelId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_chldEdnLvlLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_chldEdnLvlLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_chldEdnLvlLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_chldEdnLvlLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_chldEdnLvlLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_chldEdnLvlLangMaps_id_seq" OWNED BY public."HT_chldEdnLvlLangMaps".id;


--
-- Name: HT_chldPlmtStsLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_chldPlmtStsLangMaps" (
    id bigint NOT NULL,
    "placementStatus" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTChildPlacementStatusId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_chldPlmtStsLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_chldPlmtStsLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_chldPlmtStsLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_chldPlmtStsLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_chldPlmtStsLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_chldPlmtStsLangMaps_id_seq" OWNED BY public."HT_chldPlmtStsLangMaps".id;


--
-- Name: HT_chldStsLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_chldStsLangMaps" (
    id bigint NOT NULL,
    status character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTChildStatusId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_chldStsLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_chldStsLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_chldStsLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_chldStsLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_chldStsLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_chldStsLangMaps_id_seq" OWNED BY public."HT_chldStsLangMaps".id;


--
-- Name: HT_choiceLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_choiceLangMaps" (
    id bigint NOT NULL,
    "choiceName" text NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTChoiceId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_choiceLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_choiceLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_choiceLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_choiceLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_choiceLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_choiceLangMaps_id_seq" OWNED BY public."HT_choiceLangMaps".id;


--
-- Name: HT_choices; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_choices" (
    id bigint NOT NULL,
    "choiceName" text NOT NULL,
    score integer,
    "isIntervention" boolean DEFAULT false,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTQuestionTypeId" bigint,
    "HTQuestionDomainId" bigint,
    "HTQuestionId" bigint,
    "choiceNameLang" json
);


ALTER TABLE public."HT_choices" OWNER TO ht_db_user;

--
-- Name: HT_choices_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_choices_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_choices_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_choices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_choices_id_seq" OWNED BY public."HT_choices".id;


--
-- Name: HT_countries; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_countries" (
    id bigint NOT NULL,
    "countryName" character varying(1234) NOT NULL,
    "isoCode" character varying(1234) NOT NULL,
    "countryCode" character varying(1234) NOT NULL,
    "phoneNumberFormat" character varying(1234) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "districtRequired" boolean,
    "stateRequired" boolean,
    "iso2Code" character varying(1234),
    "countryNameLang" json
);


ALTER TABLE public."HT_countries" OWNER TO ht_db_user;

--
-- Name: HT_countryLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_countryLangMaps" (
    id bigint NOT NULL,
    "countryName" character varying(1234) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTCountryId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_countryLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_countryLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_countryLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_countryLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_countryLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_countryLangMaps_id_seq" OWNED BY public."HT_countryLangMaps".id;


--
-- Name: HT_deviceDetails; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_deviceDetails" (
    id bigint NOT NULL,
    token character varying(255),
    platform character varying(255),
    model character varying(255),
    "osVersion" character varying(255),
    "endpointARN" character varying(255),
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTUserId" text
);


ALTER TABLE public."HT_deviceDetails" OWNER TO ht_db_user;

--
-- Name: HT_deviceDetails_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_deviceDetails_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_deviceDetails_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_deviceDetails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_deviceDetails_id_seq" OWNED BY public."HT_deviceDetails".id;


--
-- Name: HT_districtLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_districtLangMaps" (
    id bigint NOT NULL,
    "districtName" character varying(1234) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTDistrictId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_districtLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_districtLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_districtLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_districtLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_districtLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_districtLangMaps_id_seq" OWNED BY public."HT_districtLangMaps".id;


--
-- Name: HT_districts; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_districts" (
    id bigint NOT NULL,
    "districtName" character varying(1234) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTStateId" bigint,
    "districtNameLang" json,
    "MPCountryId" bigint
);


ALTER TABLE public."HT_districts" OWNER TO ht_db_user;

--
-- Name: HT_events; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_events" (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    description character varying(255),
    "recurringEventName" character varying(255),
    "startDate" timestamp with time zone NOT NULL,
    "endDate" timestamp with time zone NOT NULL,
    "recurrenceEndDate" timestamp with time zone,
    "isComplete" boolean DEFAULT false,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTChildId" bigint,
    "HTUserId" text,
    "HTEventId" bigint
);


ALTER TABLE public."HT_events" OWNER TO ht_db_user;

--
-- Name: HT_events_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_events_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_events_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_events_id_seq" OWNED BY public."HT_events".id;


--
-- Name: HT_families; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_families" (
    id bigint NOT NULL,
    "familyName" character varying(255),
    "addressLine1" text NOT NULL,
    "addressLine2" text,
    city character varying(255) NOT NULL,
    "zipCode" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "injectiondocId" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTCountryId" bigint,
    "HTStateId" bigint,
    "HTDistrictId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_families" OWNER TO ht_db_user;

--
-- Name: HT_families_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_families_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_families_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_families_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_families_id_seq" OWNED BY public."HT_families".id;


--
-- Name: HT_familyMemTypeLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_familyMemTypeLangMaps" (
    id bigint NOT NULL,
    "memberType" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTFamilyMemberTypeId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_familyMemTypeLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_familyMemTypeLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_familyMemTypeLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_familyMemTypeLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_familyMemTypeLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_familyMemTypeLangMaps_id_seq" OWNED BY public."HT_familyMemTypeLangMaps".id;


--
-- Name: HT_familyMemberTypes; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_familyMemberTypes" (
    id bigint NOT NULL,
    "memberType" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "memberTypeLang" json
);


ALTER TABLE public."HT_familyMemberTypes" OWNER TO ht_db_user;

--
-- Name: HT_familyMemberTypes_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_familyMemberTypes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_familyMemberTypes_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_familyMemberTypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_familyMemberTypes_id_seq" OWNED BY public."HT_familyMemberTypes".id;


--
-- Name: HT_familyMembers; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_familyMembers" (
    id bigint NOT NULL,
    "firstName" character varying(255) NOT NULL,
    "lastName" character varying(255),
    occupation character varying(255),
    "phoneNumber" character varying(255),
    email character varying(255),
    "isPrimaryCareGiver" boolean DEFAULT false,
    "otherRelation" text,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTFamilyId" bigint,
    "HTFamilyMemberTypeId" bigint,
    "HTFamilyRelationId" bigint
);


ALTER TABLE public."HT_familyMembers" OWNER TO ht_db_user;

--
-- Name: HT_familyMembers_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_familyMembers_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_familyMembers_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_familyMembers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_familyMembers_id_seq" OWNED BY public."HT_familyMembers".id;


--
-- Name: HT_familyRelanLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_familyRelanLangMaps" (
    id bigint NOT NULL,
    relation character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTFamilyRelationId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_familyRelanLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_familyRelanLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_familyRelanLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_familyRelanLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_familyRelanLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_familyRelanLangMaps_id_seq" OWNED BY public."HT_familyRelanLangMaps".id;


--
-- Name: HT_familyRelations; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_familyRelations" (
    id bigint NOT NULL,
    relation character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "relationLang" json
);


ALTER TABLE public."HT_familyRelations" OWNER TO ht_db_user;

--
-- Name: HT_familyRelations_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_familyRelations_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_familyRelations_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_familyRelations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_familyRelations_id_seq" OWNED BY public."HT_familyRelations".id;


--
-- Name: HT_fileUploadMappings; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_fileUploadMappings" (
    id bigint NOT NULL,
    "originalFileName" character varying(255),
    "customFileName" character varying(255),
    "moduleType" character varying(255),
    "documentType" character varying(255),
    "filePath" character varying(255),
    "fileUrl" character varying(255),
    "fileStatus" character varying(255) DEFAULT 'Created'::character varying,
    "fileSize" character varying(255) DEFAULT '0'::character varying,
    description character varying(255),
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTChildId" bigint,
    "HTAccountId" text,
    "HTUserId" text
);


ALTER TABLE public."HT_fileUploadMappings" OWNER TO ht_db_user;

--
-- Name: HT_fileUploadMappings_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_fileUploadMappings_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_fileUploadMappings_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_fileUploadMappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_fileUploadMappings_id_seq" OWNED BY public."HT_fileUploadMappings".id;


--
-- Name: HT_formQuestionMappings; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_formQuestionMappings" (
    id bigint NOT NULL,
    "order" integer NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTQuestionId" bigint,
    "HTFormId" bigint
);


ALTER TABLE public."HT_formQuestionMappings" OWNER TO ht_db_user;

--
-- Name: HT_formQuestionMappings_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_formQuestionMappings_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_formQuestionMappings_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_formQuestionMappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_formQuestionMappings_id_seq" OWNED BY public."HT_formQuestionMappings".id;


--
-- Name: HT_formRevisions; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_formRevisions" (
    id bigint NOT NULL,
    "order" integer NOT NULL,
    "revisionNumber" integer NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTFormId" bigint,
    "HTQuestionId" bigint
);


ALTER TABLE public."HT_formRevisions" OWNER TO ht_db_user;

--
-- Name: HT_formRevisions_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_formRevisions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_formRevisions_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_formRevisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_formRevisions_id_seq" OWNED BY public."HT_formRevisions".id;


--
-- Name: HT_forms; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_forms" (
    id bigint NOT NULL,
    "formName" character varying(255) NOT NULL,
    description text,
    "currentRevision" integer DEFAULT 0,
    "isDraft" boolean DEFAULT false,
    "isPublished" boolean DEFAULT false,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTAccountId" text
);


ALTER TABLE public."HT_forms" OWNER TO ht_db_user;

--
-- Name: HT_forms_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_forms_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_forms_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_forms_id_seq" OWNED BY public."HT_forms".id;


--
-- Name: HT_importLogs; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_importLogs" (
    id bigint NOT NULL,
    "moduleType" character varying(255),
    data text,
    error text,
    "errorType" character varying(255),
    "entityId" character varying(255),
    "injectiondocId" character varying(255),
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."HT_importLogs" OWNER TO ht_db_user;

--
-- Name: HT_importLogs_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_importLogs_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_importLogs_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_importLogs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_importLogs_id_seq" OWNED BY public."HT_importLogs".id;


--
-- Name: HT_importMappings; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_importMappings" (
    id bigint NOT NULL,
    "originalFileName" character varying(255),
    "customFileName" character varying(255),
    "moduleType" character varying(255),
    "documentType" character varying(255) DEFAULT 'csv'::character varying,
    "filePath" character varying(255),
    "fileUrl" character varying(255),
    "fileStatus" character varying(255) DEFAULT 'Created'::character varying,
    "importStatus" character varying(255) DEFAULT 'Import_Not_Started'::character varying,
    "fileSize" character varying(255) DEFAULT '0'::character varying,
    description character varying(255),
    "dataCount" character varying(255) DEFAULT '0'::character varying,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."HT_importMappings" OWNER TO ht_db_user;

--
-- Name: HT_importMappings_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_importMappings_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_importMappings_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_importMappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_importMappings_id_seq" OWNED BY public."HT_importMappings".id;


--
-- Name: HT_langMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_langMaps" (
    id bigint NOT NULL,
    language text NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTLanguageId" bigint,
    "LanguageRefIdId" bigint
);


ALTER TABLE public."HT_langMaps" OWNER TO ht_db_user;

--
-- Name: HT_langMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_langMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_langMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_langMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_langMaps_id_seq" OWNED BY public."HT_langMaps".id;


--
-- Name: HT_languages; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_languages" (
    id bigint NOT NULL,
    language character varying(1234) NOT NULL,
    "langCode" character varying(1234),
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."HT_languages" OWNER TO ht_db_user;

--
-- Name: HT_logExports; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_logExports" (
    id bigint NOT NULL,
    "s3BucketName" text,
    location text,
    "creationTime" bigint,
    "logTaskId" text,
    "logGroupName" text,
    "logName" text,
    "fromTimestamp" bigint,
    "toTimestamp" bigint,
    "completionTime" bigint,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."HT_logExports" OWNER TO ht_db_user;

--
-- Name: HT_logExports_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_logExports_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_logExports_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_logExports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_logExports_id_seq" OWNED BY public."HT_logExports".id;


--
-- Name: HT_notifLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_notifLangMaps" (
    id bigint NOT NULL,
    title character varying(255),
    body character varying(255),
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTNotificationId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_notifLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_notifLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_notifLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_notifLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_notifLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_notifLangMaps_id_seq" OWNED BY public."HT_notifLangMaps".id;


--
-- Name: HT_notifications; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_notifications" (
    id bigint NOT NULL,
    "readStatus" boolean DEFAULT false,
    title character varying(255),
    body character varying(255),
    module character varying(255),
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTNotifnEventTypeId" bigint,
    "SenderIdId" text,
    "RecieverIdId" text,
    "HTUserId" text,
    "HTChildId" bigint,
    "HTCaseId" bigint,
    "HTFamilyId" bigint
);


ALTER TABLE public."HT_notifications" OWNER TO ht_db_user;

--
-- Name: HT_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_notifications_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_notifications_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_notifications_id_seq" OWNED BY public."HT_notifications".id;


--
-- Name: HT_notifnEventTypes; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_notifnEventTypes" (
    id bigint NOT NULL,
    "eventType" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."HT_notifnEventTypes" OWNER TO ht_db_user;

--
-- Name: HT_notifnEventTypes_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_notifnEventTypes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_notifnEventTypes_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_notifnEventTypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_notifnEventTypes_id_seq" OWNED BY public."HT_notifnEventTypes".id;


--
-- Name: HT_questionDomains; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_questionDomains" (
    id bigint NOT NULL,
    "domainName" character varying(255) NOT NULL,
    description text,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "domainNameLang" json
);


ALTER TABLE public."HT_questionDomains" OWNER TO ht_db_user;

--
-- Name: HT_questionDomains_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_questionDomains_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_questionDomains_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_questionDomains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_questionDomains_id_seq" OWNED BY public."HT_questionDomains".id;


--
-- Name: HT_questionLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_questionLangMaps" (
    id bigint NOT NULL,
    "questionText" text NOT NULL,
    "questionHelpText" text,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTQuestionId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_questionLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_questionLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_questionLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_questionLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_questionLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_questionLangMaps_id_seq" OWNED BY public."HT_questionLangMaps".id;


--
-- Name: HT_questionTypes; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_questionTypes" (
    id bigint NOT NULL,
    "typeName" character varying(255) NOT NULL,
    description text,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."HT_questionTypes" OWNER TO ht_db_user;

--
-- Name: HT_questionTypes_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_questionTypes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_questionTypes_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_questionTypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_questionTypes_id_seq" OWNED BY public."HT_questionTypes".id;


--
-- Name: HT_questions; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_questions" (
    id bigint NOT NULL,
    "questionText" text NOT NULL,
    "questionHelpText" text,
    "isRedFlag" boolean DEFAULT false,
    "isFosterCareFlag" boolean DEFAULT false,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTAccountId" text,
    "HTQuestionDomainId" bigint,
    "HTQuestionTypeId" bigint,
    "HTAnswerTypeId" bigint,
    "HTQuestionId" bigint
);


ALTER TABLE public."HT_questions" OWNER TO ht_db_user;

--
-- Name: HT_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_questions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_questions_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_questions_id_seq" OWNED BY public."HT_questions".id;


--
-- Name: HT_qusnDomainLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_qusnDomainLangMaps" (
    id bigint NOT NULL,
    "domainName" character varying(255) NOT NULL,
    description text,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTQuestionDomainId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_qusnDomainLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_qusnDomainLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_qusnDomainLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_qusnDomainLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_qusnDomainLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_qusnDomainLangMaps_id_seq" OWNED BY public."HT_qusnDomainLangMaps".id;


--
-- Name: HT_recurringEvents; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_recurringEvents" (
    id bigint NOT NULL,
    "startDate" timestamp with time zone NOT NULL,
    "endDate" timestamp with time zone NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."HT_recurringEvents" OWNER TO ht_db_user;

--
-- Name: HT_recurringEvents_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_recurringEvents_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_recurringEvents_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_recurringEvents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_recurringEvents_id_seq" OWNED BY public."HT_recurringEvents".id;


--
-- Name: HT_responses; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_responses" (
    id bigint NOT NULL,
    "textResponse" text,
    "otherResponse" text,
    "isInterResp" boolean DEFAULT false,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTAssessmentId" bigint,
    "HTQuestionId" bigint,
    "HTChoiceId" bigint
);


ALTER TABLE public."HT_responses" OWNER TO ht_db_user;

--
-- Name: HT_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_responses_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_responses_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_responses_id_seq" OWNED BY public."HT_responses".id;


--
-- Name: HT_stateLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_stateLangMaps" (
    id bigint NOT NULL,
    "stateName" character varying(1234) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTStateId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_stateLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_stateLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_stateLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_stateLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_stateLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_stateLangMaps_id_seq" OWNED BY public."HT_stateLangMaps".id;


--
-- Name: HT_states; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_states" (
    id bigint NOT NULL,
    "stateName" character varying(1234) NOT NULL,
    "stateCode" character varying(1234),
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTCountryId" bigint,
    "stateNameLang" json
);


ALTER TABLE public."HT_states" OWNER TO ht_db_user;

--
-- Name: HT_userLogs; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_userLogs" (
    id bigint NOT NULL,
    entity character varying(255) NOT NULL,
    action character varying(255) NOT NULL,
    parameters text,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTUserId" text
);


ALTER TABLE public."HT_userLogs" OWNER TO ht_db_user;

--
-- Name: HT_userLogs_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_userLogs_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_userLogs_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_userLogs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_userLogs_id_seq" OWNED BY public."HT_userLogs".id;


--
-- Name: HT_userRoleLangMaps; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_userRoleLangMaps" (
    id bigint NOT NULL,
    role character varying(1234) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTUserRoleId" bigint,
    "HTLanguageId" bigint
);


ALTER TABLE public."HT_userRoleLangMaps" OWNER TO ht_db_user;

--
-- Name: HT_userRoleLangMaps_id_seq; Type: SEQUENCE; Schema: public; Owner: ht_db_user
--

CREATE SEQUENCE public."HT_userRoleLangMaps_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."HT_userRoleLangMaps_id_seq" OWNER TO ht_db_user;

--
-- Name: HT_userRoleLangMaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ht_db_user
--

ALTER SEQUENCE public."HT_userRoleLangMaps_id_seq" OWNED BY public."HT_userRoleLangMaps".id;


--
-- Name: HT_userRoles; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_userRoles" (
    id bigint NOT NULL,
    role character varying(1234) NOT NULL,
    description character varying(1234),
    "cognitoValue" character varying(1234) NOT NULL,
    "isActive" boolean DEFAULT true,
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "roleLang" json,
    "descriptionLang" json
);


ALTER TABLE public."HT_userRoles" OWNER TO ht_db_user;

--
-- Name: HT_users; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public."HT_users" (
    id text NOT NULL,
    "cognitoId" text,
    "oldCognitoId" text,
    "firstName" character varying(1234) NOT NULL,
    "lastName" character varying(1234) NOT NULL,
    "phoneNumber" character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    "addressLine1" text NOT NULL,
    "addressLine2" text,
    city character varying(255) NOT NULL,
    "zipCode" character varying(255) NOT NULL,
    "isActive" boolean DEFAULT false,
    "isDeleted" boolean DEFAULT false,
    "createdBy" uuid,
    "updatedBy" uuid,
    "injectiondocId" character varying(255),
    "dbRegion" character varying(255) NOT NULL,
    "HTUserRoleId" bigint,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "HTCountryId" bigint,
    "HTStateId" bigint,
    "HTDistrictId" bigint,
    "HTAccountId" text,
    "HTLanguageId" bigint,
    occupation text,
    "parentUserId" text,
    "userCode" integer,
    "userTimezone" character varying(255),
    "caseManagerId" text,
    image text,
    "fileStatus" character varying(255),
    "deactivationReason" text,
    "isAccountActive" boolean
);


ALTER TABLE public."HT_users" OWNER TO ht_db_user;

--
-- Name: awsdms_apply_exceptions; Type: TABLE; Schema: public; Owner: ht_db_user
--

CREATE TABLE public.awsdms_apply_exceptions (
    "TASK_NAME" character varying(128) NOT NULL,
    "TABLE_OWNER" character varying(128) NOT NULL,
    "TABLE_NAME" character varying(128) NOT NULL,
    "ERROR_TIME" timestamp without time zone NOT NULL,
    "STATEMENT" text NOT NULL,
    "ERROR" text NOT NULL
);


ALTER TABLE public.awsdms_apply_exceptions OWNER TO ht_db_user;

--
-- Name: HT_FollowUpProgresses id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowUpProgresses" ALTER COLUMN id SET DEFAULT nextval('public."HT_FollowUpProgresses_id_seq"'::regclass);


--
-- Name: HT_FollowUpStatuses id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowUpStatuses" ALTER COLUMN id SET DEFAULT nextval('public."HT_FollowUpStatuses_id_seq"'::regclass);


--
-- Name: HT_FollowupStatusQuestionChoices id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowupStatusQuestionChoices" ALTER COLUMN id SET DEFAULT nextval('public."HT_FollowupStatusQuestionChoices_id_seq"'::regclass);


--
-- Name: HT_FollowupStatusQuestions id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowupStatusQuestions" ALTER COLUMN id SET DEFAULT nextval('public."HT_FollowupStatusQuestions_id_seq"'::regclass);


--
-- Name: HT_IntegrationOptionLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_IntegrationOptionLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_IntegrationOptionLangMaps_id_seq"'::regclass);


--
-- Name: HT_IntegrationOptions id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_IntegrationOptions" ALTER COLUMN id SET DEFAULT nextval('public."HT_IntegrationOptions_id_seq"'::regclass);


--
-- Name: HT_InterventionFollowUps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_InterventionFollowUps" ALTER COLUMN id SET DEFAULT nextval('public."HT_InterventionFollowUps_id_seq"'::regclass);


--
-- Name: HT_UserSocketConnectionMappings id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_UserSocketConnectionMappings" ALTER COLUMN id SET DEFAULT nextval('public."HT_UserSocketConnectionMappings_id_seq"'::regclass);


--
-- Name: HT_accountLinkings id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accountLinkings" ALTER COLUMN id SET DEFAULT nextval('public."HT_accountLinkings_id_seq"'::regclass);


--
-- Name: HT_acntTypLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_acntTypLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_acntTypLangMaps_id_seq"'::regclass);


--
-- Name: HT_answerTypes id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_answerTypes" ALTER COLUMN id SET DEFAULT nextval('public."HT_answerTypes_id_seq"'::regclass);


--
-- Name: HT_assessmentImages id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentImages" ALTER COLUMN id SET DEFAULT nextval('public."HT_assessmentImages_id_seq"'::regclass);


--
-- Name: HT_assessmentIntegrationOptionMappings id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentIntegrationOptionMappings" ALTER COLUMN id SET DEFAULT nextval('public."HT_assessmentIntegrationOptionMappings_id_seq"'::regclass);


--
-- Name: HT_assessmentInterventionTextResponses id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentInterventionTextResponses" ALTER COLUMN id SET DEFAULT nextval('public."HT_assessmentInterventionTextResponses_id_seq"'::regclass);


--
-- Name: HT_assessmentReintegrationTypes id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentReintegrationTypes" ALTER COLUMN id SET DEFAULT nextval('public."HT_assessmentReintegrationTypes_id_seq"'::regclass);


--
-- Name: HT_assessmentScores id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentScores" ALTER COLUMN id SET DEFAULT nextval('public."HT_assessmentScores_id_seq"'::regclass);


--
-- Name: HT_assessmentVisitTypes id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentVisitTypes" ALTER COLUMN id SET DEFAULT nextval('public."HT_assessmentVisitTypes_id_seq"'::regclass);


--
-- Name: HT_assessments id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessments" ALTER COLUMN id SET DEFAULT nextval('public."HT_assessments_id_seq"'::regclass);


--
-- Name: HT_assmntReintegrationTypeLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assmntReintegrationTypeLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_assmntReintegrationTypeLangMaps_id_seq"'::regclass);


--
-- Name: HT_assmntVisitTypeLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assmntVisitTypeLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_assmntVisitTypeLangMaps_id_seq"'::regclass);


--
-- Name: HT_auditLogs id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_auditLogs" ALTER COLUMN id SET DEFAULT nextval('public."HT_auditLogs_id_seq"'::regclass);


--
-- Name: HT_cases id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_cases" ALTER COLUMN id SET DEFAULT nextval('public."HT_cases_id_seq"'::regclass);


--
-- Name: HT_childCareGiverMappings id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childCareGiverMappings" ALTER COLUMN id SET DEFAULT nextval('public."HT_childCareGiverMappings_id_seq"'::regclass);


--
-- Name: HT_childConsentLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childConsentLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_childConsentLangMaps_id_seq"'::regclass);


--
-- Name: HT_childConsents id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childConsents" ALTER COLUMN id SET DEFAULT nextval('public."HT_childConsents_id_seq"'::regclass);


--
-- Name: HT_childCurrentPlacementStatuses id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childCurrentPlacementStatuses" ALTER COLUMN id SET DEFAULT nextval('public."HT_childCurrentPlacementStatuses_id_seq"'::regclass);


--
-- Name: HT_childEducationLevels id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childEducationLevels" ALTER COLUMN id SET DEFAULT nextval('public."HT_childEducationLevels_id_seq"'::regclass);


--
-- Name: HT_childHistories id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childHistories" ALTER COLUMN id SET DEFAULT nextval('public."HT_childHistories_id_seq"'::regclass);


--
-- Name: HT_childPlacementStatuses id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childPlacementStatuses" ALTER COLUMN id SET DEFAULT nextval('public."HT_childPlacementStatuses_id_seq"'::regclass);


--
-- Name: HT_childStatuses id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childStatuses" ALTER COLUMN id SET DEFAULT nextval('public."HT_childStatuses_id_seq"'::regclass);


--
-- Name: HT_children id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children" ALTER COLUMN id SET DEFAULT nextval('public."HT_children_id_seq"'::regclass);


--
-- Name: HT_chldCurntPlmtStsLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldCurntPlmtStsLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_chldCurntPlmtStsLangMaps_id_seq"'::regclass);


--
-- Name: HT_chldEdnLvlLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldEdnLvlLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_chldEdnLvlLangMaps_id_seq"'::regclass);


--
-- Name: HT_chldPlmtStsLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldPlmtStsLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_chldPlmtStsLangMaps_id_seq"'::regclass);


--
-- Name: HT_chldStsLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldStsLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_chldStsLangMaps_id_seq"'::regclass);


--
-- Name: HT_choiceLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_choiceLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_choiceLangMaps_id_seq"'::regclass);


--
-- Name: HT_choices id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_choices" ALTER COLUMN id SET DEFAULT nextval('public."HT_choices_id_seq"'::regclass);


--
-- Name: HT_countryLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_countryLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_countryLangMaps_id_seq"'::regclass);


--
-- Name: HT_deviceDetails id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_deviceDetails" ALTER COLUMN id SET DEFAULT nextval('public."HT_deviceDetails_id_seq"'::regclass);


--
-- Name: HT_districtLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_districtLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_districtLangMaps_id_seq"'::regclass);


--
-- Name: HT_events id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_events" ALTER COLUMN id SET DEFAULT nextval('public."HT_events_id_seq"'::regclass);


--
-- Name: HT_families id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_families" ALTER COLUMN id SET DEFAULT nextval('public."HT_families_id_seq"'::regclass);


--
-- Name: HT_familyMemTypeLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyMemTypeLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_familyMemTypeLangMaps_id_seq"'::regclass);


--
-- Name: HT_familyMemberTypes id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyMemberTypes" ALTER COLUMN id SET DEFAULT nextval('public."HT_familyMemberTypes_id_seq"'::regclass);


--
-- Name: HT_familyMembers id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyMembers" ALTER COLUMN id SET DEFAULT nextval('public."HT_familyMembers_id_seq"'::regclass);


--
-- Name: HT_familyRelanLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyRelanLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_familyRelanLangMaps_id_seq"'::regclass);


--
-- Name: HT_familyRelations id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyRelations" ALTER COLUMN id SET DEFAULT nextval('public."HT_familyRelations_id_seq"'::regclass);


--
-- Name: HT_fileUploadMappings id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_fileUploadMappings" ALTER COLUMN id SET DEFAULT nextval('public."HT_fileUploadMappings_id_seq"'::regclass);


--
-- Name: HT_formQuestionMappings id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_formQuestionMappings" ALTER COLUMN id SET DEFAULT nextval('public."HT_formQuestionMappings_id_seq"'::regclass);


--
-- Name: HT_formRevisions id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_formRevisions" ALTER COLUMN id SET DEFAULT nextval('public."HT_formRevisions_id_seq"'::regclass);


--
-- Name: HT_forms id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_forms" ALTER COLUMN id SET DEFAULT nextval('public."HT_forms_id_seq"'::regclass);


--
-- Name: HT_importLogs id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_importLogs" ALTER COLUMN id SET DEFAULT nextval('public."HT_importLogs_id_seq"'::regclass);


--
-- Name: HT_importMappings id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_importMappings" ALTER COLUMN id SET DEFAULT nextval('public."HT_importMappings_id_seq"'::regclass);


--
-- Name: HT_langMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_langMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_langMaps_id_seq"'::regclass);


--
-- Name: HT_logExports id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_logExports" ALTER COLUMN id SET DEFAULT nextval('public."HT_logExports_id_seq"'::regclass);


--
-- Name: HT_notifLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_notifLangMaps_id_seq"'::regclass);


--
-- Name: HT_notifications id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifications" ALTER COLUMN id SET DEFAULT nextval('public."HT_notifications_id_seq"'::regclass);


--
-- Name: HT_notifnEventTypes id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifnEventTypes" ALTER COLUMN id SET DEFAULT nextval('public."HT_notifnEventTypes_id_seq"'::regclass);


--
-- Name: HT_questionDomains id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questionDomains" ALTER COLUMN id SET DEFAULT nextval('public."HT_questionDomains_id_seq"'::regclass);


--
-- Name: HT_questionLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questionLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_questionLangMaps_id_seq"'::regclass);


--
-- Name: HT_questionTypes id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questionTypes" ALTER COLUMN id SET DEFAULT nextval('public."HT_questionTypes_id_seq"'::regclass);


--
-- Name: HT_questions id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questions" ALTER COLUMN id SET DEFAULT nextval('public."HT_questions_id_seq"'::regclass);


--
-- Name: HT_qusnDomainLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_qusnDomainLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_qusnDomainLangMaps_id_seq"'::regclass);


--
-- Name: HT_recurringEvents id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_recurringEvents" ALTER COLUMN id SET DEFAULT nextval('public."HT_recurringEvents_id_seq"'::regclass);


--
-- Name: HT_responses id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_responses" ALTER COLUMN id SET DEFAULT nextval('public."HT_responses_id_seq"'::regclass);


--
-- Name: HT_stateLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_stateLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_stateLangMaps_id_seq"'::regclass);


--
-- Name: HT_userLogs id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_userLogs" ALTER COLUMN id SET DEFAULT nextval('public."HT_userLogs_id_seq"'::regclass);


--
-- Name: HT_userRoleLangMaps id; Type: DEFAULT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_userRoleLangMaps" ALTER COLUMN id SET DEFAULT nextval('public."HT_userRoleLangMaps_id_seq"'::regclass);


--
-- Data for Name: HT_FollowUpProgresses; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_FollowUpProgresses" (id, "followupStatusDetail", "createdAt", "updatedAt", "HTQuestionDomainId", "HTQuestionId", "HTChoiceId", "HTAssessmentId", "HTFollowUpStatusId", "HTFollowupStatusQuestionId", "HTFollowupStatusQuestionChoiceId") FROM stdin;
29	x	2024-05-07 13:08:23.114+00	2024-05-07 13:08:23.114+00	1	2	793	34	1	1	3
30	x	2024-05-07 13:08:23.114+00	2024-05-07 13:08:23.114+00	1	8	668	34	2	3	6
31	x	2024-05-07 13:08:23.114+00	2024-05-07 13:08:23.114+00	1	8	668	34	2	2	4
32	x	2024-05-07 13:08:23.114+00	2024-05-07 13:08:23.114+00	3	24	724	34	2	3	7
33	x	2024-05-07 13:08:23.114+00	2024-05-07 13:08:23.114+00	3	24	724	34	2	2	4
34	x	2024-05-07 13:08:23.114+00	2024-05-07 13:08:23.114+00	4	26	730	34	3	4	9
35	 x	2024-05-07 13:09:21.393+00	2024-05-07 13:09:21.393+00	1	2	793	30	1	1	2
36	x	2024-05-07 13:09:21.393+00	2024-05-07 13:09:21.393+00	2	14	681	30	4	5	10
37	x	2024-05-07 13:09:21.393+00	2024-05-07 13:09:21.393+00	2	17	693	30	3	4	8
38		2024-05-22 12:47:23.335+00	2024-05-22 12:47:23.335+00	1	45	804	39	1	1	1
39	In progress	2024-05-22 12:56:20.597+00	2024-05-22 12:56:20.597+00	1	45	802	42	2	3	6
40	In progress	2024-05-22 12:56:20.597+00	2024-05-22 12:56:20.597+00	1	45	802	42	2	2	4
41	completed	2024-05-22 12:56:20.597+00	2024-05-22 12:56:20.597+00	2	48	815	42	1	1	1
42	in progress 	2024-05-22 12:56:20.597+00	2024-05-22 12:56:20.597+00	3	51	830	42	2	3	6
43	in progress 	2024-05-22 12:56:20.597+00	2024-05-22 12:56:20.597+00	3	51	830	42	2	2	4
44	not started	2024-05-22 12:56:20.597+00	2024-05-22 12:56:20.597+00	4	54	844	42	3	4	8
45	not longer relevant	2024-05-22 12:56:20.597+00	2024-05-22 12:56:20.597+00	5	57	856	42	4	5	10
46	completed 	2024-05-23 06:02:37.282+00	2024-05-23 06:02:37.282+00	1	129	1140	43	1	1	1
47	completed	2024-05-23 06:02:37.282+00	2024-05-23 06:02:37.282+00	1	130	1143	43	1	1	1
48	completed	2024-05-23 06:02:37.282+00	2024-05-23 06:02:37.282+00	1	135	1158	43	1	1	1
49		2024-05-23 06:02:37.282+00	2024-05-23 06:02:37.282+00	3	149	1209	43	1	1	1
50		2024-05-23 06:02:37.282+00	2024-05-23 06:02:37.282+00	3	150	1214	43	1	1	1
51	completed 	2024-05-23 06:02:37.282+00	2024-05-23 06:02:37.282+00	3	151	1218	43	1	1	1
52	completed	2024-05-23 06:02:37.282+00	2024-05-23 06:02:37.282+00	3	151	1216	43	1	1	1
53	in progress	2024-05-23 06:02:37.282+00	2024-05-23 06:02:37.282+00	4	152	1219	43	2	3	6
54	in progress	2024-05-23 06:02:37.282+00	2024-05-23 06:02:37.282+00	4	152	1219	43	2	2	4
\.


--
-- Data for Name: HT_FollowUpStatuses; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_FollowUpStatuses" (id, status, "helperText", "isActive", "createdAt", "updatedAt") FROM stdin;
1	Intervention Completed	Do you have any additional comments related to this intervention?	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00
3	Intervention Not Started	Please provide details on why the intervention has not been started.	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00
4	Intervention No Longer Relevant	Do you have any additional comments related to this intervention?	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00
2	Intervention In Progress	Do you have any additional comments related to this intervention or its current status?	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00
\.


--
-- Data for Name: HT_FollowupStatusQuestionChoices; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_FollowupStatusQuestionChoices" (id, choice, "isActive", "createdAt", "updatedAt", "HTFollowupStatusQuestionId", type) FROM stdin;
1	Improved the situation	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	1	Positive Impact
2	Made the situation worse	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	1	Made Worse
3	Had no impact on the situation	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	1	No Impact
5	No	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	2	No Pottential Impact
6	Yes	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	3	Plan To Continue
7	No	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	3	Dont Plan To Continue
8	Yes	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	4	Will Start
9	No	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	4	Will Not Start
10	Yes, another intervention has been selected	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	5	Have Replaced
11	No, another intervention has not been selected but will be selected	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	5	Will Replace
12	No, another intervention has not been selected	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	5	Will Not Replace
4	Yes	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	2	Potential Positive Impact
\.


--
-- Data for Name: HT_FollowupStatusQuestions; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_FollowupStatusQuestions" (id, question, "isActive", "createdAt", "updatedAt", "HTFollowUpStatusId") FROM stdin;
3	Will you continue with this intervention in the future?	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	2
4	Do you expect to continue with this intervention in the future?	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	3
5	Have you selected a different intervention to take ths intervention's place?	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	4
1	How do you feel this intervention impacted the family's [domain] situation?	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	1
2	From what you have seen so far ,do you think this intervention will improve the famly's [domain] situation?	t	2022-07-15 00:00:00+00	2022-07-15 00:00:00+00	2
\.


--
-- Data for Name: HT_IntegrationOptionLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_IntegrationOptionLangMaps" (id, "integrationOption", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTIntegrationOptionId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_IntegrationOptions; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_IntegrationOptions" (id, "integrationOption", "isRedFlag", "isCaseCloseOption", "isActive", "order", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTFormId", "integrationOptionLang") FROM stdin;
3	Expedited Case Management (ECM) with safety concerns: Consider temporary placement with family or elsewhere until risk mitigates, adding more support to family and increasing follow ups until Red Flag moved out of in-crisis	t	f	t	3	f	\N	\N	2022-02-23 05:17:56.445+00	2022-02-23 05:17:56.445+00	1	{"1" : "Expedited Case Management (ECM) with safety concerns: Consider temporary placement with family or elsewhere until risk mitigates, adding more support to family and increasing follow ups until Red Flag moved out of in-crisis", "2" : "प्लेसमेंट के निर्धारण के लिए उपयुक्त प्राधिकारी को रिपोर्ट करें\\n\\n", "3" : "அவர்களின் குடும்ப பராமரிப்பு  நிர்ணயம் குறித்து உரிய அதிகாரியிடம் தெரிவிக்கவும்\\n"}
4	Consider other FBAC options: Respite care, Foster Care, Adoption, Group Living, Semi-Independent Living, Independent Living, Aftercare, etc. until Red Flag moved out of in-crisis	t	f	t	4	f	\N	\N	2022-02-23 05:17:56.453+00	2022-02-23 05:17:56.453+00	1	{"1" : "Consider other FBAC options: Respite care, Foster Care, Adoption, Group Living, Semi-Independent Living, Independent Living, Aftercare, etc. until Red Flag moved out of in-crisis", "2" : "बच्चे को रिश्तेदारी देखभाल, पालन-पोषण देखभाल, गोद लेने या समूह में रहने जैसे वैकल्पिक स्थान पर स्थानांतरित करने पर विचार करें\\n\\n", "3" : "உறவினர் பராமரிப்பு, வளர்ப்பு பராமரிப்பு, தத்தெடுப்பு அல்லது குழு வாழ்க்கை போன்ற மாற்று இடங்களுக்கு குழந்தையை மாற்றுவதைக் கருத்தில் கொள்ளுங்கள்\\n"}
5	Other	t	f	t	5	f	\N	\N	2022-02-23 05:17:56.459+00	2022-02-23 05:17:56.459+00	1	{"1" : "Other", "2" : "अन्य", "3" : "மற்றவை\\n\\n"}
6	Preparing for Reintegration: Focus on planning/implementing support services, and preparation of child and family; resolve Red Flag items	f	f	t	6	f	\N	\N	2022-02-23 05:17:56.465+00	2022-02-23 05:17:56.465+00	1	{"1" : "Preparing for Reintegration: Focus on planning/implementing support services, and preparation of child and family; resolve Red Flag items", "2" : "बच्चे की घर वापसी के लिए बच्चे और परिवार को तैयार करें; सहायता सेवाओं की योजना बनाने और कार्यान्वयन पर ध्यान दें\\n\\n", "3" : "குழந்தை வீட்டிற்குத் திரும்புவதற்கு குழந்தையையும் குடும்பத்தையும்  தயார்படுத்துங்கள்; ஆதரவு சேவைகளை திட்டமிடுதல்/செயல்படுத்துவதில் கவனம் செலுத்துங்கள்\\n\\n"}
7	Permanent Reintegration with birth family, kin, or other Family Based Alternative Care (FBAC) option; continue providing support services and follow ups	f	f	t	7	f	\N	\N	2022-02-23 05:17:56.472+00	2022-02-23 05:17:56.472+00	1	{"1" : "Permanent Reintegration with birth family, kin, or other Family Based Alternative Care (FBAC) option; continue providing support services and follow ups", "2" : "चल रही सहायता सेवाओं के साथ बच्चे को परिवार/वर्तमान वैकल्पिक देखभाल प्लेसमेंट में रखें और घर के लिए अनुवर्ती संपर्क करें\\n\\n", "3" : "குழந்தை குடும்பத்தில் இருக்க செய்தல்/தற்போதைய மாற்றுப் பராமரிப்பில் தொடர்ந்து இருக்கும் ஆதரவுச் சேவைகள் மற்றும் வீட்டுத் தொடர்பைப் பின்தொடர்தல்\\n\\n"}
9	Expedited Case Management (ECM) with safety concerns: Consider temporary placement with family or elsewhere until risk mitigates, adding more support to family and increasing follow ups	f	f	t	9	f	\N	\N	2022-02-23 05:17:56.484+00	2022-02-23 05:17:56.484+00	1	{"1" : "Expedited Case Management (ECM) with safety concerns: Consider temporary placement with family or elsewhere until risk mitigates, adding more support to family and increasing follow ups", "2" : "प्लेसमेंट के निर्धारण के लिए उपयुक्त प्राधिकारी को रिपोर्ट करें\\n\\n", "3" : "அவர்களின் குடும்ப பராமரிப்பு  நிர்ணயம் குறித்து உரிய அதிகாரியிடம் தெரிவிக்கவும்\\n\\n"}
11	Other	f	f	t	11	f	\N	\N	2022-02-23 05:17:56.496+00	2022-02-23 05:17:56.496+00	1	{"1" : "Other", "2" : "अन्य", "3" : "மற்றவை\\n\\n"}
8	Consider returning child to CCI (eg: due to placement disruption)	f	f	t	8	f	\N	\N	2022-02-23 05:17:56.478+00	2022-02-23 05:17:56.478+00	1	{"1" : "Consider returning child to CCI (eg: due to placement disruption)", "2" : "वर्तमान में कोई विकल्प मौजूद नहीं है या गंभीर स्थितियों के लिए संस्थागत देखभाल (जैसे आवासीय उपचार केंद्र, बाल देखभाल संस्थान, अनाथालय) में अस्थायी संक्रमण की आवश्यकता है\\n\\n", "3" : "தற்போது மாற்று எதுவும் இல்லை அல்லது தீவிரமான  நிலைமைகளுக்கு நிறுவன பராமரிப்புக்கு தற்காலிக மாற்றம் தேவைப்படுகிறது (எ.கா. குடியிருப்பு சிகிச்சை மையம், குழந்தை பராமரிப்பு இல்லங்கள், அனாதை இல்லம்)\\n\\n"}
10	Consider other FBAC options: Respite care, Foster Care, Adoption, Group Living, Semi-Independent Living, Independent Living, Aftercare, etc.	f	f	t	10	f	\N	\N	2022-02-23 05:17:56.49+00	2022-02-23 05:17:56.49+00	1	{"1" : "Consider other FBAC options: Respite care, Foster Care, Adoption, Group Living, Semi-Independent Living, Independent Living, Aftercare, etc.", "2" : "बच्चे को रिश्तेदारी देखभाल, पालन-पोषण देखभाल, गोद लेने या समूह में रहने जैसे वैकल्पिक स्थान पर स्थानांतरित करने पर विचार करें\\n\\n", "3" : "உறவினர் பராமரிப்பு, வளர்ப்பு பராமரிப்பு, தத்தெடுப்பு அல்லது குழு வாழ்க்கை போன்ற மாற்று இடங்களுக்கு குழந்தையை மாற்றுவதைக் கருத்தில் கொள்ளுங்கள்\\n\\n"}
12	Close case	f	t	t	12	f	\N	\N	2022-02-23 05:17:56.501+00	2022-02-23 05:17:56.501+00	1	{"1" : "Close case", "2" : "केस बंद करें\\n\\n", "3" : "இறுதி செய்தல்"}
1	No reintegration at this time; continue providing support services and addressing Red Flag milestones	t	f	t	2	f	\N	\N	2022-02-23 05:17:56.425+00	2022-02-23 05:17:56.425+00	1	{"1" : "No reintegration at this time; continue providing support services and addressing Red Flag milestones", "2" : "बच्चे को चल रही सहायता सेवाओं और परिवार के लिए अनुवर्ती संपर्क के साथ परिवार/वर्तमान वैकल्पिक देखभाल प्लेसमेंट में रहना होगा\\n\\n", "3" : "குழந்தை குடும்பத்தில் இருக்க செய்தல்/தற்போதைய மாற்றுப் பராமரிப்பில் தொடர்ந்து இருக்கும் ஆதரவுச் சேவைகள் மற்றும் வீட்டுத் தொடர்பைப் பின்தொடர்தல்\\n"}
2	Consider returning child to CCI (eg: due to placement disruption) until Red Flag moved out of in-crisis	t	f	t	1	f	\N	\N	2022-02-23 05:17:56.439+00	2022-02-23 05:17:56.439+00	1	{"1" : "Consider returning child to CCI (eg: due to placement disruption) until Red Flag moved out of in-crisis", "2" : "वर्तमान में कोई विकल्प मौजूद नहीं है या गंभीर स्थितियों के लिए संस्थागत देखभाल (जैसे आवासीय उपचार केंद्र, बाल देखभाल संस्थान, अनाथालय) में अस्थायी संक्रमण की आवश्यकता है।\\n\\n", "3" : "தற்போது மாற்று எதுவும் இல்லை அல்லது தீவிரமான  நிலைமைகளுக்கு நிறுவன பராமரிப்புக்கு தற்காலிக மாற்றம் தேவைப்படுகிறது (எ.கா. குடியிருப்பு சிகிச்சை மையம், குழந்தை பராமரிப்பு இல்லங்கள், அனாதை இல்லம்)\\n"}
\.


--
-- Data for Name: HT_InterventionFollowUps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_InterventionFollowUps" (id, "interventionChoiceIds", "interventionDetail", "createdAt", "updatedAt", "HTAssessmentId", "HTQuestionDomainId", "HTQuestionId") FROM stdin;
23	{793}	Xxx	2024-04-22 09:59:19.818+00	2024-04-22 09:59:19.818+00	30	1	2
24	{681}	Xx	2024-04-22 09:59:19.818+00	2024-04-22 09:59:19.818+00	30	2	14
25	{693}	Xx	2024-04-22 09:59:19.818+00	2024-04-22 09:59:19.818+00	30	2	17
26	{793}	Aaa	2024-04-29 11:48:22.826+00	2024-04-29 11:48:22.826+00	34	1	2
27	{668}	Xxx	2024-04-29 11:48:22.826+00	2024-04-29 11:48:22.826+00	34	1	8
28	{724}	Xxx	2024-04-29 11:48:22.826+00	2024-04-29 11:48:22.826+00	34	3	24
29	{730}	Xxx	2024-04-29 11:48:22.826+00	2024-04-29 11:48:22.826+00	34	4	26
30	{804}	Ensure	2024-05-13 09:09:41.87+00	2024-05-13 09:09:41.87+00	39	1	45
31	{1166}	stuff	2024-05-21 19:45:49.975+00	2024-05-21 19:45:49.975+00	40	2	139
32	{1190}		2024-05-21 19:45:49.975+00	2024-05-21 19:45:49.975+00	40	2	145
33	{1195}		2024-05-21 19:45:49.975+00	2024-05-21 19:45:49.975+00	40	2	146
34	{1201}	extra stuff	2024-05-21 19:45:49.975+00	2024-05-21 19:45:49.975+00	40	2	147
35	{1253}		2024-05-21 19:45:49.975+00	2024-05-21 19:45:49.975+00	40	5	161
36	{802}	Report to authorities 	2024-05-22 12:54:12.891+00	2024-05-22 12:54:12.891+00	42	1	45
37	{815}	Refer for support	2024-05-22 12:54:12.891+00	2024-05-22 12:54:12.891+00	42	2	48
38	{830}	Discuss safety measures	2024-05-22 12:54:12.891+00	2024-05-22 12:54:12.891+00	42	3	51
39	{844}	Explore educational facilities 	2024-05-22 12:54:12.891+00	2024-05-22 12:54:12.891+00	42	4	54
40	{856}	Refer abuser for treatment	2024-05-22 12:54:12.891+00	2024-05-22 12:54:12.891+00	42	5	57
48	{678}		2024-05-22 21:23:45.864+00	2024-05-22 21:23:45.864+00	45	2	13
49	{698,696}		2024-05-22 21:23:45.864+00	2024-05-22 21:23:45.864+00	45	2	18
50	{704}		2024-05-22 21:23:45.864+00	2024-05-22 21:23:45.864+00	45	2	19
51	{708}		2024-05-22 21:23:45.864+00	2024-05-22 21:23:45.864+00	45	2	20
52	{711}		2024-05-22 21:23:45.864+00	2024-05-22 21:23:45.864+00	45	2	21
53	{1135,1136}		2024-05-23 06:18:05.181+00	2024-05-23 06:18:05.181+00	43	1	128
54	{1140}		2024-05-23 06:18:05.181+00	2024-05-23 06:18:05.181+00	43	1	129
55	{1165}		2024-05-23 06:18:05.181+00	2024-05-23 06:18:05.181+00	43	1	138
56	{1166}	stuff	2024-05-23 06:18:05.181+00	2024-05-23 06:18:05.181+00	43	2	139
57	{1190}		2024-05-23 06:18:05.181+00	2024-05-23 06:18:05.181+00	43	2	145
58	{1195}		2024-05-23 06:18:05.181+00	2024-05-23 06:18:05.181+00	43	2	146
59	{1201}	extra stuff	2024-05-23 06:18:05.181+00	2024-05-23 06:18:05.181+00	43	2	147
60	{1225}		2024-05-23 06:18:05.181+00	2024-05-23 06:18:05.181+00	43	4	153
61	{1253}		2024-05-23 06:18:05.181+00	2024-05-23 06:18:05.181+00	43	5	161
\.


--
-- Data for Name: HT_UserSocketConnectionMappings; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_UserSocketConnectionMappings" (id, "connectionId", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTUserId") FROM stdin;
\.


--
-- Data for Name: HT_accountLinkings; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_accountLinkings" (id, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "AccountId", "LinkedAccountId", "HTAccountId") FROM stdin;
\.


--
-- Data for Name: HT_accountTypes; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_accountTypes" (id, name, description, "isActive", "isDeleted", "createdAt", "updatedAt", "nameLang", "descriptionLang") FROM stdin;
1	Miracle Foundation	\N	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	\N	\N
5	Private CCI	\N	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	\N	\N
4	NGO/Partner	\N	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	\N	\N
3	Govt Organization	\N	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	\N	\N
2	Govt CCI	\N	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	\N	\N
\.


--
-- Data for Name: HT_accounts; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_accounts" (id, "accountName", "addressLine1", "addressLine2", "zipCode", "phoneNumber", email, city, website, "isDCPUOrg", "isActive", "isDeleted", "createdBy", "updatedBy", "injectiondocId", "dbRegion", "consentRequired", "createdAt", "updatedAt", "HTAccountTypeId", "HTCountryId", "HTStateId", "HTDistrictId", "accountCode", "deactivationReason", "accessType") FROM stdin;
d74a2981-22a4-4cc5-90ec-52f4d0301cd3	Thriving Together	123 Miracle Way		78703	\N	\N	Austin	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	50092e8d-588d-4ebd-b72b-dba355ab0ee4	\N	usa	t	2024-05-20 13:55:46.861+00	2024-05-21 21:28:46.891+00	5	2	37	\N	243	\N	BOTH
0cf24e7b-6487-4288-8847-d336668da62e	QA RBAC REG Phase1 UGANDA	AD01 Ugandan Street		12345	\N	\N	Uganda City	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	f09a62ed-11bc-424b-9497-9e447f96b856	\N	usa	t	2024-04-09 08:06:13.328+00	2024-04-09 10:03:33.168+00	5	3	38	\N	225	\N	THRIVE_SCALE
0d7b5e4a-9c81-4811-b010-bbef1ff42e28	GCCI UAT Staging USA	AD01 TXAS		12345	\N	\N	TXAS	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	t	2024-04-04 12:50:41.529+00	2024-04-04 12:50:41.529+00	2	2	37	\N	218	\N	BOTH
1cec9f20-62dd-4cd1-b91b-951d851ab25b	Inapp Govt CCI	ABC Tvm		696567	\N	\N	TVM	\N	f	t	f	\N	\N	\N	india	t	2024-04-04 05:26:39.864+00	2024-04-04 05:26:39.864+00	2	1	18	415	216	\N	BOTH
2593574a-10f1-4074-8fe5-51f8ac753ab9	QA RBAC REG Phase1 INDIA	AD01 		691500	\N	\N	Quilon	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	india	t	2024-04-05 08:01:56.308+00	2024-04-05 08:04:03.997+00	5	1	18	407	220	\N	BOTH
359fdbcb-8f7b-4279-99c5-9c2b094114af	FS Only US CPA - Katie 4/5	TBD		78735	\N	\N	Austin	\N	f	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	f	2024-04-05 18:24:54.351+00	2024-04-05 18:24:54.351+00	\N	2	37	\N	222	\N	FOSTER_SHARE
3af1f40b-34a5-4174-a141-9dc97bafbd57	FS Only India CPA - Katie 4/5	TBD		999999	\N	\N	TBD	\N	f	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	india	f	2024-04-05 18:26:26.379+00	2024-04-05 18:26:26.379+00	\N	1	21	481	224	\N	FOSTER_SHARE
6536ba55-07ba-4c0d-8c63-8891586345c7	Karasseril Org	Street Address 1 		65465	\N	\N	Texas	\N	f	t	f	\N	\N	\N	usa	t	2024-04-04 06:01:38.46+00	2024-04-04 06:01:38.46+00	2	2	37	\N	217	\N	BOTH
91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	Miracle Foundation	Txs North	\N	567845	\N	miraclesuperadmin@yopmail.com	TXS	\N	f	t	f	\N	\N	\N	usa	t	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	1	2	\N	\N	1000	\N	BOTH
96aca77e-d466-4be1-862d-9bf3ab4573a0	QA RBAC REG Phase1 USA	AD01 Txs	Street 2	12345	\N	\N	TXAS City	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	usa	t	2024-04-05 08:05:12.607+00	2024-04-08 09:11:34.45+00	5	2	37	\N	221	\N	BOTH
a6c3fb73-28c6-4339-8605-8b32e9947007	Mundakal Super speciality	ABS		987878	\N	\N	trv	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	india	t	2024-04-05 05:20:28.543+00	2024-04-05 05:20:28.543+00	2	1	18	415	219	\N	BOTH
aeb16ff9-0111-4da8-9f9e-c2bbb144065d	Deactivate PCCI - QA - India - TS Only	AD01 1st Address	AD02 1st Address	123456	\N	\N	Kollam City India	\N	f	f	t	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	india	t	2024-04-15 06:11:52.212+00	2024-05-09 05:54:38.142+00	5	1	18	407	230		THRIVE_SCALE
b705825d-ddd8-45cd-8bb6-4713a96b47d3	FS Only Uganda CPA - Katie 4/5	TBD		99999	\N	\N	Civic Centre	\N	f	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	f	2024-04-05 18:25:34.29+00	2024-04-05 18:25:34.29+00	\N	3	38	\N	223	\N	FOSTER_SHARE
b7a026e2-b257-450a-ad88-60ed87614d0f	Technopark Org	Kazhakkoottam	Trivandrum	695581	\N	\N	TVM	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	india	f	2024-04-12 08:56:55.679+00	2024-04-12 08:56:55.679+00	3	1	18	415	228	\N	BOTH
bb55df99-046e-4ab8-a418-813c629b0967	PCCI ThriveScale_Uganda	AD01 Kampala Street		12345	\N	\N	Kampala	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	t	2024-04-15 07:52:27.156+00	2024-04-15 07:52:27.156+00	5	3	38	\N	231	\N	BOTH
f6b5c395-6ed8-4b22-a356-201b75d16c5f	FS Only RBAC - USA	AD01 Wash DC	AD02 DC 	12345	\N	\N	Washington DC	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	f	2024-04-11 14:19:23.517+00	2024-04-11 14:19:23.517+00	\N	2	37	\N	227	\N	FOSTER_SHARE
fb50e3ce-1543-4160-bcfd-16f103ebd399	Test CCI India (jyotir)	Pune city		431214	\N	\N	Pune	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	india	t	2024-04-12 11:44:01.759+00	2024-04-12 11:48:24.656+00	5	1	21	507	229	\N	THRIVE_SCALE
80cabb24-8fc7-4ed3-a8c7-1d0e36071342	Ash test - Deactivated USA org	123 6th st		78723	\N	\N	Austin	\N	f	f	t	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	f	2024-04-18 19:59:31.527+00	2024-04-18 20:01:10.782+00	4	2	37	\N	233	\N	BOTH
e2ae7a5f-da18-4ac2-9c28-0ab59f1f9b6b	Test	123 6th st		888885	\N	\N	Test	\N	f	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	india	f	2024-04-22 12:40:23.104+00	2024-04-22 12:40:23.104+00	3	1	4	124	235	\N	BOTH
9095cbb8-30cc-408c-9c30-66c23a820855	test-FS only	123 6th st		78723	\N	\N	test	\N	f	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	f	2024-04-22 12:44:40.482+00	2024-04-22 12:44:40.482+00	\N	2	39	\N	236	\N	FOSTER_SHARE
9cfbcab5-ddf0-4fce-9b56-d8666ad2242e	Peace welfare foundation	test address		67154	\N	\N	city of texas	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	t	2024-05-15 11:14:22.797+00	2024-05-15 11:14:22.797+00	2	2	37	\N	242	\N	BOTH
3c6feba9-08b5-400a-90f1-d7324a6dfd22	Test - NV	Dfsdfsdf		888888	\N	\N	HYds[	\N	f	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	india	f	2024-04-22 12:53:24.169+00	2024-04-22 12:55:29.74+00	2	1	2	758	237	\N	BOTH
f1418a8e-2ccc-4d7e-a961-b7285ed6b27a	Ash test org_only one user	123 6th st		78723	\N	\N	City	\N	f	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	f	2024-04-18 20:08:25.48+00	2024-05-15 19:44:35.477+00	3	2	37	\N	234	\N	BOTH
733783e7-fcf9-42d5-849c-33aff0f01d35	Combo Org USA	TBD		78733	\N	\N	Austin	\N	f	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	0b9b34f2-dd92-4191-b023-f4ae32884964	\N	usa	t	2024-04-17 00:10:47.142+00	2024-04-22 18:54:33.709+00	5	2	37	\N	232	\N	BOTH
402e9214-a9d8-4a7a-b01e-5b932a0d1ecf	Ash test - USA FS and TS	123 6th st		88888	\N	\N	City	\N	f	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	f	2024-04-22 20:26:47.495+00	2024-04-22 20:26:47.495+00	5	2	37	\N	238	\N	BOTH
7afdc326-bc88-4cbd-b120-85e312fce2e1	AAAAAAAAAAAAAAAA	 Add a new organization		605020	\N	\N	city	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	india	t	2024-04-30 08:59:07.517+00	2024-04-30 08:59:07.517+00	5	1	18	399	239	\N	BOTH
116546d0-07bb-436d-be51-91cf5f34bd2a	Organization_OnlyUSA	123 6th st		78723	\N	\N	test	\N	f	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	f	2024-05-06 15:53:11.094+00	2024-05-06 15:53:11.094+00	4	2	37	\N	240	\N	BOTH
a38bbea2-e253-4888-afdc-d27a5f603d59	Deactivate PCCI - QA - US - FS Only	Street Address 01	Street Address 02	12345	\N	\N	Texas City USA	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	t	2024-05-09 05:49:44.239+00	2024-05-09 05:49:44.239+00	5	2	37	\N	241	\N	BOTH
ae6695f8-d28c-4d1e-96be-16da575330b1	Happy CCI	123 Miracle Way		000000	\N	\N	Delhi	\N	f	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	c29aa68f-d4ec-48dd-b5ae-b5c717214613	\N	india	t	2024-04-10 16:42:44.357+00	2024-05-20 10:22:31.123+00	5	1	10	239	226	\N	THRIVE_SCALE
\.


--
-- Data for Name: HT_acntTypLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_acntTypLangMaps" (id, name, description, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTAccountTypeId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_answerTypes; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_answerTypes" (id, "typeName", description, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt") FROM stdin;
1	Single Choice	\N	t	f	\N	\N	2022-02-23 05:17:56.362+00	2022-02-23 05:17:56.362+00
2	Multiple Choice	\N	t	f	\N	\N	2022-02-23 05:17:56.362+00	2022-02-23 05:17:56.362+00
3	Text	\N	t	f	\N	\N	2022-02-23 05:17:56.362+00	2022-02-23 05:17:56.362+00
\.


--
-- Data for Name: HT_assessmentImages; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_assessmentImages" (id, "s3BucketName", "objectKey", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTAssessmentId") FROM stdin;
\.


--
-- Data for Name: HT_assessmentIntegrationOptionMappings; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_assessmentIntegrationOptionMappings" (id, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTAssessmentId", "HTIntegrationOptionId") FROM stdin;
15	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.471+00	2024-04-19 09:49:09.471+00	31	7
16	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.471+00	2024-04-19 09:49:09.471+00	31	8
17	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.44+00	2024-04-22 09:59:27.44+00	30	3
18	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.742+00	2024-04-29 11:48:28.742+00	34	4
19	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.86+00	2024-05-13 09:06:38.86+00	36	10
20	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.049+00	2024-05-13 09:09:49.049+00	39	1
22	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.777+00	2024-05-21 19:46:25.777+00	40	1
28	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.781+00	2024-05-22 12:54:19.781+00	42	3
36	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.179+00	2024-05-22 21:25:07.179+00	45	5
37	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.304+00	2024-05-23 06:18:14.304+00	43	1
\.


--
-- Data for Name: HT_assessmentInterventionTextResponses; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_assessmentInterventionTextResponses" (id, "interventionDetails", "otherDetails", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTQuestionId", "HTAssessmentId") FROM stdin;
\.


--
-- Data for Name: HT_assessmentReintegrationTypes; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_assessmentReintegrationTypes" (id, "reIntegrationType", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "reIntegrationTypeLang") FROM stdin;
1	Prevention of Separation	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Prevention of Separation", "2": "अलगाव का प्रतिबन्ध", "3": "பிரிவதை தடுத்தல்"}
2	Reintegration with Parents/Step-Parents	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Reintegration with Parents/Step-Parents", "2": "माता-पिता / सौतेले माता-पिता के साथ पुनः एकीकरण", "3": "பெற்றோர்/மாற்றான் பெற்றோருடன் மறுஒருங்கிணைப்பு"}
3	Kinship Care	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Kinship Care", "2": "रिश्तेदारी में देखभाल", "3": "உறவுமுறை பராமரிப்பு"}
4	Foster Care	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Foster Care", "2": "पालन पोषण संबंधी देखभाल (फोस्टर केयर)", "3": "தற்காலிக தத்து பராமரிப்பு"}
5	Aftercare	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Aftercare", "2": "पश्चातवर्ती देखभाल (आफ्टर केयर)", "3": "தத்திற்குப் பின்னான பராமரிப்பு"}
6	Semi-Independent Living	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Semi-Independent Living", "2": "अर्ध-स्वतंत्र जीवनयापन", "3": "பகுதி சுயாதீன வாழ்க்கை"}
7	Group Living	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Group Living", "2": "सामूहिक जीवनयापन", "3": "குழுவாக வாழ்தல்"}
8	Other	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Other", "2": "अन्य", "3": "மற்றவை"}
\.


--
-- Data for Name: HT_assessmentScores; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_assessmentScores" (id, score, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTAssessmentId", "HTQuestionDomainId") FROM stdin;
46	70	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:11.743+00	2024-04-19 09:49:11.743+00	31	1
47	75	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:11.743+00	2024-04-19 09:49:11.743+00	31	2
48	75	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:11.743+00	2024-04-19 09:49:11.743+00	31	3
49	75	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:11.743+00	2024-04-19 09:49:11.743+00	31	4
50	75	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:11.743+00	2024-04-19 09:49:11.743+00	31	5
51	72.5	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:29.719+00	2024-04-22 09:59:29.719+00	30	1
52	69.4	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:29.719+00	2024-04-22 09:59:29.719+00	30	2
53	68.8	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:29.719+00	2024-04-22 09:59:29.719+00	30	3
54	75	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:29.719+00	2024-04-22 09:59:29.719+00	30	4
55	78.8	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:29.719+00	2024-04-22 09:59:29.719+00	30	5
56	70	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:31.081+00	2024-04-29 11:48:31.081+00	34	1
57	75	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:31.081+00	2024-04-29 11:48:31.081+00	34	2
58	68.8	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:31.081+00	2024-04-29 11:48:31.081+00	34	3
59	70.8	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:31.081+00	2024-04-29 11:48:31.081+00	34	4
60	75	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:31.081+00	2024-04-29 11:48:31.081+00	34	5
61	75	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:41.533+00	2024-05-13 09:06:41.533+00	36	1
62	75	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:41.533+00	2024-05-13 09:06:41.533+00	36	2
63	75	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:41.533+00	2024-05-13 09:06:41.533+00	36	3
64	75	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:41.533+00	2024-05-13 09:06:41.533+00	36	4
65	75	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:41.533+00	2024-05-13 09:06:41.533+00	36	5
66	58.3	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.386+00	2024-05-13 09:09:49.386+00	39	1
67	75	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.386+00	2024-05-13 09:09:49.386+00	39	2
68	75	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.386+00	2024-05-13 09:09:49.386+00	39	3
69	75	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.386+00	2024-05-13 09:09:49.386+00	39	4
70	75	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.386+00	2024-05-13 09:09:49.386+00	39	5
76	66.7	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:26.079+00	2024-05-21 19:46:26.079+00	40	1
77	58.3	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:26.079+00	2024-05-21 19:46:26.079+00	40	2
78	81.3	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:26.079+00	2024-05-21 19:46:26.079+00	40	3
79	70.8	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:26.079+00	2024-05-21 19:46:26.079+00	40	4
80	75	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:26.079+00	2024-05-21 19:46:26.079+00	40	5
81	58.3	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:21.968+00	2024-05-22 12:54:21.968+00	42	1
82	58.3	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:21.968+00	2024-05-22 12:54:21.968+00	42	2
83	66.7	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:21.968+00	2024-05-22 12:54:21.968+00	42	3
84	66.7	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:21.968+00	2024-05-22 12:54:21.968+00	42	4
85	66.7	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:21.968+00	2024-05-22 12:54:21.968+00	42	5
96	77.3	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.564+00	2024-05-22 21:25:07.564+00	45	1
97	61.1	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.564+00	2024-05-22 21:25:07.564+00	45	2
98	68.8	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.564+00	2024-05-22 21:25:07.564+00	45	3
99	91.7	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.564+00	2024-05-22 21:25:07.564+00	45	4
100	73.1	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.564+00	2024-05-22 21:25:07.564+00	45	5
101	66.7	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:16.91+00	2024-05-23 06:18:16.91+00	43	1
102	58.3	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:16.91+00	2024-05-23 06:18:16.91+00	43	2
103	81.3	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:16.91+00	2024-05-23 06:18:16.91+00	43	3
104	70.8	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:16.91+00	2024-05-23 06:18:16.91+00	43	4
105	75	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:16.91+00	2024-05-23 06:18:16.91+00	43	5
\.


--
-- Data for Name: HT_assessmentVisitTypes; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_assessmentVisitTypes" (id, "visitType", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "visitTypeLang") FROM stdin;
1	Risk of Family Separation	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Risk of Family Separation", "2": "परिवार से अलगाव का जोखिम", "3": "குடும்பம் பிரியும் அபாயம்"}
2	Pre-Reintegration	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Pre-Reintegration", "2": "पुनः एकीकरण से पहले", "3": "மறு ஒருங்கிணைப்புக்கு முன்"}
3	At Reintegration	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "At Reintegration", "2": "पुनः एकीकरण के समय", "3": "மறு ஒருங்கிணைப்பின் போது"}
4	Post-Reintegration	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Post-Reintegration", "2": "पुनः एकीकरण के पश्चात", "3": "மறு ஒருங்கிணைப்பிற்குப் பிறகு"}
\.


--
-- Data for Name: HT_assessments; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_assessments" (id, "meetWithChild", "dateOfAssessment", "isComplete", "formRevisionNumber", "otherReIntegrationTypeValue", "currentPagePosition", "lastIndex", "placementThoughtsOfChild", "placementThoughtsOfFamily", "otherData", "specifyReason", "overallObservation", "totalScore", "schedulingOption", "isActive", "isDeleted", "createdBy", "updatedBy", "assessmentStartsAt", "assessmentEndsAt", "isOffline", "deviceType", "followUpRequired", "followUpStatus", "followUpStartedOn", "followUpCompletedOn", "interventionFollowupStep", "createdAt", "updatedAt", "HTFormId", "HTCaseId", "HTAssessmentVisitTypeId", "HTAssessmentReintegrationTypeId") FROM stdin;
43	t	2024-05-23 00:00:00+00	t	0		10	44	Good	Good	\N	N/A	There is help needed	69.3	Monthly	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	5f8e4c5a-738e-497d-8957-9f226e1e42b0	2024-05-22 19:10:10.948+00	2024-05-23 06:18:14.181+00	f	MOBILE	t	Pending	2024-05-23 06:02:37.297+00	2024-05-23 06:02:37.297+00	3	2024-05-22 19:11:41.878+00	2024-05-23 06:18:16.926+00	20	33	4	2
35	f	2024-07-25 00:00:00+00	f	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	f	\N	\N	\N	\N	\N	UNKNOWN	f		\N	\N	0	2024-04-29 11:48:28.729+00	2024-04-29 11:48:28.729+00	1	29	\N	\N
34	t	2024-04-26 00:00:00+00	t	0		10	42	Aaa	Bbbb	\N	N/A	Aaaa	72.6	Monthly	t	f	d233665e-6b54-479f-a735-14f3747e4f51	d233665e-6b54-479f-a735-14f3747e4f51	2024-04-29 11:46:18.788+00	2024-04-29 11:48:28.609+00	f	MOBILE	t	Completed	2024-05-07 13:08:23.128+00	2024-05-07 13:08:23.128+00	3	2024-04-29 11:46:57.291+00	2024-05-07 13:08:23.128+00	1	29	2	1
30	t	2024-04-11 00:00:00+00	t	0		10	42	S	C	\N	N/A	Xxx	73.8	Fortnightly (Bi-weekly)	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	0fd8f742-ff93-40ec-bc73-1afe6db61479	2024-04-15 06:40:02.586+00	2024-04-22 09:59:27.31+00	f	MOBILE	t	Completed	2024-05-07 13:09:21.405+00	2024-05-07 13:09:21.405+00	3	2024-04-15 06:42:01.828+00	2024-05-07 13:09:21.405+00	1	26	2	1
37	t	2024-05-08 00:00:00+00	f	0		3	3	X	X	\N	N/A		0	No need for more frequent follow ups - stay with regular schedule	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-08 10:53:11.352+00	\N	f	MOBILE	f		\N	\N	0	2024-05-08 10:53:42.736+00	2024-05-08 10:53:42.736+00	17	24	1	1
46	f	2024-08-20 00:00:00+00	f	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	f	\N	\N	\N	\N	\N	UNKNOWN	f		\N	\N	0	2024-05-22 21:23:52.601+00	2024-05-22 21:23:52.601+00	1	34	\N	\N
32	f	2024-07-18 00:00:00+00	f	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	f	\N	\N	\N	\N	\N	UNKNOWN	f		\N	\N	0	2024-04-19 09:49:09.466+00	2024-04-19 09:49:09.466+00	1	23	\N	\N
31	t	2024-04-19 00:00:00+00	t	0		10	42	Hi	Hi	\N	N/A	 Snd	73.8	No need for more frequent follow ups - stay with regular schedule	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	2024-04-19 09:47:55.989+00	2024-04-19 09:49:09.356+00	f	MOBILE	f		\N	\N	0	2024-04-19 09:48:31.486+00	2024-04-19 09:49:11.76+00	1	23	2	2
45	t	2024-05-22 00:00:00+00	t	0		10	43	Loved being with dad	Dad does not have income	\N	N/A	Child is safe at home and father is looking for stable work	73.8	Fortnightly (Bi-weekly)	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	2024-05-22 21:18:40.676+00	2024-05-22 21:23:52.499+00	f	MOBILE	t	Pending	\N	\N	3	2024-05-22 21:19:49.642+00	2024-05-22 21:25:07.573+00	1	34	1	1
38	f	2024-07-30 00:00:00+00	f	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	f	\N	\N	\N	\N	\N	UNKNOWN	f		\N	\N	0	2024-05-13 09:06:38.854+00	2024-05-13 09:06:38.854+00	17	24	\N	\N
36	t	2024-05-01 00:00:00+00	t	0		10	15	X	X	\N	N/A	Consider other FBAC	75	No need for more frequent follow ups - stay with regular schedule	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	2024-05-08 10:47:30.965+00	2024-05-13 09:06:38.816+00	f	MOBILE	f		\N	\N	0	2024-05-08 10:49:01.293+00	2024-05-13 09:06:41.56+00	17	24	1	1
33	f	2024-07-10 00:00:00+00	f	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	f	\N	\N	\N	\N	\N	UNKNOWN	f		\N	\N	0	2024-04-22 09:59:27.42+00	2024-04-22 09:59:27.42+00	1	26	\N	\N
44	f	2024-08-21 00:00:00+00	f	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	f	\N	\N	\N	\N	\N	UNKNOWN	f		\N	\N	0	2024-05-22 19:19:17.339+00	2024-05-22 19:19:17.339+00	20	33	\N	\N
41	f	2024-08-19 00:00:00+00	f	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	f	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	\N	\N	UNKNOWN	f		\N	\N	0	2024-05-21 19:45:56.571+00	2024-05-21 19:56:10.254+00	20	30	\N	\N
40	t	2024-05-21 00:00:00+00	t	0		10	44	loves the idea	wants their child back	\N	N/A	there is help needed	69.3	Monthly	f	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	5f8e4c5a-738e-497d-8957-9f226e1e42b0	2024-05-21 19:38:18.195+00	2024-05-21 19:45:56.484+00	f	MOBILE	t	Pending	\N	\N	3	2024-05-21 19:40:08.435+00	2024-05-21 19:56:10.254+00	20	30	2	2
39	t	2024-05-03 00:00:00+00	t	0		10	15	Prev Sep Redflag 1	Good	\N	N/A	No reintegration	71.7	Every 2 Months (Bi-monthly)	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	2024-05-13 09:07:11.872+00	2024-05-13 09:09:49.003+00	f	MOBILE	t	Completed	2024-05-22 12:47:23.356+00	2024-05-22 12:47:23.356+00	3	2024-05-13 09:08:13.498+00	2024-05-22 12:47:23.356+00	17	24	1	1
42	t	2024-05-04 00:00:00+00	t	0		10	15	Good	Good	\N	N/A	Expedited case management 	63.3	As Needed	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	2024-05-22 12:48:27.666+00	2024-05-22 12:54:19.742+00	f	MOBILE	t	Completed	2024-05-22 12:56:20.61+00	2024-05-22 12:56:20.61+00	3	2024-05-22 12:49:18.054+00	2024-05-22 12:56:20.611+00	17	24	1	1
\.


--
-- Data for Name: HT_assmntReintegrationTypeLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_assmntReintegrationTypeLangMaps" (id, "reIntegrationType", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTAssessmentReintegrationTypeId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_assmntVisitTypeLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_assmntVisitTypeLangMaps" (id, "visitType", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTAssessmentVisitTypeId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_auditLogs; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_auditLogs" (id, entity, oldvalue, newvalue, "updateGroupId", "moduleType", "isActive", "isDeleted", "createdAt", "updatedAt", "HTChildId", "HTCaseId", "HTFamilyId", "HTFamilyMemberId", "HTUserId", "HTAccountId", "HTAssessmentId", "updatedUserId") FROM stdin;
136	email		svsvdsvsv@sdg.sdssddsf.com	1712819304586	child	t	f	2024-04-11 07:08:24.586+00	2024-04-11 07:08:24.586+00	32	\N	\N	\N	\N	\N	\N	c9326236-e7a4-47c8-8788-444247e7d23a
137	email	svsvdsvsv@sdg.sdssddsf.com	svsvdsvsv@sdg.dssddsf.com	1712819351014	child	t	f	2024-04-11 07:09:11.014+00	2024-04-11 07:09:11.014+00	32	\N	\N	\N	\N	\N	\N	c9326236-e7a4-47c8-8788-444247e7d23a
138	familyName	Ethan Hunt	Ethan Hunt CM Family	1712839908036	family	t	f	2024-04-11 12:51:48.036+00	2024-04-11 12:51:48.036+00	\N	\N	40	\N	\N	\N	\N	46e42a63-ded5-486b-9203-d5e523f745fb
139	currentPagePosition	3	4	1713163329305	assessment	t	f	2024-04-15 06:42:09.305+00	2024-04-15 06:42:09.305+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
140	lastIndex	10	19	1713163329305	assessment	t	f	2024-04-15 06:42:09.305+00	2024-04-15 06:42:09.305+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
141	currentPagePosition	4	5	1713163336058	assessment	t	f	2024-04-15 06:42:16.058+00	2024-04-15 06:42:16.058+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
142	lastIndex	19	23	1713163336058	assessment	t	f	2024-04-15 06:42:16.058+00	2024-04-15 06:42:16.058+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
143	currentPagePosition	5	6	1713163339489	assessment	t	f	2024-04-15 06:42:19.489+00	2024-04-15 06:42:19.489+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
144	lastIndex	23	29	1713163339489	assessment	t	f	2024-04-15 06:42:19.489+00	2024-04-15 06:42:19.489+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
145	currentPagePosition	6	7	1713163350773	assessment	t	f	2024-04-15 06:42:30.773+00	2024-04-15 06:42:30.773+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
146	lastIndex	29	42	1713163350773	assessment	t	f	2024-04-15 06:42:30.773+00	2024-04-15 06:42:30.773+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
147	totalScore	0	73.2	1713163403516	assessment	t	f	2024-04-15 06:43:23.516+00	2024-04-15 06:43:23.516+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
148	HTFamilyId	\N	\N	1713420210904	child	t	f	2024-04-18 06:03:30.904+00	2024-04-18 06:03:30.904+00	32	\N	\N	\N	\N	\N	\N	f191b1cc-f282-4080-8c60-3f757aacca6d
149	currentPagePosition	3	4	1713520112908	assessment	t	f	2024-04-19 09:48:32.908+00	2024-04-19 09:48:32.908+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
150	lastIndex	10	19	1713520112908	assessment	t	f	2024-04-19 09:48:32.908+00	2024-04-19 09:48:32.908+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
151	currentPagePosition	4	5	1713520115618	assessment	t	f	2024-04-19 09:48:35.619+00	2024-04-19 09:48:35.619+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
152	lastIndex	19	23	1713520115618	assessment	t	f	2024-04-19 09:48:35.619+00	2024-04-19 09:48:35.619+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
153	currentPagePosition	5	6	1713520119546	assessment	t	f	2024-04-19 09:48:39.546+00	2024-04-19 09:48:39.546+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
154	lastIndex	23	29	1713520119546	assessment	t	f	2024-04-19 09:48:39.546+00	2024-04-19 09:48:39.546+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
155	currentPagePosition	6	7	1713520127987	assessment	t	f	2024-04-19 09:48:47.987+00	2024-04-19 09:48:47.987+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
156	lastIndex	29	42	1713520127987	assessment	t	f	2024-04-19 09:48:47.987+00	2024-04-19 09:48:47.987+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
157	isComplete	false	true	1713520149536	assessment	t	f	2024-04-19 09:49:09.536+00	2024-04-19 09:49:09.536+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
158	currentPagePosition	7	10	1713520149536	assessment	t	f	2024-04-19 09:49:09.536+00	2024-04-19 09:49:09.536+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
159	overallObservation		 Snd	1713520149536	assessment	t	f	2024-04-19 09:49:09.536+00	2024-04-19 09:49:09.536+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
160	totalScore	0	73.8	1713520149536	assessment	t	f	2024-04-19 09:49:09.536+00	2024-04-19 09:49:09.536+00	\N	\N	\N	\N	\N	\N	31	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
161	placementThoughtsOfChild	Xxxx	S	1713779880864	assessment	t	f	2024-04-22 09:58:00.864+00	2024-04-22 09:58:00.864+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
162	placementThoughtsOfFamily	Xxxx	C	1713779880864	assessment	t	f	2024-04-22 09:58:00.864+00	2024-04-22 09:58:00.864+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
163	HTAssessmentVisitTypeId	\N	\N	1713779880864	assessment	t	f	2024-04-22 09:58:00.864+00	2024-04-22 09:58:00.864+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
164	isComplete	false	true	1713779967510	assessment	t	f	2024-04-22 09:59:27.51+00	2024-04-22 09:59:27.51+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
165	currentPagePosition	7	10	1713779967510	assessment	t	f	2024-04-22 09:59:27.51+00	2024-04-22 09:59:27.51+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
166	overallObservation		Xxx	1713779967510	assessment	t	f	2024-04-22 09:59:27.51+00	2024-04-22 09:59:27.51+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
167	totalScore	73.2	73.8	1713779967510	assessment	t	f	2024-04-22 09:59:27.51+00	2024-04-22 09:59:27.51+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
168	schedulingOption	No need for more frequent follow ups - stay with regular schedule	Fortnightly (Bi-weekly)	1713779967510	assessment	t	f	2024-04-22 09:59:27.51+00	2024-04-22 09:59:27.51+00	\N	\N	\N	\N	\N	\N	30	0fd8f742-ff93-40ec-bc73-1afe6db61479
169	HTUserId	\N	\N	1713819242363	case	t	f	2024-04-22 20:54:02.363+00	2024-04-22 20:54:02.363+00	\N	27	\N	\N	\N	\N	\N	c4397112-5c3e-4ef8-9b9b-9769ab180eb8
170	firstName	TSChild2	TSChild2_	1713819898452	child	t	f	2024-04-22 21:04:58.452+00	2024-04-22 21:04:58.452+00	37	\N	\N	\N	\N	\N	\N	c4397112-5c3e-4ef8-9b9b-9769ab180eb8
171	firstName	TSChild1	TSChild1_	1713819937868	child	t	f	2024-04-22 21:05:37.868+00	2024-04-22 21:05:37.868+00	36	\N	\N	\N	\N	\N	\N	f594d8ce-8c18-4f70-a85f-72619d372a4d
172	HTFamilyId	\N	\N	1713820040480	child	t	f	2024-04-22 21:07:20.481+00	2024-04-22 21:07:20.481+00	36	\N	\N	\N	\N	\N	\N	f594d8ce-8c18-4f70-a85f-72619d372a4d
173	email	AddMemberTest@mailinator.com		1714367487133	familyMember	t	f	2024-04-29 05:11:27.133+00	2024-04-29 05:11:27.133+00	\N	\N	\N	42	\N	\N	\N	f191b1cc-f282-4080-8c60-3f757aacca6d
174	occupation	AddMemberTest@mailinator.com		1714367562936	familyMember	t	f	2024-04-29 05:12:42.937+00	2024-04-29 05:12:42.937+00	\N	\N	\N	42	\N	\N	\N	f191b1cc-f282-4080-8c60-3f757aacca6d
175	email		AddMemberTest@mailinator.com	1714367562936	familyMember	t	f	2024-04-29 05:12:42.937+00	2024-04-29 05:12:42.937+00	\N	\N	\N	42	\N	\N	\N	f191b1cc-f282-4080-8c60-3f757aacca6d
176	HTFamilyId	\N	\N	1714368649926	child	t	f	2024-04-29 05:30:49.926+00	2024-04-29 05:30:49.926+00	32	\N	\N	\N	\N	\N	\N	f191b1cc-f282-4080-8c60-3f757aacca6d
177	HTFamilyId	\N	\N	1714368660252	child	t	f	2024-04-29 05:31:00.252+00	2024-04-29 05:31:00.252+00	32	\N	\N	\N	\N	\N	\N	f191b1cc-f282-4080-8c60-3f757aacca6d
178	currentPagePosition	3	4	1714391223041	assessment	t	f	2024-04-29 11:47:03.041+00	2024-04-29 11:47:03.041+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
179	lastIndex	10	19	1714391223041	assessment	t	f	2024-04-29 11:47:03.041+00	2024-04-29 11:47:03.041+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
180	currentPagePosition	4	5	1714391226442	assessment	t	f	2024-04-29 11:47:06.442+00	2024-04-29 11:47:06.442+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
181	lastIndex	19	23	1714391226442	assessment	t	f	2024-04-29 11:47:06.442+00	2024-04-29 11:47:06.442+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
182	currentPagePosition	5	6	1714391231353	assessment	t	f	2024-04-29 11:47:11.353+00	2024-04-29 11:47:11.353+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
183	lastIndex	23	29	1714391231353	assessment	t	f	2024-04-29 11:47:11.353+00	2024-04-29 11:47:11.353+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
184	currentPagePosition	6	7	1714391243411	assessment	t	f	2024-04-29 11:47:23.411+00	2024-04-29 11:47:23.411+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
185	lastIndex	29	42	1714391243411	assessment	t	f	2024-04-29 11:47:23.411+00	2024-04-29 11:47:23.411+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
186	isComplete	false	true	1714391308803	assessment	t	f	2024-04-29 11:48:28.803+00	2024-04-29 11:48:28.803+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
187	currentPagePosition	7	10	1714391308803	assessment	t	f	2024-04-29 11:48:28.803+00	2024-04-29 11:48:28.803+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
188	overallObservation		Aaaa	1714391308803	assessment	t	f	2024-04-29 11:48:28.803+00	2024-04-29 11:48:28.803+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
189	totalScore	0	72.6	1714391308803	assessment	t	f	2024-04-29 11:48:28.803+00	2024-04-29 11:48:28.803+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
190	schedulingOption	No need for more frequent follow ups - stay with regular schedule	Monthly	1714391308803	assessment	t	f	2024-04-29 11:48:28.803+00	2024-04-29 11:48:28.803+00	\N	\N	\N	\N	\N	\N	34	d233665e-6b54-479f-a735-14f3747e4f51
191	totalScore	0	15	1715591153244	assessment	t	f	2024-05-13 09:05:53.244+00	2024-05-13 09:05:53.244+00	\N	\N	\N	\N	\N	\N	36	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
192	currentPagePosition	3	4	1715591155991	assessment	t	f	2024-05-13 09:05:55.991+00	2024-05-13 09:05:55.991+00	\N	\N	\N	\N	\N	\N	36	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
193	lastIndex	3	6	1715591155991	assessment	t	f	2024-05-13 09:05:55.991+00	2024-05-13 09:05:55.991+00	\N	\N	\N	\N	\N	\N	36	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
194	currentPagePosition	4	6	1715591158482	assessment	t	f	2024-05-13 09:05:58.482+00	2024-05-13 09:05:58.482+00	\N	\N	\N	\N	\N	\N	36	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
195	lastIndex	6	12	1715591158482	assessment	t	f	2024-05-13 09:05:58.482+00	2024-05-13 09:05:58.482+00	\N	\N	\N	\N	\N	\N	36	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
196	currentPagePosition	6	7	1715591160536	assessment	t	f	2024-05-13 09:06:00.536+00	2024-05-13 09:06:00.536+00	\N	\N	\N	\N	\N	\N	36	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
197	lastIndex	12	15	1715591160536	assessment	t	f	2024-05-13 09:06:00.536+00	2024-05-13 09:06:00.536+00	\N	\N	\N	\N	\N	\N	36	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
198	isComplete	false	true	1715591198929	assessment	t	f	2024-05-13 09:06:38.929+00	2024-05-13 09:06:38.929+00	\N	\N	\N	\N	\N	\N	36	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
199	currentPagePosition	7	10	1715591198929	assessment	t	f	2024-05-13 09:06:38.929+00	2024-05-13 09:06:38.929+00	\N	\N	\N	\N	\N	\N	36	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
200	overallObservation		Consider other FBAC	1715591198929	assessment	t	f	2024-05-13 09:06:38.929+00	2024-05-13 09:06:38.929+00	\N	\N	\N	\N	\N	\N	36	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
201	totalScore	15	75	1715591198929	assessment	t	f	2024-05-13 09:06:38.929+00	2024-05-13 09:06:38.929+00	\N	\N	\N	\N	\N	\N	36	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
202	currentPagePosition	3	4	1715591295100	assessment	t	f	2024-05-13 09:08:15.1+00	2024-05-13 09:08:15.1+00	\N	\N	\N	\N	\N	\N	39	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
203	lastIndex	3	6	1715591295100	assessment	t	f	2024-05-13 09:08:15.1+00	2024-05-13 09:08:15.1+00	\N	\N	\N	\N	\N	\N	39	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
204	currentPagePosition	4	6	1715591298325	assessment	t	f	2024-05-13 09:08:18.325+00	2024-05-13 09:08:18.325+00	\N	\N	\N	\N	\N	\N	39	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
205	lastIndex	6	12	1715591298325	assessment	t	f	2024-05-13 09:08:18.325+00	2024-05-13 09:08:18.325+00	\N	\N	\N	\N	\N	\N	39	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
206	currentPagePosition	6	7	1715591299829	assessment	t	f	2024-05-13 09:08:19.829+00	2024-05-13 09:08:19.829+00	\N	\N	\N	\N	\N	\N	39	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
207	lastIndex	12	15	1715591299829	assessment	t	f	2024-05-13 09:08:19.829+00	2024-05-13 09:08:19.829+00	\N	\N	\N	\N	\N	\N	39	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
208	isComplete	false	true	1715591389106	assessment	t	f	2024-05-13 09:09:49.106+00	2024-05-13 09:09:49.106+00	\N	\N	\N	\N	\N	\N	39	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
209	currentPagePosition	7	10	1715591389106	assessment	t	f	2024-05-13 09:09:49.106+00	2024-05-13 09:09:49.106+00	\N	\N	\N	\N	\N	\N	39	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
210	overallObservation		No reintegration	1715591389106	assessment	t	f	2024-05-13 09:09:49.106+00	2024-05-13 09:09:49.106+00	\N	\N	\N	\N	\N	\N	39	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
211	totalScore	0	71.7	1715591389106	assessment	t	f	2024-05-13 09:09:49.106+00	2024-05-13 09:09:49.106+00	\N	\N	\N	\N	\N	\N	39	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
212	schedulingOption	No need for more frequent follow ups - stay with regular schedule	Every 2 Months (Bi-monthly)	1715591389106	assessment	t	f	2024-05-13 09:09:49.106+00	2024-05-13 09:09:49.106+00	\N	\N	\N	\N	\N	\N	39	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
213	primaryCareGiver	false	true	1716189998646	familyMember	t	f	2024-05-20 07:26:38.646+00	2024-05-20 07:26:38.646+00	\N	\N	\N	43	\N	\N	\N	d233665e-6b54-479f-a735-14f3747e4f51
214	primaryCareGiver	false	true	1716283210985	familyMember	t	f	2024-05-21 09:20:10.986+00	2024-05-21 09:20:10.986+00	\N	\N	\N	44	\N	\N	\N	d233665e-6b54-479f-a735-14f3747e4f51
215	currentPagePosition	3	4	1716320439228	assessment	t	f	2024-05-21 19:40:39.228+00	2024-05-21 19:40:39.228+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
216	lastIndex	12	21	1716320439228	assessment	t	f	2024-05-21 19:40:39.228+00	2024-05-21 19:40:39.228+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
217	currentPagePosition	4	5	1716320452841	assessment	t	f	2024-05-21 19:40:52.841+00	2024-05-21 19:40:52.841+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
218	lastIndex	21	25	1716320452841	assessment	t	f	2024-05-21 19:40:52.841+00	2024-05-21 19:40:52.841+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
219	currentPagePosition	5	6	1716320464180	assessment	t	f	2024-05-21 19:41:04.18+00	2024-05-21 19:41:04.18+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
220	lastIndex	25	31	1716320464180	assessment	t	f	2024-05-21 19:41:04.18+00	2024-05-21 19:41:04.18+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
221	currentPagePosition	6	7	1716320494295	assessment	t	f	2024-05-21 19:41:34.295+00	2024-05-21 19:41:34.295+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
222	lastIndex	31	44	1716320494295	assessment	t	f	2024-05-21 19:41:34.295+00	2024-05-21 19:41:34.295+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
223	totalScore	0	69.3	1716320512278	assessment	t	f	2024-05-21 19:41:52.278+00	2024-05-21 19:41:52.278+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
224	isComplete	false	true	1716320756682	assessment	t	f	2024-05-21 19:45:56.682+00	2024-05-21 19:45:56.682+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
225	currentPagePosition	7	10	1716320756682	assessment	t	f	2024-05-21 19:45:56.682+00	2024-05-21 19:45:56.682+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
226	overallObservation		there is help needed	1716320756682	assessment	t	f	2024-05-21 19:45:56.682+00	2024-05-21 19:45:56.682+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
227	schedulingOption	No need for more frequent follow ups - stay with regular schedule	Monthly	1716320756682	assessment	t	f	2024-05-21 19:45:56.682+00	2024-05-21 19:45:56.682+00	\N	\N	\N	\N	\N	\N	40	5f8e4c5a-738e-497d-8957-9f226e1e42b0
228	currentPagePosition	3	4	1716382171566	assessment	t	f	2024-05-22 12:49:31.566+00	2024-05-22 12:49:31.566+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
229	lastIndex	3	6	1716382171566	assessment	t	f	2024-05-22 12:49:31.566+00	2024-05-22 12:49:31.566+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
230	currentPagePosition	4	5	1716382177208	assessment	t	f	2024-05-22 12:49:37.208+00	2024-05-22 12:49:37.208+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
231	lastIndex	6	9	1716382177208	assessment	t	f	2024-05-22 12:49:37.208+00	2024-05-22 12:49:37.208+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
232	currentPagePosition	5	6	1716382181245	assessment	t	f	2024-05-22 12:49:41.246+00	2024-05-22 12:49:41.246+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
233	lastIndex	9	12	1716382181245	assessment	t	f	2024-05-22 12:49:41.246+00	2024-05-22 12:49:41.246+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
234	currentPagePosition	6	7	1716382187771	assessment	t	f	2024-05-22 12:49:47.771+00	2024-05-22 12:49:47.771+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
235	lastIndex	12	15	1716382187771	assessment	t	f	2024-05-22 12:49:47.771+00	2024-05-22 12:49:47.771+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
236	totalScore	0	63.3	1716382194997	assessment	t	f	2024-05-22 12:49:54.997+00	2024-05-22 12:49:54.997+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
237	overallObservation		Expedited case management 	1716382403818	assessment	t	f	2024-05-22 12:53:23.818+00	2024-05-22 12:53:23.818+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
238	schedulingOption	No need for more frequent follow ups - stay with regular schedule	As Needed	1716382403818	assessment	t	f	2024-05-22 12:53:23.818+00	2024-05-22 12:53:23.818+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
239	isComplete	false	true	1716382459840	assessment	t	f	2024-05-22 12:54:19.84+00	2024-05-22 12:54:19.84+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
240	currentPagePosition	7	10	1716382459840	assessment	t	f	2024-05-22 12:54:19.84+00	2024-05-22 12:54:19.84+00	\N	\N	\N	\N	\N	\N	42	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
241	currentPagePosition	3	4	1716405112252	assessment	t	f	2024-05-22 19:11:52.252+00	2024-05-22 19:11:52.252+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
242	lastIndex	12	21	1716405112252	assessment	t	f	2024-05-22 19:11:52.252+00	2024-05-22 19:11:52.252+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
243	currentPagePosition	4	5	1716405124943	assessment	t	f	2024-05-22 19:12:04.943+00	2024-05-22 19:12:04.943+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
244	lastIndex	21	25	1716405124943	assessment	t	f	2024-05-22 19:12:04.943+00	2024-05-22 19:12:04.943+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
245	currentPagePosition	5	6	1716405137369	assessment	t	f	2024-05-22 19:12:17.369+00	2024-05-22 19:12:17.369+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
246	lastIndex	25	31	1716405137369	assessment	t	f	2024-05-22 19:12:17.369+00	2024-05-22 19:12:17.369+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
247	currentPagePosition	6	7	1716405165218	assessment	t	f	2024-05-22 19:12:45.218+00	2024-05-22 19:12:45.218+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
248	lastIndex	31	44	1716405165218	assessment	t	f	2024-05-22 19:12:45.218+00	2024-05-22 19:12:45.218+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
249	totalScore	0	70.5	1716405169781	assessment	t	f	2024-05-22 19:12:49.781+00	2024-05-22 19:12:49.781+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
250	overallObservation		Expedited case management 	1716405463119	assessment	t	f	2024-05-22 19:17:43.119+00	2024-05-22 19:17:43.119+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
251	isComplete	false	true	1716405557477	assessment	t	f	2024-05-22 19:19:17.477+00	2024-05-22 19:19:17.477+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
252	currentPagePosition	7	10	1716405557477	assessment	t	f	2024-05-22 19:19:17.477+00	2024-05-22 19:19:17.477+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
253	schedulingOption	No need for more frequent follow ups - stay with regular schedule	Monthly	1716405557477	assessment	t	f	2024-05-22 19:19:17.477+00	2024-05-22 19:19:17.477+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
254	currentPagePosition	3	4	1716412819144	assessment	t	f	2024-05-22 21:20:19.144+00	2024-05-22 21:20:19.144+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
255	lastIndex	11	20	1716412819144	assessment	t	f	2024-05-22 21:20:19.144+00	2024-05-22 21:20:19.144+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
256	currentPagePosition	4	5	1716412828709	assessment	t	f	2024-05-22 21:20:28.709+00	2024-05-22 21:20:28.709+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
257	lastIndex	20	24	1716412828709	assessment	t	f	2024-05-22 21:20:28.709+00	2024-05-22 21:20:28.709+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
258	currentPagePosition	5	6	1716412834961	assessment	t	f	2024-05-22 21:20:34.961+00	2024-05-22 21:20:34.961+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
259	lastIndex	24	30	1716412834961	assessment	t	f	2024-05-22 21:20:34.961+00	2024-05-22 21:20:34.961+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
260	currentPagePosition	6	7	1716412847144	assessment	t	f	2024-05-22 21:20:47.144+00	2024-05-22 21:20:47.144+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
261	lastIndex	30	43	1716412847144	assessment	t	f	2024-05-22 21:20:47.144+00	2024-05-22 21:20:47.144+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
262	isComplete	false	true	1716413032691	assessment	t	f	2024-05-22 21:23:52.691+00	2024-05-22 21:23:52.691+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
263	currentPagePosition	7	10	1716413032691	assessment	t	f	2024-05-22 21:23:52.691+00	2024-05-22 21:23:52.691+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
264	overallObservation		Child is safe at home and father is looking for stable work	1716413032691	assessment	t	f	2024-05-22 21:23:52.691+00	2024-05-22 21:23:52.691+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
265	totalScore	0	73.8	1716413032691	assessment	t	f	2024-05-22 21:23:52.691+00	2024-05-22 21:23:52.691+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
266	schedulingOption	No need for more frequent follow ups - stay with regular schedule	Fortnightly (Bi-weekly)	1716413032691	assessment	t	f	2024-05-22 21:23:52.691+00	2024-05-22 21:23:52.691+00	\N	\N	\N	\N	\N	\N	45	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
267	overallObservation	Expedited case management 	There is help needed	1716445094372	assessment	t	f	2024-05-23 06:18:14.372+00	2024-05-23 06:18:14.372+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
268	HTAssessmentVisitTypeId	\N	\N	1716445094372	assessment	t	f	2024-05-23 06:18:14.372+00	2024-05-23 06:18:14.372+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
269	HTAssessmentReintegrationTypeId	\N	\N	1716445094372	assessment	t	f	2024-05-23 06:18:14.372+00	2024-05-23 06:18:14.372+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
270	totalScore	70.5	69.3	1716445096906	assessment	t	f	2024-05-23 06:18:16.943+00	2024-05-23 06:18:16.943+00	\N	\N	\N	\N	\N	\N	43	5f8e4c5a-738e-497d-8957-9f226e1e42b0
\.


--
-- Data for Name: HT_cases; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_cases" (id, "startDate", "endDate", "caseStatus", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTChildId", "HTUserId") FROM stdin;
24	\N	\N	Open	t	f	0d59b8f7-807c-4ed8-9620-69ca71ae5b34	0d59b8f7-807c-4ed8-9620-69ca71ae5b34	2024-04-11 10:30:46.087+00	2024-05-22 12:38:23.265+00	33	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
33	\N	\N	Open	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	5f8e4c5a-738e-497d-8957-9f226e1e42b0	2024-05-22 19:05:08.854+00	2024-05-22 19:05:08.854+00	42	5f8e4c5a-738e-497d-8957-9f226e1e42b0
25	\N	\N	Open	t	f	46e42a63-ded5-486b-9203-d5e523f745fb	46e42a63-ded5-486b-9203-d5e523f745fb	2024-04-11 12:47:52.757+00	2024-04-11 12:47:52.757+00	34	46e42a63-ded5-486b-9203-d5e523f745fb
26	\N	\N	Open	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	0fd8f742-ff93-40ec-bc73-1afe6db61479	2024-04-15 06:39:23.622+00	2024-04-15 06:39:23.622+00	35	0fd8f742-ff93-40ec-bc73-1afe6db61479
34	\N	\N	Open	t	f	32d34875-6aa0-4e97-9b8b-8f822263cbd1	32d34875-6aa0-4e97-9b8b-8f822263cbd1	2024-05-22 20:32:23.971+00	2024-05-22 20:32:23.971+00	43	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
28	\N	\N	Open	t	f	c4397112-5c3e-4ef8-9b9b-9769ab180eb8	c4397112-5c3e-4ef8-9b9b-9769ab180eb8	2024-04-22 21:02:10.249+00	2024-04-22 21:04:58.762+00	37	eacf4720-0eae-47c5-8afe-e8a9c3ac7bc4
27	\N	\N	Open	t	f	c4397112-5c3e-4ef8-9b9b-9769ab180eb8	f594d8ce-8c18-4f70-a85f-72619d372a4d	2024-04-22 20:48:45.991+00	2024-04-22 21:07:20.81+00	36	eacf4720-0eae-47c5-8afe-e8a9c3ac7bc4
29	\N	\N	Open	t	f	d233665e-6b54-479f-a735-14f3747e4f51	d233665e-6b54-479f-a735-14f3747e4f51	2024-04-29 11:45:41.234+00	2024-04-29 11:45:41.234+00	38	d233665e-6b54-479f-a735-14f3747e4f51
23	\N	\N	Open	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-04-08 05:26:04.184+00	2024-05-10 05:45:50.764+00	32	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
30	\N	\N	Open	f	f	0ac84ba8-9cd7-4536-a3c9-aff6b4b69f68	5f8e4c5a-738e-497d-8957-9f226e1e42b0	2024-05-20 13:15:39.429+00	2024-05-21 19:56:10.25+00	39	5f8e4c5a-738e-497d-8957-9f226e1e42b0
32	\N	\N	Open	t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-05-22 10:20:01.537+00	2024-05-22 10:20:01.537+00	41	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
\.


--
-- Data for Name: HT_childCareGiverMappings; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_childCareGiverMappings" (id, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTFamilyMemberId", "HTChildId") FROM stdin;
\.


--
-- Data for Name: HT_childConsentLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_childConsentLangMaps" (id, "consentLanguageText", "consentLanguageStatus", "createdAt", "updatedAt", "HTLanguageId") FROM stdin;
1	{"header":"Informed Consent","description":"Consent is for the completion of the Thrive Scale assessment on your family.","points":["This assessment will help us understand your family's strengths and needs in five areas including: Family & Social Relationships, Household Economy, Living Conditions, Education, and Health & Mental Health.","After completing this assessment, I (the social worker) will provide support to improve your areas of need.","All data is confidential; only those directly supporting your family and child will have access to this information."],"footer":"By clicking the box below, you are acknowledging that you agree to the above statements for [ChildName] on [Date]."}	t	2023-04-26 10:53:42.042+00	2023-04-26 10:53:42.042+00	1
2	{"header":"सूचित सहमति","description":"सहमति आपके परिवार पर थ्राइव स्केल मूल्यांकन को पूरा करने के लिए है।","points":["यह मूल्यांकन हमें पांच क्षेत्रों में आपके परिवार की ताकत और जरूरतों को समझने में मदद करेगा, जिनमें शामिल हैं: पारिवारिक और सामाजिक संबंध, घरेलू अर्थव्यवस्था, रहने की स्थिति, शिक्षा और स्वास्थ्य और मानसिक स्वास्थ्य।","इस आकलन को पूरा करने के बाद, मैं (सामाजिक कार्यकर्ता) आपकी जरूरत के क्षेत्रों में सुधार करने के लिए सहायता प्रदान करूंगा।","सभी डेटा गोपनीय हैं; केवल वे लोग जो सीधे आपके परिवार और बच्चे का समर्थन कर रहे हैं, इस जानकारी तक पहुंच पाएंगे।"],"footer":"नीचे दिए गए बॉक्स पर क्लिक करके, आप स्वीकार कर रहे हैं कि आप उपरोक्त कथनों के लिए सहमत हैं [ChildName] पर [Date]."}	t	2023-04-26 10:53:42.042+00	2023-04-26 10:53:42.042+00	\N
3	{"header":"அறிவிக்கப்பட்ட முடிவு","description":"உங்கள் குடும்பத்தில் த்ரைவ் ஸ்கேல் மதிப்பீட்டை முடிப்பதற்கான ஒப்புதல்.","points":["குடும்பம் மற்றும் சமூக உறவுகள், குடும்பப் பொருளாதாரம், வாழ்க்கை நிலைமைகள், கல்வி மற்றும் உடல்நலம் & மனநலம் உள்ளிட்ட ஐந்து பகுதிகளில் உங்கள் குடும்பத்தின் பலம் மற்றும் தேவைகளைப் புரிந்துகொள்ள இந்த மதிப்பீடு உதவும்.","இந்த மதிப்பீட்டை முடித்த பிறகு, நான் (சமூக சேவகர்) உங்களுக்கு தேவைப்படும் பகுதிகளை மேம்படுத்த ஆதரவை வழங்குவேன்.","அனைத்து தரவு ரகசியமானது; உங்கள் குடும்பம் மற்றும் குழந்தைக்கு நேரடியாக ஆதரவளிப்பவர்கள் மட்டுமே இந்தத் தகவலை அணுக முடியும்."],"footer":"கீழேயுள்ள பெட்டியைக் கிளிக் செய்வதன் மூலம், [Date] அன்று [ChildName] க்கான மேலே உள்ள அறிக்கைகளை ஏற்றுக்கொள்கிறீர்கள் என்பதை ஒப்புக்கொள்கிறீர்கள்."}	t	2023-04-26 10:53:42.042+00	2023-04-26 10:53:42.042+00	\N
\.


--
-- Data for Name: HT_childConsents; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_childConsents" (id, "primaryCareGiver", "consentStatus", "dateOfEntry", "createdAt", "updatedAt", "HTFamilyRelationId", "HTChildId", "HTUserId") FROM stdin;
5	test member	ACCEPTED	2024-04-15 06:40:01.26+00	2024-04-15 06:40:01.262+00	2024-04-15 06:40:01.262+00	2	35	0fd8f742-ff93-40ec-bc73-1afe6db61479
6	shhe	ACCEPTED	2024-04-19 09:47:54.43+00	2024-04-19 09:47:54.432+00	2024-04-19 09:47:54.432+00	6	32	75579cd6-8fbd-4c3b-9c8b-9faf5b475018
7	Sreeraj Consent Test	ACCEPTED	2024-04-24 09:42:35.78+00	2024-04-24 09:42:35.782+00	2024-04-24 09:42:35.782+00	2	33	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b
8	ABC	ACCEPTED	2024-04-29 11:46:17.223+00	2024-04-29 11:46:17.224+00	2024-04-29 11:46:17.224+00	1	38	d233665e-6b54-479f-a735-14f3747e4f51
9	Tina Max	ACCEPTED	2024-05-20 15:55:36.861+00	2024-05-20 15:55:36.863+00	2024-05-20 15:55:36.863+00	1	39	5f8e4c5a-738e-497d-8957-9f226e1e42b0
10	sreeraj	ACCEPTED	2024-05-22 19:10:03.951+00	2024-05-22 19:10:03.953+00	2024-05-22 19:10:03.953+00	1	42	5f8e4c5a-738e-497d-8957-9f226e1e42b0
11	Marko	ACCEPTED	2024-05-22 21:18:38.007+00	2024-05-22 21:18:38.009+00	2024-05-22 21:18:38.009+00	2	43	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b
\.


--
-- Data for Name: HT_childCurrentPlacementStatuses; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_childCurrentPlacementStatuses" (id, "currentPlacementStatus", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "currentPlacementStatusLang") FROM stdin;
1	Institutional Care	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Institutional Care", "2": "संस्थागत देखभाल", "3": "நிறுவன பராமரிப்பு"}
2	Parents/step parents	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Parents/Step Parents", "2": "माता-पिता / कदम माता-पिता", "3": "பெற்றோர்/ மாற்றான் பெற்றோர்"}
3	Kinship	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Kinship", "2": "समानता", "3": "உறவுமுறை"}
4	Foster care	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Foster Care", "2": "फोस्टर देखभाल", "3": "पालन ​​पोषण संबंधी देखभाल"}
5	After care	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "After Care", "2": "देखभाल के बाद", "3": "தத்திற்குப் பின்னான பராமரிப்பு"}
6	Semi- independent living	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Semi-Independent Living", "2": "अर्ध-स्वतंत्र जीवन", "3": "பகுதி சுயாதீன வாழ்க்கை"}
7	Independent living	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Independent Living", "2": "अकेले रहना", "3": "சுயாதீன வாழ்க்கை"}
8	Group living	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Group Living", "2": "ग्रुप लिविंग", "3": "குழுவாக வாழ்தல்"}
9	Other	t	f	\N	\N	2022-02-23 05:17:56.363+00	2022-02-23 05:17:56.363+00	{"1": "Other", "2": "अन्य", "3": "மற்றவை"}
\.


--
-- Data for Name: HT_childEducationLevels; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_childEducationLevels" (id, "educationLevel", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "educationLevelLang") FROM stdin;
1	Pre-Kindergarten/Pre Primary	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "Pre-Kindergarten/Pre Primary", "2": "पूर्व-प्राथमिक/प्री-प्राइमरी", "3": "மழலையர் பள்ளி/முன் ஆரம்ப பள்ளி"}
2	Kindergarten (LKG)	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "Kindergarten (LKG)", "2": "बालवाड़ी (एल केजी)", "3": "மழலையர் பள்ளி (LKG)"}
3	Kindergarten (UKG)	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "Kindergarten (UKG)", "2": "यूकेजी", "3": "மழலையர் பள்ளி (UKG)"}
4	I	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "I", "2": "पहला", "3": "I"}
5	II	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "II", "2": "दूसरा", "3": "I"}
6	III	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "III", "2": "तीसरा", "3": "III"}
7	IV	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "IV", "2": "चौथी", "3": "IV"}
8	V	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "V", "2": "पांचवां", "3": "V"}
9	VI	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "VI", "2": "छठा", "3": "VI"}
10	VII	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "VII", "2": "सातवीं", "3": "VII"}
11	VIII	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "VIII", "2": "आठवीं", "3": "VIII"}
12	IX	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "IX", "2": "नौवीं", "3": "IX"}
13	X	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "X", "2": "दसवां", "3": "X"}
14	Junior College/XI	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "Junior College/XI", "2": "जूनियर कॉलेज / ग्यारहवें", "3": "இளையவர் கல்லூரி/ XI"}
15	Junior College/XII	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "Junior College/XII", "2": "जूनियर कॉलेज / बारहवीं", "3": "இளையவர் கல்லூரி/ XII"}
16	Vocational Training	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "Vocational Training", "2": "व्यावसायिक प्रशिक्षण", "3": "தொழில் பயிற்சி"}
17	Undergraduate degree	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "Undergraduate Degree", "2": "स्नातक अध्ययन/ अन्डर्ग्रैजूइट", "3": "இளங்கலை பட்டம்"}
18	Associate degree/certificate courses	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "Associate Degree/Certificate Courses", "2": "एसोसिएट डिग्री/सर्टिफिकेट कोर्स", "3": "தோடர்புடய பட்டம் /சான்றிதழ் படிப்புகள்"}
19	Post-graduate degree	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "Post-Graduate Degree", "2": "स्नातकोत्तर/ पी जी डिग्री", "3": "முதுகலை பட்டம்"}
20	Discontinued education (specify highest level of education)	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "Discontinued Education (Specify Highest Level of Education)", "2": "बंद शिक्षा (शिक्षा का उच्चतम स्तर निर्दिष्ट करें)", "3": "கல்வி நிறுத்தப்பட்டது (அதிகப்பட்ச கல்வி நிலையை குறிப்பிடவும்)"}
21	Employed	t	f	\N	\N	2022-02-23 05:17:56.366+00	2022-02-23 05:17:56.366+00	{"1": "Employed", "2": "कार्यरत", "3": "வேலை பார்க்கிறார்"}
22	Illiterate	t	f	\N	\N	2023-04-18 11:06:55.446973+00	2023-04-18 11:06:55.446973+00	{"1": "Illiterate", "2": "अशिक्षित", "3": "அறிவியல்பான"}
\.


--
-- Data for Name: HT_childHistories; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_childHistories" (id, "fromDate", "toDate", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTChildId", "HTFamilyId", "HTFamilyMemberId") FROM stdin;
\.


--
-- Data for Name: HT_childPlacementStatuses; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_childPlacementStatuses" (id, "placementStatus", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "placementStatusLang") FROM stdin;
1	Intake	t	f	\N	\N	2022-02-23 05:17:56.364+00	2022-02-23 05:17:56.364+00	{"1": "Intake", "2": "प्रवेश", "3": "உள்ளே சேர்த்தல்"}
2	Assessment	t	f	\N	\N	2022-02-23 05:17:56.364+00	2022-02-23 05:17:56.364+00	{"1": "Assessment", "2": "मूल्यांकन", "3": "மதிப்பீடு"}
3	Planning	t	f	\N	\N	2022-02-23 05:17:56.364+00	2022-02-23 05:17:56.364+00	{"1": "Planning", "2": "योजना", "3": "திட்டமிடல்"}
4	Implementation	t	f	\N	\N	2022-02-23 05:17:56.364+00	2022-02-23 05:17:56.364+00	{"1": "Implementation", "2": "कार्यान्वयन", "3": "செயல்படுத்துதல்"}
5	Follow up/Evaluate	t	f	\N	\N	2022-02-23 05:17:56.364+00	2022-02-23 05:17:56.364+00	{"1": "Follow up/Evaluate", "2": "अनुवर्ती/मूल्यांकन", "3": "பின்தொடர்பு/மதிப்பீடு"}
6	Case Closed	t	f	\N	\N	2022-02-23 05:17:56.364+00	2022-02-23 05:17:56.364+00	{"1": "Case Closed", "2": "मामला समाप्त", "3": "வழக்கு மூடப்பட்டது"}
\.


--
-- Data for Name: HT_childStatuses; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_childStatuses" (id, status, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "statusLang") FROM stdin;
1	Orphan	t	f	\N	\N	2022-02-23 05:17:56.364+00	2022-02-23 05:17:56.364+00	{"1": "Orphan", "2": "अनाथ", "3": "அனாதை"}
2	Semi-Orphan	t	f	\N	\N	2022-02-23 05:17:56.364+00	2022-02-23 05:17:56.364+00	{"1": "Semi-Orphan", "2": "अर्ध-अनाथ", "3": "பகுதி அனாதை"}
3	Economic Orphan	t	f	\N	\N	2022-02-23 05:17:56.364+00	2022-02-23 05:17:56.364+00	{"1": "Economic Orphan", "2": "आर्थिक अनाथ", "3": "பொருளாதார அனாதை"}
\.


--
-- Data for Name: HT_children; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_children" (id, "firstName", "lastName", "addressLine1", "addressLine2", "zipCode", city, "highestEducationLevel", "birthDate", "dateOfEntry", "dateOfExit", gender, "phoneNumber", email, "isActive", "isDeleted", "createdBy", "updatedBy", "injectiondocId", "createdAt", "updatedAt", "HTFamilyId", "HTAccountId", "HTLanguageId", "HTChildEducationLevelId", "HTCountryId", "HTStateId", "HTDistrictId", "HTChildPlacementStatusId", "HTChildStatusId", "HTChildCurrentPlacementStatusId", "HTChildOldPlacementStatusId") FROM stdin;
34	Catie	CM Child	AD01 WASH DC		12345	DC		2020-03-10 00:00:00+00	\N	\N	Female	+19497288333		t	f	46e42a63-ded5-486b-9203-d5e523f745fb	46e42a63-ded5-486b-9203-d5e523f745fb	\N	2024-04-11 12:47:51.787+00	2024-04-11 12:47:51.787+00	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	2	2	39	\N	1	1	2	\N
35	Test Child	Miracle(jyotir)	Austin Texas		73301	Austin		2020-01-01 00:00:00+00	\N	\N	Male	+12819000000		t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-15 06:39:22.591+00	2024-04-15 06:39:22.591+00	41	0d7b5e4a-9c81-4811-b010-bbef1ff42e28	1	2	2	37	\N	2	3	2	\N
32	child	test	Address 1		32165	texas		2024-02-04 00:00:00+00	\N	\N	Prefer not to disclose	+12255252526	svsvdsvsv@sdg.dssddsf.com	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-08 05:26:00.41+00	2024-05-22 10:00:00.659+00	36	6536ba55-07ba-4c0d-8c63-8891586345c7	3	\N	2	37	\N	\N	\N	\N	\N
37	TSChild2_	Test	123 6th st		78723	City		2024-04-01 00:00:00+00	\N	\N	Female	+17372100120		t	f	c4397112-5c3e-4ef8-9b9b-9769ab180eb8	c4397112-5c3e-4ef8-9b9b-9769ab180eb8	\N	2024-04-22 21:02:09.947+00	2024-04-22 21:04:58.413+00	\N	402e9214-a9d8-4a7a-b01e-5b932a0d1ecf	\N	\N	2	39	\N	\N	\N	\N	\N
36	TSChild1_		123 6th st		78723	test		2023-04-22 00:00:00+00	\N	\N	Male	+17372100120		t	f	c4397112-5c3e-4ef8-9b9b-9769ab180eb8	c4397112-5c3e-4ef8-9b9b-9769ab180eb8	\N	2024-04-22 20:48:45.636+00	2024-04-22 21:07:20.445+00	43	402e9214-a9d8-4a7a-b01e-5b932a0d1ecf	\N	\N	2	37	\N	\N	\N	\N	\N
40	Tijo	Stalin	ascascacacac		21321	acacsasc		2024-03-05 00:00:00+00	\N	\N	Male	+12255654654		t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	\N	2024-05-22 10:07:14.721+00	2024-05-22 10:14:01.654+00	36	6536ba55-07ba-4c0d-8c63-8891586345c7	1	3	2	39	\N	\N	\N	\N	\N
41	test	test	jvhjhjkvjh		67676	hgfjfjh		2013-05-14 00:00:00+00	\N	\N	Male	+12255987987		t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	\N	2024-05-22 10:19:59.365+00	2024-05-22 10:21:57.116+00	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	1	\N	2	37	\N	\N	\N	\N	\N
33	Momo Gogo CH	RBAC P1	AD01 Child Adre		94972	Texas Child City		2002-02-13 00:00:00+00	\N	\N	Female	+19497288333	momochildusa@yopmail.com	t	f	0d59b8f7-807c-4ed8-9620-69ca71ae5b34	0d59b8f7-807c-4ed8-9620-69ca71ae5b34	\N	2024-04-11 10:30:45.225+00	2024-05-22 12:38:21.8+00	39	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	15	2	37	\N	2	2	2	\N
42	Cathy	SR	AD01 TEAXAS		12345	Texas Coty		2018-05-22 00:00:00+00	\N	\N	Female	+919497288333		t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-22 19:05:07.222+00	2024-05-22 19:05:07.222+00	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	1	6	2	37	\N	2	3	8	\N
38	Test child(jyotir)	5	ABC		73001	Austin		2019-09-09 00:00:00+00	\N	\N	Female	+15129999999		t	f	d233665e-6b54-479f-a735-14f3747e4f51	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:45:40.29+00	2024-05-20 07:26:54.847+00	44	733783e7-fcf9-42d5-849c-33aff0f01d35	1	5	2	37	\N	\N	3	2	\N
43	Moana	Moose	Miracle Way		78717	Austin		2021-05-18 00:00:00+00	\N	\N	Female	+15123298635		t	f	32d34875-6aa0-4e97-9b8b-8f822263cbd1	32d34875-6aa0-4e97-9b8b-8f822263cbd1	\N	2024-05-22 20:32:22.706+00	2024-05-22 20:44:57.059+00	46	d74a2981-22a4-4cc5-90ec-52f4d0301cd3	1	\N	2	37	\N	\N	\N	\N	\N
39	Judy	Max (katie test)	1506 w 6th		78735	TBD		2023-03-02 00:00:00+00	\N	\N	Female	+12816669999		t	f	0ac84ba8-9cd7-4536-a3c9-aff6b4b69f68	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-20 13:15:36.435+00	2024-05-21 19:56:48.438+00	45	733783e7-fcf9-42d5-849c-33aff0f01d35	1	\N	2	37	\N	1	3	4	\N
\.


--
-- Data for Name: HT_chldCurntPlmtStsLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_chldCurntPlmtStsLangMaps" (id, "currentPlacementStatus", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTChildCurrentPlacementStatusId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_chldEdnLvlLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_chldEdnLvlLangMaps" (id, "educationLevel", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTChildEducationLevelId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_chldPlmtStsLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_chldPlmtStsLangMaps" (id, "placementStatus", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTChildPlacementStatusId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_chldStsLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_chldStsLangMaps" (id, status, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTChildStatusId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_choiceLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_choiceLangMaps" (id, "choiceName", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTChoiceId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_choices; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_choices" (id, "choiceName", score, "isIntervention", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTQuestionTypeId", "HTQuestionDomainId", "HTQuestionId", "choiceNameLang") FROM stdin;
649	Report to proper authorities	\N	t	t	f	\N	\N	2022-02-21 16:47:41.153+00	2022-02-21 16:47:41.153+00	\N	\N	3	{"1" : "Report to proper authorities", "2" : null, "3" : null}
650	Ensure safety of the child	\N	t	t	f	\N	\N	2022-02-21 16:47:41.424+00	2022-02-21 16:47:41.424+00	\N	\N	3	{"1" : "Ensure safety of the child", "2" : null, "3" : null}
651	Educate family on risks of child marriage and review alternatives	\N	t	t	f	\N	\N	2022-02-21 16:47:41.733+00	2022-02-21 16:47:41.733+00	\N	\N	3	{"1" : "Educate family on risks of child marriage and review alternatives", "2" : null, "3" : null}
652	increase frequency monitoring support	\N	t	t	f	\N	\N	2022-02-21 16:47:42.038+00	2022-02-21 16:47:42.038+00	\N	\N	3	{"1" : "increase frequency monitoring support", "2" : null, "3" : null}
653	Empower child with information, skills and support networks	\N	t	t	f	\N	\N	2022-02-21 16:47:42.279+00	2022-02-21 16:47:42.279+00	\N	\N	3	{"1" : "Empower child with information, skills and support networks", "2" : null, "3" : null}
654	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:42.521+00	2022-02-21 16:47:42.521+00	\N	\N	3	{"1" : "Other (please specify)", "2" : "संबंधित अधिकारियों को सूचित करें", "3" : "உரிய அதிகாரிகளிடம் புகார் செய்தல்"}
655	Support to connect with extended family (such as facilitating regular contact, exploring respite care options, phone calls, transportation options, etc)	\N	t	t	f	\N	\N	2022-02-21 16:47:43.268+00	2022-02-21 16:47:43.268+00	\N	\N	4	{"1" : "Support to connect with extended family (such as facilitating regular contact, exploring respite care options, phone calls, transportation options, etc)", "2" : "बच्चे या परिवार के अन्य सदस्य की सुरक्षा सुनिश्चित करें", "3" : "குழந்தை அல்லது மற்ற குடும்ப உறுப்பினர்களின் பாதுகாப்பை உறுதி செய்தல்"}
656	Support with obtaining counseling for difficulty in relationships with family members	\N	t	t	f	\N	\N	2022-02-21 16:47:43.576+00	2022-02-21 16:47:43.576+00	\N	\N	4	{"1" : "Support with obtaining counseling for difficulty in relationships with family members", "2" : "दुर्व्यवहार के प्रभाव से निपटने हेतु परिवार की सहायता के लिए परामर्श हेतु रेफर करें", "3" : "துஷ்பிரயோகத்தின் தாக்கத்தை சமாளிக்க குடும்பத்தை ஆதரிப்பதற்கான ஆலோசனையைப் பரிந்துரைத்தல்"}
657	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:43.884+00	2022-02-21 16:47:43.884+00	\N	\N	4	{"1" : "Other (please specify)", "2" : "परामर्श प्राप्त करने में पीड़ित का सहयोग करें", "3" : "துஷ்பிரயோகம் செய்யப்பட்டவர்களுக்கு ஆலோசனைகளைப் பெறுவதற்கு ஆதரவு அளிப்பது"}
658	Assist with developing network in community	\N	t	t	f	\N	\N	2022-02-21 16:47:44.498+00	2022-02-21 16:47:44.498+00	\N	\N	5	{"1" : "Assist with developing network in community", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
659	Support with obtaining counseling for difficulty in relationships with neighbors/community	\N	t	t	f	\N	\N	2022-02-21 16:47:44.804+00	2022-02-21 16:47:44.804+00	\N	\N	5	{"1" : "Support with obtaining counseling for difficulty in relationships with neighbors/community", "2" : "संबंधित अधिकारियों को सूचित करें", "3" : "உரிய அதிகாரிகளிடம் புகார் செய்தல்"}
660	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:45.11+00	2022-02-21 16:47:45.11+00	\N	\N	5	{"1" : "Other (please specify)", "2" : "बच्चे की सुरक्षा सुनिश्चित करें", "3" : "குழந்தையின் பாதுகாப்பை உறுதிப்படுத்துதல்"}
661	Assist with parenting skills training-may include individualized training with SW or group classes; identify skills needed	\N	t	t	f	\N	\N	2022-02-21 16:47:45.725+00	2022-02-21 16:47:45.725+00	\N	\N	6	{"1" : "Assist with parenting skills training-may include individualized training with SW or group classes; identify skills needed", "2" : "बाल विवाह के जोखिमों के बारे में परिवार को शिक्षित करें और विकल्पों की समीक्षा करें", "3" : "குழந்தைத் திருமணத்தின் அபாயங்கள் குறித்து குடும்பத்திற்குக் கற்றுக் கொடுத்தல் மற்றும் மாற்று வழிகளை பரிசீலனை செய்தல்"}
662	Linked to/availing schemes (Parenting/ child care support, affordable housing, healthcare, safety, supportive social networks including respite/emergency support when family is in crisis)	\N	t	t	f	\N	\N	2022-02-21 16:47:46.033+00	2022-02-21 16:47:46.033+00	\N	\N	6	{"1" : "Linked to/availing schemes (Parenting/ child care support, affordable housing, healthcare, safety, supportive social networks including respite/emergency support when family is in crisis)", "2" : "निगरानी समर्थन की आवृत्ति बढ़ाएँ", "3" : "கண்காணிப்பு ஆதரவின் இடைவெளியை குறைத்தல்"}
663	Support with access to counseling services	\N	t	t	f	\N	\N	2022-02-21 16:47:46.271+00	2022-02-21 16:47:46.271+00	\N	\N	6	{"1" : "Support with access to counseling services", "2" : "ज्ञान, कौशल और समर्थन तंत्र के साथ बच्चे को सशक्त बनाएं", "3" : "தகவல், திறன்கள் மற்றும் ஆதரவு அளிக்கும் வலைப்பின்னல்கள் ஆகியவை குறித்து குழந்தைக்கு தகவலளித்தல்"}
664	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:46.544+00	2022-02-21 16:47:46.544+00	\N	\N	6	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
819	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	49	\N
820	Access to adult education/literacy courses	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	49	\N
665	Connect to assistance for extra support needed for child (such as access to child care, respite care support, parenting techniques other specialized support)	\N	t	t	f	\N	\N	2022-02-21 16:47:47.571+00	2022-02-21 16:47:47.571+00	\N	\N	7	{"1" : "Connect to assistance for extra support needed for child (such as access to child care, respite care support, parenting techniques other specialized support)", "2" : "विस्तारित परिवार के साथ जुड़ने में सहायता प्रदान करें (जैसे नियमित संपर्क की सुविधा, राहत देखभाल विकल्प तलाशना, फोन कॉल, परिवहन विकल्प, आदि)", "3" : "ஒன்றுவிட்ட குடும்பத்துடன் இணைவதற்கு ஆதரவு அளித்தல் (வழக்கமான தொடர்பை ஏற்பாடு செய்தல், பராமரிப்பு இல்ல விருப்பங்களை ஆராய்தல், தொலைபேசி அழைப்புகள், போக்குவரத்து விருப்பங்கள் போன்றவை)"}
666	Support with access to counseling services	\N	t	t	f	\N	\N	2022-02-21 16:47:47.822+00	2022-02-21 16:47:47.822+00	\N	\N	7	{"1" : "Support with access to counseling services", "2" : "परिवार के सदस्यों के साथ संबंधों में कठिनाई के लिए परामर्श प्राप्त करने में समर्थन करें", "3" : "குடும்ப உறுப்பினர்களுடனான உறவுகளில் உள்ள சிரமத்திற்கு ஆலோசனைகளைப் பெறுவதற்கு ஆதரவு அளித்தல்"}
667	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:48.08+00	2022-02-21 16:47:48.08+00	\N	\N	7	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
668	Support for caregivers who are under 21 or very elderly (such as parental guidance, addressing child safety issues, child care, respite care support, etc)	\N	t	t	f	\N	\N	2022-02-21 16:47:48.56+00	2022-02-21 16:47:48.56+00	\N	\N	8	{"1" : "Support for caregivers who are under 21 or very elderly (such as parental guidance, addressing child safety issues, child care, respite care support, etc)", "2" : "समुदाय में तंत्र विकसित करने में सहायता करें", "3" : "சமூகத்தில் வலைப்பின்னலை உருவாக்க உதவுதல்"}
669	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:47:48.802+00	2022-02-21 16:47:48.802+00	\N	\N	8	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "पड़ोसियों/समुदायों के साथ संबंधों में कठिनाई के लिए परामर्श प्राप्त करने में समर्थन करें", "3" : "அண்டை வீட்டாருடன்/ சமூகத்துடனான உறவுகளில் உள்ள சிரமத்திற்கு ஆலோசனைகளைப் பெறுவதற்கு ஆதரவு அளித்தல்"}
670	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:49.104+00	2022-02-21 16:47:49.104+00	\N	\N	8	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
671	Provide education on importance of children’s rights	\N	t	t	f	\N	\N	2022-02-21 16:47:50.405+00	2022-02-21 16:47:50.405+00	\N	\N	10	{"1" : "Provide education on importance of children’s rights", "2" : "पेरेंटिंग स्किल ट्रेनिंग में सहायता करें- जिसमें SW या समूह कक्षाओं के साथ व्यक्तिगत प्रशिक्षण शामिल हो सकता है; आवश्यक कौशल की पहचान करें", "3" : "குழந்தை வளர்ப்பு திறன் பயிற்சியில் உதவுதல்- இது சமூகப் பணியாளருடன் தனிப்பட்ட பயிற்சியை அல்லது குழு வகுப்புகளைக் கொண்டிருக்கலாம்; தேவையான திறன்களை அடையாளம் காணுதல்"}
672	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:50.744+00	2022-02-21 16:47:50.744+00	\N	\N	10	{"1" : "Other (please specify)", "2" : "(माता-पिता/बाल देखभाल सहायता, सस्ते आवास, स्वास्थ्य देखभाल, सुरक्षा, परिवार के संकट में राहत/आपातकालीन सहायता सहित सहायक सामाजिक तंत्र) से जुड़ी योजनाओं का लाभ", "3" : "திட்டங்களுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றைப் பெறுகிறார்கள் (குழந்தை வளர்ப்பு/ குழந்தை பராமரிப்பு ஆதரவு, மலிவு விலை வீடுகள், சுகாதாரம் பராமரிப்பு, பாதுகாப்பு, குடும்பம் நெருக்கடியில் இருக்கும்போது, பராமரிப்பு இல்லம்/ அவசர உதவி உட்பட ஆதரவளிக்கும் சமூக வலைப்பின்னல்கள்)"}
673	Support to connect with birth family (such as facilitating regular contact, exploring respite care options, phone calls, transportation options, etc)	\N	t	t	f	\N	\N	2022-02-21 16:47:51.226+00	2022-02-21 16:47:51.226+00	\N	\N	11	{"1" : "Support to connect with birth family (such as facilitating regular contact, exploring respite care options, phone calls, transportation options, etc)", "2" : "परामर्श सेवाओं तक पहुंच के लिए सहयोग प्रदान करें", "3" : "ஆலோசனை சேவைகளுக்கான அணுகும் வசதி வழங்குவதன் மூலம் ஆதரவு அளித்தல்"}
674	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:51.465+00	2022-02-21 16:47:51.465+00	\N	\N	11	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
686	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:56.786+00	2022-02-21 16:47:56.786+00	\N	\N	14	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
760	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:29.339+00	2022-02-21 16:48:29.339+00	\N	\N	34	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
675	Offer support with relationship counseling for marital issues	\N	t	t	f	\N	\N	2022-02-21 16:47:53.235+00	2022-02-21 16:47:53.235+00	\N	\N	12	{"1" : "Offer support with relationship counseling for marital issues", "2" : "बच्चे के लिए आवश्यक अतिरिक्त सहायता (जैसे बाल देखभाल तक पहुंच, राहत देखभाल सहायता, पालन-पोषण तकनीक, अन्य विशेष सहायता) प्रदान करने हेतु जुड़ें", "3" : "குழந்தைக்குத் தேவைப்படும் கூடுதல் ஆதரவுக்கான உதவிக்கான இணைப்பை ஏற்படுத்திக் கொடுத்தல் (குழந்தை பராமரிப்புக்கான அணுகும் வசதி, பராமரிப்பு இல்ல ஆதரவு, பெற்றோருக்குரிய நுட்பங்கள், மற்ற சிறப்பு ஆதரவு போன்றவை)"}
676	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:53.507+00	2022-02-21 16:47:53.507+00	\N	\N	12	{"1" : "Other (please specify)", "2" : "परामर्श सेवाओं तक पहुंच के लिए सहयोग प्रदान करें", "3" : "ஆலோசனை சேவைகளுக்கான அணுகும் வசதி வழங்குவதன் மூலம் ஆதரவு அளித்தல்"}
677	Refer for support such as relief packages	\N	t	t	f	\N	\N	2022-02-21 16:47:54.123+00	2022-02-21 16:47:54.123+00	\N	\N	13	{"1" : "Refer for support such as relief packages", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
678	Discuss stable employment opportunities	\N	t	t	f	\N	\N	2022-02-21 16:47:54.429+00	2022-02-21 16:47:54.429+00	\N	\N	13	{"1" : "Discuss stable employment opportunities", "2" : "उन देखभालकर्ताओं हेतु सहायता जो 21 वर्ष से कम या बहुत बुजुर्ग हैं (जैसे पैतृक मार्गदर्शन, बाल सुरक्षा समस्याओं का सम्बोधन, बाल देखभाल, राहत देखभाल सहायता आदि)", "3" : "21 வயதிற்குட்பட்ட அல்லது மிகவும் வயதான பராமரிப்பாளர்களுக்கு ஆதரவு அளித்தல் (குழந்தை வளர்ப்பு வழிகாட்டுதல், குழந்தை பாதுகாப்பு சிக்கல்களைத் தீர்ப்பது, குழந்தை பராமரிப்பு, பராமரிப்பு இல்ல ஆதரவு போன்றவை)"}
679	Linked to/availing schemes (such as financial assistance, Self-help groups, other unemployment benefits	\N	t	t	f	\N	\N	2022-02-21 16:47:54.668+00	2022-02-21 16:47:54.668+00	\N	\N	13	{"1" : "Linked to/availing schemes (such as financial assistance, Self-help groups, other unemployment benefits", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
680	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:54.942+00	2022-02-21 16:47:54.942+00	\N	\N	13	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
681	Access to adult education/literacy courses	\N	t	t	f	\N	\N	2022-02-21 16:47:55.556+00	2022-02-21 16:47:55.556+00	\N	\N	14	{"1" : "Access to adult education/literacy courses", "2" : "प्राथमिक देखभालकर्ता और बच्चे को बाल संरक्षण जोखिमों और रिपोर्टिंग प्रक्रियाओं पर बुनियादी प्रशिक्षण, सूचना और मार्गदर्शन प्रदान करें", "3" : "முதன்மை பராமரிப்பாளர் மற்றும் குழந்தைக்கு , குழந்தை பாதுகாப்பு  அபாயங்கள் மற்றும் அறிக்கை சமர்பபித்தலுக்கான நடைமுறைகள் குறித்த அடிப்படை பயிற்சி, தகவல் மற்றும் வழிகாட்டுதலை வழங்குதல்"}
682	Assist in obtaining vocational training for adult	\N	t	t	f	\N	\N	2022-02-21 16:47:55.797+00	2022-02-21 16:47:55.797+00	\N	\N	14	{"1" : "Assist in obtaining vocational training for adult", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
683	Assist with job-seeking- may include access to job postings, preparing job application, preparation for interviews, transportation to interviews, appropriate attire for interviews	\N	t	t	f	\N	\N	2022-02-21 16:47:56.037+00	2022-02-21 16:47:56.037+00	\N	\N	14	{"1" : "Assist with job-seeking- may include access to job postings, preparing job application, preparation for interviews, transportation to interviews, appropriate attire for interviews", "2" : "बच्चों के अधिकारों के महत्व पर ज्ञान प्रदान करें", "3" : "குழந்தைகளின் உரிமைகளின் முக்கியத்துவம் குறித்த கல்வியை வழங்குதல்"}
684	Assist with obtaining necessary documents	\N	t	t	f	\N	\N	2022-02-21 16:47:56.277+00	2022-02-21 16:47:56.277+00	\N	\N	14	{"1" : "Assist with obtaining necessary documents", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
685	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:47:56.517+00	2022-02-21 16:47:56.517+00	\N	\N	14	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "वास्तविक परिवार से जुड़ने के लिए समर्थन (जैसे नियमित संपर्क की सुविधा, राहत देखभाल विकल्प की तलाश, फोन कॉल, परिवहन विकल्प आदि)", "3" : "பிறந்த குடும்பத்துடன் இணைவதற்கான ஆதரவு அளித்தல் (வழக்கமான தொடர்பை ஏற்பாடு செய்தல், பராமரிப்பு இல்ல விருப்பங்களை ஆராய்தல், தொலைபேசி அழைப்புகள், போக்குவரத்து விருப்பங்கள் போன்றவை)"}
816	Discuss stable employment opportunities	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	48	\N
687	Assist in obtaining supplies/tools for job	\N	t	t	f	\N	\N	2022-02-21 16:47:57.4+00	2022-02-21 16:47:57.4+00	\N	\N	15	{"1" : "Assist in obtaining supplies/tools for job", "2" : "वैवाहिक समस्याओं के लिए संबंध परामर्श में सहायता प्रदान करें", "3" : "திருமண உறவு பிரச்சினைகளுக்கு , உறவு குறித்த ஆலோசனை வழங்குவது மூலம் ஆதரவை வழங்குதல்"}
688	Discuss short-term bank loans	\N	t	t	f	\N	\N	2022-02-21 16:47:57.639+00	2022-02-21 16:47:57.639+00	\N	\N	15	{"1" : "Discuss short-term bank loans", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
689	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:47:57.913+00	2022-02-21 16:47:57.913+00	\N	\N	15	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "राहत पैकेज जैसी सहायता हेतु रेफर करें", "3" : "நிவாரணப் பொருட்கள் போன்ற ஆதரவுக்குப் பரிந்துரைத்தல்"}
690	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:58.143+00	2022-02-21 16:47:58.143+00	\N	\N	15	{"1" : "Other (please specify)", "2" : "रोजगार के स्थायी अवसरों पर चर्चा करें", "3" : "நிலையான வேலை வாய்ப்புகளைப் பற்றி விவாதித்தல்"}
691	Assist with accessing transportation for job	\N	t	t	f	\N	\N	2022-02-21 16:47:58.731+00	2022-02-21 16:47:58.731+00	\N	\N	16	{"1" : "Assist with accessing transportation for job", "2" : "(वित्तीय सहायता, स्वयं सहायता समूह , अन्य बेरोजगारी लाभ) से जुड़ी योजनाओं का लाभ", "3" : "திட்டங்களுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள் (நிதி உதவி, சுயஉதவி குழுக்கள், மற்ற வேலையின்மை நலன்கள் போன்றவை"}
692	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:47:59.036+00	2022-02-21 16:47:59.036+00	\N	\N	16	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
693	Assist in locating child care during work hours (such as neighbors, extended family, etc.)	\N	t	t	f	\N	\N	2022-02-21 16:47:59.652+00	2022-02-21 16:47:59.652+00	\N	\N	17	{"1" : "Assist in locating child care during work hours (such as neighbors, extended family, etc.)", "2" : "प्रौढ़ शिक्षा/साक्षरता पाठ्यक्रमों तक पहुंच", "3" : "வயது வந்தோருக்கான கல்வி/ எழுத்தறிவு படிப்புகளுக்கான அணுகும் வசதி"}
694	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:47:59.964+00	2022-02-21 16:47:59.964+00	\N	\N	17	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "वयस्कों हेतु व्यावसायिक प्रशिक्षण प्राप्त करने में सहायता करें", "3" : "வயது வந்தோருக்கான தொழில் பயிற்சி பெற உதவுதல்"}
695	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:00.231+00	2022-02-21 16:48:00.231+00	\N	\N	17	{"1" : "Other (please specify)", "2" : "नौकरी तलाशने में सहायता-  जिसमें नौकरी की पोस्टिंग तक पहुंच, नौकरी के लिए आवेदन तैयार करना, साक्षात्कार की तैयारी, साक्षात्कार के लिए परिवहन, साक्षात्कार के लिए उपयुक्त कपड़े शामिल हो सकते हैं", "3" : "வேலை தேடுதலில் உதவுதல்- வேலை வாய்ப்பு செய்திகளுக்கு அணுகும் வசதி, வேலைக்கான விண்ணப்பத்தைத் தயாரித்தல், நேர்காணல்களுக்குத் தயாரித்தல், நேர்காணல்களுக்குப் போக்குவரத்து, நேர்காணலுக்கு ஏற்ற உடை ஆகியவற்றை உள்ளடக்கலாம்"}
696	Assist in obtaining food, clothing, and household supplies	\N	t	t	f	\N	\N	2022-02-21 16:48:00.777+00	2022-02-21 16:48:00.777+00	\N	\N	18	{"1" : "Assist in obtaining food, clothing, and household supplies", "2" : "आवश्यक दस्तावेज प्राप्त करने में सहायता करें", "3" : "தேவையான ஆவணங்களைப் பெற உதவுதல்"}
697	Budgeting skills training	\N	t	t	f	\N	\N	2022-02-21 16:48:01.085+00	2022-02-21 16:48:01.085+00	\N	\N	18	{"1" : "Budgeting skills training", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
698	Assist in obtaining financial support to reduce debt	\N	t	t	f	\N	\N	2022-02-21 16:48:01.315+00	2022-02-21 16:48:01.315+00	\N	\N	18	{"1" : "Assist in obtaining financial support to reduce debt", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
699	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:01.545+00	2022-02-21 16:48:01.545+00	\N	\N	18	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "नौकरी हेतु आपूर्ति/उपकरण प्राप्त करने में सहायता करें", "3" : "வேலைக்கான பொருட்கள்/ கருவிகள் பெற உதவுதல்"}
700	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:01.774+00	2022-02-21 16:48:01.774+00	\N	\N	18	{"1" : "Other (please specify)", "2" : "अल्पकालिक बैंक ऋणों पर चर्चा करें", "3" : "குறுகிய கால வங்கிக் கடன்களைப் பற்றி விவாதித்தல்"}
744	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:23.103+00	2022-02-21 16:48:23.103+00	\N	\N	30	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "यदि संभव हो तो दूरस्थ शिक्षा की व्यवस्था करें", "3" : "சாத்தியமெனில் தொலைநிலைக் கல்விக்கு ஏற்பாடு செய்தல்"}
701	Assist with budgeting skills training	\N	t	t	f	\N	\N	2022-02-21 16:48:02.338+00	2022-02-21 16:48:02.338+00	\N	\N	19	{"1" : "Assist with budgeting skills training", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
702	Financial assistance to pay rent/bills (one-off)	\N	t	t	f	\N	\N	2022-02-21 16:48:02.929+00	2022-02-21 16:48:02.929+00	\N	\N	19	{"1" : "Financial assistance to pay rent/bills (one-off)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
703	Assist in obtaining financial support to reduce debt	\N	t	t	f	\N	\N	2022-02-21 16:48:03.237+00	2022-02-21 16:48:03.237+00	\N	\N	19	{"1" : "Assist in obtaining financial support to reduce debt", "2" : "नौकरी के लिए परिवहन तक पहुँचने में सहायता करें", "3" : "வேலைக்கான போக்குவரத்தை அணுகிட உதவுதல்"}
704	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:04.362+00	2022-02-21 16:48:04.362+00	\N	\N	19	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
705	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:04.67+00	2022-02-21 16:48:04.67+00	\N	\N	19	{"1" : "Other (please specify)", "2" : "कार्यालय समय के दौरान बाल देखभाल सेवाओं (जैसे पड़ोसी, विस्तारित परिवार, आदि) को खोजने में सहायता करें", "3" : "வேலை நேரத்தில் குழந்தைப் பராமரிப்பை (அண்டை வீட்டுக்காரர்கள், ஒன்றுவிட்ட குடும்பம் போன்றவை) கண்டறிவதில் உதவுதல்."}
706	Assist with budgeting skills training	\N	t	t	f	\N	\N	2022-02-21 16:48:05.229+00	2022-02-21 16:48:05.229+00	\N	\N	20	{"1" : "Assist with budgeting skills training", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
707	Assist in obtaining financial support to reduce debt	\N	t	t	f	\N	\N	2022-02-21 16:48:05.488+00	2022-02-21 16:48:05.488+00	\N	\N	20	{"1" : "Assist in obtaining financial support to reduce debt", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
708	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:05.796+00	2022-02-21 16:48:05.796+00	\N	\N	20	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "भोजन, वस्त्र और घरेलू आपूर्ति प्राप्त करने में सहायता करें", "3" : "உணவு, உடை மற்றும் வீட்டுப் பொருட்களைப் பெற உதவுதல்"}
709	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:06.104+00	2022-02-21 16:48:06.104+00	\N	\N	20	{"1" : "Other (please specify)", "2" : "बजट कौशल प्रशिक्षण", "3" : "வரவு செலவுத் திட்ட திறன் பயிற்சி"}
710	Assist with obtaining necessary documents	\N	t	t	f	\N	\N	2022-02-21 16:48:06.563+00	2022-02-21 16:48:06.563+00	\N	\N	21	{"1" : "Assist with obtaining necessary documents", "2" : "ऋण कम करने हेतु वित्तीय सहायता प्राप्त करने में सहायता करें", "3" : "கடனைக் குறைக்க நிதி உதவியைப் பெற உதவுதல்"}
711	Linked to/availing schemes/resources/support from gov’t or NGOs (such as Assistance to claim benefits- may include accessing information, documentation on potential benefits, assistance with applications)	\N	t	t	f	\N	\N	2022-02-21 16:48:06.82+00	2022-02-21 16:48:06.82+00	\N	\N	21	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs (such as Assistance to claim benefits- may include accessing information, documentation on potential benefits, assistance with applications)", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
712	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:07.436+00	2022-02-21 16:48:07.436+00	\N	\N	21	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
713	Ensure child is safe – move to another placement if needed	\N	t	t	f	\N	\N	2022-02-21 16:48:07.946+00	2022-02-21 16:48:07.946+00	\N	\N	22	{"1" : "Ensure child is safe – move to another placement if needed", "2" : "बजट कौशल प्रशिक्षण में सहायता करें", "3" : "வரவு செலவு திட்டமிதல் திறன் பயிற்சிக்கு உதவுதல்"}
714	Discuss safety measures such as never go out alone, don’t go out after dark, etc.	\N	t	t	f	\N	\N	2022-02-21 16:48:08.229+00	2022-02-21 16:48:08.229+00	\N	\N	22	{"1" : "Discuss safety measures such as never go out alone, don’t go out after dark, etc.", "2" : "किराए/बिलों का भुगतान करने के लिए वित्तीय सहायता (एकमुश्त)", "3" : "வாடகை/ பில்களை செலுத்த நிதி உதவி (ஒரே முறை)"}
715	Discuss with neighbors, community influencers other political/ other authorities on matters concerning child and family safety	\N	t	t	f	\N	\N	2022-02-21 16:48:08.46+00	2022-02-21 16:48:08.46+00	\N	\N	22	{"1" : "Discuss with neighbors, community influencers other political/ other authorities on matters concerning child and family safety", "2" : "ऋण कम करने हेतु वित्तीय सहायता प्राप्त करने में सहायता करें", "3" : "கடனைக் குறைக்க நிதி உதவியைப் பெற உதவுதல்"}
716	Consider family move to safer location if possible	\N	t	t	f	\N	\N	2022-02-21 16:48:08.765+00	2022-02-21 16:48:08.765+00	\N	\N	22	{"1" : "Consider family move to safer location if possible", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
717	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:09.074+00	2022-02-21 16:48:09.074+00	\N	\N	22	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
718	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:09.304+00	2022-02-21 16:48:09.304+00	\N	\N	22	{"1" : "Other (please specify)", "2" : "बजट कौशल प्रशिक्षण में सहायता करें", "3" : "வரவு செலவு திட்டமிடுதல் திறன் பயிற்சிக்கு உதவுதல்"}
719	Explore/ provide stable accommodations	\N	t	t	f	\N	\N	2022-02-21 16:48:10.602+00	2022-02-21 16:48:10.602+00	\N	\N	23	{"1" : "Explore/ provide stable accommodations", "2" : "ऋण कम करने हेतु वित्तीय सहायता प्राप्त करने में सहायता करें", "3" : "கடனைக் குறைக்க நிதி உதவியைப் பெற உதவுதல்"}
720	Improved safety	\N	t	t	f	\N	\N	2022-02-21 16:48:10.834+00	2022-02-21 16:48:10.834+00	\N	\N	23	{"1" : "Improved safety", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
721	Assist with obtaining refurbishing/repairs	\N	t	t	f	\N	\N	2022-02-21 16:48:11.847+00	2022-02-21 16:48:11.847+00	\N	\N	23	{"1" : "Assist with obtaining refurbishing/repairs", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
722	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:12.145+00	2022-02-21 16:48:12.145+00	\N	\N	23	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "आवश्यक दस्तावेज प्राप्त करने में सहायता करें", "3" : "தேவையான ஆவணங்களைப் பெற உதவுதல்"}
723	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:12.452+00	2022-02-21 16:48:12.452+00	\N	\N	23	{"1" : "Other (please specify)", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना (जैसे कि लाभों का दावा करने में सहायता- इसमें जानकारी तक पहुंच, संभावित लाभों पर दस्तावेज़ीकरण, आवेदनों के साथ सहायता शामिल हो सकती है)", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/வளங்கள்/ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள் (பயன்களைப் பெறுவதற்கான உதவி போன்றவை- இதில் தகவல்களை அணுகுதல், சாத்தியமான பலன்கள் குறித்து ஆவணப்படுத்துதல், விண்ணப்பித்தலுக்கு உதவுதல் போன்றவை)"}
724	Assist with access to basic amenities	\N	t	t	f	\N	\N	2022-02-21 16:48:13.296+00	2022-02-21 16:48:13.296+00	\N	\N	24	{"1" : "Assist with access to basic amenities", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
725	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:13.526+00	2022-02-21 16:48:13.526+00	\N	\N	24	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "सुनिश्चित करें कि बच्चा सुरक्षित है - यदि आवश्यक हो तो दूसरे स्थान पर चले जाएं", "3" : "குழந்தை பாதுகாப்பாக இருப்பதை உறுதி செய்தல் - தேவைப்பட்டால் வேறு தத்துக்கொடுத்தலுக்கு மாற்றுதல்"}
726	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:13.783+00	2022-02-21 16:48:13.783+00	\N	\N	24	{"1" : "Other (please specify)", "2" : "सुरक्षा उपायों पर चर्चा करें जैसे कि कभी अकेले बाहर न जाएं, अंधेरा होने के बाद बाहर न जाएं आदि", "3" : "தனியாக வெளியே செல்லாதீர்கள், இருட்டிய பிறகு வெளியே செல்லாதீர்கள் போன்ற பாதுகாப்பு நடவடிக்கைகளைக் குறித்து விவாதித்தல்."}
727	Assist with purchase of furniture, household appliances, etc.	\N	t	t	f	\N	\N	2022-02-21 16:48:14.318+00	2022-02-21 16:48:14.318+00	\N	\N	25	{"1" : "Assist with purchase of furniture, household appliances, etc.", "2" : "बच्चे और परिवार की सुरक्षा से संबंधित मामलों पर पड़ोसियों, समुदाय को प्रभावित करने वाले अन्य राजनीतिक/अन्य अधिकारियों के साथ चर्चा करें", "3" : "குழந்தைகள் மற்றும் குடும்பப் பாதுகாப்பு தொடர்பான விஷயங்களில் அண்டை வீட்டார்கள், சமூகத்தில் தாக்கம் ஏற்படுத்துபவர்கள், மற்ற அரசியல்/ மற்ற அதிகாரிகள் ஆகியோருடன் கலந்துரையாடுதல்"}
745	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:23.345+00	2022-02-21 16:48:23.345+00	\N	\N	30	{"1" : "Other (please specify)", "2" : "स्कूल फीस में सहायता करें", "3" : "பள்ளிக் கட்டணத்தில் உதவுதல்"}
728	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:14.548+00	2022-02-21 16:48:14.548+00	\N	\N	25	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "यदि संभव हो तो परिवार को सुरक्षित स्थान पर ले जाने पर विचार करें", "3" : "முடிந்தால் குடும்பத்தை பாதுகாப்பான இடத்திற்கு மாற்றுவது குறித்து பரிசீலித்தல்"}
729	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:14.807+00	2022-02-21 16:48:14.807+00	\N	\N	25	{"1" : "Other (please specify)", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
730	Discuss importance of education	\N	t	t	f	\N	\N	2022-02-21 16:48:15.421+00	2022-02-21 16:48:15.421+00	\N	\N	26	{"1" : "Discuss importance of education", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
731	Explore education facilities within practical range from home	\N	t	t	f	\N	\N	2022-02-21 16:48:16.037+00	2022-02-21 16:48:16.037+00	\N	\N	26	{"1" : "Explore education facilities within practical range from home", "2" : "स्थिर आवास प्रदान करें/ खोजें", "3" : "நிலையான தங்குமிடங்களை தேடுதல்/  அவற்றை வழங்குதல்"}
732	Arrange for remote learning if possible	\N	t	t	f	\N	\N	2022-02-21 16:48:16.266+00	2022-02-21 16:48:16.266+00	\N	\N	26	{"1" : "Arrange for remote learning if possible", "2" : "बेहतर सुरक्षा", "3" : "மேம்படுத்தப்பட்ட பாதுகாப்பு"}
733	Assist with school fees	\N	t	t	f	\N	\N	2022-02-21 16:48:16.549+00	2022-02-21 16:48:16.549+00	\N	\N	26	{"1" : "Assist with school fees", "2" : "नवीनीकरण/मरम्मत प्राप्त करने में सहायता करें", "3" : "புதுப்பித்தல்/ பழுதுபார்த்தல் பெறுவதற்கு உதவுதல்"}
734	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:17.162+00	2022-02-21 16:48:17.162+00	\N	\N	26	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
735	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:17.47+00	2022-02-21 16:48:17.47+00	\N	\N	26	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
736	Assist with purchase of school supplies/educational toys	\N	t	t	f	\N	\N	2022-02-21 16:48:19.108+00	2022-02-21 16:48:19.108+00	\N	\N	28	{"1" : "Assist with purchase of school supplies/educational toys", "2" : "बुनियादी सुविधाओं तक पहुंच में सहायता करें", "3" : "அடிப்படை வசதிகளை பெறுவதற்கு உதவுதல்"}
737	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:19.417+00	2022-02-21 16:48:19.417+00	\N	\N	28	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
738	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:19.66+00	2022-02-21 16:48:19.66+00	\N	\N	28	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
739	Assist with arranging transportation to school	\N	t	t	f	\N	\N	2022-02-21 16:48:20.234+00	2022-02-21 16:48:20.234+00	\N	\N	29	{"1" : "Assist with arranging transportation to school", "2" : "फर्नीचर, घरेलू उपकरण आदि की खरीद में सहायता करें", "3" : "மரச்சாமான்கள் , வீட்டு உபயோகப் பொருட்கள் போன்றவற்றை வாங்குவதற்கு உதவுதல்."}
740	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:20.542+00	2022-02-21 16:48:20.542+00	\N	\N	29	{"1" : "Other (please specify)", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
741	Support for learning issues (LD, ADHD, physical disabilities, etc.)	\N	t	t	f	\N	\N	2022-02-21 16:48:21.873+00	2022-02-21 16:48:21.873+00	\N	\N	30	{"1" : "Support for learning issues (LD, ADHD, physical disabilities, etc.)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
742	Offer guidance to parents/ caregivers for learning issues	\N	t	t	f	\N	\N	2022-02-21 16:48:22.487+00	2022-02-21 16:48:22.487+00	\N	\N	30	{"1" : "Offer guidance to parents/ caregivers for learning issues", "2" : "शिक्षा के महत्व पर चर्चा करें", "3" : "கல்வியின் முக்கியத்துவத்தைப் பற்றி விவாதித்தல்"}
743	Discuss with school on special education needs related to child	\N	t	t	f	\N	\N	2022-02-21 16:48:22.794+00	2022-02-21 16:48:22.794+00	\N	\N	30	{"1" : "Discuss with school on special education needs related to child", "2" : "घर से व्यावहारिक दायरे में शिक्षा संबंधी सुविधाओं का अन्वेषण करें", "3" : "வீட்டிலிருந்து யதார்த்தமான தூரத்தில் கல்வி வசதிகளை தேடுதல்"}
746	Provide access to extracurricular activities (such as supplies, fees, etc.)	\N	t	t	f	\N	\N	2022-02-21 16:48:23.823+00	2022-02-21 16:48:23.823+00	\N	\N	31	{"1" : "Provide access to extracurricular activities (such as supplies, fees, etc.)", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
747	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:24.127+00	2022-02-21 16:48:24.127+00	\N	\N	31	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
748	Ensure safety of child and other family members	\N	t	t	f	\N	\N	2022-02-21 16:48:24.66+00	2022-02-21 16:48:24.66+00	\N	\N	32	{"1" : "Ensure safety of child and other family members", "2" : "बच्चे के लिए उच्च शिक्षा/व्यावसायिक प्रशिक्षण में सहायता करें", "3" : "குழந்தைக்கு உயர் கல்வி/ தொழில் பயிற்சிக்கு உதவுதல்"}
749	Set boundaries for behavior of abuser (eg, never use substances at home, never come home drunk/high, etc.)	\N	t	t	f	\N	\N	2022-02-21 16:48:24.929+00	2022-02-21 16:48:24.929+00	\N	\N	32	{"1" : "Set boundaries for behavior of abuser (eg, never use substances at home, never come home drunk/high, etc.)", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
750	Refer abuser for treatment	\N	t	t	f	\N	\N	2022-02-21 16:48:25.226+00	2022-02-21 16:48:25.226+00	\N	\N	32	{"1" : "Refer abuser for treatment", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
751	Access to de-addiction center/ Alcoholics Anonymous Groups (AA)	\N	t	t	f	\N	\N	2022-02-21 16:48:25.468+00	2022-02-21 16:48:25.468+00	\N	\N	32	{"1" : "Access to de-addiction center/ Alcoholics Anonymous Groups (AA)", "2" : "स्कूल की आपूर्ति/शैक्षिक खिलौनों की खरीद में सहायता करें", "3" : "பள்ளி பொருட்கள்/ கல்விசார்  பொம்மைகளை வாங்க உதவுதல்"}
752	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:25.707+00	2022-02-21 16:48:25.707+00	\N	\N	32	{"1" : "Other (please specify)", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
753	Access to general health care services	\N	t	t	f	\N	\N	2022-02-21 16:48:26.225+00	2022-02-21 16:48:26.225+00	\N	\N	33	{"1" : "Access to general health care services", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
754	Access to family planning and counseling	\N	t	t	f	\N	\N	2022-02-21 16:48:26.482+00	2022-02-21 16:48:26.482+00	\N	\N	33	{"1" : "Access to family planning and counseling", "2" : "स्कूल तक परिवहन की व्यवस्था करने में सहायता करें", "3" : "பள்ளிக்கு போக்குவரத்து ஏற்பாடு செய்ய உதவுதல்"}
755	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:26.788+00	2022-02-21 16:48:26.788+00	\N	\N	33	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
756	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:27.095+00	2022-02-21 16:48:27.095+00	\N	\N	33	{"1" : "Other (please specify)", "2" : "सीखने से संबंधित समस्याओं में सहायता (एलडी, एडीएचडी, शारीरिक अक्षमता, आदि)", "3" : "கற்றல் சிக்கல்களுக்கான ஆதரவு அளித்தல் (LD, ADHD, உடல் குறைபாடுகள் போன்றவை)"}
757	Access to health care services - PHCs, other catering specific health issues	\N	t	t	f	\N	\N	2022-02-21 16:48:28.529+00	2022-02-21 16:48:28.529+00	\N	\N	34	{"1" : "Access to health care services - PHCs, other catering specific health issues", "2" : "सीखने से संबंधित समस्याओं के लिए माता-पिता/देखभालकर्ता को मार्गदर्शन प्रदान करें", "3" : "கற்றல் சிக்கல்களுக்கு பெற்றோர்/ பராமரிப்பாளர்களுக்கு வழிகாட்டுதலை வழங்குதல்"}
758	Provide information to child/ family regarding managing health condition	\N	t	t	f	\N	\N	2022-02-21 16:48:28.837+00	2022-02-21 16:48:28.837+00	\N	\N	34	{"1" : "Provide information to child/ family regarding managing health condition", "2" : "बच्चे से संबंधित विशेष शिक्षा आवश्यकताओं के बारे में स्कूल से चर्चा करें", "3" : "குழந்தை தொடர்பான சிறப்புக் கல்வித் தேவைகள் குறித்து பள்ளியுடன் கலந்துரையாடுதல்"}
759	Liked to availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:29.099+00	2022-02-21 16:48:29.099+00	\N	\N	34	{"1" : "Liked to availing schemes/resources/support from gov’t or NGOs", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
817	Linked to/availing schemes (such as financial assistance, Self-help groups, other unemployment benefits	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	48	\N
761	Assist with access to dentist/vision care	\N	t	t	f	\N	\N	2022-02-21 16:48:30.987+00	2022-02-21 16:48:30.987+00	\N	\N	35	{"1" : "Assist with access to dentist/vision care", "2" : "पाठ्येतर गतिविधियों (जैसे आपूर्ति, शुल्क इत्यादि) तक पहुंच", "3" : "பாடத்திட்டம் சாராத செயல்பாடுகளுக்கான அணுகும் வசதியை வழங்குதல் (பொருட்கள், கட்டணம் போன்றவை)"}
762	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:31.238+00	2022-02-21 16:48:31.238+00	\N	\N	35	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
763	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:31.499+00	2022-02-21 16:48:31.499+00	\N	\N	35	{"1" : "Other (please specify)", "2" : "बच्चे और परिवार के अन्य सदस्यों की सुरक्षा सुनिश्चित करें", "3" : "குழந்தை மற்றும் மற்ற குடும்ப உறுப்பினர்களின் பாதுகாப்பை உறுதி செய்தல்"}
764	Assist with access to mental health services (including counseling, therapy, etc.)	\N	t	t	f	\N	\N	2022-02-21 16:48:32.114+00	2022-02-21 16:48:32.114+00	\N	\N	36	{"1" : "Assist with access to mental health services (including counseling, therapy, etc.)", "2" : "दुर्व्यवहारी के व्यवहार के लिए सीमाएं निर्धारित करें (जैसे पदार्थों का सेवन घर में ना किया जाए , घर में पीकर/नशे की हालत में ना आया जाए आदि)", "3" : "தவறான பழக்கம் உள்ளவர்களின் நடத்தைகளுக்கு எல்லைகள் அமைத்தல் (எ.கா. வீட்டில் போதை பொருட்களைப் பயன்படுத்தாதிருத்தல், குடித்துவிட்டு/ போதையில் வீட்டிற்கு வராதிருத்தல், முதலியன)"}
765	Offer support with guidance to family on managing symptoms	\N	t	t	f	\N	\N	2022-02-21 16:48:32.42+00	2022-02-21 16:48:32.42+00	\N	\N	36	{"1" : "Offer support with guidance to family on managing symptoms", "2" : "दुर्व्यवहारी को इलाज हेतु रेफर करें", "3" : "தவறான பழக்கம் உள்ளவரை சிகிச்சைக்காக பரிந்துரைத்தல்"}
766	Support with accessing medication	\N	t	t	f	\N	\N	2022-02-21 16:48:32.728+00	2022-02-21 16:48:32.728+00	\N	\N	36	{"1" : "Support with accessing medication", "2" : "नशामुक्ति केंद्र / अल्कोहलिक्स एनॉनिमस समूहों (एए) तक पहुंच", "3" : "போதை அடிமையிலிருந்து மீட்பு மையம்/ ஆல்கஹாலிக்ஸ் அனானிமஸ் குழுக்களை அணுகுவதற்கான வசதி (AA)"}
767	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:33.035+00	2022-02-21 16:48:33.035+00	\N	\N	36	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
768	Assist with access to mental health services (including counseling, therapy, etc.)	\N	t	t	f	\N	\N	2022-02-21 16:48:33.547+00	2022-02-21 16:48:33.547+00	\N	\N	37	{"1" : "Assist with access to mental health services (including counseling, therapy, etc.)", "2" : "सामान्य स्वास्थ्य देखभाल सेवाओं तक पहुंच", "3" : "பொது சுகாதார பராமரிப்பு சேவைகளுக்கு அணுகும் வசதி"}
769	Offer support with guidance to family on managing symptoms	\N	t	t	f	\N	\N	2022-02-21 16:48:33.854+00	2022-02-21 16:48:33.854+00	\N	\N	37	{"1" : "Offer support with guidance to family on managing symptoms", "2" : "परिवार नियोजन और परामर्श तक पहुंच", "3" : "குடும்பக் கட்டுப்பாடு மற்றும் ஆலோசனைக்கு அணுகும் வசதி"}
770	Support with accessing medication	\N	t	t	f	\N	\N	2022-02-21 16:48:34.161+00	2022-02-21 16:48:34.161+00	\N	\N	37	{"1" : "Support with accessing medication", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
771	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:34.469+00	2022-02-21 16:48:34.469+00	\N	\N	37	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
772	Assist with access to medication/medical equipment	\N	t	t	f	\N	\N	2022-02-21 16:48:35.083+00	2022-02-21 16:48:35.083+00	\N	\N	38	{"1" : "Assist with access to medication/medical equipment", "2" : "स्वास्थ्य देखभाल सेवाओं - प्राथमिक स्वास्थ्य देखभाल, अन्य खानपान विशिष्ट स्वास्थ्य मुद्दे तक पहुंच", "3" : "சுகாதார பராமரிப்பு சேவைகளுக்கு அணுகும் வசதி - PHC-கள், குறிப்பிட்ட சுகாதார பிரச்சினைகளை பார்க்கும் மற்ற அமைப்புகள்"}
773	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:35.698+00	2022-02-21 16:48:35.698+00	\N	\N	38	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "स्वास्थ्य की स्थिति के प्रबंधन के बारे में बच्चे/परिवार को जानकारी प्रदान करें", "3" : "குழந்தை/ குடும்பத்தினருக்கு சுகாதார நிலைமையை நிர்வகித்தல் தொடர்பான தகவல்களை வழங்குதல்"}
774	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:36.824+00	2022-02-21 16:48:36.824+00	\N	\N	38	{"1" : "Other (please specify)", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவைப் பெற்றிட இணைக்கப்பட்டுனள்ளார்கள்"}
775	Assist with access to services for impairments/disabilities/ developmental delays	\N	t	t	f	\N	\N	2022-02-21 16:48:37.3+00	2022-02-21 16:48:37.3+00	\N	\N	39	{"1" : "Assist with access to services for impairments/disabilities/ developmental delays", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
776	Assist with obtaining medical equipment (such as hearing aids, prosthetics, etc	\N	t	t	f	\N	\N	2022-02-21 16:48:37.541+00	2022-02-21 16:48:37.541+00	\N	\N	39	{"1" : "Assist with obtaining medical equipment (such as hearing aids, prosthetics, etc", "2" : "दंत चिकित्सक/दृष्टि देखभाल तक पहुंच में सहायता", "3" : "பல்மருத்துவர்/ பார்வை பராமரிப்பு அணுகுவதற்கு உதவுதல்"}
777	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:37.851+00	2022-02-21 16:48:37.851+00	\N	\N	39	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
778	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:38.156+00	2022-02-21 16:48:38.156+00	\N	\N	39	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
779	Teach personal hygiene and self-care skills and	\N	t	t	f	\N	\N	2022-02-21 16:48:38.771+00	2022-02-21 16:48:38.771+00	\N	\N	40	{"1" : "Teach personal hygiene and self-care skills and", "2" : "मानसिक स्वास्थ्य सेवाओं  (परामर्श, चिकित्सा, आदि सहित) तक पहुंच में सहायता करें", "3" : "மனநல சுகாதார சேவைகளை அணுகும் வசதிக்கு உதவுதல் (ஆலோசனை, சிகிச்சை போன்றவை உட்பட)"}
780	Offer access to personal hygiene products - (soaps, sanitary napkins, etc)	\N	t	t	f	\N	\N	2022-02-21 16:48:39.078+00	2022-02-21 16:48:39.078+00	\N	\N	40	{"1" : "Offer access to personal hygiene products - (soaps, sanitary napkins, etc)", "2" : "लक्षणों के प्रबंधन के बारे में परिवार को मार्गदर्शन में सहयोग प्रदान करें", "3" : "அறிகுறிகளை நிர்வகிப்பதில் குடும்பத்திற்கு வழிகாட்டுதல் மூலம் ஆதரவை வழங்குதல்"}
781	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:39.316+00	2022-02-21 16:48:39.316+00	\N	\N	40	{"1" : "Other (please specify)", "2" : "दवा प्राप्त करने में सहयोग करें", "3" : "மருந்துகளை அணுகுவதற்கான ஆதரவு அளித்தல்"}
782	Review diet	\N	t	t	f	\N	\N	2022-02-21 16:48:39.897+00	2022-02-21 16:48:39.897+00	\N	\N	41	{"1" : "Review diet", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
783	Offer nutritional resources	\N	t	t	f	\N	\N	2022-02-21 16:48:40.203+00	2022-02-21 16:48:40.203+00	\N	\N	41	{"1" : "Offer nutritional resources", "2" : "मानसिक स्वास्थ्य सेवाओं  (परामर्श, चिकित्सा, आदि सहित) तक पहुंच में सहायता करें", "3" : "மனநல சுகாதார சேவைகளை அணுகும் வசதிக்கு உதவுதல் (ஆலோசனை, சிகிச்சை போன்றவை உட்பட)"}
784	Assist in getting hemoglobin tested	\N	t	t	f	\N	\N	2022-02-21 16:48:40.441+00	2022-02-21 16:48:40.441+00	\N	\N	41	{"1" : "Assist in getting hemoglobin tested", "2" : "लक्षणों के प्रबंधन के बारे में परिवार को मार्गदर्शन में सहयोग प्रदान करें", "3" : "அறிகுறிகளை நிர்வகிப்பதில் குடும்பத்திற்கு வழிகாட்டுவது மூலம் ஆதரவை வழங்குதல்"}
785	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:40.68+00	2022-02-21 16:48:40.68+00	\N	\N	41	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "दवा प्राप्त करने में सहयोग करें", "3" : "மருந்துகளை அணுகுவதற்கான ஆதரவு அளித்தல்"}
786	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:40.92+00	2022-02-21 16:48:40.92+00	\N	\N	41	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
787	Access to nutritious foods	\N	t	t	f	\N	\N	2022-02-21 16:48:41.842+00	2022-02-21 16:48:41.842+00	\N	\N	42	{"1" : "Access to nutritious foods", "2" : "दवा/चिकित्सा उपकरणों तक पहुंच में सहायता करें", "3" : "மருந்து/ மருத்துவ உபகரணங்களை அணுகிட உதவுதல்"}
788	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:42.15+00	2022-02-21 16:48:42.15+00	\N	\N	42	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
789	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:42.388+00	2022-02-21 16:48:42.388+00	\N	\N	42	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
790	Assist with health insurance	\N	t	t	f	\N	\N	2022-02-21 16:48:42.968+00	2022-02-21 16:48:42.968+00	\N	\N	43	{"1" : "Assist with health insurance", "2" : "दुर्बलता /विकलांगता/विकासात्मक विलंब के लिए सेवाओं तक पहुंच में सहायता करें", "3" : "குறைபாடுகள்/ இயலாமைகள்/ வளர்ச்சி தாமதங்களுக்கான சேவைகளை அணுகிட உதவுதல்"}
818	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	48	\N
791	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	\N	2022-02-21 16:48:43.228+00	2022-02-21 16:48:43.228+00	\N	\N	43	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "चिकित्सा उपकरण प्राप्त करने में सहायता करें (जैसे श्रवण यंत्र, प्रोस्थेटिक्स, आदि)", "3" : "மருத்துவ உபகரணங்களைப் பெறுவதற்கு உதவுதல் (காது கேட்கும் கருவிகள், செயற்கை உடலுறுப்புகள் போன்றவை"}
792	Other (please specify)	\N	t	t	f	\N	\N	2022-02-21 16:48:43.467+00	2022-02-21 16:48:43.467+00	\N	\N	43	{"1" : "Other (please specify)", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
793	Report to proper authorities	\N	t	t	f	\N	86173a36-b02f-427e-9280-f4f61155dfb3	2023-07-20 06:01:39.021+00	2023-07-20 06:01:39.021+00	\N	\N	2	{"1" : "Report to proper authorities", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
794	Refer for counselling to support family to cope with impact of abuse	\N	t	t	f	\N	86173a36-b02f-427e-9280-f4f61155dfb3	2023-07-20 06:01:39.214+00	2023-07-20 06:01:39.214+00	\N	\N	2	{"1" : "Refer for counselling to support family to cope with impact of abuse", "2" : "व्यक्तिगत स्वच्छता और आत्म-देखभाल कौशल सिखाएं और", "3" : "தனிப்பட்ட சுகாதாரம் மற்றும் சுய பாதுகாப்பு திறன்களை கற்பித்தல் மற்றும்"}
795	Ensure safety of child or other family member	\N	t	t	f	\N	86173a36-b02f-427e-9280-f4f61155dfb3	2023-07-20 06:01:39.404+00	2023-07-20 06:01:39.404+00	\N	\N	2	{"1" : "Ensure safety of child or other family member", "2" : "व्यक्तिगत स्वच्छता उत्पादों तक पहुंच प्रदान करें - (साबुन, सैनिटरी नैपकिन, आदि)", "3" : "தனிப்பட்ட சுகாதார தயாரிப்புகளுக்கான அணுகும் வசதியை வழங்குதல் - (சோப்புகள், சானிட்டரி நாப்கின்கள் போன்றவை)"}
796	Support with obtaining counseling for the abused	\N	t	t	f	\N	86173a36-b02f-427e-9280-f4f61155dfb3	2023-07-20 06:01:39.594+00	2023-07-20 06:01:39.594+00	\N	\N	2	{"1" : "Support with obtaining counseling for the abused", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
797	Provide basic training, information, and guidance on CP risks & reporting procedures to primary carer and child	\N	t	t	f	\N	eb638800-13b2-4199-a5a4-dc45bb73fde5	2023-07-23 09:44:08.495+00	2023-07-23 09:44:08.495+00	\N	\N	9	{"1" : "Provide basic training, information, and guidance on CP risks & reporting procedures to primary carer and child", "2" : "आहार की समीक्षा करें", "3" : "உணவை மதிப்பாய்வு செய்தல்"}
798	Other (please specify)	\N	t	t	f	\N	eb638800-13b2-4199-a5a4-dc45bb73fde5	2023-07-23 09:44:08.686+00	2023-07-23 09:44:08.686+00	\N	\N	9	{"1" : "Other (please specify)", "2" : "पोषण संबंधी संसाधन प्रदान करें", "3" : "ஊட்டச்சத்து வளங்களை வழங்குதல்"}
799	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	9d675b84-35f0-4bb8-9945-70d1e5d04811	2023-07-26 05:57:05.075+00	2023-07-26 05:57:05.075+00	\N	\N	27	{"1" : "Linked to/availing schemes/resources/support from gov’t or NGOs", "2" : "हीमोग्लोबिन की जांच कराने में सहायता करें", "3" : "ஹீமோகுளோபின் பரிசோதனை செய்யப்பட உதவுதல்"}
800	Assist with higher education/vocational training for child	\N	t	t	f	\N	9d675b84-35f0-4bb8-9945-70d1e5d04811	2023-07-26 05:57:05.278+00	2023-07-26 05:57:05.278+00	\N	\N	27	{"1" : "Assist with higher education/vocational training for child", "2" : "सरकारी/ स्वयंसेवी योजनाओं/ संसाधनों/ सहायता से लिंक करना/ जोड़ना", "3" : "அரசு அல்லது தன்னார்வ தொண்டு நிறுவனங்களின் திட்டங்கள்/ வளங்கள்/ ஆதரவு ஆகியவற்றுடன் இணைக்கப்பட்டிருக்கிறார்கள்/ அவற்றை பெறுகிறார்கள்"}
801	Other (please specify)	\N	t	t	f	\N	9d675b84-35f0-4bb8-9945-70d1e5d04811	2023-07-26 05:57:05.473+00	2023-07-26 05:57:05.473+00	\N	\N	27	{"1" : "Other (please specify)", "2" : "अन्य (कृपया निर्दिष्ट करें)", "3" : "மற்றவை (தயவுசெய்து குறிப்பிடவும்)"}
802	Report to proper authorities	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	45	\N
803	Refer for counselling to support family to cope with impact of abuse	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	45	\N
804	Ensure safety of child or other family member	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	45	\N
805	Support with obtaining counseling for the abused	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	45	\N
806	Report to proper authorities	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	46	\N
807	Ensure safety of the child	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	46	\N
808	Educate family on risks of child marriage and review alternatives	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	46	\N
809	increase frequency monitoring support	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	46	\N
810	Empower child with information, skills and support networks	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	46	\N
811	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	46	\N
812	Support to connect with extended family (such as facilitating regular contact, exploring respite care options, phone calls, transportation options, etc)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	47	\N
813	Support with obtaining counseling for difficulty in relationships with family members	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	47	\N
814	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	47	\N
815	Refer for support such as relief packages	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	48	\N
821	Assist in obtaining vocational training for adult	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	49	\N
822	Assist with job-seeking- may include access to job postings, preparing job application, preparation for interviews, transportation to interviews, appropriate attire for interviews	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	49	\N
823	Assist with obtaining necessary documents	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	49	\N
824	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	49	\N
825	Assist in obtaining supplies/tools for job	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	50	\N
826	Discuss short-term bank loans	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	50	\N
827	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	50	\N
828	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	50	\N
829	Ensure child is safe – move to another placement if needed	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	51	\N
830	Discuss safety measures such as never go out alone, don’t go out after dark, etc.	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	51	\N
831	Discuss with neighbors, community influencers other political/ other authorities on matters concerning child and family safety	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	51	\N
832	Consider family move to safer location if possible	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	51	\N
833	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	51	\N
834	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	51	\N
835	Explore/ provide stable accommodations	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	52	\N
836	Improved safety	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	52	\N
837	Assist with obtaining refurbishing/repairs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	52	\N
838	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	52	\N
839	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	52	\N
840	Assist with access to basic amenities	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	53	\N
841	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	53	\N
842	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	53	\N
843	Discuss importance of education	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	54	\N
844	Explore education facilities within practical range from home	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	54	\N
845	Arrange for remote learning if possible	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	54	\N
846	Assist with school fees	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	54	\N
847	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	54	\N
848	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	54	\N
849	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	55	\N
850	Assist with higher education/vocational training for child	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	55	\N
851	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	55	\N
852	Provide access to extracurricular activities (such as supplies, fees, etc.)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	56	\N
853	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	56	\N
854	Ensure safety of child and other family members	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	57	\N
855	Set boundaries for behavior of abuser (eg, never use substances at home, never come home drunk/high, etc.)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	57	\N
856	Refer abuser for treatment	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	57	\N
857	Access to de-addiction center/ Alcoholics Anonymous Groups (AA)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	57	\N
858	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	57	\N
859	Access to general health care services	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	58	\N
860	Access to family planning and counseling	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	58	\N
861	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	58	\N
862	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	58	\N
863	Teach personal hygiene and self-care skills and	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	59	\N
864	Offer access to personal hygiene products - (soaps, sanitary napkins, etc)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	59	\N
865	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.351+00	2024-04-11 10:38:34.351+00	\N	\N	59	\N
866	Report to proper authorities	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:40:08.753+00	2024-04-11 10:40:08.753+00	\N	\N	60	\N
867	Ensure safety of the child	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:40:08.76+00	2024-04-11 10:40:08.76+00	\N	\N	60	\N
868	Educate family on risks of child marriage and review alternatives	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:40:08.768+00	2024-04-11 10:40:08.768+00	\N	\N	60	\N
869	increase frequency monitoring support	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:40:08.771+00	2024-04-11 10:40:08.771+00	\N	\N	60	\N
870	Empower child with information, skills and support networks	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:40:08.773+00	2024-04-11 10:40:08.773+00	\N	\N	60	\N
871	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:40:08.776+00	2024-04-11 10:40:08.776+00	\N	\N	60	\N
872	Access to general health care services	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:13.267+00	2024-04-11 10:41:13.267+00	\N	\N	61	\N
873	Access to family planning and counseling	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:13.271+00	2024-04-11 10:41:13.271+00	\N	\N	61	\N
874	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:13.273+00	2024-04-11 10:41:13.273+00	\N	\N	61	\N
875	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:13.276+00	2024-04-11 10:41:13.276+00	\N	\N	61	\N
876	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:29.036+00	2024-04-11 10:41:29.036+00	\N	\N	62	\N
877	Assist with higher education/vocational training for child	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:29.038+00	2024-04-11 10:41:29.038+00	\N	\N	62	\N
878	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:29.04+00	2024-04-11 10:41:29.04+00	\N	\N	62	\N
879	Access to adult education/literacy courses	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:39.759+00	2024-04-11 10:41:39.759+00	\N	\N	63	\N
880	Assist in obtaining vocational training for adult	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:39.761+00	2024-04-11 10:41:39.761+00	\N	\N	63	\N
881	Assist with job-seeking- may include access to job postings, preparing job application, preparation for interviews, transportation to interviews, appropriate attire for interviews	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:39.763+00	2024-04-11 10:41:39.763+00	\N	\N	63	\N
882	Assist with obtaining necessary documents	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:39.765+00	2024-04-11 10:41:39.765+00	\N	\N	63	\N
883	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:39.767+00	2024-04-11 10:41:39.767+00	\N	\N	63	\N
884	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:39.769+00	2024-04-11 10:41:39.769+00	\N	\N	63	\N
885	Intervention 1	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:42:23.606+00	2024-04-11 10:42:23.606+00	\N	\N	64	\N
886	Intervention 2	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:42:23.608+00	2024-04-11 10:42:23.608+00	\N	\N	64	\N
891	Report to proper authorities	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	66	\N
892	Ensure safety of the child	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	66	\N
893	Educate family on risks of child marriage and review alternatives	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	66	\N
894	increase frequency monitoring support	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	66	\N
895	Empower child with information, skills and support networks	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	66	\N
896	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	66	\N
897	Support to connect with extended family (such as facilitating regular contact, exploring respite care options, phone calls, transportation options, etc)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	67	\N
898	Support with obtaining counseling for difficulty in relationships with family members	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	67	\N
899	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	67	\N
900	Refer for support such as relief packages	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	68	\N
901	Discuss stable employment opportunities	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	68	\N
902	Linked to/availing schemes (such as financial assistance, Self-help groups, other unemployment benefits	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	68	\N
903	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	68	\N
904	Access to adult education/literacy courses	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	69	\N
905	Assist in obtaining vocational training for adult	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	69	\N
906	Assist with job-seeking- may include access to job postings, preparing job application, preparation for interviews, transportation to interviews, appropriate attire for interviews	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	69	\N
907	Assist with obtaining necessary documents	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	69	\N
908	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	69	\N
909	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	69	\N
910	Assist with obtaining necessary documents	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	70	\N
911	Linked to/availing schemes/resources/support from gov’t or NGOs (such as Assistance to claim benefits- may include accessing information, documentation on potential benefits, assistance with applications)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	70	\N
912	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	70	\N
913	Ensure child is safe – move to another placement if needed	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	71	\N
914	Discuss safety measures such as never go out alone, don’t go out after dark, etc.	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	71	\N
915	Discuss with neighbors, community influencers other political/ other authorities on matters concerning child and family safety	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	71	\N
916	Consider family move to safer location if possible	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	71	\N
917	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	71	\N
918	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	71	\N
924	Assist with purchase of furniture, household appliances, etc.	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	73	\N
925	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	73	\N
926	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	73	\N
927	Discuss importance of education	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	74	\N
928	Explore education facilities within practical range from home	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	74	\N
929	Arrange for remote learning if possible	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	74	\N
930	Assist with school fees	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	74	\N
931	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	74	\N
932	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	74	\N
933	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	75	\N
934	Assist with higher education/vocational training for child	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	75	\N
935	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	75	\N
936	Intervention 1	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	76	\N
937	Intervention 2	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	76	\N
938	Ensure safety of child and other family members	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	77	\N
939	Set boundaries for behavior of abuser (eg, never use substances at home, never come home drunk/high, etc.)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	77	\N
940	Refer abuser for treatment	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	77	\N
941	Access to de-addiction center/ Alcoholics Anonymous Groups (AA)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	77	\N
942	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	77	\N
943	Access to general health care services	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	78	\N
944	Access to family planning and counseling	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	78	\N
945	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	78	\N
946	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.942+00	2024-04-11 10:42:31.942+00	\N	\N	78	\N
947	Explore/ provide stable accommodations	\N	t	t	f	\N	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:14.555+00	2024-04-11 10:43:14.555+00	\N	\N	72	\N
948	Improved safety	\N	t	t	f	\N	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:14.559+00	2024-04-11 10:43:14.559+00	\N	\N	72	\N
949	Assist with obtaining refurbishing/repairs	\N	t	t	f	\N	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:14.561+00	2024-04-11 10:43:14.561+00	\N	\N	72	\N
950	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	\N	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:14.563+00	2024-04-11 10:43:14.563+00	\N	\N	72	\N
951	Other (please specify)	\N	t	t	f	\N	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:14.566+00	2024-04-11 10:43:14.566+00	\N	\N	72	\N
952	Report to proper authorities	\N	t	t	f	\N	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:54.028+00	2024-04-11 10:43:54.028+00	\N	\N	65	\N
953	Refer for counselling to support family to cope with impact of abuse	\N	t	t	f	\N	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:54.031+00	2024-04-11 10:43:54.031+00	\N	\N	65	\N
954	Ensure safety of child or other family member	\N	t	t	f	\N	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:54.033+00	2024-04-11 10:43:54.033+00	\N	\N	65	\N
955	Support with obtaining counseling for the abused	\N	t	t	f	\N	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:54.035+00	2024-04-11 10:43:54.035+00	\N	\N	65	\N
956	Report to proper authorities	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	80	\N
957	Refer for counselling to support family to cope with impact of abuse	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	80	\N
958	Ensure safety of child or other family member	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	80	\N
959	Support with obtaining counseling for the abused	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	80	\N
960	Report to proper authorities	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	81	\N
961	Ensure safety of the child	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	81	\N
962	Educate family on risks of child marriage and review alternatives	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	81	\N
963	increase frequency monitoring support	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	81	\N
964	Empower child with information, skills and support networks	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	81	\N
965	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	81	\N
966	Support to connect with extended family (such as facilitating regular contact, exploring respite care options, phone calls, transportation options, etc)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	82	\N
967	Support with obtaining counseling for difficulty in relationships with family members	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	82	\N
968	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	82	\N
969	Assist with developing network in community	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	83	\N
970	Support with obtaining counseling for difficulty in relationships with neighbors/community	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	83	\N
971	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	83	\N
972	Assist with parenting skills training-may include individualized training with SW or group classes; identify skills needed	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	84	\N
973	Linked to/availing schemes (Parenting/ child care support, affordable housing, healthcare, safety, supportive social networks including respite/emergency support when family is in crisis)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	84	\N
974	Support with access to counseling services	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	84	\N
975	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	84	\N
976	Connect to assistance for extra support needed for child (such as access to child care, respite care support, parenting techniques other specialized support)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	85	\N
977	Support with access to counseling services	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	85	\N
978	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	85	\N
979	Support for caregivers who are under 21 or very elderly (such as parental guidance, addressing child safety issues, child care, respite care support, etc)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	86	\N
980	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	86	\N
981	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	86	\N
982	Provide basic training, information, and guidance on CP risks & reporting procedures to primary carer and child	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	87	\N
983	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	87	\N
984	Provide education on importance of children’s rights	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	88	\N
985	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	88	\N
986	Support to connect with birth family (such as facilitating regular contact, exploring respite care options, phone calls, transportation options, etc)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	89	\N
987	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	89	\N
988	Offer support with relationship counseling for marital issues	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	90	\N
989	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	90	\N
990	Refer for support such as relief packages	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	91	\N
991	Discuss stable employment opportunities	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	91	\N
992	Linked to/availing schemes (such as financial assistance, Self-help groups, other unemployment benefits	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	91	\N
993	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	91	\N
994	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	92	\N
995	Access to adult education/literacy courses	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	92	\N
996	Assist in obtaining vocational training for adult	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	92	\N
997	Assist with job-seeking- may include access to job postings, preparing job application, preparation for interviews, transportation to interviews, appropriate attire for interviews	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	92	\N
998	Assist with obtaining necessary documents	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	92	\N
999	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	92	\N
1000	Assist in obtaining supplies/tools for job	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	93	\N
1001	Discuss short-term bank loans	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	93	\N
1002	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	93	\N
1003	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	93	\N
1004	Assist with accessing transportation for job	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	94	\N
1005	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	94	\N
1006	Assist in locating child care during work hours (such as neighbors, extended family, etc.)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	95	\N
1007	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	95	\N
1008	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	95	\N
1009	Assist in obtaining food, clothing, and household supplies	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	96	\N
1010	Budgeting skills training	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	96	\N
1011	Assist in obtaining financial support to reduce debt	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	96	\N
1012	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	96	\N
1013	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	96	\N
1014	Assist with budgeting skills training	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	97	\N
1015	Financial assistance to pay rent/bills (one-off)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	97	\N
1016	Assist in obtaining financial support to reduce debt	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	97	\N
1017	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	97	\N
1018	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	97	\N
1019	Assist with budgeting skills training	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	98	\N
1020	Assist in obtaining financial support to reduce debt	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	98	\N
1021	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	98	\N
1022	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	98	\N
1023	Assist with obtaining necessary documents	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	99	\N
1024	Linked to/availing schemes/resources/support from gov’t or NGOs (such as Assistance to claim benefits- may include accessing information, documentation on potential benefits, assistance with applications)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	99	\N
1025	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	99	\N
1026	Ensure child is safe – move to another placement if needed	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	100	\N
1027	Discuss safety measures such as never go out alone, don’t go out after dark, etc.	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	100	\N
1028	Discuss with neighbors, community influencers other political/ other authorities on matters concerning child and family safety	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	100	\N
1029	Consider family move to safer location if possible	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	100	\N
1030	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	100	\N
1031	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	100	\N
1032	Explore/ provide stable accommodations	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	101	\N
1033	Improved safety	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	101	\N
1034	Assist with obtaining refurbishing/repairs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	101	\N
1035	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	101	\N
1036	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	101	\N
1037	Assist with access to basic amenities	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	102	\N
1038	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	102	\N
1039	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	102	\N
1040	Assist with purchase of furniture, household appliances, etc.	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	103	\N
1041	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	103	\N
1042	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	103	\N
1043	Discuss importance of education	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	104	\N
1044	Explore education facilities within practical range from home	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	104	\N
1045	Arrange for remote learning if possible	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	104	\N
1046	Assist with school fees	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	104	\N
1047	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	104	\N
1048	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	104	\N
1049	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	105	\N
1050	Assist with higher education/vocational training for child	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	105	\N
1051	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	105	\N
1052	Assist with purchase of school supplies/educational toys	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	106	\N
1053	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	106	\N
1054	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	106	\N
1055	Assist with arranging transportation to school	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	107	\N
1056	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	107	\N
1057	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	108	\N
1058	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	108	\N
1059	Support for learning issues (LD, ADHD, physical disabilities, etc.)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	108	\N
1060	Offer guidance to parents/ caregivers for learning issues	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	108	\N
1061	Discuss with school on special education needs related to child	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	108	\N
1062	Provide access to extracurricular activities (such as supplies, fees, etc.)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	109	\N
1063	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	109	\N
1064	Ensure safety of child and other family members	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	110	\N
1065	Set boundaries for behavior of abuser (eg, never use substances at home, never come home drunk/high, etc.)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	110	\N
1066	Refer abuser for treatment	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	110	\N
1067	Access to de-addiction center/ Alcoholics Anonymous Groups (AA)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	110	\N
1068	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	110	\N
1069	Access to general health care services	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	111	\N
1070	Access to family planning and counseling	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	111	\N
1071	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	111	\N
1072	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	111	\N
1073	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	112	\N
1074	Access to health care services - PHCs, other catering specific health issues	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	112	\N
1075	Provide information to child/ family regarding managing health condition	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	112	\N
1076	Liked to availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	112	\N
1077	Assist with access to dentist/vision care	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	113	\N
1078	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	113	\N
1079	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	113	\N
1080	Assist with access to mental health services (including counseling, therapy, etc.)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	114	\N
1081	Offer support with guidance to family on managing symptoms	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	114	\N
1082	Support with accessing medication	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	114	\N
1083	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	114	\N
1084	Assist with access to mental health services (including counseling, therapy, etc.)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	115	\N
1085	Offer support with guidance to family on managing symptoms	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	115	\N
1086	Support with accessing medication	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	115	\N
1087	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	115	\N
1088	Assist with access to medication/medical equipment	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	116	\N
1089	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	116	\N
1090	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	116	\N
1091	Assist with access to services for impairments/disabilities/ developmental delays	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	117	\N
1092	Assist with obtaining medical equipment (such as hearing aids, prosthetics, etc	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	117	\N
1093	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	117	\N
1094	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	117	\N
1095	Teach personal hygiene and self-care skills and	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	118	\N
1096	Offer access to personal hygiene products - (soaps, sanitary napkins, etc)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	118	\N
1097	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	118	\N
1098	Review diet	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	119	\N
1099	Offer nutritional resources	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	119	\N
1100	Assist in getting hemoglobin tested	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	119	\N
1101	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	119	\N
1102	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	119	\N
1103	Access to nutritious foods	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	120	\N
1104	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	120	\N
1105	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	120	\N
1106	Assist with health insurance	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	121	\N
1107	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	121	\N
1108	Other (please specify)	\N	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.868+00	2024-04-11 10:49:51.868+00	\N	\N	121	\N
1	In-crisis	1	f	t	f	\N	\N	2022-02-21 16:47:36.816+00	2022-02-21 16:47:36.816+00	1	\N	\N	{"1" : "In-crisis", "2" : "संकट में", "3" : "நெருக்கடியில்"}
2	Vulnerable	2	f	t	f	\N	\N	2022-02-21 16:47:36.816+00	2022-02-21 16:47:36.816+00	1	\N	\N	{"1" : "Vulnerable", "2" : "असुरक्षित", "3" : "பாதிக்கப்படக்கூடிய நிலையில்"}
3	Safe	3	f	t	f	\N	\N	2022-02-21 16:47:36.816+00	2022-02-21 16:47:36.816+00	1	\N	\N	{"1" : "Safe", "2" : "सुरक्षित", "3" : "பாதுகாப்பான நிலையில்"}
4	Thriving	4	f	t	f	\N	\N	2022-02-21 16:47:36.816+00	2022-02-21 16:47:36.816+00	1	\N	\N	{"1" : "Thriving", "2" : "समृद्धि", "3" : "வளரும் நிலையில்"}
1109	Report to proper authorities	\N	f	t	f	\N	\N	2022-02-21 16:47:36.816+00	2022-02-21 16:47:36.816+00	\N	\N	1	\N
1110	Ensure safety of child or other family member	\N	f	t	f	\N	\N	2022-02-21 16:47:36.816+00	2022-02-21 16:47:36.816+00	\N	\N	1	\N
1111	Refer for counseling to resolve issues leading to abuse such as anger management, anxiety, depression, behavioral issues, marital issues, difficulty in relationship with family members, etc.	\N	f	t	f	\N	\N	2022-02-21 16:47:36.816+00	2022-02-21 16:47:36.816+00	\N	\N	1	\N
1112	Support with obtaining counseling for the abused	\N	f	t	f	\N	\N	2022-02-21 16:47:36.816+00	2022-02-21 16:47:36.816+00	\N	\N	1	\N
1113	Other (please specify)	\N	f	t	f	\N	\N	2022-02-21 16:47:36.816+00	2022-02-21 16:47:36.816+00	\N	\N	1	\N
1114	Refer for support such as relief packages	\N	t	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	2024-05-02 06:13:56.854+00	2024-05-02 06:13:56.854+00	\N	\N	123	\N
1115	Discuss stable employment opportunities	\N	t	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	2024-05-02 06:13:56.862+00	2024-05-02 06:13:56.862+00	\N	\N	123	\N
1116	Linked to/availing schemes (such as financial assistance, Self-help groups, other unemployment benefits	\N	t	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	2024-05-02 06:13:56.865+00	2024-05-02 06:13:56.865+00	\N	\N	123	\N
1117	Other (please specify)	\N	t	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	2024-05-02 06:13:56.869+00	2024-05-02 06:13:56.869+00	\N	\N	123	\N
1118	Refer for support such as relief packages	\N	t	t	f	78c7a329-36a7-45d6-9ad8-4efec6d3136d	\N	2024-05-15 20:33:18.881+00	2024-05-15 20:33:18.881+00	\N	\N	124	\N
1119	Discuss stable employment opportunities	\N	t	t	f	78c7a329-36a7-45d6-9ad8-4efec6d3136d	\N	2024-05-15 20:33:18.885+00	2024-05-15 20:33:18.885+00	\N	\N	124	\N
1120	Linked to/availing schemes (such as financial assistance, Self-help groups, other unemployment benefits	\N	t	t	f	78c7a329-36a7-45d6-9ad8-4efec6d3136d	\N	2024-05-15 20:33:18.889+00	2024-05-15 20:33:18.889+00	\N	\N	124	\N
1121	Other (please specify)	\N	t	t	f	78c7a329-36a7-45d6-9ad8-4efec6d3136d	\N	2024-05-15 20:33:18.891+00	2024-05-15 20:33:18.891+00	\N	\N	124	\N
1122	test	\N	t	t	f	78c7a329-36a7-45d6-9ad8-4efec6d3136d	\N	2024-05-15 20:33:18.9+00	2024-05-15 20:33:18.9+00	\N	\N	124	\N
1123	Testing the options	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	\N	2024-05-20 13:59:11.19+00	2024-05-20 13:59:11.19+00	\N	\N	125	\N
1124	Testing a second option	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	\N	2024-05-20 13:59:11.193+00	2024-05-20 13:59:11.193+00	\N	\N	125	\N
1125	Report to proper authorities	\N	f	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	126	\N
1126	Ensure safety of child or other family member	\N	f	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	126	\N
1127	Refer for counseling to resolve issues leading to abuse such as anger management, anxiety, depression, behavioral issues, marital issues, difficulty in relationship with family members, etc.	\N	f	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	126	\N
1128	Support with obtaining counseling for the abused	\N	f	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	126	\N
1129	Other (please specify)	\N	f	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	126	\N
1130	Report to proper authorities	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	127	\N
1131	Refer for counselling to support family to cope with impact of abuse	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	127	\N
1132	Ensure safety of child or other family member	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	127	\N
1133	Support with obtaining counseling for the abused	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	127	\N
1134	Report to proper authorities	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	128	\N
1135	Ensure safety of the child	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	128	\N
1136	Educate family on risks of child marriage and review alternatives	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	128	\N
1137	increase frequency monitoring support	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	128	\N
1138	Empower child with information, skills and support networks	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	128	\N
1139	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	128	\N
1140	Support to connect with extended family (such as facilitating regular contact, exploring respite care options, phone calls, transportation options, etc)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	129	\N
1141	Support with obtaining counseling for difficulty in relationships with family members	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	129	\N
1142	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	129	\N
1143	Assist with developing network in community	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	130	\N
1144	Support with obtaining counseling for difficulty in relationships with neighbors/community	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	130	\N
1145	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	130	\N
1146	Assist with parenting skills training-may include individualized training with SW or group classes; identify skills needed	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	131	\N
1147	Linked to/availing schemes (Parenting/ child care support, affordable housing, healthcare, safety, supportive social networks including respite/emergency support when family is in crisis)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	131	\N
1148	Support with access to counseling services	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	131	\N
1149	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	131	\N
1150	Connect to assistance for extra support needed for child (such as access to child care, respite care support, parenting techniques other specialized support)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	132	\N
1151	Support with access to counseling services	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	132	\N
1152	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	132	\N
1153	Support for caregivers who are under 21 or very elderly (such as parental guidance, addressing child safety issues, child care, respite care support, etc)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	133	\N
1154	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	133	\N
1155	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	133	\N
1156	Provide basic training, information, and guidance on CP risks & reporting procedures to primary carer and child	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	134	\N
1157	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	134	\N
1158	Provide education on importance of children’s rights	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	135	\N
1159	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	135	\N
1160	Support to connect with birth family (such as facilitating regular contact, exploring respite care options, phone calls, transportation options, etc)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	136	\N
1161	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	136	\N
1162	Offer support with relationship counseling for marital issues	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	137	\N
1163	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	137	\N
1164	Testing the options	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	138	\N
1165	Testing a second option	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	138	\N
1166	Refer for support such as relief packages	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	139	\N
1167	Discuss stable employment opportunities	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	139	\N
1168	Linked to/availing schemes (such as financial assistance, Self-help groups, other unemployment benefits	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	139	\N
1169	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	139	\N
1170	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	140	\N
1171	Access to adult education/literacy courses	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	140	\N
1172	Assist in obtaining vocational training for adult	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	140	\N
1223	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	152	\N
1173	Assist with job-seeking- may include access to job postings, preparing job application, preparation for interviews, transportation to interviews, appropriate attire for interviews	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	140	\N
1174	Assist with obtaining necessary documents	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	140	\N
1175	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	140	\N
1176	Assist in obtaining supplies/tools for job	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	141	\N
1177	Discuss short-term bank loans	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	141	\N
1178	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	141	\N
1179	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	141	\N
1180	Assist with accessing transportation for job	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	142	\N
1181	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	142	\N
1182	Assist in locating child care during work hours (such as neighbors, extended family, etc.)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	143	\N
1183	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	143	\N
1184	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	143	\N
1185	Assist in obtaining food, clothing, and household supplies	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	144	\N
1186	Budgeting skills training	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	144	\N
1187	Assist in obtaining financial support to reduce debt	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	144	\N
1188	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	144	\N
1189	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	144	\N
1190	Assist with budgeting skills training	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	145	\N
1191	Financial assistance to pay rent/bills (one-off)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	145	\N
1192	Assist in obtaining financial support to reduce debt	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	145	\N
1193	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	145	\N
1194	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	145	\N
1195	Assist with budgeting skills training	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	146	\N
1196	Assist in obtaining financial support to reduce debt	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	146	\N
1197	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	146	\N
1198	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	146	\N
1199	Assist with obtaining necessary documents	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	147	\N
1200	Linked to/availing schemes/resources/support from gov’t or NGOs (such as Assistance to claim benefits- may include accessing information, documentation on potential benefits, assistance with applications)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	147	\N
1201	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	147	\N
1202	Ensure child is safe – move to another placement if needed	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	148	\N
1203	Discuss safety measures such as never go out alone, don’t go out after dark, etc.	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	148	\N
1204	Discuss with neighbors, community influencers other political/ other authorities on matters concerning child and family safety	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	148	\N
1205	Consider family move to safer location if possible	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	148	\N
1206	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	148	\N
1207	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	148	\N
1208	Explore/ provide stable accommodations	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	149	\N
1209	Improved safety	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	149	\N
1210	Assist with obtaining refurbishing/repairs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	149	\N
1211	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	149	\N
1212	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	149	\N
1213	Assist with access to basic amenities	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	150	\N
1214	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	150	\N
1215	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	150	\N
1216	Assist with purchase of furniture, household appliances, etc.	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	151	\N
1217	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	151	\N
1218	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	151	\N
1219	Discuss importance of education	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	152	\N
1220	Explore education facilities within practical range from home	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	152	\N
1221	Arrange for remote learning if possible	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	152	\N
1222	Assist with school fees	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	152	\N
1224	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	152	\N
1225	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	153	\N
1226	Assist with higher education/vocational training for child	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	153	\N
1227	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	153	\N
1228	Assist with purchase of school supplies/educational toys	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	154	\N
1229	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	154	\N
1230	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	154	\N
1231	Assist with arranging transportation to school	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	155	\N
1232	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	155	\N
1233	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	156	\N
1234	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	156	\N
1235	Support for learning issues (LD, ADHD, physical disabilities, etc.)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	156	\N
1236	Offer guidance to parents/ caregivers for learning issues	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	156	\N
1237	Discuss with school on special education needs related to child	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	156	\N
1238	Provide access to extracurricular activities (such as supplies, fees, etc.)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	157	\N
1239	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	157	\N
1240	Ensure safety of child and other family members	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	158	\N
1241	Set boundaries for behavior of abuser (eg, never use substances at home, never come home drunk/high, etc.)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	158	\N
1242	Refer abuser for treatment	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	158	\N
1243	Access to de-addiction center/ Alcoholics Anonymous Groups (AA)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	158	\N
1244	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	158	\N
1245	Access to general health care services	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	159	\N
1246	Access to family planning and counseling	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	159	\N
1247	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	159	\N
1248	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	159	\N
1249	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	160	\N
1250	Access to health care services - PHCs, other catering specific health issues	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	160	\N
1251	Provide information to child/ family regarding managing health condition	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	160	\N
1252	Liked to availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	160	\N
1253	Assist with access to dentist/vision care	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	161	\N
1254	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	161	\N
1255	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	161	\N
1256	Assist with access to mental health services (including counseling, therapy, etc.)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	162	\N
1257	Offer support with guidance to family on managing symptoms	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	162	\N
1258	Support with accessing medication	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	162	\N
1259	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	162	\N
1260	Assist with access to mental health services (including counseling, therapy, etc.)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	163	\N
1261	Offer support with guidance to family on managing symptoms	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	163	\N
1262	Support with accessing medication	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	163	\N
1263	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	163	\N
1264	Assist with access to medication/medical equipment	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	164	\N
1265	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	164	\N
1266	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	164	\N
1267	Assist with access to services for impairments/disabilities/ developmental delays	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	165	\N
1268	Assist with obtaining medical equipment (such as hearing aids, prosthetics, etc	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	165	\N
1269	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	165	\N
1270	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	165	\N
1271	Teach personal hygiene and self-care skills and	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	166	\N
1272	Offer access to personal hygiene products - (soaps, sanitary napkins, etc)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	166	\N
1273	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	166	\N
1274	Review diet	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	167	\N
1275	Offer nutritional resources	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	167	\N
1276	Assist in getting hemoglobin tested	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	167	\N
1277	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	167	\N
1278	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	167	\N
1279	Access to nutritious foods	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	168	\N
1280	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	168	\N
1281	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	168	\N
1282	Assist with health insurance	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	169	\N
1283	Linked to/availing schemes/resources/support from gov’t or NGOs	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	169	\N
1284	Other (please specify)	\N	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.549+00	2024-05-20 13:59:16.549+00	\N	\N	169	\N
\.


--
-- Data for Name: HT_countries; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_countries" (id, "countryName", "isoCode", "countryCode", "phoneNumberFormat", "isActive", "isDeleted", "createdAt", "updatedAt", "districtRequired", "stateRequired", "iso2Code", "countryNameLang") FROM stdin;
1	India	IND	91	dss	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	t	t	IN	{"1":"India","2":"भारत","3":"இந்தியா"}
2	US	US	1	sfd	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	f	t	US	{"1":"US","2":"यूएसए","3":"அமெரிக்கா"}
3	Uganda	UGN	1	dfgdf	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	f	t	UG	{"1":"Uganda","2":"युगांडा","3":"உகாண்டா"}
\.


--
-- Data for Name: HT_countryLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_countryLangMaps" (id, "countryName", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTCountryId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_deviceDetails; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_deviceDetails" (id, token, platform, model, "osVersion", "endpointARN", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTUserId") FROM stdin;
\.


--
-- Data for Name: HT_districtLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_districtLangMaps" (id, "districtName", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTDistrictId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_districts; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_districts" (id, "districtName", "isActive", "isDeleted", "createdAt", "updatedAt", "HTStateId", "districtNameLang", "MPCountryId") FROM stdin;
1	Alipur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Alipur", "2" : "अलीपुर", "3" : "அலிபூர்"}	1
2	Andaman Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Andaman Island", "2" : "अंडमान द्वीप", "3" : "அந்தமான் தீவு"}	1
3	Anderson Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Anderson Island", "2" : "एंडरसन द्वीप", "3" : "ஆண்டர்சன் தீவு"}	1
4	Arainj-Laka-Punga	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Arainj-Laka-Punga", "2" : "अरंज-लाका-पुंगा", "3" : "Arainj-Laka-Punga"}	1
5	Austinabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Austinabad", "2" : "ऑस्टिनाबाद", "3" : "Ustinbad"}	1
6	Bamboo Flat	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Bamboo Flat", "2" : "बांस फ्लैट", "3" : "பம்பூ பிளாட்"}	1
7	Barren Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Barren Island", "2" : "बंजर द्वीप", "3" : "பாரன் தீவு"}	1
98	Trivandrum	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	18	\N	\N
8	Beadonabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Beadonabad", "2" : "बीडोनेबाद", "3" : "பெடோனாபாத்"}	1
9	Betapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Betapur", "2" : "बेटापुर", "3" : "பெட்பூர்"}	1
10	Bindraban	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Bindraban", "2" : "बिंद्राबन", "3" : "பிணைப்பு"}	1
11	Bonington	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Bonington", "2" : "बोनिंगटन", "3" : "போனிங்டன்"}	1
12	Brookesabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Brookesabad", "2" : "ब्रुकसेबाद", "3" : "ப்ரூக்ஸாபாத்"}	1
13	Cadell Point	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Cadell Point", "2" : "कैडेल प्वाइंट", "3" : "காடெல் புள்ளி"}	1
14	Calicut	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Calicut", "2" : "कालीकट", "3" : "காலிகட்"}	1
15	Chetamale	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Chetamale", "2" : "चेतमेल", "3" : "சேட்டமலே"}	1
16	Cinque Islands	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Cinque Islands", "2" : "सिंक द्वीपसमूह", "3" : "சின்க் தீவுகள்"}	1
17	Defence Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Defence Island", "2" : "रक्षा द्वीप", "3" : "பாதுகாப்பு தீவு"}	1
18	Digilpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Digilpur", "2" : "दिगिलपुर", "3" : "டிஜில்பூர்"}	1
19	Dolyganj	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Dolyganj", "2" : "डोलीगंज", "3" : "Dolyginj"}	1
20	Flat Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Flat Island", "2" : "फ्लैट द्वीप", "3" : "பிளாட் தீவு"}	1
21	Geinyale	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Geinyale", "2" : "जिन्याल", "3" : "புவி"}	1
22	Great Coco Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Great Coco Island", "2" : "ग्रेट कोको द्वीप", "3" : "சிறந்த கோகோ தீவு"}	1
23	Haddo	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Haddo", "2" : "हड्डो", "3" : "ஹடோ"}	1
24	Havelock Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Havelock Island", "2" : "हवेलॉक आइलैंड", "3" : "ஹேவ்லாக் தீவு"}	1
25	Henry Lawrence Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Henry Lawrence Island", "2" : "हेनरी लॉरेंस आइलैंड", "3" : "ஹென்றி லாரன்ஸ் தீவு"}	1
26	Herbertabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Herbertabad", "2" : "हरर्बटाबाद", "3" : "ஹெர்பெர்டாபாத்"}	1
27	Hobdaypur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Hobdaypur", "2" : "हॉबीपुर", "3" : "ஹாப்டேபூர்"}	1
28	Ilichar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Ilichar", "2" : "इल्चर", "3" : "Ilichar"}	1
29	Ingoie	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Ingoie", "2" : "आंत्र", "3" : "Ingoie"}	1
30	Inteview Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Inteview Island", "2" : "इंटीव्यू आइलैंड", "3" : "இன்டிவியூ தீவு"}	1
31	Jangli Ghat	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Jangli Ghat", "2" : "जंगली घाट", "3" : "ஜாங்லி காட்"}	1
32	Jhon Lawrence Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Jhon Lawrence Island", "2" : "झोन लॉरेंस आइलैंड", "3" : "ஜான் லாரன்ஸ் தீவு"}	1
33	Karen	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Karen", "2" : "करें", "3" : "கரேன்"}	1
34	Kartara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Kartara", "2" : "करतारा", "3" : "கர்தாரா"}	1
35	KYD Islannd	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "KYD Islannd", "2" : "कैद इसलैंड", "3" : "KYD ISLANND"}	1
36	Landfall Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Landfall Island", "2" : "लैंडफॉल आइलैंड", "3" : "நிலச்சரிவு தீவு"}	1
37	Little Andmand	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Little Andmand", "2" : "लिटिल अंडमाण्ड", "3" : "சிறிய மற்றும் மேண்ட்"}	1
38	Little Coco Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Little Coco Island", "2" : "लिटिल कोको आइलैंड", "3" : "சிறிய கோகோ தீவு"}	1
39	Long Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Long Island", "2" : "लॉन्ग आइलैंड", "3" : "நீண்ட தீவு"}	1
40	Maimyo	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Maimyo", "2" : "मैमो", "3" : "மைமியோ"}	1
41	Malappuram	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Malappuram", "2" : "मलप्पुरम", "3" : "மலப்புரம்"}	1
42	Manglutan	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Manglutan", "2" : "मंगलुटान", "3" : "மங்க்லூட்டன்"}	1
43	Manpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Manpur", "2" : "मानपुर", "3" : "மன்பூர்"}	1
44	Mitha Khari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Mitha Khari", "2" : "मिथा खारी", "3" : "மிதா காரி"}	1
45	Neill Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Neill Island", "2" : "नील द्वीप", "3" : "நீல் தீவு"}	1
46	Nicobar Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Nicobar Island", "2" : "निकोबार द्वीप", "3" : "நிக்கோபார் தீவு"}	1
47	North Brother Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "North Brother Island", "2" : "उत्तरी भाई द्वीप", "3" : "வடக்கு சகோதரர் தீவு"}	1
48	North Passage Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "North Passage Island", "2" : "उत्तर मार्ग द्वीप", "3" : "வடக்கு பாஸேஜ் தீவு"}	1
49	North Sentinel Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "North Sentinel Island", "2" : "उत्तरी सेंटीनेल द्वीप", "3" : "வடக்கு சென்டினல் தீவு"}	1
50	Nothen Reef Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Nothen Reef Island", "2" : "नॉटेन रीफ द्वीप", "3" : "நோத்தன் ரீஃப் தீவு"}	1
51	Outram Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Outram Island", "2" : "आउट्राम द्वीप", "3" : "அட்ராம் தீவு"}	1
52	Pahlagaon	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Pahlagaon", "2" : "पहलागांव", "3" : "பஹ்லகான்"}	1
53	Palalankwe	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Palalankwe", "2" : "पलालंक्वे", "3" : "பலாலங்க்வே"}	1
54	Passage Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Passage Island", "2" : "मार्ग द्वीप", "3" : "பாஸேஜ் தீவு"}	1
55	Phaiapong	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Phaiapong", "2" : "फाइपोंग", "3" : "பையாபோங்"}	1
56	Phoenix Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Phoenix Island", "2" : "फीनिक्स आइलैंड", "3" : "பீனிக்ஸ் தீவு"}	1
57	Port Blair	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Port Blair", "2" : "पोर्ट ब्लेयर", "3" : "போர்ட் பிளேர்"}	1
58	Preparis Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Preparis Island", "2" : "तैयारी द्वीप", "3" : "ரெப்பரிஸ் தீவு"}	1
59	Protheroepur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Protheroepur", "2" : "प्रकोष्ठ", "3" : "Protheroepur"}	1
60	Rangachang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Rangachang", "2" : "रंगाचांग", "3" : "ரங்கச்சாங்"}	1
61	Rongat	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Rongat", "2" : "रोंगत", "3" : "ரோங்காட்"}	1
62	Rutland Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Rutland Island", "2" : "रूटलैंड द्वीप", "3" : "ரட்லேண்ட் தீவு"}	1
63	Sabari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Sabari", "2" : "साबारी", "3" : "சபாரி"}	1
64	Saddle Peak	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Saddle Peak", "2" : "सैडल पीक", "3" : "சேணம் உச்சம்"}	1
706	Karur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Karur", "2" : "करूर", "3" : "கரூர்"}	1
752	Khowai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Khowai", "2" : "खोवै", "3" : "கவாய்"}	1
65	Shadipur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Shadipur", "2" : "शादीपुर", "3" : "ஷாடிபூர்"}	1
66	Smith Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Smith Island", "2" : "स्मिथ आइलैंड", "3" : "ஸ்மித் தீவு"}	1
67	Sound Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Sound Island", "2" : "ध्वनि द्वीप", "3" : "ஒலி தீவு"}	1
68	South Sentinel Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "South Sentinel Island", "2" : "दक्षिण सेंटीनेल द्वीप", "3" : "தெற்கு சென்டினல் தீவு"}	1
69	Spike Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Spike Island", "2" : "स्पाइक आइलैंड", "3" : "ஸ்பைக் தீவு"}	1
70	Tarmugli Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Tarmugli Island", "2" : "तारगुली द्वीप", "3" : "தர்முக்லி தீவு"}	1
71	Taylerabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Taylerabad", "2" : "टायलोराबाद", "3" : "டொட்டாலராபாத்"}	1
72	Titaije	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Titaije", "2" : "टेटाइज़र", "3" : "டெட்டாஸ்"}	1
73	Toibalawe	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Toibalawe", "2" : "तोइबालावे", "3" : "தைபலேவ்"}	1
74	Tusonabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Tusonabad", "2" : "तसोनबाद", "3" : "டுசோனாபாத்"}	1
75	West Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "West Island", "2" : "वेस्ट आइलैंड", "3" : "மேற்கு தீவு"}	1
76	Wimberleyganj	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Wimberleyganj", "2" : "विम्बरलेगंज", "3" : "விம்பர்லயகஞ்ச்"}	1
77	Yadita	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1" : "Yadita", "2" : "अनुकूलन", "3" : "ஏற்றுக்கொள்ளப்பட்டது"}	1
101	Anjaw	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Anjaw", "2" : "अंजॉ।", "3" : "அன்ஜாவ்"}	1
102	Changlang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Changlang", "2" : "चांगलांग।", "3" : "சாங்லாங்"}	1
103	Dibang Valley	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Dibang Valley", "2" : "डियानस घाटी।", "3" : "திபாங் பள்ளத்தாக்கு"}	1
104	East Kameng	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "East Kameng", "2" : "पूर्वी कामेंग", "3" : "கிழக்கு காமெங்"}	1
105	East Siang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "East Siang", "2" : "पूर्वी सियांग।", "3" : "கிழக்கு சியாங்"}	1
106	Itanagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Itanagar", "2" : "इटानगर।", "3" : "இட்டனகர்"}	1
107	Kurung Kumey	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Kurung Kumey", "2" : "कुरुंग कुमेरी।", "3" : "குருங் குமே"}	1
108	Lohit	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Lohit", "2" : "लोहित।", "3" : ""}	1
109	Lower Dibang Valley	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Lower Dibang Valley", "2" : "निचली दीबांग घाटी।", "3" : "லோயர் திபாங் பள்ளத்தாக்கு"}	1
110	Lower Subansiri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Lower Subansiri", "2" : "निचला सुबानसिरी।", "3" : "லோயர் சுபன்சிரி"}	1
111	Papum Pare	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Papum Pare", "2" : "पापुमार", "3" : "பாபம் பரே"}	1
112	Tawang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Tawang", "2" : "तवांग", "3" : "தவாங்"}	1
113	Tirap	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Tirap", "2" : "तिरुप", "3" : ""}	1
114	Upper Siang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Upper Siang", "2" : "ऊपरी सिआंग", "3" : "அப்பர் சியாங்"}	1
115	Upper Subansiri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "Upper Subansiri", "2" : "ऊपरी सुबानिरी", "3" : "அப்பர் சுபன்சிரி"}	1
116	West Kameng	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "West Kameng", "2" : "पश्चिम कामेंग", "3" : "மேற்கு காமெங்"}	1
117	West Siang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	3	{"1" : "West Siang", "2" : "वेस्ट सिआंग", "3" : "மேற்கு சியாங்"}	1
118	Barpeta	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Barpeta", "2" : "बारपेटा", "3" : "பார்பேட்டா"}	1
119	Bongaigaon	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Bongaigaon", "2" : "बोंगिगांव", "3" : "போங்கைகான்"}	1
120	Cachar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Cachar", "2" : "कैहर", "3" : "கச்சர்"}	1
121	Darrang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Darrang", "2" : "दरांग", "3" : "பாஸ்"}	1
122	Dhemaji	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Dhemaji", "2" : "ख्वाब", "3" : "தமாஜி"}	1
123	Dhubri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Dhubri", "2" : "धुबरी", "3" : "துப்ரி"}	1
124	Dibrugarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Dibrugarh", "2" : "डिब्रूगढ़", "3" : "திப்ருகர்"}	1
125	Goalpara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Goalpara", "2" : "गोलपाड़ा", "3" : "கோலபாதா"}	1
126	Golaghat	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Golaghat", "2" : "गोलाघाट", "3" : "கோலாகத்"}	1
127	Guwahati	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Guwahati", "2" : "गुवाहाटी", "3" : "குவஹாத்தி"}	1
128	Hailakandi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Hailakandi", "2" : "हिकलकंडी", "3" : "ஹல்லகண்டி"}	1
129	Jorhat	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Jorhat", "2" : "जोरहाट", "3" : "ஜோர்ஹாட்"}	1
130	Kamrup	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Kamrup", "2" : "कामरूप", "3" : "கம்ரப்"}	1
131	Karbi Anglong	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Karbi Anglong", "2" : "करबी कांगलॉन्ग", "3" : "கார்பி ஆங்கிலோங்"}	1
132	Karimganj	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Karimganj", "2" : "करीमगंज", "3" : "கரிம்கஞ்ச்"}	1
133	Kokrajhar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Kokrajhar", "2" : "कोकराझार", "3" : "கோக்லியர்"}	1
134	Lakhimpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Lakhimpur", "2" : "लखम्पुर", "3" : "லக்கிம்பூர்"}	1
135	Marigaon	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Marigaon", "2" : "मैरीगांव", "3" : "மெரிகோன்"}	1
136	Nagaon	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Nagaon", "2" : "ड्रैगन", "3" : "நாகான்"}	1
137	Nalbari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Nalbari", "2" : "नलबाड़ी", "3" : "கரு"}	1
138	North Cachar Hills	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "North Cachar Hills", "2" : "उत्तरी कचर हिल्स", "3" : "வடக்கு கேட்சர் ஹில்ஸ்"}	1
139	Silchar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Silchar", "2" : "सिलचर", "3" : "பட்டு"}	1
140	Sivasagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Sivasagar", "2" : "शिवासागर", "3" : "சிவசாகர்"}	1
141	Sonitpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Sonitpur", "2" : "सोनितपुर", "3" : "சோனித்பூர்"}	1
142	Tinsukia	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Tinsukia", "2" : "तिंसुकिअ", "3" : "யூட்டானா"}	1
143	Udalguri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	4	{"1" : "Udalguri", "2" : "उदालगुरी", "3" : "ஃப்ளாஷ் -ஸ்டோரி"}	1
144	Araria	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Araria", "2" : "अररिअ", "3" : "அனாரியா"}	1
145	Aurangabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Aurangabad", "2" : "औरंगाबाद", "3" : "அவுரங்காபாத்"}	1
146	Banka	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Banka", "2" : "बांका", "3" : "வங்கி"}	1
147	Begusarai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Begusarai", "2" : "बेगुसराई", "3" : "பாகுசரை"}	1
148	Bhagalpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Bhagalpur", "2" : "भागलपुर", "3" : "பகுதி"}	1
149	Bhojpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Bhojpur", "2" : "भोजपुर", "3" : "போஜ்பூர்"}	1
150	Buxar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Buxar", "2" : "बक्सर", "3" : "பாக்ஸர்"}	1
151	Darbhanga	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Darbhanga", "2" : "दरभंगा", "3" : "தர்பங்கா"}	1
152	East Champaran	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "East Champaran", "2" : "ईस्ट चंपारण", "3" : "கிழக்கு சாம்பாரன்"}	1
153	Gaya	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Gaya", "2" : "गया", "3" : "சென்றது"}	1
154	Gopalganj	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Gopalganj", "2" : "गोपालगंज", "3" : "கோபல்கஞ்ச்"}	1
155	Jamshedpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Jamshedpur", "2" : "जमशेदपुर", "3" : "ஜாம்ஷெட்பூர்"}	1
156	Jamui	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Jamui", "2" : "जमुई", "3" : "ஜமுய்"}	1
157	Jehanabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Jehanabad", "2" : "जहानाबाद", "3" : "ஜெஹனாபாத்"}	1
158	Kaimur (Bhabua)	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Kaimur (Bhabua)", "2" : "कैमूर (भबुआ)", "3" : "கைமூர் (பாபுவா)"}	1
159	Katihar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Katihar", "2" : "कटिहार", "3" : "கதிஹார்"}	1
160	Khagaria	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Khagaria", "2" : "खगरीअ", "3" : "காகாரியா"}	1
161	Kishanganj	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Kishanganj", "2" : "किशनगंज", "3" : "கிஷங்ஜஞ்சன்ஜன்"}	1
162	Lakhisarai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Lakhisarai", "2" : "लखीसराय", "3" : "லகிசாராய்"}	1
163	Madhepura	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Madhepura", "2" : "मधेपुरा", "3" : "மத்தெபுரா"}	1
164	Madhubani	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Madhubani", "2" : "मधुबनी", "3" : "மாதுபனி"}	1
165	Munger	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Munger", "2" : "मुंगेर", "3" : "முங்கர்"}	1
166	Muzaffarpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Muzaffarpur", "2" : "मुजफ्फरपुर", "3" : "முசாபாரூர்"}	1
167	Nalanda	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Nalanda", "2" : "नालंदा", "3" : "நாலந்தா"}	1
168	Nawada	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Nawada", "2" : "नवादा", "3" : "நவாடா"}	1
169	Patna	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Patna", "2" : "पटना", "3" : "பாட்னா"}	1
170	Purnia	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Purnia", "2" : "पुरनिए", "3" : "பர்னியா"}	1
171	Rohtas	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Rohtas", "2" : "रोहतास", "3" : "ரோஹ்தாஸ்"}	1
172	Saharsa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Saharsa", "2" : "सहरसा", "3" : "சர்ஹாசா"}	1
173	Samastipur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Samastipur", "2" : "समस्तीपुर", "3" : "சமஸ்திபூர்"}	1
174	Saran	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Saran", "2" : "सरन", "3" : "சரண்"}	1
175	Sheikhpura	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Sheikhpura", "2" : "शेखपुरा", "3" : "ஷேக்புரா"}	1
176	Sheohar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Sheohar", "2" : "शेओहर", "3" : "ஷியோஹர்"}	1
177	Sitamarhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Sitamarhi", "2" : "सीतामढ़ी", "3" : "சீதமரி"}	1
178	Siwan	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Siwan", "2" : "सिवान", "3" : "செவான்"}	1
179	Supaul	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Supaul", "2" : "सुपौल", "3" : "சூப்பால்"}	1
180	Vaishali	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "Vaishali", "2" : "वैशाली", "3" : "வைஷாலி"}	1
181	West Champaran	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	5	{"1" : "West Champaran", "2" : "वेस्ट चम्पारन", "3" : "மேற்கு சாம்பாரன்"}	1
182	Chandigarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	6	{"1" : "Chandigarh", "2" : "चंडीगढ़", "3" : "சண்டிகர்"}	1
183	Mani Marja	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	6	{"1" : "Mani Marja", "2" : "मणि मरजा", "3" : "மணி மார்ஜா"}	1
184	Bastar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Bastar", "2" : "बस्तर", "3" : "பாஸ்டார்"}	1
185	Bhilai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Bhilai", "2" : "भिलाई", "3" : "பிலாய்"}	1
186	Bijapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Bijapur", "2" : "बीजापुर", "3" : "பிஜாப்பூர்"}	1
187	Bilaspur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Bilaspur", "2" : "बिलासपुर", "3" : "பிலாஸ்பூர்"}	1
188	Dhamtari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Dhamtari", "2" : "धमतरी", "3" : "தம்தாரி"}	1
189	Durg	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Durg", "2" : "दुर्ग", "3" : "டர்க்"}	1
190	Janjgir-Champa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Janjgir-Champa", "2" : "जांजगीर-चंपा", "3" : "Janjgir-Champa"}	1
191	Jashpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Jashpur", "2" : "जशपुर", "3" : "ஜஷ்பூர்"}	1
192	Kabirdham-Kawardha	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Kabirdham-Kawardha", "2" : "कबीरधाम-कवर्धा", "3" : "Kabirdham-Kawardha"}	1
193	Korba	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Korba", "2" : "कोरबा", "3" : "கோர்பா"}	1
194	Korea	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Korea", "2" : "कोरिया", "3" : "கொரியா"}	1
195	Mahasamund	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Mahasamund", "2" : "महासमुंद", "3" : "மகாசமுண்ட்"}	1
196	Narayanpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Narayanpur", "2" : "नारायणपुर", "3" : "நாராயன்பூர்"}	1
197	Norh Bastar-Kanker	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Norh Bastar-Kanker", "2" : "नौरः बस्तर-कांकेर", "3" : "Naur: பஸ்தார் கோர்"}	1
198	Raigarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Raigarh", "2" : "रायगढ़", "3" : "ராய்காட்"}	1
199	Raipur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Raipur", "2" : "रायपुर", "3" : "ராய்ப்பூர்"}	1
200	Rajnandgaon	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Rajnandgaon", "2" : "राजनांदगाव", "3" : "ராஜ்னந்த்கான்"}	1
201	South Bastar-Dantewada	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "South Bastar-Dantewada", "2" : "साउथ बस्तर-दंतेवाड़ा", "3" : "தெற்கு பஸ்டர்-டான்டேவாடா"}	1
202	Surguja	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	7	{"1" : "Surguja", "2" : "सुरगुजा", "3" : "புத்திசாலி"}	1
203	Amal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Amal", "2" : "अमल", "3" : "மரணதண்டனை"}	1
204	Amli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Amli", "2" : "अमली", "3" : "செயல்படுத்தவும்"}	1
205	Bedpa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Bedpa", "2" : "बेडपा", "3" : "பேட்"}	1
206	Chikhli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Chikhli", "2" : "चिखली", "3" : "கோழி"}	1
207	Dadra & Nagar Haveli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Dadra & Nagar Haveli", "2" : "दादरा & नगर हवेली", "3" : "தாத்ரா & நகர் ஹவேலி"}	1
208	Dahikhed	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Dahikhed", "2" : "दहीखेड", "3" : "தஹிகேத்"}	1
209	Dolara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Dolara", "2" : "डॉलर", "3" : "டாலர்"}	1
210	Galonda	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Galonda", "2" : "गलोंडा", "3" : "குளிர்ச்சியானது"}	1
211	Kanadi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Kanadi", "2" : "कनदी", "3" : "காது"}	1
212	Karchond	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Karchond", "2" : "कर्कन", "3" : "செயல்திறன்"}	1
213	Khadoli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Khadoli", "2" : "खडोली", "3" : "உணவு"}	1
214	Kharadpada	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Kharadpada", "2" : "खारदपाडा", "3" : "மோசமான"}	1
215	Kherabari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Kherabari", "2" : "खारी", "3" : "ஆலங்கட்டி"}	1
216	Kherdi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Kherdi", "2" : "खड़ी", "3" : "செர்ரி"}	1
217	Kothar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Kothar", "2" : "कोथार", "3" : "எங்கே"}	1
218	Luari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Luari", "2" : "लुआरी", "3" : "மந்தமான"}	1
219	Mashat	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Mashat", "2" : "मैशत", "3" : "மாஸ்ட்"}	1
220	Rakholi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Rakholi", "2" : "राखोली", "3" : "ரேக்"}	1
221	Rudana	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Rudana", "2" : "लूट", "3" : "ருடா"}	1
222	Saili	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Saili", "2" : "अंदाज", "3" : "மாலுமி"}	1
223	Sili	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Sili", "2" : "सिली", "3" : "சி"}	1
224	Silvassa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Silvassa", "2" : "सिल्वसा", "3" : "அமைதியாக"}	1
225	Sindavni	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Sindavni", "2" : "सिंदावानी", "3" : "சிண்டவானி"}	1
226	Udva	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Udva", "2" : "झगड़ा", "3" : "தோல்வி"}	1
227	Umbarkoi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Umbarkoi", "2" : "उमबरोई", "3" : "நகல்"}	1
228	Vansda	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Vansda", "2" : "अत्यंत", "3" : "நொறுங்கியது"}	1
229	Vasona	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Vasona", "2" : "अनिर्णित", "3" : "கப்பல்"}	1
230	Velugam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	8	{"1" : "Velugam", "2" : "विस्फोट", "3" : "வெலுகம்"}	1
231	Brancavare	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	9	{"1" : "Brancavare", "2" : "ब्रांकोष", "3" : "பிரான்காவேர்"}	1
232	Dagasi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	9	{"1" : "Dagasi", "2" : "दगासी", "3" : "டாடரிங்"}	1
233	Daman	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	9	{"1" : "Daman", "2" : "दमन", "3" : "டாமன்"}	1
234	Diu	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	9	{"1" : "Diu", "2" : "आईयूडी", "3" : "டியு"}	1
235	Magarvara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	9	{"1" : "Magarvara", "2" : "मगार्वारा", "3" : "மாகர்வாரா"}	1
236	Nagwa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	9	{"1" : "Nagwa", "2" : "नाग्वा", "3" : "நாக்வாவா"}	1
237	Pariali	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	9	{"1" : "Pariali", "2" : "ख़ारिज", "3" : "Paiali"}	1
238	Passo Covo	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	9	{"1" : "Passo Covo", "2" : "पासो कोवो", "3" : "பாஸோ கோவோ"}	1
239	Central Delhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	10	{"1" : "Central Delhi", "2" : "मध्य दिल्ली", "3" : "மத்திய டெல்லி"}	1
240	East Delhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	10	{"1" : "East Delhi", "2" : "पूर्वी दिल्ली", "3" : "கிழக்கு டெல்லி"}	1
241	New Delhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	10	{"1" : "New Delhi", "2" : "नई दिल्ली", "3" : "புது தில்லி"}	1
242	North Delhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	10	{"1" : "North Delhi", "2" : "उत्तर दिल्ली", "3" : "வடக்கு டெல்லி"}	1
293	Bhiwani	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Bhiwani", "2" : "भिवानी", "3" : "பிவானி"}	1
243	North East Delhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	10	{"1" : "North East Delhi", "2" : "उत्तर पूर्व दिल्ली", "3" : "வடகிழக்கு டெல்லி"}	1
244	North West Delhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	10	{"1" : "North West Delhi", "2" : "उत्तर पश्चिम दिल्ली", "3" : "வடமேற்கு டெல்லி"}	1
245	Old Delhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	10	{"1" : "Old Delhi", "2" : "पुरानी दिल्ली", "3" : "பழைய டெல்லி"}	1
246	South Delhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	10	{"1" : "South Delhi", "2" : "दक्षिण दिल्ली", "3" : "தெற்கு டெல்லி"}	1
247	South West Delhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	10	{"1" : "South West Delhi", "2" : "दक्षिण पश्चिम दिल्ली", "3" : "தென்மேற்கு டெல்லி"}	1
248	West Delhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	10	{"1" : "West Delhi", "2" : "पश्चिम दिल्ली", "3" : "மேற்கு டெல்லி"}	1
249	Canacona	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Canacona", "2" : "कानाकोना", "3" : "கனகோனா"}	1
250	Candolim	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Candolim", "2" : "कैंडोलिम", "3" : "காண்டோலிம்"}	1
251	Chinchinim	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Chinchinim", "2" : "चिंचिनिम", "3" : "சின்சினிம்"}	1
252	Cortalim	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Cortalim", "2" : "कोर्टलिम", "3" : "கோர்டலிம்"}	1
253	Goa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Goa", "2" : "गोवा", "3" : "கோவா"}	1
254	Jua	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Jua", "2" : "नहीं", "3" : "ஜுவா"}	1
255	Madgaon	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Madgaon", "2" : "मडगांव", "3" : "மட்கான்"}	1
256	Mahem	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Mahem", "2" : "महेम", "3" : "மஹேம்"}	1
257	Mapuca	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Mapuca", "2" : "मैपुका", "3" : "மாபுகா"}	1
258	Marmagao	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Marmagao", "2" : "मर्मागाओ", "3" : "மர்மகாவோ"}	1
259	Panji	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Panji", "2" : "बैनर", "3" : "பஞ்சி"}	1
260	Ponda	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Ponda", "2" : "तालाब", "3" : "போண்டா"}	1
261	Sanvordem	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Sanvordem", "2" : "सहमत", "3" : "சிண்டெம்"}	1
262	Terekhol	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	11	{"1" : "Terekhol", "2" : "उदार", "3" : "கோடுகள்"}	1
263	Ahmedabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Ahmedabad", "2" : "हमदाबाद", "3" : "எப்போதும்"}	1
264	Amreli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Amreli", "2" : "अमरेली", "3" : "மொத்த"}	1
265	Anand	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Anand", "2" : "हर्ष", "3" : "மகிழ்ச்சி"}	1
266	Banaskantha	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Banaskantha", "2" : "बनस्कंथा", "3" : "பனஸ்கந்தா"}	1
267	Baroda	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Baroda", "2" : "बड़ौदा", "3" : "பரோடா"}	1
268	Bharuch	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Bharuch", "2" : "भरूच", "3" : "மொத்த"}	1
269	Bhavnagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Bhavnagar", "2" : "भावनगर", "3" : "பாவ்நகர்"}	1
270	Dahod	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Dahod", "2" : "दाहोद", "3" : "தஹோத்"}	1
271	Dang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Dang", "2" : "दांग", "3" : "வளையல்"}	1
272	Dwarka	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Dwarka", "2" : "द्वारका", "3" : "டுவர்கா"}	1
273	Gandhinagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Gandhinagar", "2" : "गांधीनगर", "3" : "காந்திநகர்"}	1
274	Jamnagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Jamnagar", "2" : "जामनगर", "3" : "ஜாம்நகர்"}	1
275	Junagadh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Junagadh", "2" : "जूनागढ़", "3" : "ஜுனகத்"}	1
276	Kheda	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Kheda", "2" : "खेड़ा", "3" : "சாகுபடி"}	1
277	Kutch	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Kutch", "2" : "कूच", "3" : "முறை தவறி பிறந்த குழந்தை"}	1
278	Mehsana	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Mehsana", "2" : "मेहसाणा", "3" : "பேய்"}	1
279	Nadiad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Nadiad", "2" : "नदिअद", "3" : "நாடியாட்"}	1
280	Narmada	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Narmada", "2" : "नर्मदा", "3" : "நர்மதா"}	1
281	Navsari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Navsari", "2" : "नवसारी", "3" : "பதட்டமாக"}	1
282	Panchmahals	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Panchmahals", "2" : "पंचमहलिस", "3" : "ஐந்தாவது"}	1
283	Patan	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Patan", "2" : "पाटन", "3" : "படான்"}	1
284	Porbandar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Porbandar", "2" : "पोरबंदर", "3" : "போர்பந்தர்"}	1
285	Rajkot	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Rajkot", "2" : "राजकोट", "3" : "ராஜ்கோட்"}	1
286	Sabarkantha	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Sabarkantha", "2" : "साबरकांथा", "3" : "சபர்காந்தா"}	1
287	Surat	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Surat", "2" : "सूरत", "3" : "சூரத்"}	1
288	Surendranagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Surendranagar", "2" : "सुरेंद्रनगर", "3" : "சுரேந்திரநகர்"}	1
289	Vadodara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Vadodara", "2" : "वडोदरा", "3" : "வதோதரா"}	1
290	Valsad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Valsad", "2" : "वलसाड", "3" : "வால்சாத்"}	1
291	Vapi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	12	{"1" : "Vapi", "2" : "वापी", "3" : "வாபி"}	1
292	Ambala	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Ambala", "2" : "अम्बाला", "3" : "அம்பாலா"}	1
294	Faridabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Faridabad", "2" : "फरीदाबाद", "3" : "ஃபரிதாபாத்"}	1
295	Fatehabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Fatehabad", "2" : "फतेहाबाद", "3" : "ஃபதஹாபாத்"}	1
296	Gurgaon	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Gurgaon", "2" : "गुडगाँव", "3" : "குர்கான்"}	1
297	Hisar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Hisar", "2" : "हिसार", "3" : "ஹிசார்"}	1
298	Jhajjar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Jhajjar", "2" : "झज्जर", "3" : "ஜஜ்ஜார்"}	1
299	Jind	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Jind", "2" : "जींद", "3" : "ஜிண்ட்"}	1
300	Kaithal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Kaithal", "2" : "कैथल", "3" : "கைதால்"}	1
301	Karnal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Karnal", "2" : "कर्नल", "3" : "கர்னல்"}	1
302	Kurukshetra	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Kurukshetra", "2" : "कुरुक्षेत्र", "3" : "குருக்ஷேத்ரா"}	1
303	Mahendragarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Mahendragarh", "2" : "महेंद्रगढ़", "3" : "மகேந்திரகர்"}	1
304	Mewat	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Mewat", "2" : "मेवात", "3" : "Mewat"}	1
305	Panchkula	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Panchkula", "2" : "पंचकूला", "3" : "பஞ்ச்குலா"}	1
306	Panipat	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Panipat", "2" : "पानीपत", "3" : "பானிபட்"}	1
307	Rewari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Rewari", "2" : "रेवाड़ी", "3" : "ரெவாரி"}	1
308	Rohtak	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Rohtak", "2" : "रोहतक", "3" : "ரோஹ்தக்"}	1
309	Sirsa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Sirsa", "2" : "सिरसा", "3" : "சிர்சா"}	1
310	Sonipat	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Sonipat", "2" : "सोनीपत", "3" : "சோனிபட்"}	1
311	Yamunanagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	13	{"1" : "Yamunanagar", "2" : "यमुनानगर", "3" : "யமுனனகர்"}	1
312	Bilaspur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Bilaspur", "2" : "बिलासपुर", "3" : "பிலாஸ்பூர்"}	1
313	Chamba	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Chamba", "2" : "चम्बा", "3" : "சம்பா"}	1
314	Dalhousie	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Dalhousie", "2" : "डलहौज़ी", "3" : "டால்ஹெளசி"}	1
315	Hamirpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Hamirpur", "2" : "हमीरपुर", "3" : "ஹமிர்பூர்"}	1
316	Kangra	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Kangra", "2" : "काँगड़ा", "3" : "காங்க்ரா"}	1
317	Kinnaur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Kinnaur", "2" : "किन्नौर", "3" : "திருநங்கைகள்"}	1
318	Kullu	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Kullu", "2" : "कुल्लू", "3" : "குல்லு"}	1
319	Lahaul & Spiti	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Lahaul & Spiti", "2" : "लाहौल & स्पीति", "3" : "லஹால் & ஸ்பிட்டி"}	1
320	Mandi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Mandi", "2" : "मंडी", "3" : "சந்தை"}	1
321	Shimla	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Shimla", "2" : "शिमला", "3" : "சிம்லா"}	1
322	Sirmaur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Sirmaur", "2" : "सिरमौर", "3" : "Sirmaur"}	1
323	Solan	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Solan", "2" : "सोलन", "3" : "சோலன்"}	1
324	Una	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	14	{"1" : "Una", "2" : "उन", "3" : "கம்பளி"}	1
325	Anantnag	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Anantnag", "2" : "अनंतनाग", "3" : "அனந்த்நாக்"}	1
326	Baramulla	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Baramulla", "2" : "बारामुल्ला", "3" : "பரமுல்லா"}	1
327	Budgam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Budgam", "2" : "बुड़गम", "3" : "புகம்"}	1
328	Doda	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Doda", "2" : "डोडा", "3" : "டோடா"}	1
329	Jammu	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Jammu", "2" : "जम्मू", "3" : "ஜம்மு"}	1
330	Kargil	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Kargil", "2" : "कारगिल", "3" : "கார்கில்"}	1
331	Kathua	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Kathua", "2" : "कठुआ", "3" : "கதுவா"}	1
332	Kupwara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Kupwara", "2" : "कुपवाड़ा", "3" : "சதி"}	1
333	Leh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Leh", "2" : "लेह", "3" : "லெஹ்"}	1
334	Poonch	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Poonch", "2" : "पूँछ", "3" : "பஞ்ச்"}	1
335	Pulwama	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Pulwama", "2" : "पुलवामा", "3" : "புல்பாவில்"}	1
336	Rajauri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Rajauri", "2" : "राजौरी", "3" : "ராஜூரி"}	1
337	Srinagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Srinagar", "2" : "श्रीनगर", "3" : "ஸ்ரீநகர்"}	1
338	Udhampur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	15	{"1" : "Udhampur", "2" : "उधमपुर", "3" : "உதம்பூர்"}	1
339	Bokaro	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Bokaro", "2" : "बोकारो", "3" : "போக்"}	1
340	Chatra	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Chatra", "2" : "छात्र", "3" : "காடென்ஸ்"}	1
341	Deoghar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Deoghar", "2" : "देओघर", "3" : "தியோ -ஹவுஸ்"}	1
342	Dhanbad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Dhanbad", "2" : "धनबाद", "3" : "தன்பாத்"}	1
343	Dumka	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Dumka", "2" : "दुमका", "3" : "டும்கா"}	1
391	Raichur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Raichur", "2" : "रायचुर", "3" : "ரைச்சூர்"}	1
344	East Singhbhum	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "East Singhbhum", "2" : "ईस्ट सिंघभूम", "3" : "கிழக்கு சிங்க்பம்"}	1
345	Garhwa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Garhwa", "2" : "गढ़वा", "3" : "கர்வா"}	1
346	Giridih	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Giridih", "2" : "गिरिडीह", "3" : "கிரிடிஹ்"}	1
347	Godda	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Godda", "2" : "गोड्डा", "3" : "கோடா"}	1
348	Gumla	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Gumla", "2" : "गुमला", "3" : "கும்லா"}	1
349	Hazaribag	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Hazaribag", "2" : "हज़ारीबाग", "3" : "ஹசரிபாக்"}	1
350	Jamtara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Jamtara", "2" : "जामतारा", "3" : "ஜம்தாரா"}	1
351	Koderma	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Koderma", "2" : "कोडरमा", "3" : "கோடர்மா"}	1
352	Latehar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Latehar", "2" : "लातेहार", "3" : "பிந்தையது"}	1
353	Lohardaga	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Lohardaga", "2" : "लोहरदगा", "3" : "இரும்பு"}	1
354	Pakur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Pakur", "2" : "पाकुर", "3" : "குட்டை"}	1
355	Palamu	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Palamu", "2" : "पलामू", "3" : "பைலட்"}	1
356	Ranchi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Ranchi", "2" : "रांची", "3" : "சொறி"}	1
357	Sahibganj	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Sahibganj", "2" : "साहिबगंज", "3" : "சாஹிப்கஞ்ச்"}	1
358	Seraikela	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Seraikela", "2" : "सराईकेला", "3" : "செரேட்"}	1
359	Simdega	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "Simdega", "2" : "सिमडेगा", "3" : "சிமடேகா"}	1
360	West Singhbhum	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	16	{"1" : "West Singhbhum", "2" : "वेस्ट सिंघभूम", "3" : "வெஸ்ட் சிங்கம்"}	1
361	Bagalkot	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Bagalkot", "2" : "बागलकोट", "3" : "தோட்டக்கலை"}	1
362	Bangalore	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Bangalore", "2" : "बैंगलोर", "3" : "மாளிகை"}	1
363	Bangalore Rural	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Bangalore Rural", "2" : "बैंगलोर रूरल", "3" : "பங்களூர் கிராமப்புற"}	1
364	Belgaum	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Belgaum", "2" : "बेलगाउं", "3" : "பெல்காம்"}	1
365	Bellary	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Bellary", "2" : "बेल्लारी", "3" : "பெல்லாரி"}	1
366	Bhatkal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Bhatkal", "2" : "भटकल", "3" : "முறை தவறி பிறந்த குழந்தை"}	1
367	Bidar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Bidar", "2" : "बीदर", "3" : "கட்டுப்படுத்தப்பட்ட"}	1
368	Bijapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Bijapur", "2" : "बीजापुर", "3" : "பிஜாப்பூர்"}	1
369	Chamrajnagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Chamrajnagar", "2" : "चामराजनगर", "3" : "சம்ராஜநகர்"}	1
370	Chickmagalur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Chickmagalur", "2" : "चिकमगलूर", "3" : "சிக்மங்கலூர்"}	1
371	Chikballapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Chikballapur", "2" : "चिकबिलपुर", "3" : "சிக்க்பல்லாபூர்"}	1
372	Chitradurga	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Chitradurga", "2" : "चित्रदुर्ग", "3" : "சித்ரதுர்கா"}	1
373	Dakshina Kannada	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Dakshina Kannada", "2" : "दक्षिणी कन्नड़", "3" : "தக்ஷினா கன்னடா"}	1
374	Davanagere	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Davanagere", "2" : "दावनगेरे", "3" : "Davanagere"}	1
375	Dharwad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Dharwad", "2" : "धर्मद", "3" : "தர்வத்"}	1
376	Gadag	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Gadag", "2" : "गदग", "3" : "காட்டில்"}	1
377	Gulbarga	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Gulbarga", "2" : "गुलबर्गा", "3" : "குல்பர்கா"}	1
378	Hampi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Hampi", "2" : "हम्पी", "3" : "ஹம்பி"}	1
379	Hassan	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Hassan", "2" : "हसन", "3" : "ஹுசன்"}	1
380	Haveri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Haveri", "2" : "हावेरी", "3" : "ஹேவரி"}	1
381	Hospet	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Hospet", "2" : "होसपेट", "3" : "தொகுப்பாளர்"}	1
382	Karwar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Karwar", "2" : "कारवार", "3" : "கார்வர்"}	1
383	Kodagu	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Kodagu", "2" : "कोडागू", "3" : "கோடகு"}	1
384	Kolar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Kolar", "2" : "कोलार", "3" : "கோல்ரர்"}	1
385	Koppal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Koppal", "2" : "कोप्पल", "3" : "கொப்பால்"}	1
386	Madikeri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Madikeri", "2" : "मदिकेरी", "3" : "மடிகேரி"}	1
387	Mandya	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Mandya", "2" : "मंड्या", "3" : "மாண்டியா"}	1
388	Mangalore	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Mangalore", "2" : "मंगलौर", "3" : "மங்களூர்"}	1
389	Manipal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Manipal", "2" : "मणिपाल", "3" : "மணிப்பால்"}	1
390	Mysore	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Mysore", "2" : "मैसूर", "3" : "மைசூர்"}	1
392	Shimoga	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Shimoga", "2" : "छींक", "3" : "ஷிமோகா"}	1
393	Sirsi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Sirsi", "2" : "महोदय मै", "3" : "Srysy"}	1
394	Sringeri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Sringeri", "2" : "श्रृंगेरी", "3" : "ஸ்ரீனகேரி"}	1
449	Harda	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Harda", "2" : "हरदा", "3" : "ஹார்டா"}	1
395	Srirangapatna	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Srirangapatna", "2" : "श्रीरंगपटने", "3" : "ஸ்ரீரங்கபட்னம்"}	1
396	Tumkur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Tumkur", "2" : "टुंकिर", "3" : "டங்கூர்"}	1
397	Udupi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Udupi", "2" : "उडुपी", "3" : "Udupi"}	1
398	Uttara Kannada	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	17	{"1" : "Uttara Kannada", "2" : "उत्तर कन्नड़", "3" : "வடக்கு கன்னடா"}	1
399	Alappuzha	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Alappuzha", "2" : "अलपुझा", "3" : "அலப்புஜா"}	1
402	Ernakulam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Ernakulam", "2" : "एर्नाकुलम", "3" : "எர்னகுளம்"}	1
403	Idukki	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Idukki", "2" : "इडुक्की", "3" : "இடுகி"}	1
404	Kannur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Kannur", "2" : "कन्नूर", "3" : "கண்ணூர்"}	1
405	Kasargod	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Kasargod", "2" : "कासरगोड", "3" : "கசர்கோட்"}	1
407	Kollam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Kollam", "2" : "कोल्लम", "3" : "கொல்லம்"}	1
408	Kottayam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Kottayam", "2" : "कोट्टायम", "3" : "கோட்டயம்"}	1
410	Kozhikode	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Kozhikode", "2" : "कोझिकोड", "3" : "கோழிகோட்"}	1
411	Malappuram	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Malappuram", "2" : "मलप्पुपुरम", "3" : "மலப்ப்புரம்"}	1
412	Palakkad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Palakkad", "2" : "पलक्कड़", "3" : "பலக்காத்"}	1
413	Pathanamthitta	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Pathanamthitta", "2" : "पठानमता", "3" : "பதானம்தா"}	1
415	Thiruvananthapuram	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Thiruvananthapuram", "2" : "तिरुवनंतपुरम", "3" : "திருவனந்தபுரம்"}	1
416	Thrissur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Thrissur", "2" : "त्रिशूर", "3" : "த்ரிசூர்"}	1
419	Wayanad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	18	{"1" : "Wayanad", "2" : "वायानद", "3" : "வயநாட்"}	1
420	Agatti Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "Agatti Island", "2" : "अगति आइलैंड", "3" : "அகட்டி தீவு"}	1
421	Bingaram Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "Bingaram Island", "2" : "बिंगाराम द्वीप", "3" : "பிங்கரம் தீவு"}	1
422	Bitra Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "Bitra Island", "2" : "बिट्रा आइलैंड", "3" : "பிட்ரா தீவு"}	1
423	Chetlat Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "Chetlat Island", "2" : "चेतलाट द्वीप", "3" : "செட்லாட் தீவு"}	1
424	Kadmat Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "Kadmat Island", "2" : "कदमत द्वीप", "3" : "கத்மத் தீவு"}	1
425	Kalpeni Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "Kalpeni Island", "2" : "कालपेनी द्वीप", "3" : "கல்பெனி தீவு"}	1
426	Kavaratti Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "Kavaratti Island", "2" : "कवारट्टी द्वीप", "3" : "தீவில் கேவாகேஷன்"}	1
427	Kiltan Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "Kiltan Island", "2" : "किलिन द्वीप", "3" : "கில்டன் தீவு"}	1
428	Lakshadweep Sea	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "Lakshadweep Sea", "2" : "लक्षद्वीप सागर", "3" : "லக்ஷட்வீப்பிலிருந்து"}	1
429	Minicoy Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "Minicoy Island", "2" : "मिनीकोय द्वीप", "3" : "மினிகாய் தீவு"}	1
430	North Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "North Island", "2" : "उत्तर द्विप", "3" : "வடக்கு தீவு"}	1
431	South Island	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	19	{"1" : "South Island", "2" : "दक्षिणी द्वीप", "3" : "தென் தீவு"}	1
432	Anuppur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Anuppur", "2" : "अनुपपुर", "3" : "அனுப்பூர்"}	1
433	Ashoknagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Ashoknagar", "2" : "अशोकनगर", "3" : "அசோக்நகர்"}	1
434	Balaghat	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Balaghat", "2" : "बालाघाट", "3" : "பலகத்"}	1
435	Barwani	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Barwani", "2" : "बरवानी", "3" : "பர்வானி"}	1
436	Betul	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Betul", "2" : "बैतूल", "3" : "பெத்துல்"}	1
437	Bhind	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Bhind", "2" : "भिंड", "3" : "கட்டுதல்"}	1
438	Bhopal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Bhopal", "2" : "भोपाल", "3" : "போபால்"}	1
439	Burhanpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Burhanpur", "2" : "बुरहानपुर", "3" : "புர்ஹான்பூர்"}	1
440	Chhatarpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Chhatarpur", "2" : "छतरपुर", "3" : "சதர்பூர்"}	1
441	Chhindwara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Chhindwara", "2" : "छिंदवाड़ा", "3" : "சிண்ட்வாரா"}	1
442	Damoh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Damoh", "2" : "दमोह", "3" : "டாமோ"}	1
443	Datia	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Datia", "2" : "दशा", "3" : "நிலை"}	1
444	Dewas	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Dewas", "2" : "देवास", "3" : "திவாஸ்"}	1
445	Dhar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Dhar", "2" : "धार", "3" : "கஷ்"}	1
446	Dindori	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Dindori", "2" : "डिंडोरी", "3" : "டிண்டோரி"}	1
447	Guna	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Guna", "2" : "गुना", "3" : "மடிப்பு"}	1
448	Gwalior	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Gwalior", "2" : "ग्वालियर", "3" : "குவாலியர்"}	1
701	Erode	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Erode", "2" : "इरोड", "3" : "எரோடே"}	1
450	Hoshangabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Hoshangabad", "2" : "होशंगाबाद", "3" : "ஹோஷங்காபாத்"}	1
451	Indore	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Indore", "2" : "इंदौर", "3" : "இந்தூர்"}	1
452	Jabalpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Jabalpur", "2" : "जबलपुर", "3" : "ஜபல்பூர்"}	1
453	Jagdalpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Jagdalpur", "2" : "जगदलपुर", "3" : "ஜக்தால்பூர்"}	1
454	Jhabua	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Jhabua", "2" : "झाबुआ", "3" : "ஜாபுவா"}	1
455	Katni	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Katni", "2" : "कटनी", "3" : "வெட்டு"}	1
456	Khandwa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Khandwa", "2" : "खंडवा", "3" : "கந்த்வா"}	1
457	Khargone	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Khargone", "2" : "खरगोन", "3" : "கர்கோன்"}	1
458	Mandla	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Mandla", "2" : "मंडला", "3" : "மாண்ட்லா"}	1
459	Mandsaur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Mandsaur", "2" : "मंदसौर", "3" : "மாண்ட்சர்"}	1
460	Morena	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Morena", "2" : "मोरेना", "3" : "மோரேனா"}	1
461	Narsinghpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Narsinghpur", "2" : "नर्सिंघ्पुर", "3" : "நர்சிங்பூர்"}	1
462	Neemuch	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Neemuch", "2" : "नीमच", "3" : "நீமேச்"}	1
463	Panna	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Panna", "2" : "पन्ना", "3" : "மரகதம்"}	1
464	Raisen	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Raisen", "2" : "रायसेन", "3" : "ரைசன்"}	1
465	Rajgarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Rajgarh", "2" : "राजगढ़", "3" : "ராஜ்கர்"}	1
466	Ratlam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Ratlam", "2" : "रतलाम", "3" : "ரத்தம்"}	1
467	Rewa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Rewa", "2" : "रेवा", "3" : "ரெவா"}	1
468	Sagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Sagar", "2" : "सागर", "3" : "கடல்"}	1
469	Satna	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Satna", "2" : "सतना", "3" : "சட்னா"}	1
470	Sehore	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Sehore", "2" : "सेहोरे", "3" : "செஹோர்"}	1
471	Seoni	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Seoni", "2" : "सोनी", "3" : "சோனி"}	1
472	Shahdol	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Shahdol", "2" : "शहडोल", "3" : "நிழல்"}	1
473	Shajapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Shajapur", "2" : "शाजापुर", "3" : "ஷாஜாபூர்"}	1
474	Sheopur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Sheopur", "2" : "शेओपुर", "3" : "ஷியோவாபூர்"}	1
475	Shivpuri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Shivpuri", "2" : "शिवपुरी", "3" : "சிவ்புரி"}	1
476	Sidhi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Sidhi", "2" : "सीधी", "3" : "நேராக"}	1
477	Tikamgarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Tikamgarh", "2" : "टीकमगढ़", "3" : "டிகாம்கர்"}	1
478	Ujjain	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Ujjain", "2" : "उज्जैन", "3" : "விந்துதள்ளல்"}	1
479	Umaria	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Umaria", "2" : "उमरिअ", "3" : "உம்ரித்"}	1
480	Vidisha	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	20	{"1" : "Vidisha", "2" : "विदिशा", "3" : "இனப்பெருக்க"}	1
481	Ahmednagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Ahmednagar", "2" : "अहमदनगर", "3" : "அகமதுநகர்"}	1
482	Akola	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Akola", "2" : "अकोला", "3" : "உள்ளிழுக்க"}	1
483	Amravati	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Amravati", "2" : "अमरावती", "3" : "அமராவதி"}	1
484	Aurangabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Aurangabad", "2" : "औरंगाबाद", "3" : "அவுரங்காபாத்"}	1
485	Beed	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Beed", "2" : "बीड", "3" : "ஏலம்"}	1
486	Bhandara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Bhandara", "2" : "भंडारा", "3" : "களஞ்சியம்"}	1
487	Buldhana	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Buldhana", "2" : "बुलढाना", "3" : "புல்லட்"}	1
488	Chandrapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Chandrapur", "2" : "चंद्रपुर", "3" : "சந்திரபூர்"}	1
489	Dhule	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Dhule", "2" : "धुले", "3" : "Dhule"}	1
490	Gadchiroli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Gadchiroli", "2" : "गडचिरोली", "3" : "கட்சிரோலி"}	1
491	Gondia	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Gondia", "2" : "गोंडिया", "3" : "கோண்டியா"}	1
492	Hingoli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Hingoli", "2" : "हिंगोली", "3" : "ஹிங்கோலி"}	1
493	Jalgaon	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Jalgaon", "2" : "जलगाओं", "3" : "ஜால்"}	1
494	Jalna	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Jalna", "2" : "जलना", "3" : "எரியும்"}	1
495	Kolhapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Kolhapur", "2" : "कोल्हापुर", "3" : "கோலாப்பூர்"}	1
496	Latur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Latur", "2" : "लातूर", "3" : "லதூர்"}	1
497	Mahabaleshwar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Mahabaleshwar", "2" : "महाबलेश्वर", "3" : "மகாபலேஷ்வர்"}	1
498	Mumbai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Mumbai", "2" : "मुंबई", "3" : "மும்பை"}	1
499	Mumbai City	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Mumbai City", "2" : "मुंबई सिटी", "3" : "மும்பை நகரம்"}	1
500	Mumbai Suburban	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Mumbai Suburban", "2" : "मुंबई सबअर्बन", "3" : "மும்பை சுபுரான்"}	1
501	Nagpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Nagpur", "2" : "नागपुर", "3" : "நாக்பூர்"}	1
502	Nanded	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Nanded", "2" : "नांदेड़", "3" : "Nanded"}	1
503	Nandurbar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Nandurbar", "2" : "नंदुरबार", "3" : "நந்தூர்பர்"}	1
504	Nashik	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Nashik", "2" : "नासिक", "3" : "நாஷிக்"}	1
505	Osmanabad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Osmanabad", "2" : "उस्मानाबाद", "3" : "ஒஸ்மானாபாத்"}	1
506	Parbhani	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Parbhani", "2" : "परभनी", "3" : "பெர்பானி"}	1
507	Pune	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Pune", "2" : "पुणे", "3" : "புனே"}	1
508	Raigad	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Raigad", "2" : "रायगढ़", "3" : "ராய்காட்"}	1
509	Ratnagiri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Ratnagiri", "2" : "रत्नागिरि", "3" : "ரத்னாக்ரி"}	1
510	Sangli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Sangli", "2" : "सांगली", "3" : "சாங்லி"}	1
511	Satara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Satara", "2" : "सतारा", "3" : "சதாரா"}	1
512	Sholapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Sholapur", "2" : "शोलापुर", "3" : "ஷோலாப்பூர்"}	1
513	Sindhudurg	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Sindhudurg", "2" : "सिंधुदुर्ग", "3" : "சிந்துவர்க்"}	1
514	Thane	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Thane", "2" : "थाइन", "3" : "தானே"}	1
515	Wardha	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Wardha", "2" : "वर्धा", "3" : "வரா"}	1
516	Washim	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Washim", "2" : "वाशिम", "3" : "வாஷிம்"}	1
517	Yavatmal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	21	{"1" : "Yavatmal", "2" : "यवतमाल", "3" : "யவத்மல்"}	1
518	Bishnupur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	22	{"1" : "Bishnupur", "2" : "बिश्नुपुर", "3" : "பிஷ்னுபூர்"}	1
519	Chandel	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	22	{"1" : "Chandel", "2" : "चंदेल", "3" : "சாண்டல்"}	1
520	Churachandpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	22	{"1" : "Churachandpur", "2" : "छुरछंदपुर", "3" : "சுராச்சந்த்பூர்"}	1
521	Imphal East	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	22	{"1" : "Imphal East", "2" : "अपर्याप्त पूर्व", "3" : "இம்பால்"}	1
522	Imphal West	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	22	{"1" : "Imphal West", "2" : "इम्फाल पश्चिम", "3" : "இம்பால் வெஸ்ட்"}	1
523	Senapati	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	22	{"1" : "Senapati", "2" : "सेनापति", "3" : "செனபதி"}	1
524	Tamenglong	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	22	{"1" : "Tamenglong", "2" : "तामेंगलांग", "3" : "தமெங்லாங்"}	1
525	Thoubal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	22	{"1" : "Thoubal", "2" : "थौबल", "3" : "துபல்"}	1
526	Ukhrul	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	22	{"1" : "Ukhrul", "2" : "उखरूल", "3" : "உக்ருல்"}	1
527	East Garo Hills	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	23	{"1" : "East Garo Hills", "2" : "पूर्वी गारो हिल्स", "3" : "கிழக்கு கரோ ஹில்ஸ்"}	1
528	East Khasi Hills	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	23	{"1" : "East Khasi Hills", "2" : "पूर्वी खासी हिल्स", "3" : "கிழக்கு காசி ஹில்ஸ்"}	1
529	Jaintia Hills	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	23	{"1" : "Jaintia Hills", "2" : "जेंटिया हिल्स", "3" : "ஜைன்டியா ஹில்ஸ்"}	1
530	Ri Bhoi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	23	{"1" : "Ri Bhoi", "2" : "री भोई", "3" : "ரி போய்"}	1
531	Shillong	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	23	{"1" : "Shillong", "2" : "शिलांग", "3" : "ஷில்லாங் ஷில்லாங்"}	1
532	South Garo Hills	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	23	{"1" : "South Garo Hills", "2" : "दक्षिण गारो हिल्स", "3" : "தெற்கு கரோ ஹில்ஸ்"}	1
533	West Garo Hills	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	23	{"1" : "West Garo Hills", "2" : "वेस्ट गारो हिल्स", "3" : "மேற்கு கரோ ஹில்ஸ்"}	1
534	West Khasi Hills	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	23	{"1" : "West Khasi Hills", "2" : "पश्चिम खासी हिल्स", "3" : "மேற்கு காசி ஹில்ஸ்"}	1
535	Aizawl	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	24	{"1" : "Aizawl", "2" : "आइजोल", "3" : "Aizawl"}	1
536	Champhai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	24	{"1" : "Champhai", "2" : "चम्फाई", "3" : "சேம்பாய் மாவட்ட சேம்பாய்"}	1
537	Kolasib	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	24	{"1" : "Kolasib", "2" : "कोलासिब", "3" : "கோலாசிப்"}	1
538	Lawngtlai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	24	{"1" : "Lawngtlai", "2" : "लॉंगटलाई", "3" : "லாங்ட்லாய்"}	1
539	Lunglei	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	24	{"1" : "Lunglei", "2" : "लुंगलेई", "3" : "லுன்லி"}	1
540	Mamit	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	24	{"1" : "Mamit", "2" : "मामित", "3" : "மாமிட் மாவட்டம்"}	1
541	Saiha	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	24	{"1" : "Saiha", "2" : "साहाहा", "3" : "சைஹா சாய்ஹா"}	1
542	Serchhip	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	24	{"1" : "Serchhip", "2" : "सेरछिप", "3" : "Serchipp"}	1
543	Dimapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	25	{"1" : "Dimapur", "2" : "दीमापुर", "3" : "டிமாப்பூர்"}	1
544	Kohima	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	25	{"1" : "Kohima", "2" : "कोहिमा", "3" : "கோஹிமா"}	1
545	Mokokchung	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	25	{"1" : "Mokokchung", "2" : "मोकोकचुंग", "3" : "மோகோக்சங்"}	1
546	Mon	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	25	{"1" : "Mon", "2" : "में", "3" : ""}	1
547	Phek	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	25	{"1" : "Phek", "2" : "फेक", "3" : "தட்டையானது"}	1
548	Tuensang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	25	{"1" : "Tuensang", "2" : "तुएनसांग", "3" : "இருபது"}	1
549	Wokha	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	25	{"1" : "Wokha", "2" : "वोखा", "3" : "அற்புதம்"}	1
550	Zunheboto	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	25	{"1" : "Zunheboto", "2" : "जुन्हेबोटो", "3" : "தாடை"}	1
551	Angul	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Angul", "2" : "अंगुल", "3" : "விரல்"}	1
552	Balangir	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Balangir", "2" : "बलांगीर", "3" : "பிறந்த"}	1
553	Balasore	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Balasore", "2" : "बालासोर", "3" : "பாலசூர்"}	1
554	Baleswar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Baleswar", "2" : "बालेश्वर", "3" : "பலாஷ்வர்"}	1
555	Bargarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Bargarh", "2" : "बरगढ़", "3" : "பர்கர்:"}	1
556	Berhampur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Berhampur", "2" : "बेरहामपुर", "3" : "பரஹாம்பூர்"}	1
557	Bhadrak	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Bhadrak", "2" : "भद्रक", "3" : "நற்பண்புகள் கொண்டவர்"}	1
558	Bhubaneswar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Bhubaneswar", "2" : "भुबनेश्वर", "3" : "புவனேஸ்வர்"}	1
559	Boudh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Boudh", "2" : "बौद्ध", "3" : "ப Buddhist த்த"}	1
560	Cuttack	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Cuttack", "2" : "कुट्टक", "3" : "குட்டக்"}	1
561	Deogarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Deogarh", "2" : "डोगरह", "3" : "டோகரா"}	1
562	Dhenkanal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Dhenkanal", "2" : "ढेंकानाल", "3" : "தென்கனல்"}	1
563	Gajapati	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Gajapati", "2" : "गजपति", "3" : "கஜபதி"}	1
564	Ganjam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Ganjam", "2" : "गंजाम", "3" : "கஞ்சம்"}	1
565	Jagatsinghapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Jagatsinghapur", "2" : "जगतसिंहपुर", "3" : "ஜகாட்சிங்க்பூர்"}	1
566	Jajpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Jajpur", "2" : "जाजपुर", "3" : "ஜஜ்பூர்"}	1
567	Jharsuguda	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Jharsuguda", "2" : "झारसुगुड़ा", "3" : "ஜார்சுகுடா"}	1
568	Kalahandi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Kalahandi", "2" : "कालाहांडी", "3" : "கலஹந்தி"}	1
569	Kandhamal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Kandhamal", "2" : "कंधमाल", "3" : "காந்தமல்"}	1
570	Kendrapara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Kendrapara", "2" : "केंद्रपारा", "3" : "சென்டர் பாரா"}	1
571	Kendujhar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Kendujhar", "2" : "केंदूझर", "3" : "கெண்டுஜர்"}	1
572	Khordha	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Khordha", "2" : "खोर्धा", "3" : "கோடா"}	1
573	Koraput	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Koraput", "2" : "कोरापुट", "3" : "கோராபுட்"}	1
574	Malkangiri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Malkangiri", "2" : "मलकानगिरी", "3" : "மல்காங்கிரி"}	1
575	Mayurbhanj	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Mayurbhanj", "2" : "मयूरभंज", "3" : "மயூர்பஞ்ச்"}	1
576	Nabarangapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Nabarangapur", "2" : "नबरंगपुर", "3" : "நாப்ராங்பூர்"}	1
577	Nayagarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Nayagarh", "2" : "नयागढ़", "3" : "நயகர்"}	1
578	Nuapada	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Nuapada", "2" : "नुआपाड़ा", "3" : "புதியவர்"}	1
579	Puri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Puri", "2" : "पूरी", "3" : "குறிப்பு"}	1
580	Rayagada	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Rayagada", "2" : "रायगड़ा", "3" : "ராயல்"}	1
581	Rourkela	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Rourkela", "2" : "राउरकेला", "3" : "ரவுச்சரி"}	1
582	Sambalpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Sambalpur", "2" : "सम्बलपुर", "3" : "சால்பூர்"}	1
583	Subarnapur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Subarnapur", "2" : "सुबारपुर", "3" : "சுபர்னாபூர்"}	1
584	Sundergarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	26	{"1" : "Sundergarh", "2" : "सुंदरगेर", "3" : "சுந்தர்கர்"}	1
585	Bahur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	27	{"1" : "Bahur", "2" : "बांह", "3" : "பாலிமார்பிக்"}	1
586	Karaikal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	27	{"1" : "Karaikal", "2" : "गुणवत्ता", "3" : "கரிகால்"}	1
587	Mahe	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	27	{"1" : "Mahe", "2" : "माहे", "3" : "மஹே"}	1
588	Pondicherry	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	27	{"1" : "Pondicherry", "2" : "पांडिचेरी", "3" : "பாண்டிசெர்ரி"}	1
589	Purnankuppam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	27	{"1" : "Purnankuppam", "2" : "भरा हुआ", "3" : "பர்னங்குப்பம்"}	1
590	Valudavur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	27	{"1" : "Valudavur", "2" : "विरोधी", "3" : "வலுடாவூர்"}	1
591	Villianur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	27	{"1" : "Villianur", "2" : "विलियानु", "3" : "வில்லியனூர்"}	1
592	Yanam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	27	{"1" : "Yanam", "2" : "अनाम", "3" : "யனம்"}	1
593	Amritsar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Amritsar", "2" : "अमृतसर", "3" : "அமிர்தசரஸ்"}	1
594	Barnala	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Barnala", "2" : "बरनाला", "3" : "பர்னலா"}	1
595	Bathinda	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Bathinda", "2" : "बठिंडा", "3" : "பட்டிண்டா"}	1
596	Faridkot	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Faridkot", "2" : "फरीदकोट", "3" : "ஃபரிட்கோட்"}	1
597	Fatehgarh Sahib	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Fatehgarh Sahib", "2" : "फतेहगढ़ साहिब", "3" : "ஃபதேஹ்கர் சாஹிப்"}	1
598	Ferozepur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Ferozepur", "2" : "फ़िरोज़पुर", "3" : "ஃபிரோஸ்பூர்"}	1
599	Gurdaspur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Gurdaspur", "2" : "गुरदासपुर", "3" : "குர்தாஸ்பூர்"}	1
600	Hoshiarpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Hoshiarpur", "2" : "होशिअरपुर", "3" : "HOSIERPUR"}	1
601	Jalandhar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Jalandhar", "2" : "जालंधर", "3" : "ஜலந்தர்"}	1
602	Kapurthala	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Kapurthala", "2" : "कपूरथला", "3" : "கபுர்தாலா"}	1
603	Ludhiana	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Ludhiana", "2" : "लुधिअना", "3" : "லூதினா"}	1
604	Mansa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Mansa", "2" : "मनसा", "3" : "மான்சா"}	1
605	Moga	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Moga", "2" : "मोगा", "3" : "மோகா"}	1
606	Muktsar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Muktsar", "2" : "मुक्तसर", "3" : "முக்தார்"}	1
607	Nawanshahr	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Nawanshahr", "2" : "नवांशहर", "3" : "நவன்ஷஹார்"}	1
608	Pathankot	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Pathankot", "2" : "पठानकोट", "3" : "பதான்கோட்"}	1
609	Patiala	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Patiala", "2" : "पटिआला", "3" : "பாட்டியாலா"}	1
610	Rupnagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Rupnagar", "2" : "रूपनगर", "3" : "ரூப்நகர்"}	1
611	Sangrur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Sangrur", "2" : "संगरूर", "3" : "சங்ரூர்"}	1
612	SAS Nagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "SAS Nagar", "2" : "सास नगर", "3" : "தாய் -இன் -லா"}	1
613	Tarn Taran	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	28	{"1" : "Tarn Taran", "2" : "तारन तरन", "3" : "தரன் தரன்"}	1
614	Ajmer	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Ajmer", "2" : "अजमेर", "3" : "அஜ்மர்"}	1
615	Alwar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Alwar", "2" : "अलवर", "3" : "ஆல்வார்"}	1
616	Banswara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Banswara", "2" : "बांसवाड़ा", "3" : "பன்ஸ்வாரா"}	1
617	Baran	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Baran", "2" : "बरन", "3" : "பரன்"}	1
618	Barmer	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Barmer", "2" : "बारमेर", "3" : "பார்மர்"}	1
619	Bharatpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Bharatpur", "2" : "भरतपुर", "3" : "பாரத்பூர்"}	1
620	Bhilwara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Bhilwara", "2" : "भीलवाड़ा", "3" : "பில்வாரா"}	1
621	Bikaner	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Bikaner", "2" : "बीकानेर", "3" : "பிகானர்"}	1
622	Bundi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Bundi", "2" : "बूंदी", "3" : "பண்டி"}	1
623	Chittorgarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Chittorgarh", "2" : "चित्तौरगढ़", "3" : "சிட்டோர்கர்"}	1
624	Churu	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Churu", "2" : "चूरू", "3" : "சுரு"}	1
625	Dausa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Dausa", "2" : "दौसा", "3" : "ட aus சா"}	1
626	Dholpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Dholpur", "2" : "धौलपुर", "3" : "தோல்பூர்"}	1
627	Dungarpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Dungarpur", "2" : "डूंगरपुर", "3" : "துங்கர்பூர்"}	1
628	Hanumangarh	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Hanumangarh", "2" : "हनुमानगढ़", "3" : "ஹனுமங்கர்"}	1
629	Jaipur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Jaipur", "2" : "जयपुर", "3" : "ஜெய்ப்பூர்"}	1
630	Jaisalmer	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Jaisalmer", "2" : "जैसलमेर", "3" : "ஜெய்சால்மர்"}	1
631	Jalore	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Jalore", "2" : "जालोर", "3" : "ஜலூர்"}	1
632	Jhalawar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Jhalawar", "2" : "झालावाड़", "3" : "ஜலவர்"}	1
633	Jhunjhunu	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Jhunjhunu", "2" : "झुंझुनू", "3" : "ஜுன்ஜ்ஹுனு"}	1
634	Jodhpur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Jodhpur", "2" : "जोधपुर", "3" : "ஜோத்பூர்"}	1
635	Karauli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Karauli", "2" : "करौली", "3" : "கரவுலி"}	1
636	Kota	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Kota", "2" : "कोटा", "3" : "ஒதுக்கீடு"}	1
637	Nagaur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Nagaur", "2" : "नागौर", "3" : "நாகர்"}	1
638	Pali	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Pali", "2" : "पाली", "3" : "மகிமை"}	1
639	Pilani	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Pilani", "2" : "पिलानी", "3" : "பிலானி"}	1
640	Rajsamand	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Rajsamand", "2" : "राजसमंद", "3" : "ராஜ்சமந்த்"}	1
641	Sawai Madhopur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Sawai Madhopur", "2" : "सवाई माधोपुर", "3" : "சாவாய் மாதோபூர்"}	1
642	Sikar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Sikar", "2" : "सीकर", "3" : "சிக்கார்"}	1
643	Sirohi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Sirohi", "2" : "सिरोही", "3" : "சிரோஹி"}	1
644	Sri Ganganagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Sri Ganganagar", "2" : "श्री गंगानगर", "3" : "ஸ்ரீ கங்கா நகர்"}	1
645	Tonk	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Tonk", "2" : "टोंक", "3" : "டோங்க்"}	1
646	Udaipur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	29	{"1" : "Udaipur", "2" : "उदयपुर", "3" : "உதய்பூர்"}	1
647	Barmiak	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Barmiak", "2" : "बरमीएक", "3" : "பர்மேயா"}	1
648	Be	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Be", "2" : "बे", "3" : "இரண்டு"}	1
649	Bhurtuk	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Bhurtuk", "2" : "भुरटुक", "3" : "நண்டு"}	1
650	Chhubakha	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Chhubakha", "2" : "छूबाखा", "3" : "ஏளனம்"}	1
651	Chidam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Chidam", "2" : "चिदं", "3" : "குரோம்"}	1
652	Chubha	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Chubha", "2" : "चुभा", "3" : "அலறல்"}	1
653	Chumikteng	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Chumikteng", "2" : "चुमिकटेंग", "3" : "சம்"}	1
654	Dentam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Dentam", "2" : "चिकित्सकीय", "3" : "பல்"}	1
655	Dikchu	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Dikchu", "2" : "दिक्चु", "3" : "நாண்"}	1
656	Dzongri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Dzongri", "2" : "ज़ोंगरी", "3" : "டசோங்ரி"}	1
657	Gangtok	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Gangtok", "2" : "गंगटोक", "3" : "கேங்டாக்"}	1
658	Gauzing	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Gauzing", "2" : "गजिंग", "3" : "Gauzing"}	1
659	Gyalshing	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Gyalshing", "2" : "ग्याल", "3" : "கயல்ஷிங்"}	1
660	Hema	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Hema", "2" : "हिमा", "3" : "ஹேமா"}	1
661	Kerung	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Kerung", "2" : "क्रूज", "3" : "கெருங்"}	1
662	Lachen	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Lachen", "2" : "हसना", "3" : "லாச்சன்"}	1
663	Lachung	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Lachung", "2" : "लचुंग", "3" : "லச்சுங் லாச்சங்"}	1
664	Lema	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Lema", "2" : "पौधा", "3" : "லெமா"}	1
665	Lingtam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Lingtam", "2" : "लिंगटम", "3" : "லிங்டாம்"}	1
666	Lungthu	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Lungthu", "2" : "लंगथु", "3" : "Lungthu"}	1
667	Mangan	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Mangan", "2" : "मंगल", "3" : "மன்பன்"}	1
668	Namchi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Namchi", "2" : "नमची", "3" : "நமச்சி"}	1
669	Namthang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Namthang", "2" : "नामथांग", "3" : "நம்பட்"}	1
670	Nanga	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Nanga", "2" : "नंगा", "3" : "நங்கா"}	1
671	Nantang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Nantang", "2" : "नान्तांग", "3" : "சவாலான"}	1
672	Naya Bazar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Naya Bazar", "2" : "नारा बाज़ार", "3" : "நயா பஜார்"}	1
673	Padamachen	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Padamachen", "2" : "पद्मचनेन", "3" : "பத்மாசென்"}	1
674	Pakhyong	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Pakhyong", "2" : "मेखोंग", "3" : "மக்யாங்"}	1
675	Pemayangtse	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Pemayangtse", "2" : "टूलफे", "3" : "கருவி"}	1
676	Phensang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Phensang", "2" : "फेन्सांग", "3" : "பென்சாங்"}	1
677	Rangli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Rangli", "2" : "रंगली", "3" : "ராங்லி"}	1
678	Rinchingpong	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Rinchingpong", "2" : "रिनचिंगपोंग", "3" : "ஹிங்கிங் பேங்"}	1
679	Sakyong	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Sakyong", "2" : "सकोन्योंग", "3" : "கோணி"}	1
680	Samdong	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Samdong", "2" : "सैंडोंग", "3" : "சம்டோங்"}	1
681	Singtam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Singtam", "2" : "सिंगताम", "3" : "சிம்பொனி"}	1
682	Siniolchu	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Siniolchu", "2" : "सीनियोचु", "3" : "Senial"}	1
683	Sombari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Sombari", "2" : "सोमबारी", "3" : "சோம்பரி"}	1
684	Soreng	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Soreng", "2" : "बाकी पर", "3" : "சொரெங்"}	1
685	Sosing	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Sosing", "2" : "संस्मरण", "3" : "சமூக"}	1
686	Tekhug	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Tekhug", "2" : "टेकग", "3" : "தேக்குஜி"}	1
687	Temi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Temi", "2" : "थीम्स", "3" : "டாமி"}	1
688	Tsetang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Tsetang", "2" : "त्संग", "3" : "ட்செட்டாங்"}	1
689	Tsomgo	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Tsomgo", "2" : "त्सोमगो", "3" : "சோமோகோ"}	1
690	Tumlong	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Tumlong", "2" : "तुमलांग", "3" : "டம்லாங்"}	1
691	Yangang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Yangang", "2" : "यांगांग", "3" : "யாங்காங்"}	1
692	Yumtang	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	30	{"1" : "Yumtang", "2" : "यमतंग", "3" : "யும்தாங்"}	1
693	Chennai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Chennai", "2" : "चेन्नई", "3" : "சென்னை"}	1
694	Chidambaram	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Chidambaram", "2" : "चिदंबरम", "3" : "உண்மையான"}	1
695	Chingleput	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Chingleput", "2" : "चिंगलपुट", "3" : "Cingleput"}	1
696	Coimbatore	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Coimbatore", "2" : "कोइम्बटोरे", "3" : "கோமோட்டோடோர்"}	1
697	Courtallam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Courtallam", "2" : "कोर्तल्लम", "3" : "கோர்டலம்"}	1
698	Cuddalore	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Cuddalore", "2" : "कुड्डलोरे", "3" : "கூடலூ"}	1
699	Dharmapuri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Dharmapuri", "2" : "धर्मपुरी", "3" : "தர்மபுரி"}	1
700	Dindigul	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Dindigul", "2" : "डिंडीगुल", "3" : "டிண்டிக்குள்"}	1
702	Hosur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Hosur", "2" : "होसुर", "3" : "ஹோசூர்"}	1
703	Kanchipuram	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Kanchipuram", "2" : "कांचीपुरम", "3" : "காஞ்சிபுரம்"}	1
704	Kanyakumari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Kanyakumari", "2" : "कन्याकूमारी", "3" : "கன்னியாகுமாரி"}	1
705	Karaikudi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Karaikudi", "2" : "कराइकुडी", "3" : "காரைக்குடி"}	1
707	Kodaikanal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Kodaikanal", "2" : "कोडईकनाल", "3" : "கொடைக்கானல்"}	1
708	Kovilpatti	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Kovilpatti", "2" : "कोविलपत्ती", "3" : "கோவில்பட்டி"}	1
709	Krishnagiri	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Krishnagiri", "2" : "कृष्णागिरी", "3" : "கிருஷ்ணகிரி"}	1
710	Kumbakonam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Kumbakonam", "2" : "कुम्भकोणम", "3" : "கும்பகோணம்"}	1
711	Madurai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Madurai", "2" : "मदुरै", "3" : "மதுரை"}	1
712	Mayiladuthurai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Mayiladuthurai", "2" : "माइलादुत्रयी", "3" : "மயிலாடுதுறை"}	1
713	Nagapattinam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Nagapattinam", "2" : "नागपट्टिनम", "3" : "நாகப்பட்டினம்"}	1
714	Nagarcoil	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Nagarcoil", "2" : "डिगो", "3" : "நகர்க்கோயில்"}	1
715	Namakkal	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Namakkal", "2" : "नमकलाल", "3" : "நாமக்கல்"}	1
716	Neyveli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Neyveli", "2" : "नेवेली", "3" : "நெய்வேலி"}	1
717	Nilgiris	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Nilgiris", "2" : "निगिग्रिस", "3" : "நீல்கிரிஸ்"}	1
718	Ooty	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Ooty", "2" : "ऊटी", "3" : "ஊட்டி"}	1
719	Palani	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Palani", "2" : "पलानी", "3" : "பழனி"}	1
720	Perambalur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Perambalur", "2" : "पेरामालुर", "3" : "பெரம்பலூர்"}	1
721	Pollachi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Pollachi", "2" : "पोलाची", "3" : "பொள்ளாச்சி"}	1
722	Pudukkottai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Pudukkottai", "2" : "पुडुकोट्टई", "3" : "புதுக்கோட்டை"}	1
723	Rajapalayam	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Rajapalayam", "2" : "राजपालयम", "3" : "ராஜபாளையம்"}	1
724	Ramanathapuram	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Ramanathapuram", "2" : "रामनाथपुरम", "3" : "ராமநாதபுரம்"}	1
725	Salem	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Salem", "2" : "सलेम", "3" : "சேலம்"}	1
726	Sivaganga	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Sivaganga", "2" : "शिवगंगई", "3" : "சிவகங்கை"}	1
727	Sivakasi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Sivakasi", "2" : "शिवकाशी", "3" : "சிவகாசி"}	1
728	Thanjavur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Thanjavur", "2" : "तंजावुर", "3" : "தஞ்சாவூர்"}	1
729	Theni	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Theni", "2" : "मधुमक्खी", "3" : "தேனீ"}	1
730	Thoothukudi	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Thoothukudi", "2" : "तूतीकोरिन", "3" : "தூத்துக்குடி"}	1
731	Tiruchirappalli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Tiruchirappalli", "2" : "तिरुचिरापल्ली", "3" : "திருச்சிராப்பள்ளி"}	1
732	Tirunelveli	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Tirunelveli", "2" : "तिरुनेलवेली", "3" : "திருநெல்வேலி"}	1
733	Tirupur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Tirupur", "2" : "तिरुपुर", "3" : "திருப்பூர்"}	1
734	Tiruvallur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Tiruvallur", "2" : "तिरुवल्लुर", "3" : "திருவள்ளூர்"}	1
735	Tiruvannamalai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Tiruvannamalai", "2" : "तिरुवन्नामलाई", "3" : "திருவண்ணாமலை"}	1
736	Tiruvarur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Tiruvarur", "2" : "तिरुवरुर", "3" : "திருவாரூர்"}	1
737	Trichy	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Trichy", "2" : "त्रिची", "3" : "த்ரிச்ய"}	1
738	Tuticorin	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Tuticorin", "2" : "तूतीकोरिन", "3" : "துதிகரின்"}	1
739	Vellore	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Vellore", "2" : "वेल्लोर", "3" : "வெள்ளூர்"}	1
740	Villupuram	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Villupuram", "2" : "विल्लुपुरम", "3" : "வில்லுபுரம்"}	1
741	Virudhunagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Virudhunagar", "2" : "विरुधुनगर", "3" : "விருதுநகர்"}	1
742	Yercaud	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	31	{"1" : "Yercaud", "2" : "यरकौड", "3" : "எரிகாட்"}	1
743	Agartala	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Agartala", "2" : "अगरतला", "3" : "அகர்தலா"}	1
744	Ambasa	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Ambasa", "2" : "अम्बासा", "3" : "அம்பாச"}	1
745	Bampurbari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Bampurbari", "2" : "बमपुरबारी", "3" : "பாம்புர்பரி"}	1
746	Belonia	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Belonia", "2" : "बेलोनिअ", "3" : "பெலோனியா"}	1
747	Dhalai	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Dhalai", "2" : "ढलाई", "3" : "தலை"}	1
748	Dharam Nagar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Dharam Nagar", "2" : "धरम नगर", "3" : "தரம் நகர்"}	1
749	Kailashahar	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Kailashahar", "2" : "कैलाशहर", "3" : "கைலாஷஹார்"}	1
750	Kamal Krishnabari	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Kamal Krishnabari", "2" : "कमल कृष्णबारी", "3" : "தாமரை கிருஷ்ணபாரி"}	1
751	Khopaiyapara	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Khopaiyapara", "2" : "खोपियापारा", "3" : "கோபியா பரா"}	1
753	Phuldungsei	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Phuldungsei", "2" : "फुलदुंगसे", "3" : "Fuldungse"}	1
754	Radha Kishore Pur	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Radha Kishore Pur", "2" : "राधा किशोरी पुर", "3" : "ராதா கிஷோரி புர்"}	1
755	Tripura	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	32	{"1" : "Tripura", "2" : "त्रिपुरा", "3" : "திரிபுரா"}	1
756	Allurisitharamaraju	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Allurisitharamaraju", "2" : "अल्लुरिसिथरामराजू", "3" : "அலுரிசிதரமராஜு"}	1
757	Anakapalli	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Anakapalli", "2" : "अनकापल्ली", "3" : "அனகபள்ளி"}	1
758	Ananthapuramu	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Ananthapuramu", "2" : "अनंतपुरामु", "3" : "அனந்தபுராமு"}	1
759	Annamayya	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Annamayya", "2" : "अन्नमय्या", "3" : "அன்னமய்யா"}	1
760	Bapatla	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Bapatla", "2" : "बापतला", "3" : "பபட்லா"}	1
761	Chittoor	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Chittoor", "2" : "चित्तूर", "3" : "சித்தூர்"}	1
762	Cuddapah	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Cuddapah", "2" : "कडप्पा", "3" : "குடபா"}	1
763	East Godavari	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "East Godavari", "2" : "पूर्वी गोदावरी", "3" : "கிழக்கு கோதாவரி"}	1
764	Eluru	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Eluru", "2" : "एलुरु", "3" : "எலூரு"}	1
765	Guntur	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Guntur", "2" : "गुंटूर", "3" : "குண்டூர்"}	1
766	Kakinada	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Kakinada", "2" : "काकीनाडा", "3" : "ககினாடா"}	1
767	Konaseema	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Konaseema", "2" : "कोनासीमा", "3" : "கொனசீமா"}	1
768	Krishna	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Krishna", "2" : "कृष्णा", "3" : "கிருஷ்ணா"}	1
769	Kurnool	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Kurnool", "2" : "कुरनूल", "3" : "கர்னூல்"}	1
770	N.T.R	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "N.T.R", "2" : "नं। आर।", "3" : "என்.டி.ஆர்"}	1
771	Nandyal	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Nandyal", "2" : "नांदयाल", "3" : "நந்தால்"}	1
772	Nellore	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Nellore", "2" : "नेल्लोर", "3" : "நெல்லோர்"}	1
773	Palnadu	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Palnadu", "2" : "पालनाडु", "3" : "பாலனாடு"}	1
774	Parvathipurammanyam	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Parvathipurammanyam", "2" : "पार्वतीपुरमाम्याम", "3" : "பர்வதிபுராம்மம்"}	1
775	Prakasam	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Prakasam", "2" : "प्रकाशम", "3" : "பிரகாசம்"}	1
776	Srikakulam	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Srikakulam", "2" : "श्रीकाकुलम", "3" : "ஸ்ரீகாகுளம்"}	1
777	Srisathyasai	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Srisathyasai", "2" : "श्रीसथीसई", "3" : "ஸ்ரீசாதசாய்"}	1
778	Tirupati	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Tirupati", "2" : "तिरुपति", "3" : "திருப்பதி"}	1
779	Visakhapatnam	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Visakhapatnam", "2" : "विशाखापत्तनम", "3" : "விசாகபத்னம்"}	1
780	Vizianagaram	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "Vizianagaram", "2" : "विजियानगराम", "3" : "விஜியானகரம்"}	1
781	West Godavari	t	f	2023-04-20 10:50:27.700805+00	2023-04-20 10:50:27.700805+00	2	{"1" : "West Godavari", "2" : "पश्चिम गोदावरी", "3" : "மேற்கு கோதாவரி"}	1
782	Adilabad	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Adilabad", "2" : "आदिलाबाद", "3" : "ஆதிலாபாத்"}	1
783	Bhadradri Kothagudem	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Bhadradri Kothagudem", "2" : "भद्रद्रि कोठगुडेम", "3" : "பத்ரத்ரி கோத்தகுடெம்"}	1
784	Hyderabad	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Hyderabad", "2" : "हैदराबाद", "3" : "ஹைதராபாத்"}	1
785	Jagtial	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Jagtial", "2" : "जगतियाल", "3" : "ஜெக்டியல்"}	1
786	Jangaon	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Jangaon", "2" : "जनगांव", "3" : "ஜங்கான்"}	1
787	Jayashankar Bhoopalpally	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Jayashankar Bhoopalpally", "2" : "जयशंकर भोपाल्पली", "3" : "ஜயாஷங்கர் பூபல்பள்ளி"}	1
788	Jogulamba Gadwal	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Jogulamba Gadwal", "2" : "जोगुलम्बा गडवाल", "3" : "ஜொகுலம்பா கட்வால்"}	1
789	Kamareddy	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Kamareddy", "2" : "कामारेडी", "3" : "கமரேடி"}	1
790	Karimnagar	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Karimnagar", "2" : "करीमनगर", "3" : "கரிம்நகர்"}	1
791	Khammam	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Khammam", "2" : "खम्मम", "3" : "கம்மம்"}	1
792	Kumuram Bheem	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Kumuram Bheem", "2" : "कुमुराम भीम", "3" : "குமுரம் பீம்"}	1
793	Mahabub Nagar	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Mahabub Nagar", "2" : "महाबुब नगर", "3" : "மகாபுப் நகர்"}	1
794	Mahabubabad	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Mahabubabad", "2" : "महबुबाबाद", "3" : "மகாபுபாபாத்"}	1
795	Mancherial	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Mancherial", "2" : "मंचएरियल", "3" : "மன்செரியல்"}	1
796	Medak	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Medak", "2" : "मेडक", "3" : "மெடக்"}	1
797	Medchal-Malkajgiri	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Medchal-Malkajgiri", "2" : "मेडचल-मलकजगिरी", "3" : "மெட்ச்சல்-மல்காஜ்கிரி"}	1
798	Nagarkurnool	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Nagarkurnool", "2" : "नगरकुरनूल", "3" : "நாகர்கர்னூல்"}	1
799	Nalgonda	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Nalgonda", "2" : "नलगोंडा", "3" : "நல்கோண்டா"}	1
800	Narayanpet	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Narayanpet", "2" : "नारायणपेट", "3" : "நாராயண்பெட்"}	1
801	Nirmal	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Nirmal", "2" : "निर्मल", "3" : "நிர்மல்"}	1
802	Nizamabad	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Nizamabad", "2" : "निजामाबाद", "3" : "நிஜாமாபாத்"}	1
803	Peddapally	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Peddapally", "2" : "पेडडाप के रूप में", "3" : "பெத்தப்பள்ளி"}	1
804	Rajanna Sircilla	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Rajanna Sircilla", "2" : "राजन्ना सिरकिला", "3" : "ராஜன்னா சிர்கில்லா"}	1
805	Rangareddy	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Rangareddy", "2" : "रंगारेड्डी", "3" : "ரேங்கரேடி"}	1
806	Sangareddy	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Sangareddy", "2" : "संगारेड्डी", "3" : "சங்கரெட்டி"}	1
807	Siddipet	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Siddipet", "2" : "सिडिपेट", "3" : "சித்திபெட்"}	1
808	Suryapet	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Suryapet", "2" : "सूर्यापेट", "3" : "சூர்யபெட்"}	1
809	Vikarabad	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Vikarabad", "2" : "विकाराबाद", "3" : "விகாராபாத்"}	1
810	Wanaparthy	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Wanaparthy", "2" : "वानपर्थी", "3" : "வனபார்த்தி"}	1
811	Warangal (Jayashankar Bhoopalpally)	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Warangal (Jayashankar Bhoopalpally)", "2" : "वारंगल (जयशंकर भोपाल्पली)", "3" : "வாரங்கல் (ஜெயஷங்கர் பூபல்பல்லி)"}	1
812	Warangal (Mulugu)	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Warangal (Mulugu)", "2" : "वारंगल (मुलुगु)", "3" : "வாரங்கல் (முலுகு)"}	1
813	Warangal (Rural)	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Warangal (Rural)", "2" : "वारंगल (ग्रामीण)", "3" : "வாரங்கல் (கிராமப்புற)"}	1
814	Warangal (Urban)	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Warangal (Urban)", "2" : "वारंगल (शहरी)", "3" : "வாரங்கல் (நகர்ப்புற)"}	1
815	Yadadri Bhuvanagiri	t	f	2023-04-20 11:09:53.128651+00	2023-04-20 11:09:53.128651+00	36	{"1" : "Yadadri Bhuvanagiri", "2" : "याददरी भुवनागिरी", "3" : "யாதத்ரி புவனகிரி"}	1
\.


--
-- Data for Name: HT_events; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_events" (id, title, description, "recurringEventName", "startDate", "endDate", "recurrenceEndDate", "isComplete", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTChildId", "HTUserId", "HTEventId") FROM stdin;
138	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-04-25 00:00:00+00	2024-04-25 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.427+00	2024-04-22 09:59:27.427+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N
139	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-05-09 00:00:00+00	2024-05-09 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
140	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-05-23 00:00:00+00	2024-05-23 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
141	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-06-06 00:00:00+00	2024-06-06 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
142	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-06-20 00:00:00+00	2024-06-20 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
143	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-07-04 00:00:00+00	2024-07-04 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
144	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-07-18 00:00:00+00	2024-07-18 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
145	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-08-01 00:00:00+00	2024-08-01 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
146	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-08-15 00:00:00+00	2024-08-15 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
147	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-08-29 00:00:00+00	2024-08-29 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
148	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-09-12 00:00:00+00	2024-09-12 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
149	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-09-26 00:00:00+00	2024-09-26 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
150	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-10-10 00:00:00+00	2024-10-10 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
151	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-10-24 00:00:00+00	2024-10-24 00:00:00+00	2024-10-24 00:00:00+00	f	t	f	\N	\N	2024-04-22 09:59:27.433+00	2024-04-22 09:59:27.433+00	\N	0fd8f742-ff93-40ec-bc73-1afe6db61479	138
152	undefined-Visit Plan	Frequent follow ups	Monthly	2024-05-27 00:00:00+00	2024-05-27 00:00:00+00	2024-10-27 00:00:00+00	f	t	f	\N	\N	2024-04-29 11:48:28.733+00	2024-04-29 11:48:28.733+00	\N	d233665e-6b54-479f-a735-14f3747e4f51	\N
153	undefined-Visit Plan	Frequent follow ups	Monthly	2024-06-27 00:00:00+00	2024-06-27 00:00:00+00	2024-10-27 00:00:00+00	f	t	f	\N	\N	2024-04-29 11:48:28.736+00	2024-04-29 11:48:28.736+00	\N	d233665e-6b54-479f-a735-14f3747e4f51	152
154	undefined-Visit Plan	Frequent follow ups	Monthly	2024-07-27 00:00:00+00	2024-07-27 00:00:00+00	2024-10-27 00:00:00+00	f	t	f	\N	\N	2024-04-29 11:48:28.736+00	2024-04-29 11:48:28.736+00	\N	d233665e-6b54-479f-a735-14f3747e4f51	152
155	undefined-Visit Plan	Frequent follow ups	Monthly	2024-08-27 00:00:00+00	2024-08-27 00:00:00+00	2024-10-27 00:00:00+00	f	t	f	\N	\N	2024-04-29 11:48:28.736+00	2024-04-29 11:48:28.736+00	\N	d233665e-6b54-479f-a735-14f3747e4f51	152
156	undefined-Visit Plan	Frequent follow ups	Monthly	2024-09-27 00:00:00+00	2024-09-27 00:00:00+00	2024-10-27 00:00:00+00	f	t	f	\N	\N	2024-04-29 11:48:28.736+00	2024-04-29 11:48:28.736+00	\N	d233665e-6b54-479f-a735-14f3747e4f51	152
157	undefined-Visit Plan	Frequent follow ups	Monthly	2024-10-27 00:00:00+00	2024-10-27 00:00:00+00	2024-10-27 00:00:00+00	f	t	f	\N	\N	2024-04-29 11:48:28.736+00	2024-04-29 11:48:28.736+00	\N	d233665e-6b54-479f-a735-14f3747e4f51	152
158	undefined-Visit Plan	Frequent follow ups	Every 2 Months (Bi-monthly)	2024-07-04 00:00:00+00	2024-07-04 00:00:00+00	2024-11-04 00:00:00+00	f	t	f	\N	\N	2024-05-13 09:09:49.041+00	2024-05-13 09:09:49.041+00	\N	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N
159	undefined-Visit Plan	Frequent follow ups	Every 2 Months (Bi-monthly)	2024-09-04 00:00:00+00	2024-09-04 00:00:00+00	2024-11-04 00:00:00+00	f	t	f	\N	\N	2024-05-13 09:09:49.045+00	2024-05-13 09:09:49.045+00	\N	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	158
160	undefined-Visit Plan	Frequent follow ups	Every 2 Months (Bi-monthly)	2024-11-04 00:00:00+00	2024-11-04 00:00:00+00	2024-11-04 00:00:00+00	f	t	f	\N	\N	2024-05-13 09:09:49.045+00	2024-05-13 09:09:49.045+00	\N	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	158
161	Katie Test event added on 5/20	As mentioned in title of event	Does Not Repeat	2024-05-20 09:45:01+00	2024-05-20 10:01:01+00	\N	f	t	f	0ac84ba8-9cd7-4536-a3c9-aff6b4b69f68	\N	2024-05-20 14:05:53.839+00	2024-05-20 14:05:53.839+00	39	0ac84ba8-9cd7-4536-a3c9-aff6b4b69f68	\N
162	undefined-Visit Plan	Frequent follow ups	Monthly	2024-06-22 00:00:00+00	2024-06-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:45:56.575+00	2024-05-21 19:45:56.575+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N
163	undefined-Visit Plan	Frequent follow ups	Monthly	2024-07-22 00:00:00+00	2024-07-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:45:56.579+00	2024-05-21 19:45:56.579+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	162
164	undefined-Visit Plan	Frequent follow ups	Monthly	2024-08-22 00:00:00+00	2024-08-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:45:56.579+00	2024-05-21 19:45:56.579+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	162
165	undefined-Visit Plan	Frequent follow ups	Monthly	2024-09-22 00:00:00+00	2024-09-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:45:56.579+00	2024-05-21 19:45:56.579+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	162
166	undefined-Visit Plan	Frequent follow ups	Monthly	2024-10-22 00:00:00+00	2024-10-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:45:56.579+00	2024-05-21 19:45:56.579+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	162
167	undefined-Visit Plan	Frequent follow ups	Monthly	2024-11-22 00:00:00+00	2024-11-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:45:56.579+00	2024-05-21 19:45:56.579+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	162
168	undefined-Visit Plan	Frequent follow ups	Monthly	2024-06-22 00:00:00+00	2024-06-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:46:25.768+00	2024-05-21 19:46:25.768+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N
169	undefined-Visit Plan	Frequent follow ups	Monthly	2024-07-22 00:00:00+00	2024-07-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:46:25.771+00	2024-05-21 19:46:25.771+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	168
170	undefined-Visit Plan	Frequent follow ups	Monthly	2024-08-22 00:00:00+00	2024-08-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:46:25.771+00	2024-05-21 19:46:25.771+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	168
171	undefined-Visit Plan	Frequent follow ups	Monthly	2024-09-22 00:00:00+00	2024-09-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:46:25.771+00	2024-05-21 19:46:25.771+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	168
172	undefined-Visit Plan	Frequent follow ups	Monthly	2024-10-22 00:00:00+00	2024-10-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:46:25.771+00	2024-05-21 19:46:25.771+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	168
173	undefined-Visit Plan	Frequent follow ups	Monthly	2024-11-22 00:00:00+00	2024-11-22 00:00:00+00	2024-11-22 00:00:00+00	f	t	f	\N	\N	2024-05-21 19:46:25.771+00	2024-05-21 19:46:25.771+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	168
174	undefined-Visit Plan	Frequent follow ups	Monthly	2024-06-24 00:00:00+00	2024-06-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-22 19:19:17.343+00	2024-05-22 19:19:17.343+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N
175	undefined-Visit Plan	Frequent follow ups	Monthly	2024-07-24 00:00:00+00	2024-07-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-22 19:19:17.354+00	2024-05-22 19:19:17.354+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	174
176	undefined-Visit Plan	Frequent follow ups	Monthly	2024-08-24 00:00:00+00	2024-08-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-22 19:19:17.354+00	2024-05-22 19:19:17.354+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	174
177	undefined-Visit Plan	Frequent follow ups	Monthly	2024-09-24 00:00:00+00	2024-09-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-22 19:19:17.354+00	2024-05-22 19:19:17.354+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	174
178	undefined-Visit Plan	Frequent follow ups	Monthly	2024-10-24 00:00:00+00	2024-10-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-22 19:19:17.354+00	2024-05-22 19:19:17.354+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	174
179	undefined-Visit Plan	Frequent follow ups	Monthly	2024-11-24 00:00:00+00	2024-11-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-22 19:19:17.354+00	2024-05-22 19:19:17.354+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	174
180	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-06-05 00:00:00+00	2024-06-05 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.609+00	2024-05-22 21:23:52.609+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N
181	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-06-19 00:00:00+00	2024-06-19 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
182	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-07-03 00:00:00+00	2024-07-03 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
183	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-07-17 00:00:00+00	2024-07-17 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
184	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-07-31 00:00:00+00	2024-07-31 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
185	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-08-14 00:00:00+00	2024-08-14 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
186	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-08-28 00:00:00+00	2024-08-28 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
187	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-09-11 00:00:00+00	2024-09-11 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
188	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-09-25 00:00:00+00	2024-09-25 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
189	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-10-09 00:00:00+00	2024-10-09 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
190	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-10-23 00:00:00+00	2024-10-23 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
191	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-11-06 00:00:00+00	2024-11-06 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
192	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-11-20 00:00:00+00	2024-11-20 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
193	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-12-04 00:00:00+00	2024-12-04 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:23:52.613+00	2024-05-22 21:23:52.613+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	180
194	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-06-05 00:00:00+00	2024-06-05 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.148+00	2024-05-22 21:25:07.148+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N
195	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-06-19 00:00:00+00	2024-06-19 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
196	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-07-03 00:00:00+00	2024-07-03 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
197	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-07-17 00:00:00+00	2024-07-17 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
198	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-07-31 00:00:00+00	2024-07-31 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
199	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-08-14 00:00:00+00	2024-08-14 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
200	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-08-28 00:00:00+00	2024-08-28 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
201	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-09-11 00:00:00+00	2024-09-11 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
202	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-09-25 00:00:00+00	2024-09-25 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
203	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-10-09 00:00:00+00	2024-10-09 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
204	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-10-23 00:00:00+00	2024-10-23 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
205	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-11-06 00:00:00+00	2024-11-06 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
206	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-11-20 00:00:00+00	2024-11-20 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
207	undefined-Visit Plan	Frequent follow ups	Fortnightly (Bi-weekly)	2024-12-04 00:00:00+00	2024-12-04 00:00:00+00	2024-12-04 00:00:00+00	f	t	f	\N	\N	2024-05-22 21:25:07.16+00	2024-05-22 21:25:07.16+00	\N	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	194
208	undefined-Visit Plan	Frequent follow ups	Monthly	2024-06-24 00:00:00+00	2024-06-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-23 06:18:14.287+00	2024-05-23 06:18:14.287+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N
209	undefined-Visit Plan	Frequent follow ups	Monthly	2024-07-24 00:00:00+00	2024-07-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-23 06:18:14.291+00	2024-05-23 06:18:14.291+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	208
210	undefined-Visit Plan	Frequent follow ups	Monthly	2024-08-24 00:00:00+00	2024-08-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-23 06:18:14.291+00	2024-05-23 06:18:14.291+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	208
211	undefined-Visit Plan	Frequent follow ups	Monthly	2024-09-24 00:00:00+00	2024-09-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-23 06:18:14.291+00	2024-05-23 06:18:14.291+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	208
212	undefined-Visit Plan	Frequent follow ups	Monthly	2024-10-24 00:00:00+00	2024-10-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-23 06:18:14.291+00	2024-05-23 06:18:14.291+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	208
213	undefined-Visit Plan	Frequent follow ups	Monthly	2024-11-24 00:00:00+00	2024-11-24 00:00:00+00	2024-11-24 00:00:00+00	f	t	f	\N	\N	2024-05-23 06:18:14.291+00	2024-05-23 06:18:14.291+00	\N	5f8e4c5a-738e-497d-8957-9f226e1e42b0	208
\.


--
-- Data for Name: HT_families; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_families" (id, "familyName", "addressLine1", "addressLine2", city, "zipCode", "isActive", "isDeleted", "createdBy", "updatedBy", "injectiondocId", "createdAt", "updatedAt", "HTCountryId", "HTStateId", "HTDistrictId", "HTLanguageId") FROM stdin;
36	Karasseril	Test Family 1		Texas	32321	t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	\N	\N	2024-04-04 06:13:05.861+00	2024-04-04 06:13:05.861+00	2	37	\N	1
37	Test fam	Address 1 		Address 1 	54654	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	\N	2024-04-08 05:40:21.459+00	2024-04-08 05:40:21.459+00	2	37	\N	2
38	test fam	Address 1 		Texas	32132	t	f	c9326236-e7a4-47c8-8788-444247e7d23a	\N	\N	2024-04-11 08:55:05.399+00	2024-04-11 08:55:05.399+00	2	37	\N	1
39	Gogo TS RBAC Phase 1	AD01 Gogo land		Texas City	12345	t	f	0d59b8f7-807c-4ed8-9620-69ca71ae5b34	\N	\N	2024-04-11 10:27:09.479+00	2024-04-11 10:27:09.479+00	2	37	\N	1
40	Ethan Hunt CM Family	AD01 WASH DC		Washington DC	12345	t	f	46e42a63-ded5-486b-9203-d5e523f745fb	46e42a63-ded5-486b-9203-d5e523f745fb	\N	2024-04-11 12:50:07.017+00	2024-04-11 12:51:48.021+00	2	39	\N	1
41	Test Family(Jyotir)	Austin, Texas 		Austin	73301	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	\N	2024-04-15 06:37:36.995+00	2024-04-15 06:37:36.995+00	2	37	\N	1
42	Test Family (TS)	Austin		Austin	11001	t	f	827b4381-3556-4bca-82d9-e186d0aae8d7	\N	\N	2024-04-18 11:36:22.635+00	2024-04-18 11:36:22.635+00	2	37	\N	1
43	TSFAM1	123 6th st		City	88888	t	f	f594d8ce-8c18-4f70-a85f-72619d372a4d	\N	\N	2024-04-22 21:07:06.354+00	2024-04-22 21:07:06.354+00	2	37	\N	1
44	Test Family 1	Austin, texas		Austin	11111	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	\N	2024-05-20 07:24:37.84+00	2024-05-20 07:24:37.84+00	2	37	\N	1
45	Tina Max (Katie test)	TBD		TBD	78735	t	f	0ac84ba8-9cd7-4536-a3c9-aff6b4b69f68	\N	\N	2024-05-20 13:16:48.639+00	2024-05-20 13:16:48.639+00	2	37	\N	1
46	Moose	123 Miracle Way		Austin	78717	t	f	32d34875-6aa0-4e97-9b8b-8f822263cbd1	\N	\N	2024-05-22 20:44:57.033+00	2024-05-22 20:44:57.033+00	2	37	\N	1
\.


--
-- Data for Name: HT_familyMemTypeLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_familyMemTypeLangMaps" (id, "memberType", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTFamilyMemberTypeId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_familyMemberTypes; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_familyMemberTypes" (id, "memberType", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "memberTypeLang") FROM stdin;
1	Care Giver	t	f	\N	\N	2022-02-23 05:17:56.364+00	2022-02-23 05:17:56.364+00	{"1": "Care Giver", "2": "देखभाल देने वाला", "3": "பராமரிப்பாளர்"}
2	Other Member	t	f	\N	\N	2022-02-23 05:17:56.364+00	2022-02-23 05:17:56.364+00	{"1": "Other Member", "2": "अन्य सदस्य", "3": "மற்ற உறுப்பினர்"}
\.


--
-- Data for Name: HT_familyMembers; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_familyMembers" (id, "firstName", "lastName", occupation, "phoneNumber", email, "isPrimaryCareGiver", "otherRelation", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTFamilyId", "HTFamilyMemberTypeId", "HTFamilyRelationId") FROM stdin;
34	Shagil	Krishna	Farmer	+12255365241		t		t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-04-04 06:13:05.875+00	2024-04-04 06:25:32.51+00	36	1	6
35	name 1 	name 2	Farmer 	+12255365102		t		t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-08 05:40:21.473+00	2024-04-08 05:40:21.473+00	37	1	7
36	tester 	1	farmer	+12255321165		t		t	f	c9326236-e7a4-47c8-8788-444247e7d23a	\N	2024-04-11 08:55:05.421+00	2024-04-11 08:55:05.421+00	38	1	7
38	Ethan Hunt	CM Family	Ex-Spec Ops	+19497288333		t		t	f	46e42a63-ded5-486b-9203-d5e523f745fb	46e42a63-ded5-486b-9203-d5e523f745fb	2024-04-11 12:50:07.029+00	2024-04-11 12:51:48.029+00	40	1	2
39	Test Member1(Jyotir)	Member1(Jyotir)	Self employed	+12819999990		t		t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-15 06:37:37.013+00	2024-04-15 06:37:37.013+00	41	1	2
40	Test	Family	Truck Driver	+15127000000		t		t	f	827b4381-3556-4bca-82d9-e186d0aae8d7	\N	2024-04-18 11:36:22.658+00	2024-04-18 11:36:22.658+00	42	1	2
41	TSTestparent1	test	QA test	+17372100120		t		t	f	f594d8ce-8c18-4f70-a85f-72619d372a4d	\N	2024-04-22 21:07:06.375+00	2024-04-22 21:07:06.375+00	43	1	2
42	Add Member	Test		+12255654654	AddMemberTest@mailinator.com	f	AddMemberTest	t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-04-29 05:11:11.571+00	2024-04-29 05:12:42.921+00	36	2	7
37	Gogo 	TS RBAC P1	Engineer	+19497288333		t		t	f	0d59b8f7-807c-4ed8-9620-69ca71ae5b34	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	2024-04-11 10:27:09.502+00	2024-05-13 10:03:49.388+00	39	1	2
45	Tina	Max (Katie test)	Shop keeper	+12812223333		t		t	f	0ac84ba8-9cd7-4536-a3c9-aff6b4b69f68	\N	2024-05-20 13:16:48.656+00	2024-05-20 13:16:48.656+00	45	1	1
46	Carol	Uber (Katie test)		+12812223333		f		t	f	0ac84ba8-9cd7-4536-a3c9-aff6b4b69f68	\N	2024-05-20 13:18:40.285+00	2024-05-20 13:18:40.285+00	45	1	5
43	Test Mother	1	Professor	+15129999999		f		t	f	d233665e-6b54-479f-a735-14f3747e4f51	d233665e-6b54-479f-a735-14f3747e4f51	2024-05-20 07:24:37.858+00	2024-05-21 09:20:10.965+00	44	1	1
44	Test Father	1	Truck Driver	+15128888888		t		t	f	d233665e-6b54-479f-a735-14f3747e4f51	d233665e-6b54-479f-a735-14f3747e4f51	2024-05-20 07:26:04.911+00	2024-05-21 09:20:10.979+00	44	1	2
47	Marko	Moose	Diver	+15123298635		t		t	f	32d34875-6aa0-4e97-9b8b-8f822263cbd1	\N	2024-05-22 20:44:57.054+00	2024-05-22 20:44:57.054+00	46	1	2
\.


--
-- Data for Name: HT_familyRelanLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_familyRelanLangMaps" (id, relation, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTFamilyRelationId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_familyRelations; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_familyRelations" (id, relation, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "relationLang") FROM stdin;
1	Mother	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Mother", "2": "अम्मा", "3": "அம்மா"}
2	Father	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Father", "2": "पिता", "3": "அப்பா"}
3	Sibling	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Sibling", "2": "भाई", "3": "உடன்பிறப்பு"}
4	Uncle/Aunt	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Uncle/Aunt", "2": "चाचा/चाची", "3": "மாமா/ அத்தை"}
5	Grandparent(s)	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Grandparent(s)", "2": "दादा/दादी", "3": "தாத்தா/ பாட்டி(கள்)"}
6	Cousin	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Cousin", "2": "चचेरा भाई", "3": "ஒன்றுவிட்ட சகோதர, சகோதரிகள்"}
7	Others(specify)	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Others(specify)", "2": "अन्य (निर्दिष्ट करें)", "3": "மற்றவர்கள் (குறிப்பிடவும்)"}
\.


--
-- Data for Name: HT_fileUploadMappings; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_fileUploadMappings" (id, "originalFileName", "customFileName", "moduleType", "documentType", "filePath", "fileUrl", "fileStatus", "fileSize", description, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTChildId", "HTAccountId", "HTUserId") FROM stdin;
1	81957Black Gold Creative elegant Happy Birthday Banner.png	81957Black Gold Creative elegant Happy Birthday Banner.png	HT_CHILD	doc	81957Black Gold Creative elegant Happy Birthday Banner.png		Created	9916.48046875	Child document	t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-04-29 05:40:24.12+00	2024-04-29 05:40:24.12+00	32	\N	\N
2	21990child-logs (10).pdf	21990child-logs (10).pdf	HT_CHILD	doc	21990child-logs (10).pdf		Created	38.142578125	Child document	t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-04-29 05:54:24.43+00	2024-04-29 05:54:24.43+00	32	\N	\N
3	81837child-logs (10).pdf	81837child-logs (10).pdf	HT_CHILD	doc	81837child-logs (10).pdf		Created	38.142578125	Child document	t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-04-29 05:54:50.012+00	2024-04-29 05:54:50.012+00	32	\N	\N
4	93682child-logs (10).pdf	93682child-logs (10).pdf	HT_CHILD	doc	93682child-logs (10).pdf		Created	38.142578125	Child document	t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-04-29 05:55:26.045+00	2024-04-29 05:55:26.045+00	32	\N	\N
5	9073child-logs (10).pdf	9073child-logs (10).pdf	HT_CHILD	doc	9073child-logs (10).pdf		Created	38.142578125	Child document	t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-04-29 05:55:56.462+00	2024-04-29 05:55:56.462+00	32	\N	\N
6	65302child-logs (10).pdf	65302child-logs (10).pdf	HT_CHILD	doc	65302child-logs (10).pdf		Created	38.142578125	Child document	t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-04-29 06:00:28.8+00	2024-04-29 06:00:28.8+00	32	\N	\N
7	56763clg0evi8n164011mekgq2exgm (2).pdf	56763clg0evi8n164011mekgq2exgm (2).pdf	HT_CHILD	doc	56763clg0evi8n164011mekgq2exgm (2).pdf		Created	137.29296875	Child document	t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-04-29 06:18:49.995+00	2024-04-29 06:18:49.995+00	32	\N	\N
8	28971Hero_MotoCorp_Logo.svg.png	28971Hero_MotoCorp_Logo.svg.png	HT_CHILD	doc	28971Hero_MotoCorp_Logo.svg.png		Created	52.4814453125	Child document	t	f	f191b1cc-f282-4080-8c60-3f757aacca6d	f191b1cc-f282-4080-8c60-3f757aacca6d	2024-05-02 05:39:06.824+00	2024-05-02 05:39:06.824+00	32	\N	\N
\.


--
-- Data for Name: HT_formQuestionMappings; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_formQuestionMappings" (id, "order", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTQuestionId", "HTFormId") FROM stdin;
463	1	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	80	19
330	2	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	2	1
331	3	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	3	1
332	4	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	4	1
333	5	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	5	1
334	6	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	6	1
335	7	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	7	1
336	8	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	8	1
337	9	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	9	1
338	10	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	10	1
339	11	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	11	1
340	12	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	12	1
341	13	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	13	1
342	14	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	14	1
343	15	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	15	1
344	16	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	16	1
345	17	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	17	1
346	18	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	18	1
347	19	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	19	1
348	20	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	20	1
349	21	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	21	1
350	22	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	22	1
351	23	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	23	1
352	24	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	24	1
353	25	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	25	1
354	26	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	26	1
355	27	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	27	1
356	28	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	28	1
357	29	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	29	1
358	30	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	30	1
359	31	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	31	1
360	32	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	32	1
361	33	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	33	1
362	34	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	34	1
363	35	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	35	1
364	36	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	36	1
365	37	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	37	1
366	38	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	38	1
367	39	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	39	1
368	40	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	40	1
369	41	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	41	1
370	42	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	42	1
371	43	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	43	1
372	44	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	44	1
373	1	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	45	17
374	2	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	46	17
375	3	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	47	17
376	4	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	48	17
377	5	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	49	17
378	6	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	50	17
379	7	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	51	17
380	8	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	52	17
381	9	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	53	17
382	10	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	54	17
383	11	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	55	17
384	12	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	56	17
385	13	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	57	17
386	14	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	58	17
387	15	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.367+00	2024-04-11 10:38:34.367+00	59	17
464	2	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	81	19
465	3	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	82	19
466	4	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	83	19
467	5	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	84	19
468	6	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	85	19
469	7	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	86	19
470	8	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	87	19
471	9	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	88	19
472	10	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	89	19
473	11	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	90	19
474	12	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	91	19
475	13	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	92	19
476	14	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	93	19
477	15	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	94	19
478	16	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	95	19
479	17	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	96	19
480	18	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	97	19
481	19	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	98	19
482	20	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	99	19
483	21	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	100	19
484	22	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	101	19
485	23	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	102	19
486	24	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	103	19
487	25	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	104	19
488	26	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	105	19
489	27	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	106	19
490	28	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	107	19
491	29	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	108	19
492	30	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	109	19
493	31	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	110	19
494	32	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	111	19
495	33	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	112	19
496	34	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	113	19
497	35	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	114	19
498	36	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	115	19
499	37	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	116	19
500	38	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	117	19
501	39	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	118	19
502	40	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	119	19
503	41	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	120	19
504	42	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	121	19
505	43	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.946+00	2024-04-11 10:49:51.946+00	122	19
329	1	t	f	\N	\N	2024-03-20 09:23:40.749377+00	2024-03-20 09:23:40.749377+00	1	1
506	1	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	126	20
507	2	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	127	20
508	3	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	128	20
509	4	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	129	20
510	5	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	130	20
511	6	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	131	20
512	7	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	132	20
513	8	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	133	20
514	9	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	134	20
515	10	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	135	20
516	11	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	136	20
517	12	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	137	20
518	13	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	138	20
519	14	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	139	20
520	15	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	140	20
521	16	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	141	20
522	17	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	142	20
448	1	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	65	18
449	2	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	66	18
450	3	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	67	18
451	4	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	68	18
452	5	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	69	18
453	6	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	70	18
454	7	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	71	18
455	8	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	72	18
456	9	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	73	18
457	10	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	74	18
458	11	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	75	18
459	12	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	76	18
460	13	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	77	18
461	14	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	78	18
462	15	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:43:57.127+00	2024-04-11 10:43:57.127+00	79	18
523	18	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	143	20
524	19	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	144	20
525	20	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	145	20
526	21	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	146	20
527	22	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	147	20
528	23	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	148	20
529	24	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	149	20
530	25	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	150	20
531	26	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	151	20
532	27	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	152	20
533	28	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	153	20
534	29	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	154	20
535	30	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	155	20
536	31	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	156	20
537	32	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	157	20
538	33	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	158	20
539	34	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	159	20
540	35	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	160	20
541	36	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	161	20
542	37	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	162	20
543	38	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	163	20
544	39	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	164	20
545	40	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	165	20
546	41	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	166	20
547	42	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	167	20
548	43	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	168	20
549	44	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	169	20
550	45	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.641+00	2024-05-20 13:59:16.641+00	170	20
\.


--
-- Data for Name: HT_formRevisions; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_formRevisions" (id, "order", "revisionNumber", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTFormId", "HTQuestionId") FROM stdin;
\.


--
-- Data for Name: HT_forms; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_forms" (id, "formName", description, "currentRevision", "isDraft", "isPublished", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTAccountId") FROM stdin;
1	Miracle Foundation(Default Form)	(Default Form)	0	f	t	t	f	\N	\N	2023-07-20 06:01:38.824+00	2024-03-28 17:16:19.522+00	\N
17	RBAC Phase 1 Form Add v1.0	RBAC Phase 1 Form Add v1.0	1	f	t	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:38:34.323+00	2024-04-11 10:38:46.22+00	96aca77e-d466-4be1-862d-9bf3ab4573a0
18	RBAC Phase 1 Form Add and Edit	RBAC Phase 1 Form Add and Edit	1	t	f	f	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:42:31.918+00	2024-04-11 10:43:57.123+00	96aca77e-d466-4be1-862d-9bf3ab4573a0
19	Delete Forms	Delete Forms	1	t	f	f	t	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	2024-04-11 10:49:51.788+00	2024-04-11 10:50:01.052+00	96aca77e-d466-4be1-862d-9bf3ab4573a0
20	Katie Testing Assessment Customization Feature	Katie Testing Assessment Customization Feature	1	f	t	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	2024-05-20 13:59:16.488+00	2024-05-20 14:03:01.458+00	733783e7-fcf9-42d5-849c-33aff0f01d35
\.


--
-- Data for Name: HT_importLogs; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_importLogs" (id, "moduleType", data, error, "errorType", "entityId", "injectiondocId", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: HT_importMappings; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_importMappings" (id, "originalFileName", "customFileName", "moduleType", "documentType", "filePath", "fileUrl", "fileStatus", "importStatus", "fileSize", description, "dataCount", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: HT_langMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_langMaps" (id, language, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTLanguageId", "LanguageRefIdId") FROM stdin;
\.


--
-- Data for Name: HT_languages; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_languages" (id, language, "langCode", "isActive", "isDeleted", "createdAt", "updatedAt") FROM stdin;
1	English	ENG	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00
2	Hindi	hi	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00
3	Tamil	ta	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00
4	Spanish	es	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00
\.


--
-- Data for Name: HT_logExports; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_logExports" (id, "s3BucketName", location, "creationTime", "logTaskId", "logGroupName", "logName", "fromTimestamp", "toTimestamp", "completionTime", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: HT_notifLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_notifLangMaps" (id, title, body, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTNotificationId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_notifications; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_notifications" (id, "readStatus", title, body, module, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTNotifnEventTypeId", "SenderIdId", "RecieverIdId", "HTUserId", "HTChildId", "HTCaseId", "HTFamilyId") FROM stdin;
\.


--
-- Data for Name: HT_notifnEventTypes; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_notifnEventTypes" (id, "eventType", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: HT_questionDomains; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_questionDomains" (id, "domainName", description, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "domainNameLang") FROM stdin;
1	Family and Social Relationships	\N	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Family and Social Relationships", "2": "परिवार और सामाजिक संबंध", "3": "குடும்ப மற்றும் சமூக உறவுகள்"}
2	Household Economy 	\N	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Household Economy", "2": "घरेलू अर्थव्यवस्था", "3": "வீட்டுப் பொருளாதாரம்"}
3	Living Conditions	\N	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Living Conditions", "2": "रहने की स्थिति", "3": "வாழும் நிலைமைகள்"}
4	Education	\N	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Education", "2": "शिक्षा", "3": "கல்வி"}
5	Health and Mental Health	\N	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00	{"1": "Health and Mental Health", "2": "स्वास्थ्य और मानसिक स्वास्थ्य", "3": "ஆரோக்கியம் மற்றும் மன ஆரோக்கியம்"}
\.


--
-- Data for Name: HT_questionLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_questionLangMaps" (id, "questionText", "questionHelpText", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTQuestionId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_questionTypes; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_questionTypes" (id, "typeName", description, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt") FROM stdin;
1	Domain Question	\N	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00
2	Redflag Followup Question	\N	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00
3	Intervention Question	\N	t	f	\N	\N	2022-02-23 05:17:56.365+00	2022-02-23 05:17:56.365+00
\.


--
-- Data for Name: HT_questions; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_questions" (id, "questionText", "questionHelpText", "isRedFlag", "isFosterCareFlag", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTAccountId", "HTQuestionDomainId", "HTQuestionTypeId", "HTAnswerTypeId", "HTQuestionId") FROM stdin;
45	Sexual Abuse in family - child or another family member is victim of inappropriate touching, molestation, forced viewing of pornography, child grooming, cyber molestation.	Must rate In-Crisis (1) if child/ family is still victim of abuse & or abuser still has access to the child. Rate Vulnerable (2) if there is history of abuse.	t	f	t	f	\N	\N	2022-02-21 16:47:39.171+00	2023-07-20 06:01:38.824+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
46	Child is victim or at risk of child marriage.		t	f	t	f	\N	\N	2022-02-21 16:47:40.911+00	2022-02-21 16:47:40.911+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
47	Relationships with extended family.	Can include financial or emotional support, childcare, etc.	f	f	t	f	\N	\N	2022-02-21 16:47:42.944+00	2022-02-21 16:47:42.944+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
48	Secure income/employment - Employment can support the family's financial needs.	Risk factor: Migratory workers, wage earners, farm laborer etc that is impacting the child’s rights	t	f	t	f	\N	\N	2022-02-21 16:47:53.814+00	2022-02-21 16:47:53.814+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
49	Adults have education/skills for employment.		f	f	t	f	\N	\N	2022-02-21 16:47:55.229+00	2022-02-21 16:47:55.229+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
50	Ability to purchase supplies/tools for job		f	f	t	f	\N	\N	2022-02-21 16:47:57.121+00	2022-02-21 16:47:57.121+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
51	Living situation safe for children.	(Risk factors: high crime, alcoholism/substance abuse common in the community, parent or community engages as commercial sex workers, community trauma such as pandemic, flood)	t	f	t	f	\N	\N	2022-02-21 16:48:07.665+00	2022-02-21 16:48:07.665+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	3	1	1	\N
52	Secure stable housing.	Risk factors: displacement of family/child - migration, frequent shifting family, risk of eviction	f	f	t	f	\N	\N	2022-02-21 16:48:09.585+00	2022-02-21 16:48:09.585+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	3	1	1	\N
53	Basic amenities.	Safe water, sanitation, cooking facilities, food storage, sleeping arrangements	f	f	t	f	\N	\N	2022-02-21 16:48:13.068+00	2022-02-21 16:48:13.068+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	3	1	1	\N
54	All school age children attend school	Remote education where applicable	t	f	t	f	\N	\N	2022-02-21 16:48:15.115+00	2022-02-21 16:48:15.115+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
55	Children attend higher education or vocational training if desired.	Remote education where applicable	f	f	t	f	\N	\N	2022-02-21 16:48:17.777+00	2023-07-26 05:57:04.873+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
56	Children are involved in extracurricular activities.	e.g. sports, dance, music, clubs	f	f	t	f	\N	\N	2022-02-21 16:48:23.584+00	2022-02-21 16:48:23.584+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
57	Alcohol/substance abuse in child or family.		t	f	t	f	\N	\N	2022-02-21 16:48:24.372+00	2022-02-21 16:48:24.372+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
58	Access to health care facilities for routine health care and emergencies.		f	f	t	f	\N	\N	2022-02-21 16:48:25.975+00	2022-02-21 16:48:25.975+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
59	Personal hygiene/self-care skills		f	f	t	f	\N	\N	2022-02-21 16:48:38.463+00	2022-02-21 16:48:38.463+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
60	Edit - Child is victim or at risk of child marriage.		t	f	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:40:08.74+00	2024-04-11 10:40:08.74+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
61	Edited - Access to health care facilities for routine health care and emergencies.		f	f	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:13.263+00	2024-04-11 10:41:13.263+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
62	Edited - Children attend higher education or vocational training if desired.	Remote education where applicable	f	f	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:29.032+00	2024-04-11 10:41:29.032+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
63	Edited - Adults have education/skills for employment.		f	f	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:39.751+00	2024-04-11 10:41:39.751+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
64	Added Question 01		f	f	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:42:23.602+00	2024-04-11 10:42:23.602+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
66	Edit - Child is victim or at risk of child marriage.		t	f	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:40:08.74+00	2024-04-11 10:40:08.74+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
67	Relationships with extended family.	Can include financial or emotional support, childcare, etc.	f	f	t	f	\N	\N	2022-02-21 16:47:42.944+00	2022-02-21 16:47:42.944+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
68	Secure income/employment - Employment can support the family's financial needs.	Risk factor: Migratory workers, wage earners, farm laborer etc that is impacting the child’s rights	t	f	t	f	\N	\N	2022-02-21 16:47:53.814+00	2022-02-21 16:47:53.814+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
69	Edited - Adults have education/skills for employment.		f	f	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:39.751+00	2024-04-11 10:41:39.751+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
70	Claiming all entitled benefits - Accessing support from community, NGOs, government		f	f	t	f	\N	\N	2022-02-21 16:48:06.335+00	2022-02-21 16:48:06.335+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
71	Living situation safe for children.	(Risk factors: high crime, alcoholism/substance abuse common in the community, parent or community engages as commercial sex workers, community trauma such as pandemic, flood)	t	f	t	f	\N	\N	2022-02-21 16:48:07.665+00	2022-02-21 16:48:07.665+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	3	1	1	\N
73	Adequately furnished specific to cultural context		f	f	t	f	\N	\N	2022-02-21 16:48:14.09+00	2022-02-21 16:48:14.09+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	3	1	1	\N
74	All school age children attend school	Remote education where applicable	t	f	t	f	\N	\N	2022-02-21 16:48:15.115+00	2022-02-21 16:48:15.115+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
75	Edited - Children attend higher education or vocational training if desired.	Remote education where applicable	f	f	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:29.032+00	2024-04-11 10:41:29.032+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
76	Added Question 01		f	f	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:42:23.602+00	2024-04-11 10:42:23.602+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
77	Alcohol/substance abuse in child or family.		t	f	t	f	\N	\N	2022-02-21 16:48:24.372+00	2022-02-21 16:48:24.372+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
78	Edited - Access to health care facilities for routine health care and emergencies.		f	f	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	2024-04-11 10:41:13.263+00	2024-04-11 10:41:13.263+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
79	Transportation for medical care/emergencies		f	f	t	f	\N	\N	2022-02-21 16:48:43.788+00	2022-02-21 16:48:43.788+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
72	Edit - Secure stable housing.	Risk factors: displacement of family/child - migration, frequent shifting family, risk of eviction	f	f	t	f	\N	d093e74c-259d-4851-a522-5ca4d78fc61f	2022-02-21 16:48:09.585+00	2024-04-11 10:43:14.552+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	3	1	1	\N
65	Edit After Save - Sexual Abuse in family - child or another family member is victim of inappropriate touching, molestation, forced viewing of pornography, child grooming, cyber molestation.	Must rate In-Crisis (1) if child/ family is still victim of abuse & or abuser still has access to the child. Rate Vulnerable (2) if there is history of abuse.	t	f	t	f	\N	d093e74c-259d-4851-a522-5ca4d78fc61f	2022-02-21 16:47:39.171+00	2024-04-11 10:43:54.025+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
80	Sexual Abuse in family - child or another family member is victim of inappropriate touching, molestation, forced viewing of pornography, child grooming, cyber molestation.	Must rate In-Crisis (1) if child/ family is still victim of abuse & or abuser still has access to the child. Rate Vulnerable (2) if there is history of abuse.	t	f	t	f	\N	\N	2022-02-21 16:47:39.171+00	2023-07-20 06:01:38.824+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
81	Child is victim or at risk of child marriage.		t	f	t	f	\N	\N	2022-02-21 16:47:40.911+00	2022-02-21 16:47:40.911+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
82	Relationships with extended family.	Can include financial or emotional support, childcare, etc.	f	f	t	f	\N	\N	2022-02-21 16:47:42.944+00	2022-02-21 16:47:42.944+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
83	Relationship with neighbors/community.	Support network, safety of neighborhood.	f	f	t	f	\N	\N	2022-02-21 16:47:44.19+00	2022-02-21 16:47:44.19+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
84	Parenting skills/parental guidance and support	Positive discipline, attachment behaviors, listening skills, or irresponsible parenting, discipline issues.	f	f	t	f	\N	\N	2022-02-21 16:47:45.418+00	2022-02-21 16:47:45.418+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
85	Parent/caregiver(s) capable of providing support to children requiring extra support (e.g. teens, infants, behavioral/ emotional/ physical issues)	Positive discipline, attachment behaviors, listening skills, or irresponsible parenting, discipline issues.	f	f	t	f	\N	\N	2022-02-21 16:47:47.242+00	2022-02-21 16:47:47.242+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
86	Primary caregiver(s) is a young person (21 years or less) or elderly person capable of supporting the child/children.	Positive discipline, attachment behaviors, listening skills, or irresponsible parenting, discipline issues.	f	f	t	f	\N	\N	2022-02-21 16:47:48.32+00	2022-02-21 16:47:48.32+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
87	Child protection training and awareness of child protection risks and reporting procedures.		t	f	t	f	\N	\N	2022-02-21 16:47:49.342+00	2023-07-23 09:44:08.305+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
88	Supportive of their children’s rights.	(eg. right to privacy, be heard and participate in decisions that affect them, equal opportunities, lack of child labour/working child resulting in violation of child’s rights, etc.)	f	f	t	f	\N	\N	2022-02-21 16:47:50.164+00	2022-02-21 16:47:50.164+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
89	Foster Care only: Contact with birth family.		f	t	t	f	\N	\N	2022-02-21 16:47:50.985+00	2022-02-21 16:47:50.985+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
90	Relationship between Parent/caregiver(s)		f	f	t	f	\N	\N	2022-02-21 16:47:51.767+00	2022-02-21 16:47:51.767+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	1	1	1	\N
91	Secure income/employment - Employment can support the family's financial needs.	Risk factor: Migratory workers, wage earners, farm laborer etc that is impacting the child’s rights	t	f	t	f	\N	\N	2022-02-21 16:47:53.814+00	2022-02-21 16:47:53.814+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
92	Adults have education/skills for employment.		f	f	t	f	\N	\N	2022-02-21 16:47:55.229+00	2022-02-21 16:47:55.229+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
93	Ability to purchase supplies/tools for job		f	f	t	f	\N	\N	2022-02-21 16:47:57.121+00	2022-02-21 16:47:57.121+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
94	Access to transportation for job		f	f	t	f	\N	\N	2022-02-21 16:47:58.424+00	2022-02-21 16:47:58.424+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
95	Access to child care during working hours		f	f	t	f	\N	\N	2022-02-21 16:47:59.344+00	2022-02-21 16:47:59.344+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
96	Ability to provide food, clothing and household supplies for family		f	f	t	f	\N	\N	2022-02-21 16:48:00.482+00	2022-02-21 16:48:00.482+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
97	Ability to pay rent and bills regularly		f	f	t	f	\N	\N	2022-02-21 16:48:02.109+00	2022-02-21 16:48:02.109+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
98	Ability to cope with contingency/emergency expenses	Illness in family, pandemic situation, natural disaster, lean period, etc.	f	f	t	f	\N	\N	2022-02-21 16:48:04.978+00	2022-02-21 16:48:04.978+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
99	Claiming all entitled benefits - Accessing support from community, NGOs, government		f	f	t	f	\N	\N	2022-02-21 16:48:06.335+00	2022-02-21 16:48:06.335+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	2	1	1	\N
100	Living situation safe for children.	(Risk factors: high crime, alcoholism/substance abuse common in the community, parent or community engages as commercial sex workers, community trauma such as pandemic, flood)	t	f	t	f	\N	\N	2022-02-21 16:48:07.665+00	2022-02-21 16:48:07.665+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	3	1	1	\N
101	Secure stable housing.	Risk factors: displacement of family/child - migration, frequent shifting family, risk of eviction	f	f	t	f	\N	\N	2022-02-21 16:48:09.585+00	2022-02-21 16:48:09.585+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	3	1	1	\N
102	Basic amenities.	Safe water, sanitation, cooking facilities, food storage, sleeping arrangements	f	f	t	f	\N	\N	2022-02-21 16:48:13.068+00	2022-02-21 16:48:13.068+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	3	1	1	\N
103	Adequately furnished specific to cultural context		f	f	t	f	\N	\N	2022-02-21 16:48:14.09+00	2022-02-21 16:48:14.09+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	3	1	1	\N
104	All school age children attend school	Remote education where applicable	t	f	t	f	\N	\N	2022-02-21 16:48:15.115+00	2022-02-21 16:48:15.115+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
105	Children attend higher education or vocational training if desired.	Remote education where applicable	f	f	t	f	\N	\N	2022-02-21 16:48:17.777+00	2023-07-26 05:57:04.873+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
106	Children have appropriate school supplies/educational toys, access to resources for remote education as needed		f	f	t	f	\N	\N	2022-02-21 16:48:18.801+00	2022-02-21 16:48:18.801+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
107	Children have transportation to school		f	f	t	f	\N	\N	2022-02-21 16:48:19.927+00	2022-02-21 16:48:19.927+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
108	Children receive educational support as needed.	e.g. coaching teachers, testing and support for learning issues	f	f	t	f	\N	\N	2022-02-21 16:48:20.849+00	2022-02-21 16:48:20.849+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
109	Children are involved in extracurricular activities.	e.g. sports, dance, music, clubs	f	f	t	f	\N	\N	2022-02-21 16:48:23.584+00	2022-02-21 16:48:23.584+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	4	1	1	\N
110	Alcohol/substance abuse in child or family.		t	f	t	f	\N	\N	2022-02-21 16:48:24.372+00	2022-02-21 16:48:24.372+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
111	Access to health care facilities for routine health care and emergencies.		f	f	t	f	\N	\N	2022-02-21 16:48:25.975+00	2022-02-21 16:48:25.975+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
112	Recent or chronic health issues of child or family members and access to health care for the issue.	eg. high blood pressure, diabetes, anemia, epilepsy, cancer, etc.	f	f	t	f	\N	\N	2022-02-21 16:48:27.402+00	2022-02-21 16:48:27.402+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
113	Significant dental or vision issues and access to dental/vision care		f	f	t	f	\N	\N	2022-02-21 16:48:30.373+00	2022-02-21 16:48:30.373+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
114	Depression, anxiety, ADHD of child or family member		f	f	t	f	\N	\N	2022-02-21 16:48:31.806+00	2022-02-21 16:48:31.806+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
115	Diagnosis of mental illness of child or family member (e.g. psychosis, bipolar disorder, PTSD, etc.)		f	f	t	f	\N	\N	2022-02-21 16:48:33.274+00	2022-02-21 16:48:33.274+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
116	Access to medications/medical equipment		f	f	t	f	\N	\N	2022-02-21 16:48:34.776+00	2022-02-21 16:48:34.776+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
117	Diagnosed impairments/ disabilities/ developmental delays and access to services		f	f	t	f	\N	\N	2022-02-21 16:48:37.062+00	2022-02-21 16:48:37.062+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
118	Personal hygiene/self-care skills		f	f	t	f	\N	\N	2022-02-21 16:48:38.463+00	2022-02-21 16:48:38.463+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
119	Nutritional deficiency (unhealthy weight loss, malnutrition, anemia)		f	f	t	f	\N	\N	2022-02-21 16:48:39.555+00	2022-02-21 16:48:39.555+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
120	Access to nutritious foods		f	f	t	f	\N	\N	2022-02-21 16:48:41.535+00	2022-02-21 16:48:41.535+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
121	Health insurance		f	f	t	f	\N	\N	2022-02-21 16:48:42.661+00	2022-02-21 16:48:42.661+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
122	Transportation for medical care/emergencies		f	f	t	f	\N	\N	2022-02-21 16:48:43.788+00	2022-02-21 16:48:43.788+00	96aca77e-d466-4be1-862d-9bf3ab4573a0	5	1	1	\N
2	Sexual abuse is occuring in the family.	A child or another family member is a victim of inappropriate touching, molestation, forced viewing of pornography, child grooming, cyber molestation.	t	f	t	f	\N	\N	2022-02-21 16:47:39.171+00	2023-07-20 06:01:38.824+00	\N	1	1	1	\N
3	The child is a victim or at risk of child marriage.	\N	t	f	t	f	\N	\N	2022-02-21 16:47:40.911+00	2022-02-21 16:47:40.911+00	\N	1	1	1	\N
4	The family has strong relationships with their extended family.	The family receives support such as emotional, financial, childcare, etc from extended family.	f	f	t	f	\N	\N	2022-02-21 16:47:42.944+00	2022-02-21 16:47:42.944+00	\N	1	1	1	\N
5	The family has a strong support network with their neighbors and community.	The family has neighbors and community that they can turn to when they need help.	f	f	t	f	\N	\N	2022-02-21 16:47:44.19+00	2022-02-21 16:47:44.19+00	\N	1	1	1	\N
6	Parents/caregivers have the skills needed to guide and support their children.	\N	f	f	t	f	\N	\N	2022-02-21 16:47:45.418+00	2022-02-21 16:47:45.418+00	\N	1	1	1	\N
7	Parents/caregivers are capable of providing care to children requiring extra support (e.g. teens, infants, behavioral/emotional/physical issues).	\N	f	f	t	f	\N	\N	2022-02-21 16:47:47.242+00	2022-02-21 16:47:47.242+00	\N	1	1	1	\N
8	Parents/caregivers have the energy, knowledge, and resources to care for their children (e.g. primary caregivers are not under 21 years of age or elderly).	\N	f	f	t	f	\N	\N	2022-02-21 16:47:48.32+00	2022-02-21 16:47:48.32+00	\N	1	1	1	\N
9	The family is aware of child protection risks, signs, and reporting procedures.	\N	t	f	t	f	\N	\N	2022-02-21 16:47:49.342+00	2023-07-23 09:44:08.305+00	\N	1	1	1	\N
10	Parents are supportive of their childrens rights.	Parents/caregivers treat their children with respect, and recognize their right to privacy, equal opportunity regardless of gender, and to participate in decisions that affect them.	f	f	t	f	\N	\N	2022-02-21 16:47:50.164+00	2022-02-21 16:47:50.164+00	\N	1	1	1	\N
11	Foster Care only: The child has contact with their birth family.	\N	f	t	t	f	\N	\N	2022-02-21 16:47:50.985+00	2022-02-21 16:47:50.985+00	\N	1	1	1	\N
12	Parents/caregivers have a positive relationship with each other.	Parents/caregivers love, support, respect, trust, and care for each other, and communicate openly and honestly.	f	f	t	f	\N	\N	2022-02-21 16:47:51.767+00	2022-02-21 16:47:51.767+00	\N	1	1	1	\N
13	Adults in the home have steady, secure, safe employment that can support their financial needs.	\N	t	f	t	f	\N	\N	2022-02-21 16:47:53.814+00	2022-02-21 16:47:53.814+00	\N	2	1	1	\N
14	The adult(s) have education/skills for employment that can financially support the family.	\N	f	f	t	f	\N	\N	2022-02-21 16:47:55.229+00	2022-02-21 16:47:55.229+00	\N	2	1	1	\N
15	The adults are able to purchase supplies/tools for their jobs.	\N	f	f	t	f	\N	\N	2022-02-21 16:47:57.121+00	2022-02-21 16:47:57.121+00	\N	2	1	1	\N
16	Adults have access to transportation for their job(s).	\N	f	f	t	f	\N	\N	2022-02-21 16:47:58.424+00	2022-02-21 16:47:58.424+00	\N	2	1	1	\N
17	The family has childcare during working hours.	\N	f	f	t	f	\N	\N	2022-02-21 16:47:59.344+00	2022-02-21 16:47:59.344+00	\N	2	1	1	\N
18	Adults are able to provide food, clothing, and household supplies for the family.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:00.482+00	2022-02-21 16:48:00.482+00	\N	2	1	1	\N
19	Adults are able to pay rent and bills regularly.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:02.109+00	2022-02-21 16:48:02.109+00	\N	2	1	1	\N
20	The family is able to cope with emergency expenses.	The family is able to cope with emergency expenses such as loss of employment, pandemic situation, natural disaster, lean period, etc.	f	f	t	f	\N	\N	2022-02-21 16:48:04.978+00	2022-02-21 16:48:04.978+00	\N	2	1	1	\N
21	The family is claiming all benefits and schemes that they are entitled to, and accessing support from community NGOs as needed.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:06.335+00	2022-02-21 16:48:06.335+00	\N	2	1	1	\N
22	Living conditions are safe for the family.	Living conditions are safe for the family, including safe water and sanitation, absence of high crime and alcoholism/substance abuse in the community, or lack of community trauma such as pandemic, flood, extreme pollution, etc.  Parent/Caregiver meets the child’s immediate needs for supervision, food, clothing, medical care.	t	f	t	f	\N	\N	2022-02-21 16:48:07.665+00	2022-02-21 16:48:07.665+00	\N	3	1	1	\N
23	The familys housing is stable and secure, not at risk of loss or eviction.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:09.585+00	2022-02-21 16:48:09.585+00	\N	3	1	1	\N
24	The family has the basic amenities.	The family has the basic necessities of energy for cooking, heating, and lighting, proper food storage, and suitable refuse disposal.	f	f	t	f	\N	\N	2022-02-21 16:48:13.068+00	2022-02-21 16:48:13.068+00	\N	3	1	1	\N
25	The familys home is equipped/furnished similar to others in their community, according to cultural norms and standards.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:14.09+00	2022-02-21 16:48:14.09+00	\N	3	1	1	\N
26	All school age children attend school regularly.	\N	t	f	t	f	\N	\N	2022-02-21 16:48:15.115+00	2022-02-21 16:48:15.115+00	\N	4	1	1	\N
27	The children attend higher education or vocational training if desired.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:17.777+00	2023-07-26 05:57:04.873+00	\N	4	1	1	\N
28	The children have appropriate school supplies/educational toys, and access to resources for remote education as needed.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:18.801+00	2022-02-21 16:48:18.801+00	\N	4	1	1	\N
29	The children have transportation to school.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:19.927+00	2022-02-21 16:48:19.927+00	\N	4	1	1	\N
30	The children receive educational support as needed.	The children receive educational support as needed such as coaching teachers, and testing and support for learning issues.	f	f	t	f	\N	\N	2022-02-21 16:48:20.849+00	2022-02-21 16:48:20.849+00	\N	4	1	1	\N
31	The children are involved in extracurricular activities.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:23.584+00	2022-02-21 16:48:23.584+00	\N	4	1	1	\N
32	The family is not impacted by alcohol/substance abuse by a family member(s).	\N	t	f	t	f	\N	\N	2022-02-21 16:48:24.372+00	2022-02-21 16:48:24.372+00	\N	5	1	1	\N
33	Family members have access to healthcare for routine care and emergencies.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:25.975+00	2022-02-21 16:48:25.975+00	\N	5	1	1	\N
34	The family has the resources to address recent or chronic health issues.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:27.402+00	2022-02-21 16:48:27.402+00	\N	5	1	1	\N
35	The family has the resources to address significant dental or vision issues.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:30.373+00	2022-02-21 16:48:30.373+00	\N	5	1	1	\N
36	The family has support for dealing with depression, anxiety, or ADHD.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:31.806+00	2022-02-21 16:48:31.806+00	\N	5	1	1	\N
37	The family has support for dealing with psychosis, bipolar disorder, PTSD or other mental illness.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:33.274+00	2022-02-21 16:48:33.274+00	\N	5	1	1	\N
38	The family has access to medications/medical equipment.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:34.776+00	2022-02-21 16:48:34.776+00	\N	5	1	1	\N
39	The family has support for any diagnosed impairment, disability, or developmental delay.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:37.062+00	2022-02-21 16:48:37.062+00	\N	5	1	1	\N
40	The family practices proper hygiene and self-care.	The family practices proper hygiene and self-care including healthy eating, proper hydration, good sleep habits, exercise in the form of walks/physical activity, and adequate relaxation.	f	f	t	f	\N	\N	2022-02-21 16:48:38.463+00	2022-02-21 16:48:38.463+00	\N	5	1	1	\N
41	The family is able to address any nutritional deficiency, unhealthy weight loss, malnutrition, or anemia.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:39.555+00	2022-02-21 16:48:39.555+00	\N	5	1	1	\N
42	The family has regular access to nutritional food.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:41.535+00	2022-02-21 16:48:41.535+00	\N	5	1	1	\N
43	Everyone in the family is covered by health insurance.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:42.661+00	2022-02-21 16:48:42.661+00	\N	5	1	1	\N
44	The family has transportation for medical care/emergencies.	The family has access to a personal vehicle, reliable transportation from family member, neighbor, or friend, or public transportation appropriate to the medical urgency.	f	f	t	f	\N	\N	2022-02-21 16:48:43.788+00	2022-02-21 16:48:43.788+00	\N	5	1	1	\N
1	Physical or emotional abuse is occurring in the family.	A child or another family member is a victim of physical/emotional abuse, bullying, non-accidental injury, or domestic violence.	t	f	t	f	\N	\N	2023-07-20 06:01:38.824+00	2023-07-20 06:01:38.824+00	\N	1	1	1	\N
123	Adults in the home have steady, secure, safe employment that can support their financial needs.		t	f	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	2024-05-02 06:13:56.837+00	2024-05-02 06:13:56.837+00	6536ba55-07ba-4c0d-8c63-8891586345c7	2	1	1	\N
124	Adults in the home have steady, secure, safe employment that can support their financial needs.		t	f	t	f	78c7a329-36a7-45d6-9ad8-4efec6d3136d	\N	2024-05-15 20:33:18.864+00	2024-05-15 20:33:18.864+00	733783e7-fcf9-42d5-849c-33aff0f01d35	2	1	1	\N
125	This is Katie testing the customization feature in family and social relationships	Does it work?	f	f	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	\N	2024-05-20 13:59:11.169+00	2024-05-20 13:59:11.169+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
126	Physical or emotional abuse is occurring in the family.	A child or another family member is a victim of physical/emotional abuse, bullying, non-accidental injury, or domestic violence.	t	f	t	f	\N	\N	2023-07-20 06:01:38.824+00	2023-07-20 06:01:38.824+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
127	Sexual abuse is occuring in the family.	A child or another family member is a victim of inappropriate touching, molestation, forced viewing of pornography, child grooming, cyber molestation.	t	f	t	f	\N	\N	2022-02-21 16:47:39.171+00	2023-07-20 06:01:38.824+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
128	The child is a victim or at risk of child marriage.	\N	t	f	t	f	\N	\N	2022-02-21 16:47:40.911+00	2022-02-21 16:47:40.911+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
129	The family has strong relationships with their extended family.	The family receives support such as emotional, financial, childcare, etc from extended family.	f	f	t	f	\N	\N	2022-02-21 16:47:42.944+00	2022-02-21 16:47:42.944+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
130	The family has a strong support network with their neighbors and community.	The family has neighbors and community that they can turn to when they need help.	f	f	t	f	\N	\N	2022-02-21 16:47:44.19+00	2022-02-21 16:47:44.19+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
131	Parents/caregivers have the skills needed to guide and support their children.	\N	f	f	t	f	\N	\N	2022-02-21 16:47:45.418+00	2022-02-21 16:47:45.418+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
132	Parents/caregivers are capable of providing care to children requiring extra support (e.g. teens, infants, behavioral/emotional/physical issues).	\N	f	f	t	f	\N	\N	2022-02-21 16:47:47.242+00	2022-02-21 16:47:47.242+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
133	Parents/caregivers have the energy, knowledge, and resources to care for their children (e.g. primary caregivers are not under 21 years of age or elderly).	\N	f	f	t	f	\N	\N	2022-02-21 16:47:48.32+00	2022-02-21 16:47:48.32+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
134	The family is aware of child protection risks, signs, and reporting procedures.	\N	t	f	t	f	\N	\N	2022-02-21 16:47:49.342+00	2023-07-23 09:44:08.305+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
135	Parents are supportive of their childrens rights.	Parents/caregivers treat their children with respect, and recognize their right to privacy, equal opportunity regardless of gender, and to participate in decisions that affect them.	f	f	t	f	\N	\N	2022-02-21 16:47:50.164+00	2022-02-21 16:47:50.164+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
136	Foster Care only: The child has contact with their birth family.	\N	f	t	t	f	\N	\N	2022-02-21 16:47:50.985+00	2022-02-21 16:47:50.985+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
137	Parents/caregivers have a positive relationship with each other.	Parents/caregivers love, support, respect, trust, and care for each other, and communicate openly and honestly.	f	f	t	f	\N	\N	2022-02-21 16:47:51.767+00	2022-02-21 16:47:51.767+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
138	This is Katie testing the customization feature in family and social relationships	Does it work?	f	f	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	\N	2024-05-20 13:59:11.169+00	2024-05-20 13:59:11.169+00	733783e7-fcf9-42d5-849c-33aff0f01d35	1	1	1	\N
139	Adults in the home have steady, secure, safe employment that can support their financial needs.	\N	t	f	t	f	\N	\N	2022-02-21 16:47:53.814+00	2022-02-21 16:47:53.814+00	733783e7-fcf9-42d5-849c-33aff0f01d35	2	1	1	\N
140	The adult(s) have education/skills for employment that can financially support the family.	\N	f	f	t	f	\N	\N	2022-02-21 16:47:55.229+00	2022-02-21 16:47:55.229+00	733783e7-fcf9-42d5-849c-33aff0f01d35	2	1	1	\N
141	The adults are able to purchase supplies/tools for their jobs.	\N	f	f	t	f	\N	\N	2022-02-21 16:47:57.121+00	2022-02-21 16:47:57.121+00	733783e7-fcf9-42d5-849c-33aff0f01d35	2	1	1	\N
142	Adults have access to transportation for their job(s).	\N	f	f	t	f	\N	\N	2022-02-21 16:47:58.424+00	2022-02-21 16:47:58.424+00	733783e7-fcf9-42d5-849c-33aff0f01d35	2	1	1	\N
143	The family has childcare during working hours.	\N	f	f	t	f	\N	\N	2022-02-21 16:47:59.344+00	2022-02-21 16:47:59.344+00	733783e7-fcf9-42d5-849c-33aff0f01d35	2	1	1	\N
144	Adults are able to provide food, clothing, and household supplies for the family.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:00.482+00	2022-02-21 16:48:00.482+00	733783e7-fcf9-42d5-849c-33aff0f01d35	2	1	1	\N
145	Adults are able to pay rent and bills regularly.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:02.109+00	2022-02-21 16:48:02.109+00	733783e7-fcf9-42d5-849c-33aff0f01d35	2	1	1	\N
146	The family is able to cope with emergency expenses.	The family is able to cope with emergency expenses such as loss of employment, pandemic situation, natural disaster, lean period, etc.	f	f	t	f	\N	\N	2022-02-21 16:48:04.978+00	2022-02-21 16:48:04.978+00	733783e7-fcf9-42d5-849c-33aff0f01d35	2	1	1	\N
147	The family is claiming all benefits and schemes that they are entitled to, and accessing support from community NGOs as needed.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:06.335+00	2022-02-21 16:48:06.335+00	733783e7-fcf9-42d5-849c-33aff0f01d35	2	1	1	\N
148	Living conditions are safe for the family.	Living conditions are safe for the family, including safe water and sanitation, absence of high crime and alcoholism/substance abuse in the community, or lack of community trauma such as pandemic, flood, extreme pollution, etc.  Parent/Caregiver meets the child’s immediate needs for supervision, food, clothing, medical care.	t	f	t	f	\N	\N	2022-02-21 16:48:07.665+00	2022-02-21 16:48:07.665+00	733783e7-fcf9-42d5-849c-33aff0f01d35	3	1	1	\N
149	The familys housing is stable and secure, not at risk of loss or eviction.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:09.585+00	2022-02-21 16:48:09.585+00	733783e7-fcf9-42d5-849c-33aff0f01d35	3	1	1	\N
150	The family has the basic amenities.	The family has the basic necessities of energy for cooking, heating, and lighting, proper food storage, and suitable refuse disposal.	f	f	t	f	\N	\N	2022-02-21 16:48:13.068+00	2022-02-21 16:48:13.068+00	733783e7-fcf9-42d5-849c-33aff0f01d35	3	1	1	\N
151	The familys home is equipped/furnished similar to others in their community, according to cultural norms and standards.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:14.09+00	2022-02-21 16:48:14.09+00	733783e7-fcf9-42d5-849c-33aff0f01d35	3	1	1	\N
152	All school age children attend school regularly.	\N	t	f	t	f	\N	\N	2022-02-21 16:48:15.115+00	2022-02-21 16:48:15.115+00	733783e7-fcf9-42d5-849c-33aff0f01d35	4	1	1	\N
153	The children attend higher education or vocational training if desired.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:17.777+00	2023-07-26 05:57:04.873+00	733783e7-fcf9-42d5-849c-33aff0f01d35	4	1	1	\N
154	The children have appropriate school supplies/educational toys, and access to resources for remote education as needed.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:18.801+00	2022-02-21 16:48:18.801+00	733783e7-fcf9-42d5-849c-33aff0f01d35	4	1	1	\N
155	The children have transportation to school.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:19.927+00	2022-02-21 16:48:19.927+00	733783e7-fcf9-42d5-849c-33aff0f01d35	4	1	1	\N
156	The children receive educational support as needed.	The children receive educational support as needed such as coaching teachers, and testing and support for learning issues.	f	f	t	f	\N	\N	2022-02-21 16:48:20.849+00	2022-02-21 16:48:20.849+00	733783e7-fcf9-42d5-849c-33aff0f01d35	4	1	1	\N
157	The children are involved in extracurricular activities.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:23.584+00	2022-02-21 16:48:23.584+00	733783e7-fcf9-42d5-849c-33aff0f01d35	4	1	1	\N
158	The family is not impacted by alcohol/substance abuse by a family member(s).	\N	t	f	t	f	\N	\N	2022-02-21 16:48:24.372+00	2022-02-21 16:48:24.372+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
159	Family members have access to healthcare for routine care and emergencies.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:25.975+00	2022-02-21 16:48:25.975+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
160	The family has the resources to address recent or chronic health issues.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:27.402+00	2022-02-21 16:48:27.402+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
161	The family has the resources to address significant dental or vision issues.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:30.373+00	2022-02-21 16:48:30.373+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
162	The family has support for dealing with depression, anxiety, or ADHD.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:31.806+00	2022-02-21 16:48:31.806+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
163	The family has support for dealing with psychosis, bipolar disorder, PTSD or other mental illness.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:33.274+00	2022-02-21 16:48:33.274+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
164	The family has access to medications/medical equipment.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:34.776+00	2022-02-21 16:48:34.776+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
165	The family has support for any diagnosed impairment, disability, or developmental delay.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:37.062+00	2022-02-21 16:48:37.062+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
166	The family practices proper hygiene and self-care.	The family practices proper hygiene and self-care including healthy eating, proper hydration, good sleep habits, exercise in the form of walks/physical activity, and adequate relaxation.	f	f	t	f	\N	\N	2022-02-21 16:48:38.463+00	2022-02-21 16:48:38.463+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
167	The family is able to address any nutritional deficiency, unhealthy weight loss, malnutrition, or anemia.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:39.555+00	2022-02-21 16:48:39.555+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
168	The family has regular access to nutritional food.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:41.535+00	2022-02-21 16:48:41.535+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
169	Everyone in the family is covered by health insurance.	\N	f	f	t	f	\N	\N	2022-02-21 16:48:42.661+00	2022-02-21 16:48:42.661+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
170	The family has transportation for medical care/emergencies.	The family has access to a personal vehicle, reliable transportation from family member, neighbor, or friend, or public transportation appropriate to the medical urgency.	f	f	t	f	\N	\N	2022-02-21 16:48:43.788+00	2022-02-21 16:48:43.788+00	733783e7-fcf9-42d5-849c-33aff0f01d35	5	1	1	\N
\.


--
-- Data for Name: HT_qusnDomainLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_qusnDomainLangMaps" (id, "domainName", description, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTQuestionDomainId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_recurringEvents; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_recurringEvents" (id, "startDate", "endDate", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: HT_responses; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_responses" (id, "textResponse", "otherResponse", "isInterResp", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTAssessmentId", "HTQuestionId", "HTChoiceId") FROM stdin;
1150			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	126	3
1151			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	127	3
1152			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	128	2
1153			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	128	1136
1154			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	128	1135
1155			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	134	3
1156			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	129	2
1157			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	129	1140
1158			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	130	3
1159			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	131	3
1160			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	132	3
1161			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	133	3
1162			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	135	3
1163			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	137	3
1164			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	138	1
1165			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	138	1165
905			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	7	3
906	Xxx		f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	8	2
907	Xxx		t	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	8	668
908			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	10	3
909			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	12	3
910			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	13	3
911			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	14	3
912			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	15	3
913			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	16	3
914			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	17	3
915			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	18	3
916			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	19	3
917			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	20	3
918			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	21	3
919			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	22	3
920			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	23	3
921	Xxx		f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	24	2
922	Xxx		t	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	24	724
923			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	25	3
924	Xxx		f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	26	2
925	Xxx		t	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	26	730
926			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	27	3
927			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	28	3
928			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	29	3
929			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	30	3
930			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	31	3
931			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	32	3
932			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	33	3
933			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	34	3
934			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	35	3
935			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	36	3
936			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	37	3
937			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	38	3
938			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	39	3
939			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	40	3
940			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	41	3
941			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	42	3
942			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	43	3
943			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	44	3
947			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-08 10:53:42.742+00	2024-05-08 10:53:42.742+00	37	45	3
948			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-08 10:53:42.742+00	2024-05-08 10:53:42.742+00	37	46	3
949			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-08 10:53:42.742+00	2024-05-08 10:53:42.742+00	37	47	3
1166	stuff		t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	139	1166
1167	stuff		f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	139	1
1168			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	140	3
1169			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	141	3
1170			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	142	3
1171			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	143	3
965			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	45	3
966			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	46	3
967			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	47	3
968			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	48	3
969			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	49	3
970			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	50	3
971			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	51	3
972			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	52	3
973			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	53	3
974			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	54	3
975			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	55	3
730			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	5	2
731			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	6	2
1172			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	144	3
1173			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	145	1190
1174			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	145	1
1175			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	146	1195
1176			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	146	2
1177	extra stuff	more stuff	t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	147	1201
1178	extra stuff	more stuff	f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	147	2
1179			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	148	3
1180			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	149	4
1181			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	150	3
1182			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	151	3
1183			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	152	3
1184			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	153	2
1185			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	153	1225
1186			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	154	3
1187			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	155	3
1188			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	156	3
1189			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	157	3
1190			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	158	3
1191			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	159	3
1192			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	160	3
1193			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	161	2
1194			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	161	1253
1195			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	162	3
1196			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	163	3
1197			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	164	3
1198			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	165	3
726			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	2	3
727			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	3	3
728			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	9	3
729			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	4	3
732			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	7	3
733			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	8	3
734			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	10	3
735			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	12	3
736			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	13	3
737			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	14	3
738			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	15	3
739			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	16	3
740			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	17	3
741			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	18	3
742			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	19	3
743			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	20	3
744			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	21	3
745			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	22	3
746			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	23	3
747			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	24	3
748			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	25	3
749			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	26	3
1199			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	166	3
1200			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	167	4
976			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	56	3
977			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	57	3
978			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	58	3
979			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:06:38.842+00	2024-05-13 09:06:38.842+00	36	59	3
992	Ensure		f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	45	1
993	Ensure		t	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	45	804
994			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	46	3
995			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	47	3
996			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	48	3
997			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	49	3
998			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	50	3
999			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	51	3
1000			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	52	3
1001			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	53	3
1002			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	54	3
1003			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	55	3
1004			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	56	3
1005			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	57	3
1006			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	58	3
1007			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-13 09:09:49.03+00	2024-05-13 09:09:49.03+00	39	59	3
750			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	27	3
751			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	28	3
752			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	29	3
753			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	30	3
754			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	31	3
755			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	32	3
756			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	33	3
757			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	34	3
758			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	35	3
759			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	36	3
760			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	37	3
761			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	38	3
762			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	39	3
763			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	40	3
764			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	41	3
765			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	42	3
766			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	43	3
767			f	t	f	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	2024-04-19 09:49:09.424+00	2024-04-19 09:49:09.424+00	31	44	3
1201			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	168	3
1202			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	169	3
1203			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-21 19:46:25.741+00	2024-05-21 19:46:25.741+00	40	170	3
1245	Report to authorities 		f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	45	1
810	Xxx		f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	2	2
811	Xxx		t	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	2	793
812			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	3	3
813			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	9	3
814			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	4	3
815			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	5	3
816			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	6	3
817			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	7	3
818			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	8	3
819			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	10	3
820			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	12	3
821			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	13	3
822	Xx		f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	14	2
823	Xx		t	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	14	681
824			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	15	3
825			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	16	3
826	Xx		f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	17	2
827	Xx		t	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	17	693
828			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	18	3
829			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	19	3
830			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	20	3
831			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	21	3
832	Cxx		f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	22	2
833	Cxx		t	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	22	713
834			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	23	3
835			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	24	3
836			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	25	3
837			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	26	3
838			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	27	3
839			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	28	3
840			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	29	3
841			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	30	3
842			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	31	3
843			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	32	3
844			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	33	3
845			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	34	3
846			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	35	3
847			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	36	4
848			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	37	3
849			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	38	3
850			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	39	4
851			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	40	3
852			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	41	3
853			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	42	3
854			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	43	3
855			f	t	f	0fd8f742-ff93-40ec-bc73-1afe6db61479	\N	2024-04-22 09:59:27.363+00	2024-04-22 09:59:27.363+00	30	44	3
898	Aaa		f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	2	2
899	Aaa		t	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	2	793
900			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	3	3
901			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	9	3
902			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	4	3
903			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	5	3
904			f	t	f	d233665e-6b54-479f-a735-14f3747e4f51	\N	2024-04-29 11:48:28.678+00	2024-04-29 11:48:28.678+00	34	6	3
1246	Report to authorities 		t	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	45	802
1247			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	46	3
1248			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	47	3
1249	Refer for support		f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	48	1
1250	Refer for support		t	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	48	815
1251			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	49	3
1252			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	50	3
1253	Discuss safety measures		f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	51	2
1254	Discuss safety measures		t	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	51	830
1255			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	52	3
1256			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	53	3
1573			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	126	3
1574			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	127	3
1575			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	128	2
1576			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	128	1135
1577			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	128	1136
1578			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	134	3
1579			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	129	2
1580			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	129	1140
1257	Explore educational facilities 		f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	54	2
1258	Explore educational facilities 		t	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	54	844
1259			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	55	3
1260			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	56	3
1261	Refer abuser for treatment		f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	57	2
1262	Refer abuser for treatment		t	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	57	856
1263			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	58	3
1264			f	t	f	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	2024-05-22 12:54:19.768+00	2024-05-22 12:54:19.768+00	42	59	3
1581			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	130	3
1582			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	131	3
1583			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	132	3
1584			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	133	3
1585			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	135	3
1586			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	137	3
1587			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	138	1
1588			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	138	1165
1589	stuff		f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	139	1
1590	stuff		t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	139	1166
1591			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	140	3
1592			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	141	3
1593			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	142	3
1594			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	143	3
1595			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	144	3
1596			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	145	1
1597			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	145	1190
1598			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	146	2
1599			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	146	1195
1600	extra stuff	more stuff	f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	147	2
1601	extra stuff	more stuff	t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	147	1201
1602			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	148	3
1603			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	149	4
1604			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	150	3
1605			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	151	3
1606			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	152	3
1607			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	153	2
1608			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	153	1225
1609			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	154	3
1610			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	155	3
1611			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	156	3
1612			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	157	3
1613			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	158	3
1614			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	159	3
1615			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	160	3
1616			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	161	2
1617			t	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	161	1253
1618			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	162	3
1619			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	163	3
1620			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	164	3
1621			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	165	3
1622			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	166	3
1623			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	167	4
1624			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	168	3
1625			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	169	3
1626			f	t	f	5f8e4c5a-738e-497d-8957-9f226e1e42b0	\N	2024-05-23 06:18:14.261+00	2024-05-23 06:18:14.261+00	43	170	3
1521			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	1	3
1522			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	2	4
1523			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	3	4
1524			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	9	3
1525			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	4	3
1526			t	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	5	658
1527			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	5	2
1528			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	6	3
1529			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	7	3
1530			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	8	3
1531			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	10	3
1532			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	12	3
1533			t	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	13	678
1534			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	13	2
1535			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	14	3
1536			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	15	3
1537			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	16	3
1538			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	17	3
1539			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	18	2
1540			t	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	18	696
1541			t	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	18	698
1542			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	19	2
1543			t	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	19	704
1544			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	20	2
1545			t	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	20	708
1546			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	21	2
1547			t	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	21	711
1548			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	22	3
1549			t	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	23	722
1550			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	23	2
1551			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	24	3
1552			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	25	3
1553			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	26	4
1554			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	27	4
1555			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	28	4
1556			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	29	3
1557			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	30	4
1558			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	31	3
1559			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	32	3
1560			t	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	33	755
1561			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	33	2
1562			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	34	3
1563			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	35	3
1564			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	36	3
1565			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	37	3
1566			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	38	3
1567			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	39	3
1568			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	40	3
1569			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	41	3
1570			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	42	3
1571			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	43	3
1572			f	t	f	1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	\N	2024-05-22 21:25:07.116+00	2024-05-22 21:25:07.116+00	45	44	3
\.


--
-- Data for Name: HT_stateLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_stateLangMaps" (id, "stateName", "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTStateId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_states; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_states" (id, "stateName", "stateCode", "isActive", "isDeleted", "createdAt", "updatedAt", "HTCountryId", "stateNameLang") FROM stdin;
1	Andaman & Nicobar	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Andaman & Nicobar", "2": "अंडमान और निकोबार", "3": "அந்தமான் & நிக்கோபார்"}
2	Andhra Pradesh	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Andhra Pradesh", "2": "आंध्र प्रदेश", "3": "ஆந்திரப் பிரதேசம்"}
3	Arunachal Pradesh	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Arunachal Pradesh", "2": "अरुणाचल प्रदेश", "3": "அருணாசலப் பிரதேசம்"}
4	Assam	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Assam", "2": "आसाम", "3": "அசாம்"}
5	Bihar	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Bihar", "2": "बिहार", "3": "பீகார்"}
6	Chandigarh	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Chandigarh", "2": "चंडीगढ़", "3": "சண்டிகர்"}
7	Chhattisgarh	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Chhattisgarh", "2": "छत्तीसगढ़", "3": "சட்டீஸ்கர்"}
8	Dadra & Nagar Haveli	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Dadra & Nagar Haveli", "2": "दादरा और नगर हवेली", "3": "டாட்ரா & நகர் ஹவேலி"}
9	Daman & Diu	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Daman & Diu", "2": "दमन और दीव", "3": "டாமன் & டியூ"}
10	Delhi	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Delhi", "2": "दिल्ली", "3": "தில்லி"}
11	Goa	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Goa", "2": "गोवा", "3": "கோவா"}
12	Gujarat	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Gujarat", "2": "गुजरात", "3": "குஜராத்"}
13	Haryana	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Haryana", "2": "हरियाणा", "3": "ஹரியானா"}
14	Himachal Pradesh	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Himachal Pradesh", "2": "हिमाचल प्रदेश", "3": "ஹிமாச்சல் பிரதேசம்"}
15	Jammu & Kashmir	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Jammu & Kashmir", "2": "जम्मू और कश्मीर", "3": "ஜம்மு & காஷ்மீர்"}
16	Jharkhand	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Jharkhand", "2": "झारखंड", "3": "ஜார்கண்ட்"}
17	Karnataka	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Karnataka", "2": "कर्नाटक", "3": "கர்நாடகா"}
18	Kerala	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Kerala", "2": "केरल", "3": "கேரளா"}
19	Lakshadweep	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Lakshadweep", "2": "लक्षद्वीप", "3": "லக்ஷத்வீப்"}
20	Madhya Pradesh	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Madhya Pradesh", "2": "मध्य प्रदेश", "3": "மத்திய பிரதேசம்"}
21	Maharashtra	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Maharashtra", "2": "महाराष्ट्र", "3": "மஹாராஷ்டிரா"}
22	Manipur	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Manipur", "2": "मणिपुर", "3": "மணிப்பூர்"}
23	Meghalaya	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Meghalaya", "2": "मेघालय", "3": "மெகாலயா"}
24	Mizoram	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Mizoram", "2": "मिज़ोरम", "3": "மிசோரம்"}
25	Nagaland	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Nagaland", "2": "नागालैंड", "3": "நாகாலாந்து"}
26	Orissa	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Orissa", "2": "उड़ीसा", "3": "ஒரிசா"}
27	Pondicherry	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Pondicherry", "2": "पुडुचेरी", "3": "புதுச்சேரி"}
28	Punjab	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Punjab", "2": "पंजाब", "3": "பஞ்சாப்"}
29	Rajasthan	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Rajasthan", "2": "राजस्थान", "3": "ராஜஸ்தான்"}
30	Sikkim	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Sikkim", "2": "सिक्किम", "3": "சிக்கிம்"}
31	Tamil Nadu	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Tamil Nadu", "2": "तमिलनाडु", "3": "தமிழ்நாடு"}
32	Tripura	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Tripura", "2": "त्रिपुरा", "3": "திரிபுரா"}
33	Uttar Pradesh	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Uttar Pradesh", "2": "उत्तर प्रदेश", "3": "உத்தரப்பிரதேசம்"}
34	Uttaranchal	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Uttaranchal", "2": "उत्तरांचल", "3": "உத்திராஞ்சல்"}
35	West Bengal	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "West Bengal", "2": "पश्चिम बंगाल", "3": "மேற்கு பங்காளம்"}
36	Telengana	\N	t	f	2021-10-27 11:17:25.289+00	2021-10-27 11:17:25.289+00	1	{"1": "Telengana", "2": "तेलंगाना", "3": "தெலங்கானா"}
37	Texas	dss	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	2	{"1": "Texas", "2": "टेक्सास", "3": "டெக்சாஸ்"}
38	Uganda Region 1	dss	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	3	{"1": "Uganda Region 1", "2": "युगांडा क्षेत्र 1", "3": "உகாண்டா பகுதி 1"}
39	Washington	dss	t	f	2024-01-16 07:01:42+00	2024-01-16 07:01:42+00	2	{"1": "Washington", "2": "वाशिंगटन", "3": "வாஷிங்டன்"}
\.


--
-- Data for Name: HT_userLogs; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_userLogs" (id, entity, action, parameters, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTUserId") FROM stdin;
\.


--
-- Data for Name: HT_userRoleLangMaps; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_userRoleLangMaps" (id, role, "isActive", "isDeleted", "createdBy", "updatedBy", "createdAt", "updatedAt", "HTUserRoleId", "HTLanguageId") FROM stdin;
\.


--
-- Data for Name: HT_userRoles; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_userRoles" (id, role, description, "cognitoValue", "isActive", "isDeleted", "createdAt", "updatedAt", "roleLang", "descriptionLang") FROM stdin;
1	Super Admin	Add/edit/view users in this organization Can view children assigned to Social Workers Can view assessments and reports No access to mobile application	superadmin	t	f	2024-01-10 09:34:22+00	2024-01-10 09:34:22+00	\N	\N
2	Admin	Add/edit/view users in this organization Can view children assigned to Social Workers Can view assessments and reports No access to mobile application	admin	t	f	2024-01-10 09:34:22+00	2024-01-10 09:34:22+00	\N	\N
3	Admin+Case Manager	Same as admin, but can have children assigned Has access to mobile application	admin+casemanager	t	f	2024-01-10 09:34:22+00	2024-01-10 09:34:22+00	\N	\N
4	Admin+Social Worker	Same as admin, but can have children assigned Has access to mobile application	admin+caseworker	t	f	2024-01-10 09:34:22+00	2024-01-10 09:34:22+00	\N	\N
5	Social Worker	Only has access to assigned children	caseworker	t	f	2024-01-10 09:34:22+00	2024-01-10 09:34:22+00	\N	\N
6	Case Manager	Only has access to assigned children	casemanager	t	f	2024-01-10 09:34:22+00	2024-01-10 09:34:22+00	\N	\N
7	View Only	Can view account/user information View only permissions to child data	viewonly	t	f	2024-01-10 09:34:22+00	2024-01-10 09:34:22+00	\N	\N
8	Parent	Have Access to mobile application only	parent	t	f	2024-01-10 09:34:22+00	2024-01-10 09:34:22+00	\N	\N
9	Unassigned	User does not have access	unassigned	t	f	2024-01-10 09:34:22+00	2024-01-10 09:34:22+00	\N	\N
\.


--
-- Data for Name: HT_users; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public."HT_users" (id, "cognitoId", "oldCognitoId", "firstName", "lastName", "phoneNumber", email, "addressLine1", "addressLine2", city, "zipCode", "isActive", "isDeleted", "createdBy", "updatedBy", "injectiondocId", "dbRegion", "HTUserRoleId", "createdAt", "updatedAt", "HTCountryId", "HTStateId", "HTDistrictId", "HTAccountId", "HTLanguageId", occupation, "parentUserId", "userCode", "userTimezone", "caseManagerId", image, "fileStatus", "deactivationReason", "isAccountActive") FROM stdin;
27c1c439-5e4b-45a4-88f0-a46cebfdbeeb	\N	\N	Karasseril pending	Family	+12255987654	shagil.k1712211758909@mailinator.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	\N	75f234ab-edd7-4a1a-bf9a-2decac943a19	\N	usa	\N	2024-04-04 06:22:43.936+00	2024-04-15 04:30:47.841+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	312	\N	f191b1cc-f282-4080-8c60-3f757aacca6d	\N	None	\N	t
76c706f5-671e-4a39-b1aa-f57a2544bb02	\N	\N	Jack CM	Sparrow	+19497288333	parent.jacksparrow@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	\N	usa	\N	2024-05-13 10:01:49.497+00	2024-05-13 10:01:49.497+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	Pirate	\N	420	\N	46e42a63-ded5-486b-9203-d5e523f745fb	\N	None	\N	t
d4162595-3d89-4a0a-8b83-92da80fcef4a	b98b55ca-c76e-408a-a5a1-f31eb8e2a83d	\N	Lilly	Potter	+19497288333	parent.lilly@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	\N	usa	\N	2024-05-13 06:14:15.454+00	2024-05-13 06:15:30.488+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	Wizard	d07d65bd-6f8c-456f-8ebd-06fb11e48a3a	419	\N	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	None	\N	t
5f512203-57cd-49d9-91fb-8d1c98670f78	\N	\N	Akhil	Varma	+919899889878	akhil@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	\N	\N	\N	usa	\N	2024-04-04 05:44:02.742+00	2024-04-04 05:44:02.742+00	2	\N	\N	1cec9f20-62dd-4cd1-b91b-951d851ab25b	\N	Enginerr	f569b1ab-bb21-4ff2-b2d6-f16711100f34	310	\N	8d074998-fcad-4863-9429-d7318933b5e3	\N	None	\N	\N
f569b1ab-bb21-4ff2-b2d6-f16711100f34	ceb8e3ca-3e24-49f6-ac56-13342fec9221	\N	Arun	Varma	+919877887876	aruncaregiver@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	\N	\N	\N	usa	\N	2024-04-04 05:44:02.732+00	2024-04-04 05:45:51.35+00	2	\N	\N	1cec9f20-62dd-4cd1-b91b-951d851ab25b	\N	Manager	\N	309	\N	8d074998-fcad-4863-9429-d7318933b5e3	\N	None	\N	\N
95be6d97-d216-4320-a292-2a06700480a4	f53f4ebd-b3fd-4af3-ad81-949051a6ec0d	\N	Tom Hardy	FSTS USA	+19497288333	parent.tomhardy@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	usa	\N	2024-04-05 08:41:31.942+00	2024-04-05 08:44:17.012+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	Engineer	\N	318	\N	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	None	\N	\N
d4cb2947-b73d-4969-86fb-1942ac8d736d	67a7e745-a3da-4425-b452-3221647a6bc6	\N	Lucy	Lu	+15123255555	lucy_lu_fs_admin@yopmail.com	TBD		Austin	78735	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	9	2024-04-05 20:28:27.679+00	2024-04-05 20:29:34.958+00	2	37	\N	359fdbcb-8f7b-4279-99c5-9c2b094114af	\N	\N	\N	323	\N	\N	\N	None	\N	\N
8d074998-fcad-4863-9429-d7318933b5e3	6a621300-1bdf-44b7-a5af-435f27f1d138	\N	Fostershare	Admin	+919877667678	fsadmin@yopmail.com	ABC TXS		TXS COUNTY	89878	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	5	2024-04-04 05:33:02.192+00	2024-04-04 09:50:53.55+00	2	37	\N	1cec9f20-62dd-4cd1-b91b-951d851ab25b	\N	\N	\N	308	\N	\N	\N	None	\N	\N
16b0c8aa-e199-49b4-afd3-0cd79f3063d0	\N	\N	UAT Admin FSTS	USA	+19497288333	admin.uat.usa@yopmail.com	AD01 Halem		Washington DC	12345	f	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	2	2024-04-05 06:07:44.116+00	2024-04-05 06:07:44.116+00	2	39	\N	0d7b5e4a-9c81-4811-b010-bbef1ff42e28	\N	\N	\N	315	\N	\N	\N	None	\N	\N
0d59b8f7-807c-4ed8-9620-69ca71ae5b34	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	Admin QA RBAC REG Phase1	USA	+19497288333	admin.rbac.usa@yopmail.com	AD01 Texas		TXAS County	12345	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	2	2024-04-05 08:14:45.352+00	2024-04-05 08:17:18.368+00	2	37	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	\N	\N	316	\N	\N	\N	None	\N	\N
571b5222-d59e-4640-bc6d-558e1122591a	bd33877e-40d9-4684-8395-54c4cc2dd4f2	\N	Camren	Diaz	+15124445858	camren_diaz_fs_cmadmin@yopmail.com	TBD		Austin	78735	t	f	67a7e745-a3da-4425-b452-3221647a6bc6	67a7e745-a3da-4425-b452-3221647a6bc6	\N	usa	9	2024-04-05 20:32:52.744+00	2024-04-05 20:37:35.043+00	2	37	\N	359fdbcb-8f7b-4279-99c5-9c2b094114af	\N	\N	\N	324	\N	\N	\N	None	\N	\N
46e42a63-ded5-486b-9203-d5e523f745fb	d99c57eb-2de4-440c-a0d9-244e0b34e04d	\N	Case WorkManager QA RBAC REG Phase1	USA	+19497288333	caseworker.rbac.usa@yopmail.com	AD01 Wash DC		Washington DC	12345	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	usa	5	2024-04-05 09:07:44.336+00	2024-04-05 10:38:11.194+00	2	39	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	\N	\N	320	\N	\N	\N	None	\N	\N
3e451f32-f2f3-47e7-93c7-08d54fa39622	\N	\N	Drew	Barrymore	+15125464564	drew_barrymore_fs_cm@yopmail.com	TBD		Austin	78735	f	f	bd33877e-40d9-4684-8395-54c4cc2dd4f2	bd33877e-40d9-4684-8395-54c4cc2dd4f2	\N	usa	9	2024-04-05 20:39:16.399+00	2024-04-05 20:39:16.399+00	2	37	\N	359fdbcb-8f7b-4279-99c5-9c2b094114af	\N	\N	\N	325	\N	\N	\N	None	\N	\N
ea69e109-110d-41dc-96fc-eea82bc0aa04	\N	\N	Honeybee	Cole	+256391111111	honeybee_cole_fs@yopmail.com	TBD		Austin	78735	f	f	bd33877e-40d9-4684-8395-54c4cc2dd4f2	bd33877e-40d9-4684-8395-54c4cc2dd4f2	\N	uganda	9	2024-04-05 20:43:01.286+00	2024-04-05 20:43:01.286+00	3	38	\N	359fdbcb-8f7b-4279-99c5-9c2b094114af	\N	\N	\N	326	\N	\N	\N	None	\N	\N
259d0864-8e00-4007-b819-63b64141a3d7	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	Kate	Cole	+12812364888	katie@miraclefoundation.org	1506 w 6th		Austin	78735	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	1	2024-04-05 18:21:41.142+00	2024-04-05 18:23:13.303+00	2	37	\N	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	\N	\N	322	\N	\N	\N	None	\N	\N
b6103226-f97c-4b11-9885-b0e4bb4323d9	b72b662c-a76e-4702-8aff-960313193846	\N	Katie	Cole	+12812364879	kcole@miraclefoundation.org	1506 w 6th		Austin	78735	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	9	2024-04-05 18:08:57.255+00	2024-04-05 18:10:42.311+00	2	37	\N	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	\N	\N	321	\N	\N	\N	None	\N	\N
f191b1cc-f282-4080-8c60-3f757aacca6d	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	Shagil	Krishna	+12255987989	shagil.k@inapp.com	Address 1		Texas	65432	t	f	\N	\N	\N	usa	4	2024-04-04 06:08:27.842+00	2024-04-08 04:05:57.668+00	2	37	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N	\N	\N	311	\N	\N	\N	None	\N	\N
c9326236-e7a4-47c8-8788-444247e7d23a	75f234ab-edd7-4a1a-bf9a-2decac943a19	\N	Shagil	Admin	+12255654654	Shagil.admn3511@mailinator.com	Address 1		Texas	32165	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	2	2024-04-09 05:42:09.874+00	2024-04-09 06:08:16.914+00	2	37	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N	\N	\N	330	\N	\N	\N	None	\N	\N
962ff0b6-5316-4119-8184-41c12dd1f272	\N	\N	Case Worker TS Uganda	Pending Deact Test	+256412345678	cw.deact.pcci.uganda@yopmail.com	AD01 Kampala Street		Kampala	12345	f	f	f09a62ed-11bc-424b-9497-9e447f96b856	f09a62ed-11bc-424b-9497-9e447f96b856	\N	uganda	5	2024-04-09 08:20:46.766+00	2024-04-09 08:20:46.766+00	3	38	\N	0cf24e7b-6487-4288-8847-d336668da62e	\N	\N	\N	332	\N	\N	\N	None	\N	\N
d68ac785-7860-4e59-8c17-4c368affb855	f09a62ed-11bc-424b-9497-9e447f96b856	\N	TS Admin Case Worker	RBAC Uganda Only	+256412345678	admincw.pcci.uganda@yopmail.com	AD01 Uganda Street		Uganda City	12345	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	uganda	4	2024-04-09 08:16:13.051+00	2024-04-09 08:18:08.225+00	3	38	\N	0cf24e7b-6487-4288-8847-d336668da62e	\N	\N	\N	331	\N	\N	\N	None	\N	\N
4e92afc8-97e4-4b50-ad05-0d3ef49fe7c3	3c0de899-7b21-4077-a2ce-019d1bc48222	\N	Jane Foster	FSTS USA	+19497288333	parent.janefoster@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	usa	\N	2024-04-05 08:47:29.293+00	2024-04-11 11:00:54.826+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	Fire and Rescue	\N	319	\N	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	None	\N	\N
5faf77fe-ac2e-4afa-92f4-e35dd5ea4cc4	\N	\N	test pending	fam	+12255654565	Email@Email .com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	2b73eaab-3911-442b-a0b8-a8fceeb50781	75f234ab-edd7-4a1a-bf9a-2decac943a19	\N	usa	\N	2024-04-08 06:38:28.938+00	2024-04-12 06:55:05.999+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	328	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
75579cd6-8fbd-4c3b-9c8b-9faf5b475018	2b73eaab-3911-442b-a0b8-a8fceeb50781	\N	shagil	Caseworker	+12255636254	caseworker3511@mailinator.com	Address 1	Address 1	texas	65465	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	5	2024-04-08 05:01:27.968+00	2024-04-24 05:39:48.206+00	2	37	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N	\N	\N	327	\N	\N	\N	None	\N	t
91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	Miracle Foundation	SA	+19497288333	miraclesuperadmin@yopmail.com	Txs		TRX	67676	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	1	2024-01-16 07:01:42+00	2024-05-10 07:31:48.293+00	2	37	\N	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	\N	\N	1000	\N	\N	\N	None	\N	t
6af032d5-1a7f-4507-9eaf-34e3084208a1	\N	\N	test parent	Status check	+12255654964	ajeesh.ts@inapp.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	2b73eaab-3911-442b-a0b8-a8fceeb50781	2b73eaab-3911-442b-a0b8-a8fceeb50781	\N	usa	\N	2024-04-15 09:10:11.584+00	2024-04-15 09:10:11.584+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	350	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
45a1329d-7002-43f6-90d2-614b8aa879ea	e8462146-d42c-414e-b8f0-11460a3ab7ed	\N	TS Caseworker	RBAC Uganda Only	+19497288333	caseworker.pcci.uganda@yopmail.com	AD01 Kampala Street		Kampala City	12345	t	f	f09a62ed-11bc-424b-9497-9e447f96b856	f09a62ed-11bc-424b-9497-9e447f96b856	\N	uganda	5	2024-04-09 09:48:21.364+00	2024-04-09 09:49:20.585+00	3	38	\N	0cf24e7b-6487-4288-8847-d336668da62e	\N	\N	\N	333	\N	\N	\N	None	\N	\N
b11d9e94-fc6e-41f7-a1ce-db7030c6309d	\N	\N	Elizabeth ADCM	Sparrow	+19497283333	parent.eliza02@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	\N	usa	\N	2024-05-13 10:01:49.52+00	2024-05-13 10:01:49.52+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	Pirate	76c706f5-671e-4a39-b1aa-f57a2544bb02	421	\N	46e42a63-ded5-486b-9203-d5e523f745fb	\N	None	\N	t
0fd8f742-ff93-40ec-bc73-1afe6db61479	1d738958-ad88-414c-b972-462d8f9541e3	\N	UAT Case Manager FSTS	USA	+19497288333	caseworker.uat.usa@yopmail.com	AD01 TexCity		Texas City	12345	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	5	2024-04-04 12:54:39.429+00	2024-04-16 02:46:12.303+00	2	37	\N	0d7b5e4a-9c81-4811-b010-bbef1ff42e28	\N	\N	\N	313	\N	\N	\N	None	\N	t
db9547ba-b116-46ed-968d-ae14e88da451	\N	\N	Thor Odinson	FSTS USA	+19497288333	parent.thor@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	usa	\N	2024-04-11 11:00:54.635+00	2024-04-11 11:00:54.635+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	King that is Worthy	4e92afc8-97e4-4b50-ad05-0d3ef49fe7c3	337	\N	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	None	\N	\N
c8d14ddc-f0a0-4484-bbdc-2ea020da91e1	\N	\N	Admin FS Only	QA RBAC REG Phase1 USA	+19497288833	admin.fostershare.usa@yopmail.com	AD01 WASDC		Washington DC	12345	f	f	d093e74c-259d-4851-a522-5ca4d78fc61f	d093e74c-259d-4851-a522-5ca4d78fc61f	\N	usa	9	2024-04-11 13:54:46.777+00	2024-04-11 13:54:46.777+00	2	39	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	\N	\N	339	\N	\N	\N	None	\N	t
2ac61357-b350-424a-b732-1fdc00389202	\N	\N	Rohan	Nambiar	+19895098950	rohannambiar@mailinator.com	TVM		TVM	65897	f	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	4	2024-04-15 09:45:48.512+00	2024-04-15 09:46:02.156+00	2	37	\N	1cec9f20-62dd-4cd1-b91b-951d851ab25b	\N	\N	\N	355	\N	\N	\N	None	\N	t
97e755ed-a649-44ca-8eab-0363c7016008	\N	\N	Pending Team Member 01	RBAC REG Phase1 USA	+19497288333	pending.fsts.usa@yopmail.com	AD01 WASDC		Washington DC	52251	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	9	2024-04-11 11:21:42.987+00	2024-04-15 09:12:02.127+00	2	39	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	\N	\N	338	\N	\N	\N	None	\N	t
6299b5a1-d2ce-4487-aa18-badc106cf72d	1f1587c7-5785-458f-9551-65c92faf60fc	\N	Test	Child	+12255654987	testingemail@yopmail.com	Add1		test city	32165	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	2	2024-04-15 09:17:23.138+00	2024-05-14 09:53:46.889+00	2	39	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N	\N	\N	352	\N	\N	\N	None	\N	t
82ade43a-cac1-432b-bd6d-271772daf917	\N	\N	Primary Caregiver	Mail Check	+12255346435	Caregiver@mailinator.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	\N	2024-04-15 09:19:30.743+00	2024-04-15 09:19:30.743+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	353	\N	f191b1cc-f282-4080-8c60-3f757aacca6d	\N	None	\N	t
c588a0a7-6bdf-42d2-a899-dcfb7ba0fa96	7049e3f7-a12e-4bec-8f47-886bbebe3eae	\N	Test	Android	+12255646546	tsmoblogin@yopmail.com	adad		sasa	56565	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	5	2024-05-14 05:19:21.642+00	2024-05-14 05:23:44.047+00	2	39	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N	\N	\N	423	Asia/Kolkata	\N	\N	None	\N	t
5961704a-1f1f-455b-b5dc-33fe814d3da8	\N	\N	Test 	Parent	+12255362514	Parent@mailinator.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	2b73eaab-3911-442b-a0b8-a8fceeb50781	2b73eaab-3911-442b-a0b8-a8fceeb50781	\N	usa	\N	2024-04-15 08:37:20.155+00	2024-04-15 08:44:59.084+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	347	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
9a1b166d-2231-471d-bb47-674cd52c61e2	\N	\N	Test	ChildStatus_Complete 	+12255668764	abin.ak@inapp.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	2b73eaab-3911-442b-a0b8-a8fceeb50781	2b73eaab-3911-442b-a0b8-a8fceeb50781	\N	usa	\N	2024-04-15 08:47:23.48+00	2024-04-15 08:51:37.851+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	348	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
76b500c7-c318-4f38-a845-63f23b0764c4	\N	\N	Primary Caregiver	Status_Complete	+12255635241	abin.ak+1@ianpp.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	2b73eaab-3911-442b-a0b8-a8fceeb50781	2b73eaab-3911-442b-a0b8-a8fceeb50781	\N	usa	\N	2024-04-15 08:56:02.259+00	2024-04-15 08:56:02.259+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	349	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
b10b2b1a-7ffa-474d-b4af-6065e0dff40f	78c7a329-36a7-45d6-9ad8-4efec6d3136d	\N	Ash	Or	+17372100120	aorr@miraclefoundation.org	123 6th st		Austin	78723	t	f	78c7a329-36a7-45d6-9ad8-4efec6d3136d	78c7a329-36a7-45d6-9ad8-4efec6d3136d	\N	usa	2	2024-04-17 12:14:09.281+00	2024-05-15 20:48:01.093+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	361	\N	\N	\N	None	\N	t
4c2fcd13-08d2-40a8-96f7-f5a496267d23	\N	\N	test	parent	+12255265136	shagil.k+3@inapp.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	2b73eaab-3911-442b-a0b8-a8fceeb50781	2b73eaab-3911-442b-a0b8-a8fceeb50781	\N	usa	\N	2024-04-15 09:12:12.638+00	2024-04-15 09:44:07.089+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N	\N	\N	351	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
7d5ef7fa-1dac-4dc2-99f1-ac2cf95b242a	728a27cf-b22f-461d-a57c-da04981608fb	\N	Kang the Conqueror Edit	FSTS USA	+19497288333	parent.kang@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	728a27cf-b22f-461d-a57c-da04981608fb	728a27cf-b22f-461d-a57c-da04981608fb	\N	usa	\N	2024-04-11 10:58:17.799+00	2024-05-22 09:10:04.058+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	Conqueror of the Multiverse	\N	336	Asia/Calcutta	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	None	\N	t
aeff2c20-85c7-4822-b367-711bbb1a73e4	6bd02702-ab5c-4c65-8331-d5f69dcd6308	\N	Charlie	Angel 	+15124445555	charlie_angel_fsp@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	bd33877e-40d9-4684-8395-54c4cc2dd4f2	bd33877e-40d9-4684-8395-54c4cc2dd4f2	\N	usa	\N	2024-04-22 15:12:25.18+00	2024-04-22 15:13:56.558+00	2	\N	\N	359fdbcb-8f7b-4279-99c5-9c2b094114af	\N		\N	379	\N	571b5222-d59e-4640-bc6d-558e1122591a	\N	None	\N	t
656211a5-d67c-4e80-8c54-171021adcbe0	\N	\N	Caseworker (TS)	2	+15129999999	cw2.ts@yopmail.com	Austin, texas		Austin	11001	f	f	827b4381-3556-4bca-82d9-e186d0aae8d7	827b4381-3556-4bca-82d9-e186d0aae8d7	\N	usa	5	2024-04-18 11:22:53.757+00	2024-04-18 11:22:53.757+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	371	\N	\N	\N	None	\N	t
9b5c0b28-b615-43ec-8654-596199439e7a	\N	\N	Caseworker (FS)	3	+15128888888	cw3.fs@yopmail.com	Austin, texas		Austin	11001	f	f	827b4381-3556-4bca-82d9-e186d0aae8d7	827b4381-3556-4bca-82d9-e186d0aae8d7	\N	usa	9	2024-04-18 11:27:34.163+00	2024-04-18 11:27:34.163+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	372	\N	\N	\N	None	\N	t
0ac84ba8-9cd7-4536-a3c9-aff6b4b69f68	0b9b34f2-dd92-4191-b023-f4ae32884964	\N	Katie	FSCMADMINTSADMIN	+15122223333	katie_fscmadmintsadmin@yopmail.com	TBD st		Austin	78735	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	2	2024-04-22 18:04:45.345+00	2024-04-22 18:34:50.991+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	380	\N	\N	\N	None	\N	t
2d4318a1-1a23-4cdd-88e4-1efab8c38237	\N	\N	Katie	FSCMADMINTSCW	+15123334444	katie_fscmadmintscw@yopmail.com	TBD st		Austin	78735	f	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	\N	usa	5	2024-04-22 19:13:58.32+00	2024-04-22 19:16:39.541+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	381	\N	\N	\N	None	\N	t
aa21aabf-2525-465c-b97c-7bd736bf8ebe	5c9719d7-3305-4da2-affa-d08e2cff875d	\N	Pending User 02	RBAC Phase 1	+19497288333	pendinguser565@yopmail.com	cQAWDWDW	DQWDWQD	fwefef	16516	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	5	2024-04-15 09:22:15.098+00	2024-04-23 09:30:26.512+00	2	37	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	\N	\N	354	\N	\N	\N	None	\N	t
09c6e9aa-f6bc-465b-8579-1aa020367960	\N	\N	Jim	Ponds	+12812333333	jim_ponds@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	\N	usa	\N	2024-04-22 19:30:10.477+00	2024-04-22 19:30:10.477+00	2	\N	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N		1c6895a3-048d-4765-b6eb-478f370b0e0e	383	\N	0ac84ba8-9cd7-4536-a3c9-aff6b4b69f68	\N	None	\N	t
1c6895a3-048d-4765-b6eb-478f370b0e0e	3e60bbd0-6c55-4d25-b15f-c94ae24d3cbb	\N	Pam	Ponds	+12812223333	pam_ponds@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	\N	usa	\N	2024-04-22 19:30:10.466+00	2024-04-22 19:31:04.101+00	2	\N	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N		\N	382	\N	0ac84ba8-9cd7-4536-a3c9-aff6b4b69f68	\N	None	\N	t
b4b6337a-81a6-43a6-b81a-6ef84646ef62	5d259413-ce18-4270-b9d0-3abcd7ad2f6f	\N	Catnis Everdeen	ADFAM	+19497288333	parent.catnis@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	978e3d94-7411-4760-b8a2-b9f3033ec15c	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	\N	usa	\N	2024-04-29 09:52:08.355+00	2024-05-13 10:29:15.993+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	Hunter	\N	398	\N	46e42a63-ded5-486b-9203-d5e523f745fb	\N	None	\N	t
13c6f9cb-eaf1-47e0-b09b-9f3bc742e905	600c6fbb-6df5-406c-83ac-e1e2c3eb4983	\N	Test FS admin	test	+15122102456	usafsts@yopmail.com	123 6th st		test	78723	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	9	2024-04-22 20:28:25.331+00	2024-04-22 20:28:55.082+00	2	37	\N	402e9214-a9d8-4a7a-b01e-5b932a0d1ecf	\N	\N	\N	384	\N	\N	\N	None	\N	t
b1281c75-ccd8-4ea7-bdc3-6d9a9c23dacc	8b6a8c3a-8d41-4427-b84f-607a0976703b	\N	RoleChange Test USA	AdminPlus	+19497288333	admincw.rolechange.usa@yopmail.com	AD01 Wash DC		Washington DC	12345	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	5	2024-04-23 13:08:22.377+00	2024-04-23 13:12:15.438+00	2	39	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	\N	\N	392	\N	\N	\N	None	\N	t
c4397112-5c3e-4ef8-9b9b-9769ab180eb8	21410735-be51-4c90-bb93-9bf936bbfeec	\N	Test USA TS only	Test	+15122102456	usats@yopmail.com	123 6th st		City	88888	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	2	2024-04-22 20:30:53.036+00	2024-04-22 20:33:04.076+00	2	37	\N	402e9214-a9d8-4a7a-b01e-5b932a0d1ecf	\N	\N	\N	385	\N	\N	\N	None	\N	t
01461a6d-8eb2-4187-9b29-1b26dd0c1ea2	820b8953-8604-473e-9052-35539a631e41	\N	test	devloper	+18675467568	testdeveloper@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	\N	2024-04-24 06:52:17.806+00	2024-05-22 10:26:05.113+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	395	Asia/Kolkata	ceae199d-b372-4265-a697-1afd37b49c24	\N	None	\N	t
f594d8ce-8c18-4f70-a85f-72619d372a4d	274b2d4e-fc02-4584-ad4e-9ec841c1ac2b	\N	tscm	test	+15122102456	tscm@yopmail.com	123 6th st		test	78723	t	f	21410735-be51-4c90-bb93-9bf936bbfeec	21410735-be51-4c90-bb93-9bf936bbfeec	\N	usa	5	2024-04-22 20:45:06.231+00	2024-04-22 20:46:07.609+00	2	37	\N	402e9214-a9d8-4a7a-b01e-5b932a0d1ecf	\N	\N	\N	386	\N	\N	\N	None	\N	t
d233665e-6b54-479f-a735-14f3747e4f51	d8bf8a7b-e3e0-4132-863e-e2fe35c04c74	\N	CW_5	Test(jyotir)	+15129999999	cw_5@yopmail.com	ABC		Austin	73001	t	f	827b4381-3556-4bca-82d9-e186d0aae8d7	827b4381-3556-4bca-82d9-e186d0aae8d7	\N	usa	5	2024-04-29 11:04:36.228+00	2024-05-16 12:46:00.19+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	399	Asia/Kolkata	\N	\N	None	\N	t
eacf4720-0eae-47c5-8afe-e8a9c3ac7bc4	914ed98d-869b-4fbb-bc83-11da614a6824	\N	tscm2	Test	+17372100120	tscm2@yopmail.com	123 st.		City	78723	t	f	21410735-be51-4c90-bb93-9bf936bbfeec	21410735-be51-4c90-bb93-9bf936bbfeec	\N	usa	5	2024-04-22 20:53:16.401+00	2024-04-22 20:53:38.649+00	2	37	\N	402e9214-a9d8-4a7a-b01e-5b932a0d1ecf	\N	\N	\N	387	\N	\N	\N	None	\N	t
a0da02cf-444d-48fe-bb19-6f5eed7accf3	\N	\N	Pending user	Test	+17372100120	pendingts@yopmail.com	123 6th st		City	78723	f	t	274b2d4e-fc02-4584-ad4e-9ec841c1ac2b	274b2d4e-fc02-4584-ad4e-9ec841c1ac2b	\N	usa	2	2024-04-22 20:56:55.298+00	2024-04-22 20:58:16.325+00	2	37	\N	402e9214-a9d8-4a7a-b01e-5b932a0d1ecf	\N	\N	\N	388	\N	\N	\N	None	\N	t
062296e0-af32-45d7-8292-5bc5bff33b33	ceeea40b-2680-451e-a2aa-0b41b0834f36	\N	Test - no access to TS	Test	+17372100120	no_ts@yopmail.com	123 6th st		City	78723	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	9	2024-04-23 12:56:27.946+00	2024-04-23 12:56:46.614+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	390	\N	\N	\N	None	\N	t
7682bead-cdf8-4df3-aef5-4684f2cd4544	\N	\N	Secondary caregiver	......	+13213213213	Addanewfamily01@mailinator.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	\N	2024-04-29 08:55:14.951+00	2024-04-29 08:55:14.951+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		cb048363-0c71-4ca4-9336-9601a0e33f1a	397	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
24cccf01-52d1-4f27-890c-41781842564b	c07e1f18-ec1b-401e-b1fb-43287c9e8f8a	\N	RoleChange Test	AdminPlus	+19497288333	admincw.rolechange@yopmail.com	Ad01ghj		Washington DC	12345	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	4	2024-04-23 13:00:56.035+00	2024-04-23 13:04:07.826+00	2	39	\N	2593574a-10f1-4074-8fe5-51f8ac753ab9	\N	\N	\N	391	\N	\N	\N	None	\N	t
ceae199d-b372-4265-a697-1afd37b49c24	7aa28aa4-09ab-499a-8680-dcb74ccc07b6	\N	Shagil	caseworker	+12255654545	caseworker3512@mailinator.com	add		us	45247	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	9	2024-04-24 05:41:02.224+00	2024-04-24 05:41:38.083+00	2	37	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N	\N	\N	393	\N	\N	\N	None	\N	t
d2523f09-dd66-49ff-bdc6-a00fedabd645	\N	\N	Add Team Member	test	+12253615351	figin+2@inapp.com	wfe21fw32f1		fwf	22323	f	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	7	2024-05-07 09:15:07.804+00	2024-05-07 09:15:07.804+00	2	39	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N	\N	\N	405	\N	\N	\N	None	\N	t
cb048363-0c71-4ca4-9336-9601a0e33f1a	a743ee49-b44a-47f2-bf53-2245e52f8896	\N	Add a new family	Flow	+12255654656	Addanewfamily@mailinator.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	\N	2024-04-29 08:55:14.771+00	2024-04-29 09:00:33.707+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	396	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
e4f6ac51-8a93-4f92-a02d-8206869be269	950e8679-9344-4bcb-a0e8-6b089bd13252	\N	Peta	ADFAM	+19497288333	parent.peta@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	\N	usa	\N	2024-05-06 09:32:44.054+00	2024-05-06 09:36:55.756+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	Hunter	b4b6337a-81a6-43a6-b81a-6ef84646ef62	401	\N	46e42a63-ded5-486b-9203-d5e523f745fb	\N	None	\N	t
87a6373a-7228-402c-8e43-2d5ea4968474	7cccc2b7-51ef-4296-b09d-4066cae4a799	\N	Admin FS USA	Deactivate Org	+19497288333	us.admin.ts.indiaorg@yopmail.com	AD01 WASH DC		Washington DC	12345	f	t	e78efa00-834a-4fdd-95f5-b3a4e498982d	e78efa00-834a-4fdd-95f5-b3a4e498982d	\N	usa	2	2024-04-15 07:26:29.974+00	2024-05-09 05:54:38.149+00	2	39	\N	aeb16ff9-0111-4da8-9f9e-c2bbb144065d	\N	\N	\N	346	\N	\N	\N	None	Organization account deactivated:	f
9060529f-808a-4047-99f2-50f2fccc3d36	a430870a-7a1d-483a-bbe1-bbc8d7ee774c	\N	Team member FSTS	Only USA	+17372100120	fsts@yopmail.com	123 6th st		City	78723	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	2	2024-05-06 15:53:53.833+00	2024-05-06 15:54:28.253+00	2	37	\N	116546d0-07bb-436d-be51-91cf5f34bd2a	\N	\N	\N	402	\N	\N	\N	None	\N	t
24abc4a2-7bfe-4616-ba4f-33857b5dc052	\N	\N	Newt Scamander	AdminFamily	+19497288333	parent.newt@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	978e3d94-7411-4760-b8a2-b9f3033ec15c	978e3d94-7411-4760-b8a2-b9f3033ec15c	\N	usa	\N	2024-05-07 09:49:13.079+00	2024-05-07 09:49:13.079+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	Beastologist	\N	407	\N	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	None	\N	t
0474cb5d-a42e-465d-9bbf-ac0c77b13805	011d1e40-71c4-4a41-b096-cb28139f462e	\N	CaseManager FS Only	QA RBAC REG Phase1	+19497288888	casemanager.fostershare.usa@yopmail.com	AD01 5th Street		Washington DC	42644	t	f	978e3d94-7411-4760-b8a2-b9f3033ec15c	978e3d94-7411-4760-b8a2-b9f3033ec15c	\N	usa	9	2024-05-07 09:53:02.852+00	2024-05-07 09:53:56.659+00	2	39	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	\N	\N	408	\N	\N	\N	None	\N	t
c955ef97-e1ef-4468-ae4d-e0ddc45165d7	\N	\N	Secondary 	caregiver	+12255321313	SecondaryCaregiverTest@mailinator.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	\N	2024-05-10 05:57:19.511+00	2024-05-10 05:57:19.511+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		89082d9c-7463-4b2a-8b0f-2656708943c9	411	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
2227eeba-2a7e-4a87-a473-ba4e938236ee	00c9a51f-1c4d-4107-bd82-7002d953d229	\N	Test(Jyotir)	4	+17132345555	test_jyotir_4@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	d8bf8a7b-e3e0-4132-863e-e2fe35c04c74	d8bf8a7b-e3e0-4132-863e-e2fe35c04c74	\N	usa	\N	2024-05-16 05:09:00.133+00	2024-05-22 05:16:49.658+00	2	\N	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	farmer	\N	426	Asia/Kolkata	d233665e-6b54-479f-a735-14f3747e4f51	\N	None	\N	t
afc14aae-eb94-4182-a6a6-3ed4999296bb	\N	\N	 testmobile	1	+12255654654	anoop.m@inapp.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	\N	2024-05-13 05:12:08.691+00	2024-05-13 05:12:22.511+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	417	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
ee974fee-6633-4fcc-ba42-2e03818d5f34	79eeea2a-1644-4162-8ff3-bb3d4f5168c5	\N	Elizabeth ADCM	Sparrow	+19497283333	parent.eliza@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	\N	usa	\N	2024-05-13 05:32:13.93+00	2024-05-13 05:46:42.07+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	Pirate	7bfbd3f1-04a4-4385-ade2-1254ceb2a68d	418	\N	46e42a63-ded5-486b-9203-d5e523f745fb	\N	None	\N	t
89082d9c-7463-4b2a-8b0f-2656708943c9	70e053d5-b6d2-44e1-8520-2bc136cdc651	\N	Primary Caregiver	Active test	+12255654654	PrimaryCaregiverTest@mailinator.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	\N	2024-05-10 05:57:19.491+00	2024-05-10 05:58:18.246+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	410	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
7d89ddd1-5a21-47c5-8e94-47e28455f815	c732d1de-3058-4240-bdd5-7bd18599df0e	\N	Admin FS Only	Deact Org USA	+19497288333	admin.fostershare.deact.usa@yopmail.com	AD01 Wash DC	AD01 Wash DC	Washington DC	12345	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	9	2024-05-09 09:15:45.911+00	2024-05-10 06:59:24.131+00	2	39	\N	a38bbea2-e253-4888-afdc-d27a5f603d59	\N	\N	\N	409	\N	\N	\N	None	\N	t
57d2edf5-1fd0-418e-8c5c-16eb11a47247	\N	\N	Admin CW FS Only	Deact Org USA	+19497288333	admincw.fostershare.deact.usa@yopmail.com	AD01 Texas DC	AD02 Texas DC	Texas City USA	12345	f	f	c732d1de-3058-4240-bdd5-7bd18599df0e	c732d1de-3058-4240-bdd5-7bd18599df0e	\N	usa	9	2024-05-10 09:23:09.41+00	2024-05-10 09:23:09.41+00	2	37	\N	a38bbea2-e253-4888-afdc-d27a5f603d59	\N	\N	\N	412	\N	\N	\N	None	\N	t
899ef9d5-366a-47a3-86f0-e60d1b01678a	\N	\N	Case Manager FS Only	Deact Org USA	+19497288833	casemanager.fostershare.deact.usa@yopmail.com	AD01 WASDC	AD02 Wash DC	Washington DC	12345	f	f	c732d1de-3058-4240-bdd5-7bd18599df0e	c732d1de-3058-4240-bdd5-7bd18599df0e	\N	usa	9	2024-05-10 09:56:05.21+00	2024-05-10 09:56:05.21+00	2	39	\N	a38bbea2-e253-4888-afdc-d27a5f603d59	\N	\N	\N	413	\N	\N	\N	None	\N	t
fa5f853d-1847-4b55-84bd-fd3dfc888884	1419d1d6-ff98-4c4b-afbf-bf3c8d457aeb	\N	peace	primarycaregiver	+15735455555	peaceprimarycaregiverinapp@mailinator.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	0160e507-8db6-4a42-80a9-2c20272fee0b	0160e507-8db6-4a42-80a9-2c20272fee0b	\N	usa	\N	2024-05-15 11:19:42.78+00	2024-05-16 09:29:46.473+00	2	\N	\N	9cfbcab5-ddf0-4fce-9b56-d8666ad2242e	\N		\N	425	Asia/Kolkata	8088dc95-acb1-4356-be15-69cfb4daf6d8	\N	None	\N	t
8088dc95-acb1-4356-be15-69cfb4daf6d8	0160e507-8db6-4a42-80a9-2c20272fee0b	\N	Peace	manager	+15734544444	peacemanagerinapp@mailinator.com	test address		city of texas	78777	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	4	2024-05-15 11:16:04.827+00	2024-05-15 11:17:04.496+00	2	37	\N	9cfbcab5-ddf0-4fce-9b56-d8666ad2242e	\N	\N	\N	424	\N	\N	\N	None	\N	t
6a771743-da55-4f04-a95a-70f97effbda7	e3a6874b-b857-4ce5-8f54-d120a5d77b55	\N	Admin Edit Email FS Only	Deact Org USA	+19497288833	admin01.fostershare.deact.usa@yopmail.com	AD01 Street	AD02 Street	Washington DC	12345	t	f	e3a6874b-b857-4ce5-8f54-d120a5d77b55	e3a6874b-b857-4ce5-8f54-d120a5d77b55	\N	usa	9	2024-05-10 10:12:18.703+00	2024-05-13 04:58:50.701+00	2	39	\N	a38bbea2-e253-4888-afdc-d27a5f603d59	\N	\N	\N	414	\N	\N	\N	None	\N	t
7adcc6d0-760d-4b31-a932-ba7c8d2bab20	\N	\N	CaseManager Edit Email FS Only	Deact Org USA	+19497288333	cm01.fostershare.deact.usa@yopmail.com	AD01 Texas	AD02 Texas	Texas City	12345	f	f	e3a6874b-b857-4ce5-8f54-d120a5d77b55	e3a6874b-b857-4ce5-8f54-d120a5d77b55	\N	usa	9	2024-05-13 05:03:20.346+00	2024-05-13 05:03:20.346+00	2	37	\N	a38bbea2-e253-4888-afdc-d27a5f603d59	\N	\N	\N	415	\N	\N	\N	None	\N	t
e1de582e-8bdd-43c9-9ecf-ffc5359ff811	90288768-311f-42dd-8f76-1071be96658d	\N	Primary Caregiver	FS	+12255654687	PrimaryCaregiver@mailinator.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	7aa28aa4-09ab-499a-8680-dcb74ccc07b6	7aa28aa4-09ab-499a-8680-dcb74ccc07b6	\N	usa	\N	2024-04-24 05:51:50.974+00	2024-05-13 05:06:42.81+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	394	Asia/Kolkata	ceae199d-b372-4265-a697-1afd37b49c24	\N	None	\N	t
d1f0b6e2-67d3-42c6-b505-9c16d48dcc8c	a95a13af-4e1b-4128-9991-5d4d1b412d12	\N	Test	Android	+12255654654	TestAndroid@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	\N	2024-05-14 04:33:41.502+00	2024-05-14 04:35:54.284+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	422	\N	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
ef99024d-e430-429b-b22f-e785aca3dab4	b22b514f-4699-4b72-bbeb-65ed85b095e8	\N	Test	Mobile	+12255654654	shagil.k+7979@inapp.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	74dacbb7-2032-4e24-ac9d-6bce973796da	74dacbb7-2032-4e24-ac9d-6bce973796da	\N	usa	\N	2024-05-13 05:10:06.016+00	2024-05-15 12:07:30.906+00	2	\N	\N	6536ba55-07ba-4c0d-8c63-8891586345c7	\N		\N	416	Asia/Kolkata	75579cd6-8fbd-4c3b-9c8b-9faf5b475018	\N	None	\N	t
d07d65bd-6f8c-456f-8ebd-06fb11e48a3a	02f88d47-03bf-4c58-be13-4673aca6196b	\N	James	Potter	+19497288333	parent.james@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	d093e74c-259d-4851-a522-5ca4d78fc61f	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	\N	usa	\N	2024-04-15 13:43:38.547+00	2024-05-22 05:58:21.663+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	Senior Seeker	\N	356	Asia/Kolkata	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	None	\N	t
32d34875-6aa0-4e97-9b8b-8f822263cbd1	50092e8d-588d-4ebd-b72b-dba355ab0ee4	\N	Sergio	Perla	+15123298635	twadmin@yopmail.com	123 Miracle Way		Austin	78703	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	2	2024-05-20 13:59:01.729+00	2024-05-20 14:00:10.806+00	2	37	\N	d74a2981-22a4-4cc5-90ec-52f4d0301cd3	\N	\N	\N	429	\N	\N	\N	None	\N	t
3cd034e0-f967-48d7-9245-e8197f47f92b	fec351f9-c915-4aa2-989d-74e27c87c69f	\N	Serena	Brown	+15123298635	ustwcm@yopmail.com	123 Miracle Way		Austin	78702	t	f	50092e8d-588d-4ebd-b72b-dba355ab0ee4	50092e8d-588d-4ebd-b72b-dba355ab0ee4	\N	usa	9	2024-05-20 14:06:41.8+00	2024-05-20 14:08:11.983+00	2	37	\N	d74a2981-22a4-4cc5-90ec-52f4d0301cd3	\N	\N	\N	430	\N	\N	\N	None	\N	t
c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	\N	Admin CaseWorkManager QA RBAC REG Phase1	USA	+19497288333	admincw.rbac.usa@yopmail.com	AD01 WASDC		Washington DC	12345	t	f	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	91e4d220-7bfd-4495-8d06-0fd99e1cd9aa	\N	usa	4	2024-04-05 08:22:30.879+00	2024-05-22 12:56:29.679+00	2	39	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N	\N	\N	317	Asia/Kolkata	\N	\N	None	\N	t
a3ef887f-a91a-4331-b4e1-61a3ccbb509a	bb005163-7e9c-4c25-b022-fc32a6e35607	\N	Paula	Grenon	+15123298635	ustwparent@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	50092e8d-588d-4ebd-b72b-dba355ab0ee4	50092e8d-588d-4ebd-b72b-dba355ab0ee4	\N	usa	\N	2024-05-20 14:10:25.773+00	2024-05-21 04:10:13.698+00	2	\N	\N	d74a2981-22a4-4cc5-90ec-52f4d0301cd3	\N	Teacher	\N	431	America/Chicago	3cd034e0-f967-48d7-9245-e8197f47f92b	\N	None	\N	t
c864b11c-d2fe-455d-a0b9-08e8489b7f74	\N	\N	Ashley	Orr	+17372100120	cscmtest@yopmail.com	1508	Northridge Drive	Austin	78723	f	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	5	2024-05-22 19:33:58.926+00	2024-05-22 19:34:35.19+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	441	\N	\N	\N	None	\N	t
a267f3db-19cf-4a6b-9258-8b07d59e3f34	2775eeab-4f4a-487a-bcec-61ec0c4c2a20	\N	John	Mark	+15123293586	ustwcm2@yopmail.com	123 Miracle Way		Austin	78717	f	t	50092e8d-588d-4ebd-b72b-dba355ab0ee4	50092e8d-588d-4ebd-b72b-dba355ab0ee4	\N	usa	9	2024-05-22 19:38:02.451+00	2024-05-22 20:16:38.908+00	2	37	\N	d74a2981-22a4-4cc5-90ec-52f4d0301cd3	\N	\N	\N	442	\N	\N	\N	None	\N	t
83a0bc88-ffc6-4b15-b9e5-6d04ccfb27ef	e151038a-5cab-4c2f-b335-e9a08f4177ed	\N	KatieTestRole4	FSACMTSViewOnly	+12812223333	katietestrole4@yopmail.com	TBD		Austin	78735	t	f	00066141-a2ec-4c4d-9338-7c522cbd9caf	00066141-a2ec-4c4d-9338-7c522cbd9caf	\N	usa	7	2024-05-20 20:13:46.145+00	2024-05-20 20:21:28.78+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	433	\N	\N	\N	None	\N	t
9295b35e-b79a-4143-a7d8-35be16a6db7d	1cee50f3-1bf7-4de8-8d65-dc31524c57c4	\N	Pecan	Pie	+15123298635	ustwparent2@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	50092e8d-588d-4ebd-b72b-dba355ab0ee4	50092e8d-588d-4ebd-b72b-dba355ab0ee4	\N	usa	\N	2024-05-20 20:22:40.478+00	2024-05-20 20:26:43.537+00	2	\N	\N	d74a2981-22a4-4cc5-90ec-52f4d0301cd3	\N		\N	434	\N	3cd034e0-f967-48d7-9245-e8197f47f92b	\N	None	\N	t
f7513d06-72a4-46d2-8291-973ea91b26c7	0533952f-bb82-44fe-8b5d-02da75a17c93	\N	KTtest5	FSACMTSUnassigned	+12812223333	kttest5@yopmail.com	TBD		Austin	78735	t	f	e151038a-5cab-4c2f-b335-e9a08f4177ed	e151038a-5cab-4c2f-b335-e9a08f4177ed	\N	usa	9	2024-05-20 20:31:09.78+00	2024-05-20 20:33:24.445+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	435	\N	\N	\N	None	\N	t
143af665-64eb-4dcf-b7ef-78cef11882c1	\N	\N	KTtest6	FSAny	+12812222225	kttest6@yopmail.com	TBD		Civic Centre	78735	f	f	0533952f-bb82-44fe-8b5d-02da75a17c93	0533952f-bb82-44fe-8b5d-02da75a17c93	\N	usa	9	2024-05-20 20:37:05.864+00	2024-05-20 20:37:05.864+00	2	39	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	436	\N	\N	\N	None	\N	t
2c9095f2-7b77-4fd1-ad84-33c4323c039f	f319b7cd-3de6-4e21-9e96-422e6614c1c2	\N	Sara	Doe	+12812225555	saradoe@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0533952f-bb82-44fe-8b5d-02da75a17c93	\N	usa	\N	2024-05-20 13:22:51.215+00	2024-05-21 19:25:19.28+00	2	\N	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N		\N	428	America/Chicago	83a0bc88-ffc6-4b15-b9e5-6d04ccfb27ef	\N	None	\N	t
5f8e4c5a-738e-497d-8957-9f226e1e42b0	00066141-a2ec-4c4d-9338-7c522cbd9caf	\N	FSCMADMINTSADMINCW	KTTestRole2	+12812222225	kttestrole2@yopmail.com	TBD		Austin	78735	t	f	0b9b34f2-dd92-4191-b023-f4ae32884964	0b9b34f2-dd92-4191-b023-f4ae32884964	\N	usa	4	2024-05-20 14:34:24.862+00	2024-05-23 06:18:06.984+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	432	Asia/Kolkata	\N	\N	None	\N	t
405d1414-4828-48c5-942d-a7d0b4d993cd	914a5996-e0a3-4785-bb7a-7e115221637d	\N	Test - No access to TS	Test	+15122102456	nots@yopmail.com	123 6th st		test	78723	t	f	fd9de831-d021-40b4-97f3-b13ee07b048e	fd9de831-d021-40b4-97f3-b13ee07b048e	\N	usa	9	2024-04-22 13:59:47.707+00	2024-05-21 20:55:01.997+00	2	37	\N	733783e7-fcf9-42d5-849c-33aff0f01d35	\N	\N	\N	378	\N	\N	\N	None	\N	t
5900db26-3d92-4b50-b7f7-c8ea0f6efad3	dbd7f49e-e989-4798-bb19-f2c0ec8a0250	\N	Odin	Alfather	+19497288333	parent.odin@yopmail.com	UNKNOWN	\N	UNKNOWN	UNKNOWN	t	f	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	04ab91e2-51f1-4db9-aa7c-ebea8f4e2586	\N	usa	\N	2024-05-22 05:53:47.252+00	2024-05-22 10:03:56.87+00	2	\N	\N	96aca77e-d466-4be1-862d-9bf3ab4573a0	\N		\N	439	Asia/Kolkata	c9da21ac-cf9d-44b0-ae64-c0d73074fb5b	\N	None	\N	t
1eeea27d-6003-4e6d-b6a8-1f9dacdca48b	7d3061bb-9a62-4919-86bd-b97bec9b6f3f	\N	Manu	Luau	+15123293586	ustwadmincm@yopmail.com	123 Miracle Way		Austin	78717	t	f	7d3061bb-9a62-4919-86bd-b97bec9b6f3f	7d3061bb-9a62-4919-86bd-b97bec9b6f3f	\N	usa	4	2024-05-22 20:29:26.434+00	2024-05-22 21:25:01.924+00	2	37	\N	d74a2981-22a4-4cc5-90ec-52f4d0301cd3	\N	\N	\N	443	America/Chicago	\N	\N	None	\N	t
\.


--
-- Data for Name: awsdms_apply_exceptions; Type: TABLE DATA; Schema: public; Owner: ht_db_user
--

COPY public.awsdms_apply_exceptions ("TASK_NAME", "TABLE_OWNER", "TABLE_NAME", "ERROR_TIME", "STATEMENT", "ERROR") FROM stdin;
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_countries	2024-02-09 06:08:44.391629	INSERT INTO "public"."HT_countries" ( "id","countryName","phoneNumberFormat","isActive","isDeleted","createdAt","updatedAt" )  VALUES (2,'USA','sfd','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000')	RetCode: SQL_ERROR  SqlState: 23502 NativeError: 1 Message: ERROR: null value in column "isoCode" of relation "HT_countries" violates not-null constraint;\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_countries	2024-02-09 06:08:44.402176	INSERT INTO "public"."HT_countries" ( "id","countryName","phoneNumberFormat","isActive","isDeleted","createdAt","updatedAt" )  VALUES (3,'Uganda','dfgdf','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000')	RetCode: SQL_ERROR  SqlState: 23502 NativeError: 1 Message: ERROR: null value in column "isoCode" of relation "HT_countries" violates not-null constraint;\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_countries	2024-02-09 06:28:14.077509	INSERT INTO "public"."HT_countries" ( "id","countryName","phoneNumberFormat","isActive","isDeleted","createdAt","updatedAt","countryCode","isoCode" )  VALUES (2,'USA','sfd','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000','1','US')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_countries_pkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_countries	2024-02-09 06:28:14.086817	INSERT INTO "public"."HT_countries" ( "id","countryName","phoneNumberFormat","isActive","isDeleted","createdAt","updatedAt","countryCode","isoCode" )  VALUES (3,'Uganda','dfgdf','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000','1','UGN')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_countries_pkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.188333	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (1,'Andaman & Nicobar',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.198563	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (2,'Andhra Pradesh',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.200554	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (3,'Arunachal Pradesh',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.202503	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (4,'Assam',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.204363	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (5,'Bihar',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.206144	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (6,'Chandigarh',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.208031	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (7,'Chhattisgarh',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.20976	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (8,'Dadra & Nagar Haveli',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.211552	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (9,'Daman & Diu',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.213307	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (10,'Delhi',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.215037	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (11,'Goa',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.218441	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (12,'Gujarat',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.220058	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (13,'Haryana',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.221812	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (14,'Himachal Pradesh',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.223581	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (15,'Jammu & Kashmir',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.225095	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (16,'Jharkhand',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.226612	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (17,'Karnataka',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.228059	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (18,'Kerala',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.229722	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (19,'Lakshadweep',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.231249	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (20,'Madhya Pradesh',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.232958	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (21,'Maharashtra',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.238925	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (22,'Manipur',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.242096	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (23,'Meghalaya',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.244633	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (24,'Mizoram',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.247298	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (25,'Nagaland',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.24951	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (26,'Orissa',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.251484	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (27,'Pondicherry',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.253879	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (28,'Punjab',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.255784	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (29,'Rajasthan',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.257786	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (30,'Sikkim',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.259674	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (31,'Tamil Nadu',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.261678	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (32,'Tripura',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.263531	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (33,'Uttar Pradesh',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.265304	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (34,'Uttaranchal',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.267087	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (35,'West Bengal',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-09 06:29:06.26883	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (36,'Telengana',NULL,'true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_states" violates foreign key constraint "HT_states_HTCountryId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_districts	2024-02-09 06:30:04.503245	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId" )  VALUES (1,'Trivandrum','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_districts" violates foreign key constraint "HT_districts_HTStateId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_districts	2024-02-09 06:30:04.521613	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId" )  VALUES (2,'kollam','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000',1)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_districts" violates foreign key constraint "HT_districts_HTStateId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_districts	2024-02-09 06:30:04.523925	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId" )  VALUES (3,'Chennai','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000',2)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_districts" violates foreign key constraint "HT_districts_HTStateId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-12 06:27:10.019658	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","userCode","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId" )  VALUES ('8254e494-60be-45c4-8427-dd1df01ed3bb',NULL,NULL,77,'Rahul','M','+17788778768','rahul01@yopmail.com','ds','','txs','676789','false','false',NULL,NULL,NULL,'usa','2024-02-12 06:27:04.362000','2024-02-12 06:27:04.362000',2,37,1,'e921f3e7-119d-44ab-81f2-c007bb6d288f',5)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-12 06:28:30.418533	UPDATE  "public"."HT_users" SET "id"='8254e494-60be-45c4-8427-dd1df01ed3bb', "cognitoId"='a94eeeb8-0dea-4185-8cfc-a8b19dfd7d71', "oldCognitoId"=NULL, "userCode"=77, "firstName"='Rahul', "lastName"='M', "phoneNumber"='+17788778768', "email"='rahul01@yopmail.com', "addressLine1"='ds', "addressLine2"='', "city"='txs', "zipCode"='676789', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-12 06:27:04.362000', "updatedAt"='2024-02-12 06:28:24.395000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='e921f3e7-119d-44ab-81f2-c007bb6d288f', "HTUserRoleId"=5 WHERE "id"='8254e494-60be-45c4-8427-dd1df01ed3bb'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-12 06:46:54.761158	UPDATE  "public"."HT_users" SET "id"='8254e494-60be-45c4-8427-dd1df01ed3bb', "cognitoId"='a94eeeb8-0dea-4185-8cfc-a8b19dfd7d71', "oldCognitoId"=NULL, "userCode"=77, "firstName"='Rahul', "lastName"='M', "phoneNumber"='+17788778768', "email"='rahul01@yopmail.com', "addressLine1"='ds', "addressLine2"='', "city"='txs', "zipCode"='676789', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-12 06:27:04.362000', "updatedAt"='2024-02-12 06:28:24.395000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='e921f3e7-119d-44ab-81f2-c007bb6d288g', "HTUserRoleId"=5 WHERE "id"='8254e494-60be-45c4-8427-dd1df01ed3bb'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-12 07:06:10.810385	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","userCode","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId" )  VALUES ('5c3d6435-c7e6-4db5-b5e5-2657fd2e24a7',NULL,NULL,78,'Harry','Potter','+18888888888','harry@yopmail.com','vbvn','','tsx','89898','false','false',NULL,NULL,NULL,'usa','2024-02-12 07:06:04.765000','2024-02-12 07:06:04.765000',2,37,1,'e05c93ff-e68d-4d9d-9310-c5fd1de750a3',5)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-12 07:07:20.571855	UPDATE  "public"."HT_users" SET "id"='5c3d6435-c7e6-4db5-b5e5-2657fd2e24a7', "cognitoId"='70a4bc2e-7ea8-4c55-b893-4fff98555f3c', "oldCognitoId"=NULL, "userCode"=78, "firstName"='Harry', "lastName"='Potter', "phoneNumber"='+18888888888', "email"='harry@yopmail.com', "addressLine1"='vbvn', "addressLine2"='', "city"='tsx', "zipCode"='89898', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-12 07:06:04.765000', "updatedAt"='2024-02-12 07:07:14.553000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='e05c93ff-e68d-4d9d-9310-c5fd1de750a3', "HTUserRoleId"=5 WHERE "id"='5c3d6435-c7e6-4db5-b5e5-2657fd2e24a7'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_accounts	2024-02-12 07:12:57.070094	UPDATE  "public"."HT_accounts" SET "id"='e05c93ff-e68d-4d9d-9310-c5fd1de750a3', "accountName"='USA TEST ACCOUNT', "addressLine1"='hArr', "addressLine2"='', "zipCode"='67788', "phoneNumber"=NULL, "email"=NULL, "city"='TXS', "website"=NULL, "isDCPUOrg"='false', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "consentRequired"='true', "createdAt"='2024-02-12 07:05:03.248000', "updatedAt"='2024-02-12 07:05:03.248000', "HTAccountTypeId"=2, "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "accountCode"=1078 WHERE "id"='e05c93ff-e68d-4d9d-9310-c5fd1de750a3'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_districts	2024-02-12 10:22:51.899651	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId" )  VALUES (4,'TXS REGION','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000',37)	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-12 10:25:05.551133	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","userCode","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId" )  VALUES ('0edd51b7-f18c-4598-8228-451dbe07b70c',NULL,NULL,79,'James','P','+911010101014','james@yopmail.com','addr1','addr2','TXS','000000','false','false',NULL,NULL,NULL,'usa','2024-02-12 10:24:59.512000','2024-02-12 10:24:59.512000',2,37,4,'1cc3b7c8-755a-4d30-bb03-9f04959e6745',5)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-12 10:26:50.468638	UPDATE  "public"."HT_users" SET "id"='0edd51b7-f18c-4598-8228-451dbe07b70c', "cognitoId"='6a11c962-d89a-4dab-8b66-8f336307df5f', "oldCognitoId"=NULL, "userCode"=79, "firstName"='James', "lastName"='P', "phoneNumber"='+911010101014', "email"='james@yopmail.com', "addressLine1"='addr1', "addressLine2"='addr2', "city"='TXS', "zipCode"='000000', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-12 10:24:59.512000', "updatedAt"='2024-02-12 10:26:44.446000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=4, "HTAccountId"='1cc3b7c8-755a-4d30-bb03-9f04959e6745', "HTUserRoleId"=5 WHERE "id"='0edd51b7-f18c-4598-8228-451dbe07b70c'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-13 05:35:12.464519	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId","userCode","occupation","parentUserId" )  VALUES ('a538ff49-c749-4221-92f5-044e64eaa1cc',NULL,NULL,'Sreeraj','P1','+16546546546','sreer01aj.b@inapp.com','AD01 5th Street','','Texas North','755774','true','false',NULL,NULL,NULL,'usa','2024-02-13 05:35:06.413000','2024-02-13 05:35:06.413000',2,37,1,'dae54f85-70bf-449a-b9ae-727a7e6158c2',4,63,NULL,NULL)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-02-23 04:51:56.126803	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt" )  VALUES (3,'Admin+Case Manager','Same as admin, but can have children assigned Has access to mobile application','admin+casemanager','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-13 05:35:25.905489	UPDATE  "public"."HT_users" SET "id"='a538ff49-c749-4221-92f5-044e64eaa1cc', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Sreeraj', "lastName"='P1', "phoneNumber"='+16546546546', "email"='sreer01aj.b@inapp.com', "addressLine1"='AD01 5th Street', "addressLine2"='', "city"='Texas North', "zipCode"='755774', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-13 05:35:06.413000', "updatedAt"='2024-02-13 05:35:15.877000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='dae54f85-70bf-449a-b9ae-727a7e6158c2', "HTUserRoleId"=4, "userCode"=63, "occupation"=NULL, "parentUserId"=NULL WHERE "id"='a538ff49-c749-4221-92f5-044e64eaa1cc'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_states	2024-02-14 08:54:58.968044	INSERT INTO "public"."HT_states" ( "id","stateName","stateCode","isActive","isDeleted","createdAt","updatedAt","HTCountryId" )  VALUES (39,'Washington','dss','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000',2)	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_states_pkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_districts	2024-02-14 08:56:34.662633	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId" )  VALUES (5,'New TXS Destrict','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000',37)	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_districts	2024-02-14 08:57:50.480296	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId" )  VALUES (6,'Washngtn Regn','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000',39)	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_districts	2024-02-14 08:58:14.584354	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId" )  VALUES (7,'Washngtn Regn 2','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000',39)	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 06:34:06.68671	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId","occupation","parentUserId","userCode","userTimezone" )  VALUES ('6271ab4b-e2f9-426d-88fd-f579ef74ef30',NULL,NULL,'Shagil','Tester','+18956232356','shagil.k1707978824195@mailinator.com','Address1','','Texas','654654','true','false',NULL,NULL,NULL,'usa','2024-02-15 06:34:00.644000','2024-02-15 06:34:00.644000',2,37,1,'4116c3d8-84ae-4733-9081-1769ce38355e',4,NULL,NULL,82,NULL)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 09:09:12.367553	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId","occupation","parentUserId","userCode","userTimezone" )  VALUES ('4d60b7f7-c332-4d57-ad9b-bf8c500c4e23',NULL,NULL,'Robert','DowneyJr','+19895098950','robertd@mailinator.com','ABC','','Texas','698523','true','false',NULL,NULL,NULL,'usa','2024-02-15 09:09:06.309000','2024-02-15 09:09:06.309000',2,37,1,'1000',4,NULL,NULL,83,NULL)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 09:09:32.368218	UPDATE  "public"."HT_users" SET "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Robert', "lastName"='DowneyJr', "phoneNumber"='+19895098950', "email"='robertd@mailinator.com', "addressLine1"='ABC', "addressLine2"='', "city"='Texas', "zipCode"='698523', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-15 09:09:06.309000', "updatedAt"='2024-02-15 09:09:26.438000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='1000', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=83, "userTimezone"=NULL WHERE "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 09:09:32.378073	UPDATE  "public"."HT_users" SET "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Robert', "lastName"='DowneyJr', "phoneNumber"='+19895098950', "email"='robertd@mailinator.com', "addressLine1"='ABC', "addressLine2"='', "city"='Texas', "zipCode"='698523', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-15 09:09:06.309000', "updatedAt"='2024-02-15 09:09:27.331000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='1000', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=83, "userTimezone"=NULL WHERE "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 09:09:41.967182	UPDATE  "public"."HT_users" SET "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Robert', "lastName"='DowneyJr', "phoneNumber"='+19895098950', "email"='robertd@mailinator.com', "addressLine1"='ABC', "addressLine2"='', "city"='Texas', "zipCode"='698523', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-15 09:09:06.309000', "updatedAt"='2024-02-15 09:09:41.961000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='1000', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=83, "userTimezone"=NULL WHERE "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-02-23 04:51:56.130004	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt" )  VALUES (4,'Admin+Social Worker','Same as admin, but can have children assigned Has access to mobile application','admin+caseworker','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 09:09:42.734532	UPDATE  "public"."HT_users" SET "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Robert', "lastName"='DowneyJr', "phoneNumber"='+19895098950', "email"='robertd@mailinator.com', "addressLine1"='ABC', "addressLine2"='', "city"='Texas', "zipCode"='698523', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-15 09:09:06.309000', "updatedAt"='2024-02-15 09:09:42.728000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='1000', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=83, "userTimezone"=NULL WHERE "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 09:09:52.278432	UPDATE  "public"."HT_users" SET "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23', "cognitoId"='784eae19-802f-42b6-9f0f-ddf574efe558', "oldCognitoId"=NULL, "firstName"='Robert', "lastName"='DowneyJr', "phoneNumber"='+19895098950', "email"='robertd@mailinator.com', "addressLine1"='ABC', "addressLine2"='', "city"='Texas', "zipCode"='698523', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-15 09:09:06.309000', "updatedAt"='2024-02-15 09:09:52.266000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='1000', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=83, "userTimezone"=NULL WHERE "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 09:26:00.189461	UPDATE  "public"."HT_users" SET "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23', "cognitoId"='784eae19-802f-42b6-9f0f-ddf574efe558', "oldCognitoId"=NULL, "firstName"='Robert', "lastName"='DowneyJr', "phoneNumber"='+19895098950', "email"='robertd@mailinator.com', "addressLine1"='ABC', "addressLine2"='', "city"='Texas', "zipCode"='698523', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-15 09:09:06.309000', "updatedAt"='2024-02-15 09:26:00.134000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='1000', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=83, "userTimezone"=NULL WHERE "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 09:26:00.745072	UPDATE  "public"."HT_users" SET "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23', "cognitoId"='784eae19-802f-42b6-9f0f-ddf574efe558', "oldCognitoId"=NULL, "firstName"='Robert', "lastName"='DowneyJr', "phoneNumber"='+19895098950', "email"='robertd@mailinator.com', "addressLine1"='ABC', "addressLine2"='', "city"='Texas', "zipCode"='698523', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-15 09:09:06.309000', "updatedAt"='2024-02-15 09:26:00.727000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='1000', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=83, "userTimezone"=NULL WHERE "id"='4d60b7f7-c332-4d57-ad9b-bf8c500c4e23'	0 rows affected
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 09:44:25.119434	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId","occupation","parentUserId","userCode","userTimezone" )  VALUES ('363dbd9a-0e10-4639-81d8-5d808d1a5ae9',NULL,NULL,'Shagil','Tester','+19895098950','shagil.k1707990190442@mailinator.com','Address1','','Texas','654654','true','false',NULL,NULL,NULL,'usa','2024-02-15 09:44:18.585000','2024-02-15 09:44:18.585000',2,37,1,'ab5d12a2-db6b-491c-94f3-54bb1655c8e5',4,NULL,NULL,84,NULL)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 10:00:41.530303	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId","occupation","parentUserId","userCode","userTimezone" )  VALUES ('5495b90b-4e60-4064-808f-79eedb366a10',NULL,NULL,'Shagil','Tester','+19856232356','shagil.k1707991221448@mailinator.com','Address1','','Uganda','654654','true','false',NULL,NULL,NULL,'uganda','2024-02-15 10:00:35.877000','2024-02-15 10:00:35.877000',3,38,1,'24bb1e2b-155b-4ae8-bd1c-3c51d1115973',4,NULL,NULL,85,NULL)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 10:14:21.310619	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId","occupation","parentUserId","userCode","userTimezone" )  VALUES ('2d38ded7-b475-4156-bb0c-c49a5562a7b5',NULL,NULL,'Shagil','Tester','+19856232356','shagil.k1707992040102@mailinator.com','Address1','','Uganda','654654','true','false',NULL,NULL,NULL,'uganda','2024-02-15 10:14:14.834000','2024-02-15 10:14:14.834000',3,38,1,'c9808887-e947-4b91-a2c4-c7075f1ff6f1',4,NULL,NULL,86,NULL)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-15 10:15:10.582624	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId","occupation","parentUserId","userCode","userTimezone" )  VALUES ('92e26130-a695-4d4c-9733-1ad03d1f9727',NULL,NULL,'Shagil','Tester','+19856232356','shagil.k1707992090400@mailinator.com','Address1','','Texas','654544','true','false',NULL,NULL,NULL,'usa','2024-02-15 10:15:04.534000','2024-02-15 10:15:04.534000',2,37,1,'b4570af7-fe72-4fc0-a369-942e6bcae60e',4,NULL,NULL,87,NULL)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-02-23 04:51:56.133231	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt" )  VALUES (5,'Social Worker','Only has access to assigned children','caseworker','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-16 09:22:46.93825	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId","occupation","parentUserId","userCode","userTimezone" )  VALUES ('52751db2-a86a-4586-b545-f6929c352058',NULL,NULL,'Shagil','Tester','+19856232356','shagil.k1708075342194@mailinator.com','Address1','','Uganda','654654','true','false',NULL,NULL,NULL,'uganda','2024-02-16 09:22:41.038000','2024-02-16 09:22:41.038000',3,38,1,'cae7045e-dc8b-4502-a59e-88ca0dda41ac',4,NULL,NULL,96,NULL)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-16 09:23:23.7218	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId","occupation","parentUserId","userCode","userTimezone" )  VALUES ('9328f68a-a73f-46b1-9e11-56d72890ba5d',NULL,NULL,'Shagil','Tester','+19856232356','shagil.k1708075381543@mailinator.com','Address1','','Texas','654544','true','false',NULL,NULL,NULL,'usa','2024-02-16 09:23:17.978000','2024-02-16 09:23:17.978000',2,37,1,'89059c40-6ab6-4e23-a859-da49328ed843',4,NULL,NULL,97,NULL)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-20 09:51:04.544786	INSERT INTO "public"."HT_users" ( "id","cognitoId","oldCognitoId","firstName","lastName","phoneNumber","email","addressLine1","addressLine2","city","zipCode","isActive","isDeleted","createdBy","updatedBy","injectiondocId","dbRegion","createdAt","updatedAt","HTCountryId","HTStateId","HTDistrictId","HTAccountId","HTUserRoleId","occupation","parentUserId","userCode","userTimezone" )  VALUES ('3ce6579b-1b63-4596-a310-265789cf97f9',NULL,NULL,'Sree','rajB','+917012006775','sreeraj.b12@inapp.com','AD01 5th Street','','Texas North','677733','true','false',NULL,NULL,NULL,'usa','2024-02-20 09:50:58.670000','2024-02-20 09:50:58.670000',2,37,1,'1001',7,NULL,NULL,117,NULL)	RetCode: SQL_ERROR  SqlState: 23503 NativeError: 1 Message: ERROR: insert or update on table "HT_users" violates foreign key constraint "HT_users_HTAccountId_fkey";\nError while executing the query
FOYOSPMJ5CIVID3NE4GJI4QEZEM523I5XKZZKXA	public	HT_users	2024-02-20 09:51:26.154306	UPDATE  "public"."HT_users" SET "id"='3ce6579b-1b63-4596-a310-265789cf97f9', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Sree', "lastName"='rajB', "phoneNumber"='+917012006775', "email"='sreeraj.b12@inapp.com', "addressLine1"='AD01 5th Street', "addressLine2"='', "city"='Texas North', "zipCode"='677733', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-20 09:50:58.670000', "updatedAt"='2024-02-20 09:51:20.666000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='1001', "HTUserRoleId"=7, "occupation"=NULL, "parentUserId"=NULL, "userCode"=117, "userTimezone"=NULL WHERE "id"='3ce6579b-1b63-4596-a310-265789cf97f9'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_accountTypes	2024-02-23 04:50:42.405162	INSERT INTO "public"."HT_accountTypes" ( "id","name","description","isActive","isDeleted","createdAt","updatedAt" )  VALUES (1,'Miracle Foundation',NULL,'true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_accountTypes_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_accountTypes	2024-02-23 04:50:42.420522	INSERT INTO "public"."HT_accountTypes" ( "id","name","description","isActive","isDeleted","createdAt","updatedAt" )  VALUES (5,'Private CCI',NULL,'true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_accountTypes_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_accountTypes	2024-02-23 04:50:42.423944	INSERT INTO "public"."HT_accountTypes" ( "id","name","description","isActive","isDeleted","createdAt","updatedAt" )  VALUES (4,'NGO/Partner',NULL,'true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_accountTypes_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_accountTypes	2024-02-23 04:50:42.427112	INSERT INTO "public"."HT_accountTypes" ( "id","name","description","isActive","isDeleted","createdAt","updatedAt" )  VALUES (3,'Govt Organization',NULL,'true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_accountTypes_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_accountTypes	2024-02-23 04:50:42.430295	INSERT INTO "public"."HT_accountTypes" ( "id","name","description","isActive","isDeleted","createdAt","updatedAt" )  VALUES (2,'Govt CCI',NULL,'true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_accountTypes_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-02-23 04:51:56.107648	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt" )  VALUES (1,'Super Admin','Add/edit/view users in this organization Can view children assigned to Social Workers Can view assessments and reports No access to mobile application','superadmin','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-02-23 04:51:56.121878	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt" )  VALUES (2,'Admin','Add/edit/view users in this organization Can view children assigned to Social Workers Can view assessments and reports No access to mobile application','admin','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-02-23 04:51:56.136317	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt" )  VALUES (6,'Case Manager','Only has access to assigned children','casemanager','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-02-23 04:51:56.139324	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt" )  VALUES (7,'View Only','Can view account/user information View only permissions to child data','viewonly','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-02-23 04:51:56.142179	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt" )  VALUES (8,'Parent','Have Access to mobile application only','parent','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-02-23 04:51:56.145069	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt" )  VALUES (9,'Unassigned','User does not have access','unassigned','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-02-27 10:57:21.611446	UPDATE  "public"."HT_users" SET "id"='b7e3a489-e3ad-40cb-86bf-caece3189c8b', "cognitoId"='d5e00260-3d5d-4cf3-9b14-04e17727850d', "oldCognitoId"=NULL, "firstName"='inapp', "lastName"='admin', "phoneNumber"='+16785356897', "email"='inappadmin@yopmail.com', "addressLine1"='test street', "addressLine2"='north', "city"='tx', "zipCode"='56786', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-27 05:01:31.155000', "updatedAt"='2024-02-27 10:57:15.576000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"='8ae1305c-52cd-40be-a0ae-43b1b6d6ed78', "HTUserRoleId"=9, "occupation"=NULL, "parentUserId"=NULL, "userCode"=129, "userTimezone"=NULL, "caseManagerId"=NULL WHERE "id"='b7e3a489-e3ad-40cb-86bf-caece3189c8b'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-02-28 05:02:33.293366	UPDATE  "public"."HT_users" SET "id"='cb0248b1-5ddc-4837-9920-82aebd99a409', "cognitoId"='0a096b49-8c48-4fb8-94f2-ffa30fe5e0a1', "oldCognitoId"=NULL, "firstName"='SocialWorker-01', "lastName"='Inapp', "phoneNumber"='+919877665678', "email"='socialworker@yopmail.com', "addressLine1"='ABC', "addressLine2"='', "city"='TRV', "zipCode"='676567', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-26 07:07:44.436000', "updatedAt"='2024-02-26 07:08:56.947000', "HTCountryId"=1, "HTStateId"=18, "HTDistrictId"=1, "HTAccountId"='6d939888-8b9a-4b8d-89d6-f3878c7b567d', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=125, "userTimezone"=NULL, "caseManagerId"=NULL WHERE "id"='cb0248b1-5ddc-4837-9920-82aebd99a409'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-02-28 08:54:30.844714	UPDATE  "public"."HT_users" SET "id"='b7e3a489-e3ad-40cb-86bf-caece3189c8b', "cognitoId"='d5e00260-3d5d-4cf3-9b14-04e17727850d', "oldCognitoId"=NULL, "firstName"='inapp', "lastName"='admin', "phoneNumber"='+16785356897', "email"='inappadmin@yopmail.com', "addressLine1"='test street', "addressLine2"='north', "city"='tx', "zipCode"='56786', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-27 05:01:31.155000', "updatedAt"='2024-02-27 10:57:15.576000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"=NULL, "HTUserRoleId"=9, "occupation"=NULL, "parentUserId"=NULL, "userCode"=129, "userTimezone"=NULL, "caseManagerId"=NULL WHERE "id"='b7e3a489-e3ad-40cb-86bf-caece3189c8b'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-02-28 08:54:30.858714	UPDATE  "public"."HT_users" SET "id"='10912793-f1c1-4054-8478-a4f4475c5afe', "cognitoId"='2866fd9e-42d4-445c-abbc-69d6a74cb491', "oldCognitoId"=NULL, "firstName"='Test', "lastName"='Kumar', "phoneNumber"='+16785356897', "email"='testkumar@mailinator.com', "addressLine1"='test street', "addressLine2"='north', "city"='tx', "zipCode"='56786', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-26 08:30:41.005000', "updatedAt"='2024-02-27 10:58:34.010000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"=NULL, "HTUserRoleId"=9, "occupation"=NULL, "parentUserId"=NULL, "userCode"=126, "userTimezone"=NULL, "caseManagerId"=NULL WHERE "id"='10912793-f1c1-4054-8478-a4f4475c5afe'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-02-28 08:54:30.862034	UPDATE  "public"."HT_users" SET "id"='21e91883-afa6-425d-8077-c55267a4475a', "cognitoId"='ad8da099-989d-47f5-a5bb-6dc8d20f9865', "oldCognitoId"=NULL, "firstName"='Mob Dev', "lastName"='Parent', "phoneNumber"='+16785443455', "email"='mobdevparent@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-28 05:21:03.480000', "updatedAt"='2024-02-28 05:22:46.659000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"=NULL, "HTUserRoleId"=NULL, "occupation"='nill', "parentUserId"=NULL, "userCode"=136, "userTimezone"=NULL, "caseManagerId"='0bade7ba-1d2f-4262-9e0f-b9b474609b76' WHERE "id"='21e91883-afa6-425d-8077-c55267a4475a'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-02-28 08:54:30.864747	UPDATE  "public"."HT_users" SET "id"='43ada0b1-0b3c-4b30-af63-6155a8214679', "cognitoId"='a06f9b36-5ad1-4d38-917f-6f41e6766605', "oldCognitoId"=NULL, "firstName"='mob dev', "lastName"='cm', "phoneNumber"='+16785356897', "email"='mobdevcm@yopmail.com', "addressLine1"='test street', "addressLine2"='north', "city"='tx', "zipCode"='56786', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-28 04:19:23.527000', "updatedAt"='2024-02-28 05:16:32.066000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"=NULL, "HTUserRoleId"=9, "occupation"=NULL, "parentUserId"=NULL, "userCode"=134, "userTimezone"=NULL, "caseManagerId"=NULL WHERE "id"='43ada0b1-0b3c-4b30-af63-6155a8214679'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-02-28 08:54:30.867163	UPDATE  "public"."HT_users" SET "id"='0bade7ba-1d2f-4262-9e0f-b9b474609b76', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Mob', "lastName"='Case Manager', "phoneNumber"='+16785356897', "email"='mobcasemanager@yopmail.com', "addressLine1"='test street', "addressLine2"='north', "city"='tx', "zipCode"='56786', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-28 05:19:18.081000', "updatedAt"='2024-02-28 05:19:18.081000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"=NULL, "HTUserRoleId"=9, "occupation"=NULL, "parentUserId"=NULL, "userCode"=135, "userTimezone"=NULL, "caseManagerId"=NULL WHERE "id"='0bade7ba-1d2f-4262-9e0f-b9b474609b76'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-02-28 08:54:30.869712	UPDATE  "public"."HT_users" SET "id"='a3ad2fb0-dd3c-490a-ba8a-60a0251e3206', "cognitoId"='b4ace79e-00e9-4b0d-a8ac-7c4db52722ba', "oldCognitoId"=NULL, "firstName"='Admin FS Sreeraj', "lastName"='USA', "phoneNumber"='+19497288333', "email"='admin.fostershare.usa@yopmail.com', "addressLine1"='FosterShare USA', "addressLine2"='', "city"='Texas City USA', "zipCode"='12345', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-28 06:31:55.589000', "updatedAt"='2024-02-28 07:19:39.658000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=1, "HTAccountId"=NULL, "HTUserRoleId"=9, "occupation"=NULL, "parentUserId"=NULL, "userCode"=137, "userTimezone"=NULL, "caseManagerId"=NULL WHERE "id"='a3ad2fb0-dd3c-490a-ba8a-60a0251e3206'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-02-28 08:54:30.872128	UPDATE  "public"."HT_users" SET "id"='5f44bc89-cd49-470b-a610-9893f86db99b', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Primary Parent QA01', "lastName"='FS_USA', "phoneNumber"='+19497288333', "email"='primaryparent.fs.usa@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"=NULL, "updatedBy"=NULL, "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-02-28 07:23:10.909000', "updatedAt"='2024-02-28 07:23:10.909000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"=NULL, "HTUserRoleId"=NULL, "occupation"='', "parentUserId"=NULL, "userCode"=138, "userTimezone"=NULL, "caseManagerId"='0bade7ba-1d2f-4262-9e0f-b9b474609b76' WHERE "id"='5f44bc89-cd49-470b-a610-9893f86db99b'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-03-20 05:30:05.582611	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt","roleLang","descriptionLang" )  VALUES (3,'Admin+Case Manager','Same as admin, but can have children assigned Has access to mobile application','admin+casemanager','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000','{"1" : "Admin+Case Manager", "2" : "व्यवस्थापक+केस प्रबंधक", "3" : "நிர்வாகி+வழக்கு மேலாளர்"}','{"1" : "Same as admin, but can have children assigned. Has access to mobile application", "2" : "व्यवस्थापक के समान, लेकिन बच्चों को सौंपा जा सकता है। मोबाइल एप्लिकेशन तक पहुंच है", "3" : "நிர்வாகி போல, ஆனால் குழந்தைகள் ஒதுக்கப்படலாம். மொபைல் பயன்பாட்டிற்கு அணுகல் உள்ளது"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-03-20 05:30:05.599692	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt","roleLang","descriptionLang" )  VALUES (4,'Admin+Social Worker','Same as admin, but can have children assigned Has access to mobile application','admin+caseworker','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000','{"1" : "Admin+Social Worker", "2" : "व्यवस्थापक+सामाजिक कार्यकर्ता", "3" : "நிர்வாகி+சமூக உதவி"}','{"1" : "Same as admin, but can have children assigned. Has access to mobile application", "2" : "व्यवस्थापक के समान, लेकिन बच्चों को सौंपा जा सकता है। मोबाइल एप्लिकेशन तक पहुंच है", "3" : "நிர்வாகி போல, ஆனால் குழந்தைகள் ஒதுக்கப்படலாம். மொபைல் பயன்பாட்டிற்கு அணுகல் உள்ளது"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-03-20 05:30:05.603134	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt","roleLang","descriptionLang" )  VALUES (5,'Social Worker','Only has access to assigned children','caseworker','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000','{"1" : "Social Worker", "2" : "सामाजिक कार्यकर्ता", "3" : "சமூக உதவி"}','{"1" : "Only has access to assigned children", "2" : "केवल निर्धारित बच्चों का पहुंच है", "3" : "ஒதுக்கிய குழந்தைகளுக்கு மட்டும் அணுகல் உள்ளது"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-03-20 05:30:05.606649	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt","roleLang","descriptionLang" )  VALUES (6,'Case Manager','Only has access to assigned children','casemanager','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000','{"1" : "Case Manager", "2" : "केस प्रबंधक", "3" : "வழக்கு மேலாளர்"}','{"1" : "Only has access to assigned children", "2" : "केवल निर्धारित बच्चों का पहुंच है", "3" : "ஒதுக்கிய குழந்தைகளுக்கு மட்டும் அணுகல் உள்ளது"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.452737	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (7,'Barren Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Barren Island", "2" : "बंजर द्वीप", "3" : "பாரன் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-03-20 05:30:05.61075	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt","roleLang","descriptionLang" )  VALUES (7,'View Only','Can view account/user information View only permissions to child data','viewonly','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000','{"1" : "View Only", "2" : "केवल देखें", "3" : "மட்டும் காண்க"}','{"1" : "Can view account/user information. View only permissions to child data", "2" : "खाता/उपयोगकर्ता जानकारी देख सकते हैं। बच्चों के डेटा के लिए केवल अनुमतियाँ देखें", "3" : "கணக்கு/பயனர் தகவலை பார்க்கலாம். குழந்தை தரவுகளுக்கான மட்டும் உரிமைகளை பார்க்கலாம்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-03-20 05:30:05.613996	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt","roleLang","descriptionLang" )  VALUES (8,'Parent','Have Access to mobile application only','parent','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000','{"1" : "Parent", "2" : "माता-पिता", "3" : "பெற்றோர்"}','{"1" : "Have Access to mobile application only", "2" : "केवल मोबाइल एप्लिकेशन का उपयोग कर सकते हैं", "3" : "மொபைல் பயன்பாட்டிற்க"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-03-20 05:30:05.617446	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt","roleLang","descriptionLang" )  VALUES (9,'Unassigned','User does not have access','unassigned','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000','{"1" : "Unassigned", "2" : "अनसाइन", "3" : "ஒதுக்கப்படாதது"}','{"1" : "User does not have access", "2" : "उपयोगकर्ता के पास पहुंच नहीं है", "3" : "பயனருக்கு அணுகல் இல்லை"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-03-20 05:30:05.620378	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt","roleLang","descriptionLang" )  VALUES (2,'Admin','Add/edit/view users in this organization Can view children assigned to Social Workers Can view assessments and reports No access to mobile application','admin','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000','{"1" : "Admin", "2" : "व्यवस्थापक", "3" : "நிர்வாகி"}','{"1" : "Add/edit/view users in this organization. Can view children assigned to Social Workers. Can view assessments and reports. No access to mobile application", "2" : "इस संगठन में उपयोगकर्ताओं को जोड़ें/संपादित करें/देखें। सामाजिक कार्यकर्ताओं को सौंपे गए बच्चों को देख सकते हैं। आकलन और रिपोर्ट देख सकते हैं. मोबाइल एप्लिकेशन तक पहुंच नहीं", "3" : "இந்த நிறுவனத்தில் பயனர்களைச் சேர்க்கவும்/திருத்தவும்/பார்க்கவும். சமூகப் பணியாளர்களுக்கு ஒதுக்கப்பட்ட குழந்தைகளைப் பார்க்கலாம். மதிப்பீடுகளையும் அறிக்கைகளையும் பார்க்கலாம். மொபைல் பயன்பாட்டிற்கான அணுகல் இல்லை "}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_userRoles	2024-03-20 05:30:05.623742	INSERT INTO "public"."HT_userRoles" ( "id","role","description","cognitoValue","isActive","isDeleted","createdAt","updatedAt","roleLang","descriptionLang" )  VALUES (1,'Super Admin','Add/edit/view users in this organization Can view children assigned to Social Workers Can view assessments and reports No access to mobile application','superadmin','true','false','2024-01-10 09:34:22.000000','2024-01-10 09:34:22.000000','{"1" : "Super Admin", "2" : "सुपर व्यवस्थापक", "3" : "சூப்பர் அட்மின்"}','{"1" : "Add/edit/view users in this organization. Can view children assigned to Social Workers. Can view assessments and reports. No access to mobile application", "2" : "इस संगठन में उपयोगकर्ताओं को जोड़ें/संपादित करें/देखें। सामाजिक कार्यकर्ताओं को सौंपे गए बच्चों को देख सकते हैं। आकलन और रिपोर्ट देख सकते हैं. मोबाइल एप्लिकेशन तक पहुंच नहीं", "3" : "இந்த நிறுவனத்தில் பயனர்களைச் சேர்க்கவும்/திருத்தவும்/பார்க்கவும். சமூகப் பணியாளர்களுக்கு ஒதுக்கப்பட்ட குழந்தைகளைப் பார்க்கலாம். மதிப்பீடுகளையும் அறிக்கைகளையும் பார்க்கலாம். மொபைல் பயன்பாட்டிற்கான அணுகல் இல்லை "}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_userRoles_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_accountTypes	2024-03-20 05:38:20.258893	INSERT INTO "public"."HT_accountTypes" ( "id","name","description","isActive","isDeleted","createdAt","updatedAt","nameLang","descriptionLang" )  VALUES (1,'Miracle Foundation','Only Miracle Foundation USA, Miracle Foundation India','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000','{"1": "Miracle Foundation", "2": "मिराकल फाउंडेशन", "3": "அதிசயமான அமைப்பு"}','{"1": "Only Miracle Foundation USA, Miracle Foundation India, and other future branches (Internal only)", "2": "केवल मिराकल फाउंडेशन यूएसए, मिराकल फाउंडेशन इंडिया, और अन्य भविष्य की शाखाएँ (केवल आंतरिक) ", "3": "கேவலமாக மிராக்கிள் அமைப்பு யூஎஸ்ஏ, மிராக்கிள் அமைப்பு இந்தியா, மற்றும் மொத்த எதிர்கால கிளைகள் (உள்ளூர் மட்டும்)"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_accountTypes_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_accountTypes	2024-03-20 05:38:20.273957	INSERT INTO "public"."HT_accountTypes" ( "id","name","description","isActive","isDeleted","createdAt","updatedAt","nameLang","descriptionLang" )  VALUES (2,'Govt CCI','Child Care Institution that is funded and operated by the gov''t','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000','{"1": "Govt CCI", "2": "सरकारी सीसीआई", "3": "அரசியல் சிசிஐ"}','{"1": "Child Care Institution that is funded and operated by the gov''t", "2": "सरकार द्वारा अनुदानित और संचालित बच्चों की देखभाल संस्थान", "3": "அரசு மூலம் அநுபவிக்கப்படும் மற்றும் செயலாக்குக்கான பிள்ளை பராமரிப்பு நிறுவனம்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_accountTypes_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_accountTypes	2024-03-20 05:38:20.279112	INSERT INTO "public"."HT_accountTypes" ( "id","name","description","isActive","isDeleted","createdAt","updatedAt","nameLang","descriptionLang" )  VALUES (3,'Govt Organization','Any entity that operates as a component of a government','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000','{"1": "Govt Organization", "2": "सरकारी संगठन", "3": "அரசு அமைப்பு"}','{"1": "Any entity that operates as a component of a government", "2": "सरकार के एक घटक के रूप में संचालित कोई भी संस्था", "3": "அரசின் ஒரு பொருளாதாரமாக நடக்கும் எந்த பொருளாதாரம்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_accountTypes_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_accountTypes	2024-03-20 05:38:20.282842	INSERT INTO "public"."HT_accountTypes" ( "id","name","description","isActive","isDeleted","createdAt","updatedAt","nameLang","descriptionLang" )  VALUES (4,'NGO/Partner','Any organization that child welfare organization or funding organization','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000','{"1": "NGO/Partner", "2": "एनजीओ/साथी संगठन", "3": "என்ஜியோ/கூட்டுத்திறனாளி"}','{"1": "Any organization that child welfare organization or funding organization", "2": "बाल कल्याण संगठन या अनुदान संगठन कोई भी संगठन", "3": "குழந்தை கல்யாண அமைப்பு அல்லது அமைத்திய அமைப்பு எந்த நிறுவனம்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_accountTypes_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_accountTypes	2024-03-20 05:38:20.285937	INSERT INTO "public"."HT_accountTypes" ( "id","name","description","isActive","isDeleted","createdAt","updatedAt","nameLang","descriptionLang" )  VALUES (5,'Private CCI','Child Care Institution that is privately funded.','true','false','2024-01-16 07:01:42.000000','2024-01-16 07:01:42.000000','{"1": "Private CCI", "2": "निजी सीसीआई", "3": "தனியார் சிசிஐ"}','{"1": "Child Care Institution that is privately funded.", "2": "निजी धन से अनुदानित बच्चों की देखभाल संस्थान।", "3": "தனியார் அமைத்திய பொருளாதார பிள்ளை பராமரிப்பு நிறுவனம்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_accountTypes_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.416837	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (1,'Alipur','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Alipur", "2" : "अलीपुर", "3" : "அலிபூர்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.434354	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (2,'Andaman Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Andaman Island", "2" : "अंडमान द्वीप", "3" : "அந்தமான் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.437797	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (3,'Anderson Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Anderson Island", "2" : "एंडरसन द्वीप", "3" : "ஆண்டர்சன் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.44124	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (4,'Arainj-Laka-Punga','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Arainj-Laka-Punga", "2" : "अरंज-लाका-पुंगा", "3" : "Arainj-Laka-Punga"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.445244	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (5,'Austinabad','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Austinabad", "2" : "ऑस्टिनाबाद", "3" : "Ustinbad"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.449404	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (6,'Bamboo Flat','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Bamboo Flat", "2" : "बांस फ्लैट", "3" : "பம்பூ பிளாட்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.456371	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (8,'Beadonabad','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Beadonabad", "2" : "बीडोनेबाद", "3" : "பெடோனாபாத்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.459924	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (9,'Betapur','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Betapur", "2" : "बेटापुर", "3" : "பெட்பூர்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.464352	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (10,'Bindraban','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Bindraban", "2" : "बिंद्राबन", "3" : "பிணைப்பு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.467869	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (11,'Bonington','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Bonington", "2" : "बोनिंगटन", "3" : "போனிங்டன்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.471611	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (12,'Brookesabad','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Brookesabad", "2" : "ब्रुकसेबाद", "3" : "ப்ரூக்ஸாபாத்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.475047	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (13,'Cadell Point','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Cadell Point", "2" : "कैडेल प्वाइंट", "3" : "காடெல் புள்ளி"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.478541	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (14,'Calicut','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Calicut", "2" : "कालीकट", "3" : "காலிகட்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.482053	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (15,'Chetamale','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Chetamale", "2" : "चेतमेल", "3" : "சேட்டமலே"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.486558	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (16,'Cinque Islands','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Cinque Islands", "2" : "सिंक द्वीपसमूह", "3" : "சின்க் தீவுகள்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.489927	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (17,'Defence Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Defence Island", "2" : "रक्षा द्वीप", "3" : "பாதுகாப்பு தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.494372	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (18,'Digilpur','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Digilpur", "2" : "दिगिलपुर", "3" : "டிஜில்பூர்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.497878	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (19,'Dolyganj','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Dolyganj", "2" : "डोलीगंज", "3" : "Dolyginj"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.501212	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (20,'Flat Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Flat Island", "2" : "फ्लैट द्वीप", "3" : "பிளாட் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.504783	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (21,'Geinyale','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Geinyale", "2" : "जिन्याल", "3" : "புவி"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.508162	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (22,'Great Coco Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Great Coco Island", "2" : "ग्रेट कोको द्वीप", "3" : "சிறந்த கோகோ தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.51146	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (23,'Haddo','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Haddo", "2" : "हड्डो", "3" : "ஹடோ"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.515618	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (24,'Havelock Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Havelock Island", "2" : "हवेलॉक आइलैंड", "3" : "ஹேவ்லாக் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.519442	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (25,'Henry Lawrence Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Henry Lawrence Island", "2" : "हेनरी लॉरेंस आइलैंड", "3" : "ஹென்றி லாரன்ஸ் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.522703	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (26,'Herbertabad','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Herbertabad", "2" : "हरर्बटाबाद", "3" : "ஹெர்பெர்டாபாத்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.526057	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (27,'Hobdaypur','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Hobdaypur", "2" : "हॉबीपुर", "3" : "ஹாப்டேபூர்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.529454	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (28,'Ilichar','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Ilichar", "2" : "इल्चर", "3" : "Ilichar"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.533614	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (29,'Ingoie','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Ingoie", "2" : "आंत्र", "3" : "Ingoie"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.537031	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (30,'Inteview Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Inteview Island", "2" : "इंटीव्यू आइलैंड", "3" : "இன்டிவியூ தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.540478	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (31,'Jangli Ghat','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Jangli Ghat", "2" : "जंगली घाट", "3" : "ஜாங்லி காட்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.543935	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (32,'Jhon Lawrence Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Jhon Lawrence Island", "2" : "झोन लॉरेंस आइलैंड", "3" : "ஜான் லாரன்ஸ் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.547686	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (33,'Karen','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Karen", "2" : "करें", "3" : "கரேன்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.551432	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (34,'Kartara','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Kartara", "2" : "करतारा", "3" : "கர்தாரா"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.554884	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (35,'KYD Islannd','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "KYD Islannd", "2" : "कैद इसलैंड", "3" : "KYD ISLANND"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.558528	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (36,'Landfall Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Landfall Island", "2" : "लैंडफॉल आइलैंड", "3" : "நிலச்சரிவு தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.562094	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (37,'Little Andmand','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Little Andmand", "2" : "लिटिल अंडमाण्ड", "3" : "சிறிய மற்றும் மேண்ட்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.565614	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (38,'Little Coco Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Little Coco Island", "2" : "लिटिल कोको आइलैंड", "3" : "சிறிய கோகோ தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.568984	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (39,'Long Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Long Island", "2" : "लॉन्ग आइलैंड", "3" : "நீண்ட தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.572404	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (40,'Maimyo','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Maimyo", "2" : "मैमो", "3" : "மைமியோ"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.575766	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (41,'Malappuram','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Malappuram", "2" : "मलप्पुरम", "3" : "மலப்புரம்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.579168	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (42,'Manglutan','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Manglutan", "2" : "मंगलुटान", "3" : "மங்க்லூட்டன்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.582463	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (43,'Manpur','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Manpur", "2" : "मानपुर", "3" : "மன்பூர்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.585772	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (44,'Mitha Khari','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Mitha Khari", "2" : "मिथा खारी", "3" : "மிதா காரி"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.590054	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (45,'Neill Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Neill Island", "2" : "नील द्वीप", "3" : "நீல் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.593444	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (46,'Nicobar Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Nicobar Island", "2" : "निकोबार द्वीप", "3" : "நிக்கோபார் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.596906	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (47,'North Brother Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "North Brother Island", "2" : "उत्तरी भाई द्वीप", "3" : "வடக்கு சகோதரர் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.600373	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (48,'North Passage Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "North Passage Island", "2" : "उत्तर मार्ग द्वीप", "3" : "வடக்கு பாஸேஜ் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.603696	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (49,'North Sentinel Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "North Sentinel Island", "2" : "उत्तरी सेंटीनेल द्वीप", "3" : "வடக்கு சென்டினல் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.607029	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (50,'Nothen Reef Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Nothen Reef Island", "2" : "नॉटेन रीफ द्वीप", "3" : "நோத்தன் ரீஃப் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.61041	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (51,'Outram Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Outram Island", "2" : "आउट्राम द्वीप", "3" : "அட்ராம் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.613791	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (52,'Pahlagaon','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Pahlagaon", "2" : "पहलागांव", "3" : "பஹ்லகான்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.61701	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (53,'Palalankwe','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Palalankwe", "2" : "पलालंक्वे", "3" : "பலாலங்க்வே"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.620361	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (54,'Passage Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Passage Island", "2" : "मार्ग द्वीप", "3" : "பாஸேஜ் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.623795	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (55,'Phaiapong','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Phaiapong", "2" : "फाइपोंग", "3" : "பையாபோங்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.627313	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (56,'Phoenix Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Phoenix Island", "2" : "फीनिक्स आइलैंड", "3" : "பீனிக்ஸ் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.630547	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (57,'Port Blair','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Port Blair", "2" : "पोर्ट ब्लेयर", "3" : "போர்ட் பிளேர்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.634313	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (58,'Preparis Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Preparis Island", "2" : "तैयारी द्वीप", "3" : "ரெப்பரிஸ் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.637688	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (59,'Protheroepur','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Protheroepur", "2" : "प्रकोष्ठ", "3" : "Protheroepur"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.641076	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (60,'Rangachang','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Rangachang", "2" : "रंगाचांग", "3" : "ரங்கச்சாங்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.644456	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (61,'Rongat','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Rongat", "2" : "रोंगत", "3" : "ரோங்காட்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.647935	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (62,'Rutland Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Rutland Island", "2" : "रूटलैंड द्वीप", "3" : "ரட்லேண்ட் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.656697	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (63,'Sabari','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Sabari", "2" : "साबारी", "3" : "சபாரி"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.66087	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (64,'Saddle Peak','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Saddle Peak", "2" : "सैडल पीक", "3" : "சேணம் உச்சம்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.664142	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (65,'Shadipur','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Shadipur", "2" : "शादीपुर", "3" : "ஷாடிபூர்"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.667373	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (66,'Smith Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Smith Island", "2" : "स्मिथ आइलैंड", "3" : "ஸ்மித் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.670545	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (67,'Sound Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Sound Island", "2" : "ध्वनि द्वीप", "3" : "ஒலி தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.673824	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (68,'South Sentinel Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "South Sentinel Island", "2" : "दक्षिण सेंटीनेल द्वीप", "3" : "தெற்கு சென்டினல் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.677304	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (69,'Spike Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Spike Island", "2" : "स्पाइक आइलैंड", "3" : "ஸ்பைக் தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_districts	2024-03-20 06:40:28.680974	INSERT INTO "public"."HT_districts" ( "id","districtName","isActive","isDeleted","createdAt","updatedAt","HTStateId","districtNameLang" )  VALUES (70,'Tarmugli Island','true','false','2021-10-27 11:17:25.289000','2021-10-27 11:17:25.289000',1,'{"1" : "Tarmugli Island", "2" : "तारगुली द्वीप", "3" : "தர்முக்லி தீவு"}')	RetCode: SQL_ERROR  SqlState: 23505 NativeError: 1 Message: ERROR: duplicate key value violates unique constraint "HT_districts_pkey";\nError while executing the query
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-04-17 12:12:27.549625	UPDATE  "public"."HT_users" SET "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jyotir', "lastName"='Nagpal', "phoneNumber"='+12812223333', "email"='jyotir@miraclefoundation.org', "addressLine1"='TBD', "addressLine2"='', "city"='TBD', "zipCode"='78735', "isActive"='false', "isDeleted"='false', "createdBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "updatedBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 00:12:43.789000', "updatedAt"='2024-04-17 12:12:21.478000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=2, "occupation"=NULL, "parentUserId"=NULL, "userCode"=359, "userTimezone"=NULL, "caseManagerId"=NULL, "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-04-17 12:12:32.854499	UPDATE  "public"."HT_users" SET "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jyotir', "lastName"='Nagpal', "phoneNumber"='+12812223333', "email"='jyotir@miraclefoundation.org', "addressLine1"='TBD', "addressLine2"='', "city"='TBD', "zipCode"='78735', "isActive"='false', "isDeleted"='false', "createdBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "updatedBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 00:12:43.789000', "updatedAt"='2024-04-17 12:12:32.849000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=2, "occupation"=NULL, "parentUserId"=NULL, "userCode"=359, "userTimezone"=NULL, "caseManagerId"=NULL, "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-04-17 12:12:38.016076	UPDATE  "public"."HT_users" SET "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jyotir', "lastName"='Nagpal', "phoneNumber"='+12812223333', "email"='jyotir@miraclefoundation.org', "addressLine1"='TBD', "addressLine2"='', "city"='TBD', "zipCode"='78735', "isActive"='false', "isDeleted"='false', "createdBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "updatedBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 00:12:43.789000', "updatedAt"='2024-04-17 12:12:38.010000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=2, "occupation"=NULL, "parentUserId"=NULL, "userCode"=359, "userTimezone"=NULL, "caseManagerId"=NULL, "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-04-17 12:12:39.480082	UPDATE  "public"."HT_users" SET "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jyotir', "lastName"='Nagpal', "phoneNumber"='+12812223333', "email"='jyotir@miraclefoundation.org', "addressLine1"='TBD', "addressLine2"='', "city"='TBD', "zipCode"='78735', "isActive"='false', "isDeleted"='false', "createdBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "updatedBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 00:12:43.789000', "updatedAt"='2024-04-17 12:12:39.476000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=2, "occupation"=NULL, "parentUserId"=NULL, "userCode"=359, "userTimezone"=NULL, "caseManagerId"=NULL, "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-04-22 19:26:50.343944	UPDATE  "public"."HT_users" SET "id"='cb2f9c80-78fc-4e05-b1fc-4ce1f0ad0ffb', "cognitoId"='77d29da8-8c86-4341-b9c5-05158ae2c2c9', "oldCognitoId"=NULL, "firstName"='Family1', "lastName"='Test', "phoneNumber"='+15122101234', "email"='fsfamily1@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='78c7a329-36a7-45d6-9ad8-4efec6d3136d', "updatedBy"='0b9b34f2-dd92-4191-b023-f4ae32884964', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 14:35:35.732000', "updatedAt"='2024-04-22 19:26:44.306000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=NULL, "occupation"='', "parentUserId"=NULL, "userCode"=366, "userTimezone"=NULL, "caseManagerId"='0ac84ba8-9cd7-4536-a3c9-aff6b4b69f68', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='cb2f9c80-78fc-4e05-b1fc-4ce1f0ad0ffb'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-04-22 19:27:50.099862	UPDATE  "public"."HT_users" SET "id"='cb2f9c80-78fc-4e05-b1fc-4ce1f0ad0ffb', "cognitoId"='77d29da8-8c86-4341-b9c5-05158ae2c2c9', "oldCognitoId"=NULL, "firstName"='Family1', "lastName"='Test', "phoneNumber"='+15122101234', "email"='fsfamily1@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='78c7a329-36a7-45d6-9ad8-4efec6d3136d', "updatedBy"='0b9b34f2-dd92-4191-b023-f4ae32884964', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 14:35:35.732000', "updatedAt"='2024-04-22 19:27:50.094000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=NULL, "occupation"='', "parentUserId"=NULL, "userCode"=366, "userTimezone"=NULL, "caseManagerId"='b10b2b1a-7ffa-474d-b4af-6065e0dff40f', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='cb2f9c80-78fc-4e05-b1fc-4ce1f0ad0ffb'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-04-24 05:06:42.410774	UPDATE  "public"."HT_users" SET "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9', "cognitoId"='827b4381-3556-4bca-82d9-e186d0aae8d7', "oldCognitoId"=NULL, "firstName"='Jyotir', "lastName"='Nagpal', "phoneNumber"='+12812223333', "email"='jyotir@miraclefoundation.org', "addressLine1"='TBD', "addressLine2"='', "city"='TBD', "zipCode"='78735', "isActive"='true', "isDeleted"='false', "createdBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "updatedBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 00:12:43.789000', "updatedAt"='2024-04-24 05:06:35.657000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=2, "occupation"=NULL, "parentUserId"=NULL, "userCode"=359, "userTimezone"=NULL, "caseManagerId"=NULL, "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-04-24 05:06:42.42735	UPDATE  "public"."HT_users" SET "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9', "cognitoId"='827b4381-3556-4bca-82d9-e186d0aae8d7', "oldCognitoId"=NULL, "firstName"='Jyotir', "lastName"='Nagpal', "phoneNumber"='+12812223333', "email"='jyotir@miraclefoundation.org', "addressLine1"='TBD', "addressLine2"='', "city"='TBD', "zipCode"='78735', "isActive"='true', "isDeleted"='false', "createdBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "updatedBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 00:12:43.789000', "updatedAt"='2024-04-24 05:06:37.366000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=2, "occupation"=NULL, "parentUserId"=NULL, "userCode"=359, "userTimezone"=NULL, "caseManagerId"=NULL, "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-04-29 10:30:41.155479	UPDATE  "public"."HT_users" SET "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9', "cognitoId"='827b4381-3556-4bca-82d9-e186d0aae8d7', "oldCognitoId"=NULL, "firstName"='Jyotir', "lastName"='Nagpal', "phoneNumber"='+12812223333', "email"='jyotir@miraclefoundation.org', "addressLine1"='TBD', "addressLine2"='', "city"='TBD', "zipCode"='78735', "isActive"='true', "isDeleted"='false', "createdBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "updatedBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 00:12:43.789000', "updatedAt"='2024-04-29 10:30:35.109000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=2, "occupation"=NULL, "parentUserId"=NULL, "userCode"=359, "userTimezone"=NULL, "caseManagerId"=NULL, "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='f077216b-ff7e-4e40-a67a-6a27b8aecce9'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-02 19:37:14.357394	UPDATE  "public"."HT_users" SET "id"='22af2fe0-6950-45b6-99bf-473985d77ce6', "cognitoId"='80f8377c-8d46-4d30-adf2-039e56c7b656', "oldCognitoId"=NULL, "firstName"='CM ACW', "lastName"='Test', "phoneNumber"='+15122102456', "email"='cm_1@yopmail.com', "addressLine1"='123 6th st', "addressLine2"='', "city"='Austin', "zipCode"='78723', "isActive"='true', "isDeleted"='false', "createdBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "updatedBy"='fd9de831-d021-40b4-97f3-b13ee07b048e', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 13:36:36.725000', "updatedAt"='2024-05-02 19:37:07.800000', "HTCountryId"=2, "HTStateId"=37, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=362, "userTimezone"=NULL, "caseManagerId"=NULL, "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='22af2fe0-6950-45b6-99bf-473985d77ce6'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 05:32:19.775343	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.jacksparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 05:32:14.018000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 05:34:28.292913	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.jacksparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 05:34:28.285000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 05:46:31.693596	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.jacksparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 05:46:31.672000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 05:47:36.212033	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.jacksparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 05:47:30.588000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 05:48:32.36021	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.jacksparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 05:48:32.355000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 05:50:01.298863	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.jacksparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 05:50:01.294000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 05:51:29.605735	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.jacksparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 05:51:29.601000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 06:03:59.243422	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.sparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 06:03:59.232000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 06:04:27.809633	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"=NULL, "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.sparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 06:04:22.107000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 06:04:31.891652	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"='8eb76eed-07c4-4e32-abf9-95df92c302e3', "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.sparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 06:04:31.886000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 06:05:41.961929	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"='8eb76eed-07c4-4e32-abf9-95df92c302e3', "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.sparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 06:05:41.956000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-13 06:06:11.987317	UPDATE  "public"."HT_users" SET "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d', "cognitoId"='8eb76eed-07c4-4e32-abf9-95df92c302e3', "oldCognitoId"=NULL, "firstName"='Jack CM', "lastName"='Sparrow', "phoneNumber"='+19497288333', "email"='parent.sparrow@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='d99c57eb-2de4-440c-a0d9-244e0b34e04d', "updatedBy"='04ab91e2-51f1-4db9-aa7c-ebea8f4e2586', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-16 10:37:23.095000', "updatedAt"='2024-05-13 06:06:11.980000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='96aca77e-d466-4be1-862d-9bf3ab4573a0', "HTUserRoleId"=NULL, "occupation"='Pirate', "parentUserId"=NULL, "userCode"=357, "userTimezone"=NULL, "caseManagerId"='46e42a63-ded5-486b-9203-d5e523f745fb', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='7bfbd3f1-04a4-4385-ade2-1254ceb2a68d'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-15 20:47:38.58976	UPDATE  "public"."HT_users" SET "id"='cb2f9c80-78fc-4e05-b1fc-4ce1f0ad0ffb', "cognitoId"='77d29da8-8c86-4341-b9c5-05158ae2c2c9', "oldCognitoId"=NULL, "firstName"='Family1', "lastName"='Test', "phoneNumber"='+15122101234', "email"='fsfamily1@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='78c7a329-36a7-45d6-9ad8-4efec6d3136d', "updatedBy"='78c7a329-36a7-45d6-9ad8-4efec6d3136d', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 14:35:35.732000', "updatedAt"='2024-05-15 20:47:32.528000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=NULL, "occupation"='', "parentUserId"=NULL, "userCode"=366, "userTimezone"=NULL, "caseManagerId"='b10b2b1a-7ffa-474d-b4af-6065e0dff40f', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='cb2f9c80-78fc-4e05-b1fc-4ce1f0ad0ffb'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-20 19:10:31.444915	UPDATE  "public"."HT_users" SET "id"='cb2f9c80-78fc-4e05-b1fc-4ce1f0ad0ffb', "cognitoId"='77d29da8-8c86-4341-b9c5-05158ae2c2c9', "oldCognitoId"=NULL, "firstName"='Family1', "lastName"='Test', "phoneNumber"='+15122101234', "email"='fsfamily1@yopmail.com', "addressLine1"='UNKNOWN', "addressLine2"=NULL, "city"='UNKNOWN', "zipCode"='UNKNOWN', "isActive"='true', "isDeleted"='false', "createdBy"='78c7a329-36a7-45d6-9ad8-4efec6d3136d', "updatedBy"='78c7a329-36a7-45d6-9ad8-4efec6d3136d', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-17 14:35:35.732000', "updatedAt"='2024-05-20 19:10:25.027000', "HTCountryId"=2, "HTStateId"=NULL, "HTDistrictId"=NULL, "HTAccountId"='733783e7-fcf9-42d5-849c-33aff0f01d35', "HTUserRoleId"=NULL, "occupation"='', "parentUserId"=NULL, "userCode"=366, "userTimezone"='America/Chicago', "caseManagerId"='b10b2b1a-7ffa-474d-b4af-6065e0dff40f', "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='cb2f9c80-78fc-4e05-b1fc-4ce1f0ad0ffb'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-22 09:52:21.889857	UPDATE  "public"."HT_users" SET "id"='9b6271a2-91bf-4253-a6bc-fe36de115d18', "cognitoId"='ff00b744-3a9c-44dc-8aa7-bf97e8f97bcc', "oldCognitoId"=NULL, "firstName"='TS A+CW', "lastName"='Test', "phoneNumber"='+12255896385', "email"='tsa+cw_test@mailinator.com', "addressLine1"='Address 1', "addressLine2"='', "city"='Washington', "zipCode"='32132', "isActive"='true', "isDeleted"='false', "createdBy"='74dacbb7-2032-4e24-ac9d-6bce973796da', "updatedBy"='74dacbb7-2032-4e24-ac9d-6bce973796da', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-18 05:49:38.076000', "updatedAt"='2024-05-22 09:52:15.321000', "HTCountryId"=2, "HTStateId"=39, "HTDistrictId"=NULL, "HTAccountId"='6536ba55-07ba-4c0d-8c63-8891586345c7', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=370, "userTimezone"='Asia/Kolkata', "caseManagerId"=NULL, "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='9b6271a2-91bf-4253-a6bc-fe36de115d18'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-22 09:52:21.908563	UPDATE  "public"."HT_users" SET "id"='9b6271a2-91bf-4253-a6bc-fe36de115d18', "cognitoId"='ff00b744-3a9c-44dc-8aa7-bf97e8f97bcc', "oldCognitoId"=NULL, "firstName"='TS A+CW', "lastName"='Test', "phoneNumber"='+12255896385', "email"='tsa+cw_test@mailinator.com', "addressLine1"='Address 1', "addressLine2"='', "city"='Washington', "zipCode"='32132', "isActive"='true', "isDeleted"='false', "createdBy"='74dacbb7-2032-4e24-ac9d-6bce973796da', "updatedBy"='74dacbb7-2032-4e24-ac9d-6bce973796da', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-18 05:49:38.076000', "updatedAt"='2024-05-22 09:52:18.818000', "HTCountryId"=2, "HTStateId"=39, "HTDistrictId"=NULL, "HTAccountId"='6536ba55-07ba-4c0d-8c63-8891586345c7', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=370, "userTimezone"='Asia/Kolkata', "caseManagerId"=NULL, "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='9b6271a2-91bf-4253-a6bc-fe36de115d18'	0 rows affected
7BSCSVI573BPCGNED53IBDLLP4MDPSJKJURSFIA	public	HT_users	2024-05-22 10:07:48.208605	UPDATE  "public"."HT_users" SET "id"='9b6271a2-91bf-4253-a6bc-fe36de115d18', "cognitoId"='ff00b744-3a9c-44dc-8aa7-bf97e8f97bcc', "oldCognitoId"=NULL, "firstName"='TS A+CW', "lastName"='Test', "phoneNumber"='+12255896385', "email"='tsa+cw_test@mailinator.com', "addressLine1"='Address 1', "addressLine2"='', "city"='Washington', "zipCode"='32132', "isActive"='true', "isDeleted"='false', "createdBy"='74dacbb7-2032-4e24-ac9d-6bce973796da', "updatedBy"='74dacbb7-2032-4e24-ac9d-6bce973796da', "injectiondocId"=NULL, "dbRegion"='usa', "createdAt"='2024-04-18 05:49:38.076000', "updatedAt"='2024-05-22 10:07:42.116000', "HTCountryId"=2, "HTStateId"=39, "HTDistrictId"=NULL, "HTAccountId"='6536ba55-07ba-4c0d-8c63-8891586345c7', "HTUserRoleId"=4, "occupation"=NULL, "parentUserId"=NULL, "userCode"=370, "userTimezone"='Asia/Kolkata', "caseManagerId"=NULL, "image"=NULL, "fileStatus"='None', "deactivationReason"=NULL, "isAccountActive"='true' WHERE "id"='9b6271a2-91bf-4253-a6bc-fe36de115d18'	0 rows affected
\.


--
-- Name: HT_FollowUpProgresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_FollowUpProgresses_id_seq"', 54, true);


--
-- Name: HT_FollowUpStatuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_FollowUpStatuses_id_seq"', 1, false);


--
-- Name: HT_FollowupStatusQuestionChoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_FollowupStatusQuestionChoices_id_seq"', 1, false);


--
-- Name: HT_FollowupStatusQuestions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_FollowupStatusQuestions_id_seq"', 1, false);


--
-- Name: HT_IntegrationOptionLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_IntegrationOptionLangMaps_id_seq"', 1, false);


--
-- Name: HT_IntegrationOptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_IntegrationOptions_id_seq"', 1, false);


--
-- Name: HT_InterventionFollowUps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_InterventionFollowUps_id_seq"', 61, true);


--
-- Name: HT_UserSocketConnectionMappings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_UserSocketConnectionMappings_id_seq"', 1, false);


--
-- Name: HT_accountLinkings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_accountLinkings_id_seq"', 1, false);


--
-- Name: HT_acntTypLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_acntTypLangMaps_id_seq"', 1, false);


--
-- Name: HT_answerTypes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_answerTypes_id_seq"', 1, false);


--
-- Name: HT_assessmentImages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_assessmentImages_id_seq"', 1, false);


--
-- Name: HT_assessmentIntegrationOptionMappings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_assessmentIntegrationOptionMappings_id_seq"', 37, true);


--
-- Name: HT_assessmentInterventionTextResponses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_assessmentInterventionTextResponses_id_seq"', 1, false);


--
-- Name: HT_assessmentReintegrationTypes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_assessmentReintegrationTypes_id_seq"', 1, false);


--
-- Name: HT_assessmentScores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_assessmentScores_id_seq"', 105, true);


--
-- Name: HT_assessmentVisitTypes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_assessmentVisitTypes_id_seq"', 1, false);


--
-- Name: HT_assessments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_assessments_id_seq"', 46, true);


--
-- Name: HT_assmntReintegrationTypeLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_assmntReintegrationTypeLangMaps_id_seq"', 1, false);


--
-- Name: HT_assmntVisitTypeLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_assmntVisitTypeLangMaps_id_seq"', 1, false);


--
-- Name: HT_auditLogs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_auditLogs_id_seq"', 270, true);


--
-- Name: HT_cases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_cases_id_seq"', 34, true);


--
-- Name: HT_childCareGiverMappings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_childCareGiverMappings_id_seq"', 1, false);


--
-- Name: HT_childConsentLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_childConsentLangMaps_id_seq"', 3, true);


--
-- Name: HT_childConsents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_childConsents_id_seq"', 11, true);


--
-- Name: HT_childCurrentPlacementStatuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_childCurrentPlacementStatuses_id_seq"', 9, true);


--
-- Name: HT_childEducationLevels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_childEducationLevels_id_seq"', 22, true);


--
-- Name: HT_childHistories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_childHistories_id_seq"', 1, false);


--
-- Name: HT_childPlacementStatuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_childPlacementStatuses_id_seq"', 6, true);


--
-- Name: HT_childStatuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_childStatuses_id_seq"', 3, true);


--
-- Name: HT_children_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_children_id_seq"', 43, true);


--
-- Name: HT_chldCurntPlmtStsLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_chldCurntPlmtStsLangMaps_id_seq"', 1, false);


--
-- Name: HT_chldEdnLvlLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_chldEdnLvlLangMaps_id_seq"', 1, false);


--
-- Name: HT_chldPlmtStsLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_chldPlmtStsLangMaps_id_seq"', 1, false);


--
-- Name: HT_chldStsLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_chldStsLangMaps_id_seq"', 1, false);


--
-- Name: HT_choiceLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_choiceLangMaps_id_seq"', 1, false);


--
-- Name: HT_choices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_choices_id_seq"', 1284, true);


--
-- Name: HT_countryLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_countryLangMaps_id_seq"', 1, false);


--
-- Name: HT_deviceDetails_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_deviceDetails_id_seq"', 1, false);


--
-- Name: HT_districtLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_districtLangMaps_id_seq"', 1, false);


--
-- Name: HT_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_events_id_seq"', 213, true);


--
-- Name: HT_families_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_families_id_seq"', 46, true);


--
-- Name: HT_familyMemTypeLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_familyMemTypeLangMaps_id_seq"', 1, false);


--
-- Name: HT_familyMemberTypes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_familyMemberTypes_id_seq"', 2, true);


--
-- Name: HT_familyMembers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_familyMembers_id_seq"', 47, true);


--
-- Name: HT_familyRelanLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_familyRelanLangMaps_id_seq"', 1, false);


--
-- Name: HT_familyRelations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_familyRelations_id_seq"', 7, true);


--
-- Name: HT_fileUploadMappings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_fileUploadMappings_id_seq"', 8, true);


--
-- Name: HT_formQuestionMappings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_formQuestionMappings_id_seq"', 550, true);


--
-- Name: HT_formRevisions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_formRevisions_id_seq"', 1, false);


--
-- Name: HT_forms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_forms_id_seq"', 20, true);


--
-- Name: HT_importLogs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_importLogs_id_seq"', 1, false);


--
-- Name: HT_importMappings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_importMappings_id_seq"', 1, false);


--
-- Name: HT_langMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_langMaps_id_seq"', 1, false);


--
-- Name: HT_logExports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_logExports_id_seq"', 1, false);


--
-- Name: HT_notifLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_notifLangMaps_id_seq"', 1, false);


--
-- Name: HT_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_notifications_id_seq"', 1, false);


--
-- Name: HT_notifnEventTypes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_notifnEventTypes_id_seq"', 1, false);


--
-- Name: HT_questionDomains_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_questionDomains_id_seq"', 1, false);


--
-- Name: HT_questionLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_questionLangMaps_id_seq"', 1, false);


--
-- Name: HT_questionTypes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_questionTypes_id_seq"', 1, false);


--
-- Name: HT_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_questions_id_seq"', 170, true);


--
-- Name: HT_qusnDomainLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_qusnDomainLangMaps_id_seq"', 1, false);


--
-- Name: HT_recurringEvents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_recurringEvents_id_seq"', 1, false);


--
-- Name: HT_responses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_responses_id_seq"', 1626, true);


--
-- Name: HT_stateLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_stateLangMaps_id_seq"', 1, false);


--
-- Name: HT_userLogs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_userLogs_id_seq"', 1, false);


--
-- Name: HT_userRoleLangMaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ht_db_user
--

SELECT pg_catalog.setval('public."HT_userRoleLangMaps_id_seq"', 1, false);


--
-- Name: HT_FollowUpProgresses HT_FollowUpProgresses_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowUpProgresses"
    ADD CONSTRAINT "HT_FollowUpProgresses_pkey" PRIMARY KEY (id);


--
-- Name: HT_FollowUpStatuses HT_FollowUpStatuses_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowUpStatuses"
    ADD CONSTRAINT "HT_FollowUpStatuses_pkey" PRIMARY KEY (id);


--
-- Name: HT_FollowupStatusQuestionChoices HT_FollowupStatusQuestionChoices_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowupStatusQuestionChoices"
    ADD CONSTRAINT "HT_FollowupStatusQuestionChoices_pkey" PRIMARY KEY (id);


--
-- Name: HT_FollowupStatusQuestions HT_FollowupStatusQuestions_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowupStatusQuestions"
    ADD CONSTRAINT "HT_FollowupStatusQuestions_pkey" PRIMARY KEY (id);


--
-- Name: HT_IntegrationOptionLangMaps HT_IntegrationOptionLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_IntegrationOptionLangMaps"
    ADD CONSTRAINT "HT_IntegrationOptionLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_IntegrationOptions HT_IntegrationOptions_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_IntegrationOptions"
    ADD CONSTRAINT "HT_IntegrationOptions_pkey" PRIMARY KEY (id);


--
-- Name: HT_InterventionFollowUps HT_InterventionFollowUps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_InterventionFollowUps"
    ADD CONSTRAINT "HT_InterventionFollowUps_pkey" PRIMARY KEY (id);


--
-- Name: HT_UserSocketConnectionMappings HT_UserSocketConnectionMappings_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_UserSocketConnectionMappings"
    ADD CONSTRAINT "HT_UserSocketConnectionMappings_pkey" PRIMARY KEY (id);


--
-- Name: HT_accountLinkings HT_accountLinkings_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accountLinkings"
    ADD CONSTRAINT "HT_accountLinkings_pkey" PRIMARY KEY (id);


--
-- Name: HT_accountTypes HT_accountTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accountTypes"
    ADD CONSTRAINT "HT_accountTypes_pkey" PRIMARY KEY (id);


--
-- Name: HT_accounts HT_accounts_accountName_key; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accounts"
    ADD CONSTRAINT "HT_accounts_accountName_key" UNIQUE ("accountName");


--
-- Name: HT_accounts HT_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accounts"
    ADD CONSTRAINT "HT_accounts_pkey" PRIMARY KEY (id);


--
-- Name: HT_acntTypLangMaps HT_acntTypLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_acntTypLangMaps"
    ADD CONSTRAINT "HT_acntTypLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_answerTypes HT_answerTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_answerTypes"
    ADD CONSTRAINT "HT_answerTypes_pkey" PRIMARY KEY (id);


--
-- Name: HT_assessmentImages HT_assessmentImages_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentImages"
    ADD CONSTRAINT "HT_assessmentImages_pkey" PRIMARY KEY (id);


--
-- Name: HT_assessmentIntegrationOptionMappings HT_assessmentIntegrationOptio_HTAssessmentId_HTIntegrationO_key; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentIntegrationOptionMappings"
    ADD CONSTRAINT "HT_assessmentIntegrationOptio_HTAssessmentId_HTIntegrationO_key" UNIQUE ("HTAssessmentId", "HTIntegrationOptionId");


--
-- Name: HT_assessmentIntegrationOptionMappings HT_assessmentIntegrationOptionMappings_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentIntegrationOptionMappings"
    ADD CONSTRAINT "HT_assessmentIntegrationOptionMappings_pkey" PRIMARY KEY (id);


--
-- Name: HT_assessmentInterventionTextResponses HT_assessmentInterventionTextResponses_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentInterventionTextResponses"
    ADD CONSTRAINT "HT_assessmentInterventionTextResponses_pkey" PRIMARY KEY (id);


--
-- Name: HT_assessmentReintegrationTypes HT_assessmentReintegrationTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentReintegrationTypes"
    ADD CONSTRAINT "HT_assessmentReintegrationTypes_pkey" PRIMARY KEY (id);


--
-- Name: HT_assessmentScores HT_assessmentScores_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentScores"
    ADD CONSTRAINT "HT_assessmentScores_pkey" PRIMARY KEY (id);


--
-- Name: HT_assessmentVisitTypes HT_assessmentVisitTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentVisitTypes"
    ADD CONSTRAINT "HT_assessmentVisitTypes_pkey" PRIMARY KEY (id);


--
-- Name: HT_assessments HT_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessments"
    ADD CONSTRAINT "HT_assessments_pkey" PRIMARY KEY (id);


--
-- Name: HT_assmntReintegrationTypeLangMaps HT_assmntReintegrationTypeLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assmntReintegrationTypeLangMaps"
    ADD CONSTRAINT "HT_assmntReintegrationTypeLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_assmntVisitTypeLangMaps HT_assmntVisitTypeLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assmntVisitTypeLangMaps"
    ADD CONSTRAINT "HT_assmntVisitTypeLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_auditLogs HT_auditLogs_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_auditLogs"
    ADD CONSTRAINT "HT_auditLogs_pkey" PRIMARY KEY (id);


--
-- Name: HT_cases HT_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_cases"
    ADD CONSTRAINT "HT_cases_pkey" PRIMARY KEY (id);


--
-- Name: HT_childCareGiverMappings HT_childCareGiverMappings_HTFamilyMemberId_HTChildId_key; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childCareGiverMappings"
    ADD CONSTRAINT "HT_childCareGiverMappings_HTFamilyMemberId_HTChildId_key" UNIQUE ("HTFamilyMemberId", "HTChildId");


--
-- Name: HT_childCareGiverMappings HT_childCareGiverMappings_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childCareGiverMappings"
    ADD CONSTRAINT "HT_childCareGiverMappings_pkey" PRIMARY KEY (id);


--
-- Name: HT_childConsentLangMaps HT_childConsentLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childConsentLangMaps"
    ADD CONSTRAINT "HT_childConsentLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_childConsents HT_childConsents_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childConsents"
    ADD CONSTRAINT "HT_childConsents_pkey" PRIMARY KEY (id);


--
-- Name: HT_childCurrentPlacementStatuses HT_childCurrentPlacementStatuses_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childCurrentPlacementStatuses"
    ADD CONSTRAINT "HT_childCurrentPlacementStatuses_pkey" PRIMARY KEY (id);


--
-- Name: HT_childEducationLevels HT_childEducationLevels_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childEducationLevels"
    ADD CONSTRAINT "HT_childEducationLevels_pkey" PRIMARY KEY (id);


--
-- Name: HT_childHistories HT_childHistories_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childHistories"
    ADD CONSTRAINT "HT_childHistories_pkey" PRIMARY KEY (id);


--
-- Name: HT_childPlacementStatuses HT_childPlacementStatuses_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childPlacementStatuses"
    ADD CONSTRAINT "HT_childPlacementStatuses_pkey" PRIMARY KEY (id);


--
-- Name: HT_childStatuses HT_childStatuses_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childStatuses"
    ADD CONSTRAINT "HT_childStatuses_pkey" PRIMARY KEY (id);


--
-- Name: HT_children HT_children_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children"
    ADD CONSTRAINT "HT_children_pkey" PRIMARY KEY (id);


--
-- Name: HT_chldCurntPlmtStsLangMaps HT_chldCurntPlmtStsLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldCurntPlmtStsLangMaps"
    ADD CONSTRAINT "HT_chldCurntPlmtStsLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_chldEdnLvlLangMaps HT_chldEdnLvlLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldEdnLvlLangMaps"
    ADD CONSTRAINT "HT_chldEdnLvlLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_chldPlmtStsLangMaps HT_chldPlmtStsLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldPlmtStsLangMaps"
    ADD CONSTRAINT "HT_chldPlmtStsLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_chldStsLangMaps HT_chldStsLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldStsLangMaps"
    ADD CONSTRAINT "HT_chldStsLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_choiceLangMaps HT_choiceLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_choiceLangMaps"
    ADD CONSTRAINT "HT_choiceLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_choices HT_choices_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_choices"
    ADD CONSTRAINT "HT_choices_pkey" PRIMARY KEY (id);


--
-- Name: HT_countries HT_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_countries"
    ADD CONSTRAINT "HT_countries_pkey" PRIMARY KEY (id);


--
-- Name: HT_countryLangMaps HT_countryLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_countryLangMaps"
    ADD CONSTRAINT "HT_countryLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_deviceDetails HT_deviceDetails_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_deviceDetails"
    ADD CONSTRAINT "HT_deviceDetails_pkey" PRIMARY KEY (id);


--
-- Name: HT_districtLangMaps HT_districtLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_districtLangMaps"
    ADD CONSTRAINT "HT_districtLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_districts HT_districts_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_districts"
    ADD CONSTRAINT "HT_districts_pkey" PRIMARY KEY (id);


--
-- Name: HT_events HT_events_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_events"
    ADD CONSTRAINT "HT_events_pkey" PRIMARY KEY (id);


--
-- Name: HT_families HT_families_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_families"
    ADD CONSTRAINT "HT_families_pkey" PRIMARY KEY (id);


--
-- Name: HT_familyMemTypeLangMaps HT_familyMemTypeLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyMemTypeLangMaps"
    ADD CONSTRAINT "HT_familyMemTypeLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_familyMemberTypes HT_familyMemberTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyMemberTypes"
    ADD CONSTRAINT "HT_familyMemberTypes_pkey" PRIMARY KEY (id);


--
-- Name: HT_familyMembers HT_familyMembers_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyMembers"
    ADD CONSTRAINT "HT_familyMembers_pkey" PRIMARY KEY (id);


--
-- Name: HT_familyRelanLangMaps HT_familyRelanLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyRelanLangMaps"
    ADD CONSTRAINT "HT_familyRelanLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_familyRelations HT_familyRelations_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyRelations"
    ADD CONSTRAINT "HT_familyRelations_pkey" PRIMARY KEY (id);


--
-- Name: HT_fileUploadMappings HT_fileUploadMappings_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_fileUploadMappings"
    ADD CONSTRAINT "HT_fileUploadMappings_pkey" PRIMARY KEY (id);


--
-- Name: HT_formQuestionMappings HT_formQuestionMappings_HTQuestionId_HTFormId_key; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_formQuestionMappings"
    ADD CONSTRAINT "HT_formQuestionMappings_HTQuestionId_HTFormId_key" UNIQUE ("HTQuestionId", "HTFormId");


--
-- Name: HT_formQuestionMappings HT_formQuestionMappings_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_formQuestionMappings"
    ADD CONSTRAINT "HT_formQuestionMappings_pkey" PRIMARY KEY (id);


--
-- Name: HT_formRevisions HT_formRevisions_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_formRevisions"
    ADD CONSTRAINT "HT_formRevisions_pkey" PRIMARY KEY (id);


--
-- Name: HT_forms HT_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_forms"
    ADD CONSTRAINT "HT_forms_pkey" PRIMARY KEY (id);


--
-- Name: HT_importLogs HT_importLogs_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_importLogs"
    ADD CONSTRAINT "HT_importLogs_pkey" PRIMARY KEY (id);


--
-- Name: HT_importMappings HT_importMappings_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_importMappings"
    ADD CONSTRAINT "HT_importMappings_pkey" PRIMARY KEY (id);


--
-- Name: HT_langMaps HT_langMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_langMaps"
    ADD CONSTRAINT "HT_langMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_languages HT_languages_language_key; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_languages"
    ADD CONSTRAINT "HT_languages_language_key" UNIQUE (language);


--
-- Name: HT_languages HT_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_languages"
    ADD CONSTRAINT "HT_languages_pkey" PRIMARY KEY (id);


--
-- Name: HT_logExports HT_logExports_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_logExports"
    ADD CONSTRAINT "HT_logExports_pkey" PRIMARY KEY (id);


--
-- Name: HT_notifLangMaps HT_notifLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifLangMaps"
    ADD CONSTRAINT "HT_notifLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_notifications HT_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifications"
    ADD CONSTRAINT "HT_notifications_pkey" PRIMARY KEY (id);


--
-- Name: HT_notifnEventTypes HT_notifnEventTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifnEventTypes"
    ADD CONSTRAINT "HT_notifnEventTypes_pkey" PRIMARY KEY (id);


--
-- Name: HT_questionDomains HT_questionDomains_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questionDomains"
    ADD CONSTRAINT "HT_questionDomains_pkey" PRIMARY KEY (id);


--
-- Name: HT_questionLangMaps HT_questionLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questionLangMaps"
    ADD CONSTRAINT "HT_questionLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_questionTypes HT_questionTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questionTypes"
    ADD CONSTRAINT "HT_questionTypes_pkey" PRIMARY KEY (id);


--
-- Name: HT_questions HT_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questions"
    ADD CONSTRAINT "HT_questions_pkey" PRIMARY KEY (id);


--
-- Name: HT_qusnDomainLangMaps HT_qusnDomainLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_qusnDomainLangMaps"
    ADD CONSTRAINT "HT_qusnDomainLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_recurringEvents HT_recurringEvents_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_recurringEvents"
    ADD CONSTRAINT "HT_recurringEvents_pkey" PRIMARY KEY (id);


--
-- Name: HT_responses HT_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_responses"
    ADD CONSTRAINT "HT_responses_pkey" PRIMARY KEY (id);


--
-- Name: HT_stateLangMaps HT_stateLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_stateLangMaps"
    ADD CONSTRAINT "HT_stateLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_states HT_states_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_states"
    ADD CONSTRAINT "HT_states_pkey" PRIMARY KEY (id);


--
-- Name: HT_userLogs HT_userLogs_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_userLogs"
    ADD CONSTRAINT "HT_userLogs_pkey" PRIMARY KEY (id);


--
-- Name: HT_userRoleLangMaps HT_userRoleLangMaps_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_userRoleLangMaps"
    ADD CONSTRAINT "HT_userRoleLangMaps_pkey" PRIMARY KEY (id);


--
-- Name: HT_userRoles HT_userRoles_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_userRoles"
    ADD CONSTRAINT "HT_userRoles_pkey" PRIMARY KEY (id);


--
-- Name: HT_users HT_users_cognitoId_key; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_users"
    ADD CONSTRAINT "HT_users_cognitoId_key" UNIQUE ("cognitoId");


--
-- Name: HT_users HT_users_pkey; Type: CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_users"
    ADD CONSTRAINT "HT_users_pkey" PRIMARY KEY (id);


--
-- Name: HT_users user_deactivation_activation_triger; Type: TRIGGER; Schema: public; Owner: ht_db_user
--

CREATE TRIGGER user_deactivation_activation_triger AFTER UPDATE ON public."HT_users" FOR EACH ROW WHEN ((old."isActive" IS DISTINCT FROM new."isActive")) EXECUTE FUNCTION public.user_deactivation_triger();


--
-- Name: HT_FollowUpProgresses HT_FollowUpProgresses_HTAssessmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowUpProgresses"
    ADD CONSTRAINT "HT_FollowUpProgresses_HTAssessmentId_fkey" FOREIGN KEY ("HTAssessmentId") REFERENCES public."HT_assessments"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_FollowUpProgresses HT_FollowUpProgresses_HTChoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowUpProgresses"
    ADD CONSTRAINT "HT_FollowUpProgresses_HTChoiceId_fkey" FOREIGN KEY ("HTChoiceId") REFERENCES public."HT_choices"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_FollowUpProgresses HT_FollowUpProgresses_HTFollowUpStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowUpProgresses"
    ADD CONSTRAINT "HT_FollowUpProgresses_HTFollowUpStatusId_fkey" FOREIGN KEY ("HTFollowUpStatusId") REFERENCES public."HT_FollowUpStatuses"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_FollowUpProgresses HT_FollowUpProgresses_HTFollowupStatusQuestionChoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowUpProgresses"
    ADD CONSTRAINT "HT_FollowUpProgresses_HTFollowupStatusQuestionChoiceId_fkey" FOREIGN KEY ("HTFollowupStatusQuestionChoiceId") REFERENCES public."HT_FollowupStatusQuestionChoices"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_FollowUpProgresses HT_FollowUpProgresses_HTFollowupStatusQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowUpProgresses"
    ADD CONSTRAINT "HT_FollowUpProgresses_HTFollowupStatusQuestionId_fkey" FOREIGN KEY ("HTFollowupStatusQuestionId") REFERENCES public."HT_FollowupStatusQuestions"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_FollowUpProgresses HT_FollowUpProgresses_HTQuestionDomainId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowUpProgresses"
    ADD CONSTRAINT "HT_FollowUpProgresses_HTQuestionDomainId_fkey" FOREIGN KEY ("HTQuestionDomainId") REFERENCES public."HT_questionDomains"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_FollowUpProgresses HT_FollowUpProgresses_HTQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowUpProgresses"
    ADD CONSTRAINT "HT_FollowUpProgresses_HTQuestionId_fkey" FOREIGN KEY ("HTQuestionId") REFERENCES public."HT_questions"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_FollowupStatusQuestionChoices HT_FollowupStatusQuestionChoice_HTFollowupStatusQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowupStatusQuestionChoices"
    ADD CONSTRAINT "HT_FollowupStatusQuestionChoice_HTFollowupStatusQuestionId_fkey" FOREIGN KEY ("HTFollowupStatusQuestionId") REFERENCES public."HT_FollowupStatusQuestions"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_FollowupStatusQuestions HT_FollowupStatusQuestions_HTFollowUpStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_FollowupStatusQuestions"
    ADD CONSTRAINT "HT_FollowupStatusQuestions_HTFollowUpStatusId_fkey" FOREIGN KEY ("HTFollowUpStatusId") REFERENCES public."HT_FollowUpStatuses"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_IntegrationOptionLangMaps HT_IntegrationOptionLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_IntegrationOptionLangMaps"
    ADD CONSTRAINT "HT_IntegrationOptionLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_IntegrationOptions HT_IntegrationOptions_HTFormId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_IntegrationOptions"
    ADD CONSTRAINT "HT_IntegrationOptions_HTFormId_fkey" FOREIGN KEY ("HTFormId") REFERENCES public."HT_forms"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_InterventionFollowUps HT_InterventionFollowUps_HTAssessmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_InterventionFollowUps"
    ADD CONSTRAINT "HT_InterventionFollowUps_HTAssessmentId_fkey" FOREIGN KEY ("HTAssessmentId") REFERENCES public."HT_assessments"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_InterventionFollowUps HT_InterventionFollowUps_HTQuestionDomainId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_InterventionFollowUps"
    ADD CONSTRAINT "HT_InterventionFollowUps_HTQuestionDomainId_fkey" FOREIGN KEY ("HTQuestionDomainId") REFERENCES public."HT_questionDomains"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_InterventionFollowUps HT_InterventionFollowUps_HTQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_InterventionFollowUps"
    ADD CONSTRAINT "HT_InterventionFollowUps_HTQuestionId_fkey" FOREIGN KEY ("HTQuestionId") REFERENCES public."HT_questions"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_UserSocketConnectionMappings HT_UserSocketConnectionMappings_HTUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_UserSocketConnectionMappings"
    ADD CONSTRAINT "HT_UserSocketConnectionMappings_HTUserId_fkey" FOREIGN KEY ("HTUserId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_accountLinkings HT_accountLinkings_AccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accountLinkings"
    ADD CONSTRAINT "HT_accountLinkings_AccountId_fkey" FOREIGN KEY ("AccountId") REFERENCES public."HT_accounts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_accountLinkings HT_accountLinkings_HTAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accountLinkings"
    ADD CONSTRAINT "HT_accountLinkings_HTAccountId_fkey" FOREIGN KEY ("HTAccountId") REFERENCES public."HT_accounts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_accountLinkings HT_accountLinkings_LinkedAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accountLinkings"
    ADD CONSTRAINT "HT_accountLinkings_LinkedAccountId_fkey" FOREIGN KEY ("LinkedAccountId") REFERENCES public."HT_accounts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_accounts HT_accounts_HTAccountTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accounts"
    ADD CONSTRAINT "HT_accounts_HTAccountTypeId_fkey" FOREIGN KEY ("HTAccountTypeId") REFERENCES public."HT_accountTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_accounts HT_accounts_HTCountryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accounts"
    ADD CONSTRAINT "HT_accounts_HTCountryId_fkey" FOREIGN KEY ("HTCountryId") REFERENCES public."HT_countries"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_accounts HT_accounts_HTDistrictId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accounts"
    ADD CONSTRAINT "HT_accounts_HTDistrictId_fkey" FOREIGN KEY ("HTDistrictId") REFERENCES public."HT_districts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_accounts HT_accounts_HTStateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_accounts"
    ADD CONSTRAINT "HT_accounts_HTStateId_fkey" FOREIGN KEY ("HTStateId") REFERENCES public."HT_states"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_acntTypLangMaps HT_acntTypLangMaps_HTAccountTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_acntTypLangMaps"
    ADD CONSTRAINT "HT_acntTypLangMaps_HTAccountTypeId_fkey" FOREIGN KEY ("HTAccountTypeId") REFERENCES public."HT_accountTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_acntTypLangMaps HT_acntTypLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_acntTypLangMaps"
    ADD CONSTRAINT "HT_acntTypLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assessmentImages HT_assessmentImages_HTAssessmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentImages"
    ADD CONSTRAINT "HT_assessmentImages_HTAssessmentId_fkey" FOREIGN KEY ("HTAssessmentId") REFERENCES public."HT_assessments"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assessmentIntegrationOptionMappings HT_assessmentIntegrationOptionMappings_HTAssessmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentIntegrationOptionMappings"
    ADD CONSTRAINT "HT_assessmentIntegrationOptionMappings_HTAssessmentId_fkey" FOREIGN KEY ("HTAssessmentId") REFERENCES public."HT_assessments"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_assessmentInterventionTextResponses HT_assessmentInterventionTextResponses_HTAssessmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentInterventionTextResponses"
    ADD CONSTRAINT "HT_assessmentInterventionTextResponses_HTAssessmentId_fkey" FOREIGN KEY ("HTAssessmentId") REFERENCES public."HT_assessments"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assessmentInterventionTextResponses HT_assessmentInterventionTextResponses_HTQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentInterventionTextResponses"
    ADD CONSTRAINT "HT_assessmentInterventionTextResponses_HTQuestionId_fkey" FOREIGN KEY ("HTQuestionId") REFERENCES public."HT_questions"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assessmentScores HT_assessmentScores_HTAssessmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentScores"
    ADD CONSTRAINT "HT_assessmentScores_HTAssessmentId_fkey" FOREIGN KEY ("HTAssessmentId") REFERENCES public."HT_assessments"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assessmentScores HT_assessmentScores_HTQuestionDomainId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessmentScores"
    ADD CONSTRAINT "HT_assessmentScores_HTQuestionDomainId_fkey" FOREIGN KEY ("HTQuestionDomainId") REFERENCES public."HT_questionDomains"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assessments HT_assessments_HTAssessmentReintegrationTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessments"
    ADD CONSTRAINT "HT_assessments_HTAssessmentReintegrationTypeId_fkey" FOREIGN KEY ("HTAssessmentReintegrationTypeId") REFERENCES public."HT_assessmentReintegrationTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assessments HT_assessments_HTAssessmentVisitTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessments"
    ADD CONSTRAINT "HT_assessments_HTAssessmentVisitTypeId_fkey" FOREIGN KEY ("HTAssessmentVisitTypeId") REFERENCES public."HT_assessmentVisitTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assessments HT_assessments_HTCaseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessments"
    ADD CONSTRAINT "HT_assessments_HTCaseId_fkey" FOREIGN KEY ("HTCaseId") REFERENCES public."HT_cases"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assessments HT_assessments_HTFormId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assessments"
    ADD CONSTRAINT "HT_assessments_HTFormId_fkey" FOREIGN KEY ("HTFormId") REFERENCES public."HT_forms"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assmntReintegrationTypeLangMaps HT_assmntReintegrationTypeLan_HTAssessmentReintegrationTyp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assmntReintegrationTypeLangMaps"
    ADD CONSTRAINT "HT_assmntReintegrationTypeLan_HTAssessmentReintegrationTyp_fkey" FOREIGN KEY ("HTAssessmentReintegrationTypeId") REFERENCES public."HT_assessmentReintegrationTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assmntReintegrationTypeLangMaps HT_assmntReintegrationTypeLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assmntReintegrationTypeLangMaps"
    ADD CONSTRAINT "HT_assmntReintegrationTypeLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assmntVisitTypeLangMaps HT_assmntVisitTypeLangMaps_HTAssessmentVisitTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assmntVisitTypeLangMaps"
    ADD CONSTRAINT "HT_assmntVisitTypeLangMaps_HTAssessmentVisitTypeId_fkey" FOREIGN KEY ("HTAssessmentVisitTypeId") REFERENCES public."HT_assessmentVisitTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_assmntVisitTypeLangMaps HT_assmntVisitTypeLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_assmntVisitTypeLangMaps"
    ADD CONSTRAINT "HT_assmntVisitTypeLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_auditLogs HT_auditLogs_HTAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_auditLogs"
    ADD CONSTRAINT "HT_auditLogs_HTAccountId_fkey" FOREIGN KEY ("HTAccountId") REFERENCES public."HT_accounts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_auditLogs HT_auditLogs_HTAssessmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_auditLogs"
    ADD CONSTRAINT "HT_auditLogs_HTAssessmentId_fkey" FOREIGN KEY ("HTAssessmentId") REFERENCES public."HT_assessments"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_auditLogs HT_auditLogs_HTCaseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_auditLogs"
    ADD CONSTRAINT "HT_auditLogs_HTCaseId_fkey" FOREIGN KEY ("HTCaseId") REFERENCES public."HT_cases"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_auditLogs HT_auditLogs_HTChildId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_auditLogs"
    ADD CONSTRAINT "HT_auditLogs_HTChildId_fkey" FOREIGN KEY ("HTChildId") REFERENCES public."HT_children"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_auditLogs HT_auditLogs_HTFamilyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_auditLogs"
    ADD CONSTRAINT "HT_auditLogs_HTFamilyId_fkey" FOREIGN KEY ("HTFamilyId") REFERENCES public."HT_families"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_auditLogs HT_auditLogs_HTFamilyMemberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_auditLogs"
    ADD CONSTRAINT "HT_auditLogs_HTFamilyMemberId_fkey" FOREIGN KEY ("HTFamilyMemberId") REFERENCES public."HT_familyMembers"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_auditLogs HT_auditLogs_HTUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_auditLogs"
    ADD CONSTRAINT "HT_auditLogs_HTUserId_fkey" FOREIGN KEY ("HTUserId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_auditLogs HT_auditLogs_updatedUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_auditLogs"
    ADD CONSTRAINT "HT_auditLogs_updatedUserId_fkey" FOREIGN KEY ("updatedUserId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_cases HT_cases_HTChildId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_cases"
    ADD CONSTRAINT "HT_cases_HTChildId_fkey" FOREIGN KEY ("HTChildId") REFERENCES public."HT_children"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_cases HT_cases_HTUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_cases"
    ADD CONSTRAINT "HT_cases_HTUserId_fkey" FOREIGN KEY ("HTUserId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_childCareGiverMappings HT_childCareGiverMappings_HTChildId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childCareGiverMappings"
    ADD CONSTRAINT "HT_childCareGiverMappings_HTChildId_fkey" FOREIGN KEY ("HTChildId") REFERENCES public."HT_children"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_childCareGiverMappings HT_childCareGiverMappings_HTFamilyMemberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childCareGiverMappings"
    ADD CONSTRAINT "HT_childCareGiverMappings_HTFamilyMemberId_fkey" FOREIGN KEY ("HTFamilyMemberId") REFERENCES public."HT_familyMembers"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_childConsentLangMaps HT_childConsentLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childConsentLangMaps"
    ADD CONSTRAINT "HT_childConsentLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_childConsents HT_childConsents_HTChildId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childConsents"
    ADD CONSTRAINT "HT_childConsents_HTChildId_fkey" FOREIGN KEY ("HTChildId") REFERENCES public."HT_children"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_childConsents HT_childConsents_HTFamilyRelationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childConsents"
    ADD CONSTRAINT "HT_childConsents_HTFamilyRelationId_fkey" FOREIGN KEY ("HTFamilyRelationId") REFERENCES public."HT_familyRelations"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_childConsents HT_childConsents_HTUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childConsents"
    ADD CONSTRAINT "HT_childConsents_HTUserId_fkey" FOREIGN KEY ("HTUserId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_childHistories HT_childHistories_HTChildId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childHistories"
    ADD CONSTRAINT "HT_childHistories_HTChildId_fkey" FOREIGN KEY ("HTChildId") REFERENCES public."HT_children"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_childHistories HT_childHistories_HTFamilyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childHistories"
    ADD CONSTRAINT "HT_childHistories_HTFamilyId_fkey" FOREIGN KEY ("HTFamilyId") REFERENCES public."HT_families"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_childHistories HT_childHistories_HTFamilyMemberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_childHistories"
    ADD CONSTRAINT "HT_childHistories_HTFamilyMemberId_fkey" FOREIGN KEY ("HTFamilyMemberId") REFERENCES public."HT_familyMembers"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_children HT_children_HTAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children"
    ADD CONSTRAINT "HT_children_HTAccountId_fkey" FOREIGN KEY ("HTAccountId") REFERENCES public."HT_accounts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_children HT_children_HTChildCurrentPlacementStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children"
    ADD CONSTRAINT "HT_children_HTChildCurrentPlacementStatusId_fkey" FOREIGN KEY ("HTChildCurrentPlacementStatusId") REFERENCES public."HT_childCurrentPlacementStatuses"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_children HT_children_HTChildEducationLevelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children"
    ADD CONSTRAINT "HT_children_HTChildEducationLevelId_fkey" FOREIGN KEY ("HTChildEducationLevelId") REFERENCES public."HT_childEducationLevels"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_children HT_children_HTChildPlacementStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children"
    ADD CONSTRAINT "HT_children_HTChildPlacementStatusId_fkey" FOREIGN KEY ("HTChildPlacementStatusId") REFERENCES public."HT_childPlacementStatuses"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_children HT_children_HTChildStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children"
    ADD CONSTRAINT "HT_children_HTChildStatusId_fkey" FOREIGN KEY ("HTChildStatusId") REFERENCES public."HT_childStatuses"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_children HT_children_HTCountryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children"
    ADD CONSTRAINT "HT_children_HTCountryId_fkey" FOREIGN KEY ("HTCountryId") REFERENCES public."HT_countries"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_children HT_children_HTDistrictId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children"
    ADD CONSTRAINT "HT_children_HTDistrictId_fkey" FOREIGN KEY ("HTDistrictId") REFERENCES public."HT_districts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_children HT_children_HTFamilyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children"
    ADD CONSTRAINT "HT_children_HTFamilyId_fkey" FOREIGN KEY ("HTFamilyId") REFERENCES public."HT_families"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_children HT_children_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children"
    ADD CONSTRAINT "HT_children_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_children HT_children_HTStateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_children"
    ADD CONSTRAINT "HT_children_HTStateId_fkey" FOREIGN KEY ("HTStateId") REFERENCES public."HT_states"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_chldCurntPlmtStsLangMaps HT_chldCurntPlmtStsLangMaps_HTChildCurrentPlacementStatusI_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldCurntPlmtStsLangMaps"
    ADD CONSTRAINT "HT_chldCurntPlmtStsLangMaps_HTChildCurrentPlacementStatusI_fkey" FOREIGN KEY ("HTChildCurrentPlacementStatusId") REFERENCES public."HT_childCurrentPlacementStatuses"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_chldCurntPlmtStsLangMaps HT_chldCurntPlmtStsLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldCurntPlmtStsLangMaps"
    ADD CONSTRAINT "HT_chldCurntPlmtStsLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_chldEdnLvlLangMaps HT_chldEdnLvlLangMaps_HTChildEducationLevelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldEdnLvlLangMaps"
    ADD CONSTRAINT "HT_chldEdnLvlLangMaps_HTChildEducationLevelId_fkey" FOREIGN KEY ("HTChildEducationLevelId") REFERENCES public."HT_childEducationLevels"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_chldEdnLvlLangMaps HT_chldEdnLvlLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldEdnLvlLangMaps"
    ADD CONSTRAINT "HT_chldEdnLvlLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_chldPlmtStsLangMaps HT_chldPlmtStsLangMaps_HTChildPlacementStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldPlmtStsLangMaps"
    ADD CONSTRAINT "HT_chldPlmtStsLangMaps_HTChildPlacementStatusId_fkey" FOREIGN KEY ("HTChildPlacementStatusId") REFERENCES public."HT_childPlacementStatuses"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_chldPlmtStsLangMaps HT_chldPlmtStsLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldPlmtStsLangMaps"
    ADD CONSTRAINT "HT_chldPlmtStsLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_chldStsLangMaps HT_chldStsLangMaps_HTChildStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldStsLangMaps"
    ADD CONSTRAINT "HT_chldStsLangMaps_HTChildStatusId_fkey" FOREIGN KEY ("HTChildStatusId") REFERENCES public."HT_childStatuses"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_chldStsLangMaps HT_chldStsLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_chldStsLangMaps"
    ADD CONSTRAINT "HT_chldStsLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_choiceLangMaps HT_choiceLangMaps_HTChoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_choiceLangMaps"
    ADD CONSTRAINT "HT_choiceLangMaps_HTChoiceId_fkey" FOREIGN KEY ("HTChoiceId") REFERENCES public."HT_choices"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_choiceLangMaps HT_choiceLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_choiceLangMaps"
    ADD CONSTRAINT "HT_choiceLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_choices HT_choices_HTQuestionDomainId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_choices"
    ADD CONSTRAINT "HT_choices_HTQuestionDomainId_fkey" FOREIGN KEY ("HTQuestionDomainId") REFERENCES public."HT_questionDomains"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_choices HT_choices_HTQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_choices"
    ADD CONSTRAINT "HT_choices_HTQuestionId_fkey" FOREIGN KEY ("HTQuestionId") REFERENCES public."HT_questions"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_choices HT_choices_HTQuestionTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_choices"
    ADD CONSTRAINT "HT_choices_HTQuestionTypeId_fkey" FOREIGN KEY ("HTQuestionTypeId") REFERENCES public."HT_questionTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_countryLangMaps HT_countryLangMaps_HTCountryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_countryLangMaps"
    ADD CONSTRAINT "HT_countryLangMaps_HTCountryId_fkey" FOREIGN KEY ("HTCountryId") REFERENCES public."HT_countries"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_countryLangMaps HT_countryLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_countryLangMaps"
    ADD CONSTRAINT "HT_countryLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_deviceDetails HT_deviceDetails_HTUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_deviceDetails"
    ADD CONSTRAINT "HT_deviceDetails_HTUserId_fkey" FOREIGN KEY ("HTUserId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_districtLangMaps HT_districtLangMaps_HTDistrictId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_districtLangMaps"
    ADD CONSTRAINT "HT_districtLangMaps_HTDistrictId_fkey" FOREIGN KEY ("HTDistrictId") REFERENCES public."HT_districts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_districtLangMaps HT_districtLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_districtLangMaps"
    ADD CONSTRAINT "HT_districtLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_districts HT_districts_HTStateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_districts"
    ADD CONSTRAINT "HT_districts_HTStateId_fkey" FOREIGN KEY ("HTStateId") REFERENCES public."HT_states"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_events HT_events_HTChildId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_events"
    ADD CONSTRAINT "HT_events_HTChildId_fkey" FOREIGN KEY ("HTChildId") REFERENCES public."HT_children"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_events HT_events_HTEventId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_events"
    ADD CONSTRAINT "HT_events_HTEventId_fkey" FOREIGN KEY ("HTEventId") REFERENCES public."HT_events"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_events HT_events_HTUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_events"
    ADD CONSTRAINT "HT_events_HTUserId_fkey" FOREIGN KEY ("HTUserId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_families HT_families_HTCountryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_families"
    ADD CONSTRAINT "HT_families_HTCountryId_fkey" FOREIGN KEY ("HTCountryId") REFERENCES public."HT_countries"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_families HT_families_HTDistrictId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_families"
    ADD CONSTRAINT "HT_families_HTDistrictId_fkey" FOREIGN KEY ("HTDistrictId") REFERENCES public."HT_districts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_families HT_families_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_families"
    ADD CONSTRAINT "HT_families_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_families HT_families_HTStateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_families"
    ADD CONSTRAINT "HT_families_HTStateId_fkey" FOREIGN KEY ("HTStateId") REFERENCES public."HT_states"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_familyMemTypeLangMaps HT_familyMemTypeLangMaps_HTFamilyMemberTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyMemTypeLangMaps"
    ADD CONSTRAINT "HT_familyMemTypeLangMaps_HTFamilyMemberTypeId_fkey" FOREIGN KEY ("HTFamilyMemberTypeId") REFERENCES public."HT_familyMemberTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_familyMemTypeLangMaps HT_familyMemTypeLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyMemTypeLangMaps"
    ADD CONSTRAINT "HT_familyMemTypeLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_familyMembers HT_familyMembers_HTFamilyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyMembers"
    ADD CONSTRAINT "HT_familyMembers_HTFamilyId_fkey" FOREIGN KEY ("HTFamilyId") REFERENCES public."HT_families"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_familyMembers HT_familyMembers_HTFamilyMemberTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyMembers"
    ADD CONSTRAINT "HT_familyMembers_HTFamilyMemberTypeId_fkey" FOREIGN KEY ("HTFamilyMemberTypeId") REFERENCES public."HT_familyMemberTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_familyMembers HT_familyMembers_HTFamilyRelationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyMembers"
    ADD CONSTRAINT "HT_familyMembers_HTFamilyRelationId_fkey" FOREIGN KEY ("HTFamilyRelationId") REFERENCES public."HT_familyRelations"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_familyRelanLangMaps HT_familyRelanLangMaps_HTFamilyRelationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyRelanLangMaps"
    ADD CONSTRAINT "HT_familyRelanLangMaps_HTFamilyRelationId_fkey" FOREIGN KEY ("HTFamilyRelationId") REFERENCES public."HT_familyRelations"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_familyRelanLangMaps HT_familyRelanLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_familyRelanLangMaps"
    ADD CONSTRAINT "HT_familyRelanLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_fileUploadMappings HT_fileUploadMappings_HTAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_fileUploadMappings"
    ADD CONSTRAINT "HT_fileUploadMappings_HTAccountId_fkey" FOREIGN KEY ("HTAccountId") REFERENCES public."HT_accounts"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_fileUploadMappings HT_fileUploadMappings_HTChildId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_fileUploadMappings"
    ADD CONSTRAINT "HT_fileUploadMappings_HTChildId_fkey" FOREIGN KEY ("HTChildId") REFERENCES public."HT_children"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_fileUploadMappings HT_fileUploadMappings_HTUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_fileUploadMappings"
    ADD CONSTRAINT "HT_fileUploadMappings_HTUserId_fkey" FOREIGN KEY ("HTUserId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_formQuestionMappings HT_formQuestionMappings_HTFormId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_formQuestionMappings"
    ADD CONSTRAINT "HT_formQuestionMappings_HTFormId_fkey" FOREIGN KEY ("HTFormId") REFERENCES public."HT_forms"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_formQuestionMappings HT_formQuestionMappings_HTQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_formQuestionMappings"
    ADD CONSTRAINT "HT_formQuestionMappings_HTQuestionId_fkey" FOREIGN KEY ("HTQuestionId") REFERENCES public."HT_questions"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HT_formRevisions HT_formRevisions_HTFormId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_formRevisions"
    ADD CONSTRAINT "HT_formRevisions_HTFormId_fkey" FOREIGN KEY ("HTFormId") REFERENCES public."HT_forms"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_formRevisions HT_formRevisions_HTQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_formRevisions"
    ADD CONSTRAINT "HT_formRevisions_HTQuestionId_fkey" FOREIGN KEY ("HTQuestionId") REFERENCES public."HT_questions"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_forms HT_forms_HTAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_forms"
    ADD CONSTRAINT "HT_forms_HTAccountId_fkey" FOREIGN KEY ("HTAccountId") REFERENCES public."HT_accounts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_langMaps HT_langMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_langMaps"
    ADD CONSTRAINT "HT_langMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_langMaps HT_langMaps_LanguageRefIdId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_langMaps"
    ADD CONSTRAINT "HT_langMaps_LanguageRefIdId_fkey" FOREIGN KEY ("LanguageRefIdId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_notifLangMaps HT_notifLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifLangMaps"
    ADD CONSTRAINT "HT_notifLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_notifLangMaps HT_notifLangMaps_HTNotificationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifLangMaps"
    ADD CONSTRAINT "HT_notifLangMaps_HTNotificationId_fkey" FOREIGN KEY ("HTNotificationId") REFERENCES public."HT_notifications"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_notifications HT_notifications_HTCaseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifications"
    ADD CONSTRAINT "HT_notifications_HTCaseId_fkey" FOREIGN KEY ("HTCaseId") REFERENCES public."HT_cases"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_notifications HT_notifications_HTChildId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifications"
    ADD CONSTRAINT "HT_notifications_HTChildId_fkey" FOREIGN KEY ("HTChildId") REFERENCES public."HT_children"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_notifications HT_notifications_HTFamilyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifications"
    ADD CONSTRAINT "HT_notifications_HTFamilyId_fkey" FOREIGN KEY ("HTFamilyId") REFERENCES public."HT_families"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_notifications HT_notifications_HTNotifnEventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifications"
    ADD CONSTRAINT "HT_notifications_HTNotifnEventTypeId_fkey" FOREIGN KEY ("HTNotifnEventTypeId") REFERENCES public."HT_notifnEventTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_notifications HT_notifications_HTUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifications"
    ADD CONSTRAINT "HT_notifications_HTUserId_fkey" FOREIGN KEY ("HTUserId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_notifications HT_notifications_RecieverIdId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifications"
    ADD CONSTRAINT "HT_notifications_RecieverIdId_fkey" FOREIGN KEY ("RecieverIdId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_notifications HT_notifications_SenderIdId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_notifications"
    ADD CONSTRAINT "HT_notifications_SenderIdId_fkey" FOREIGN KEY ("SenderIdId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_questionLangMaps HT_questionLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questionLangMaps"
    ADD CONSTRAINT "HT_questionLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_questionLangMaps HT_questionLangMaps_HTQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questionLangMaps"
    ADD CONSTRAINT "HT_questionLangMaps_HTQuestionId_fkey" FOREIGN KEY ("HTQuestionId") REFERENCES public."HT_questions"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_questions HT_questions_HTAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questions"
    ADD CONSTRAINT "HT_questions_HTAccountId_fkey" FOREIGN KEY ("HTAccountId") REFERENCES public."HT_accounts"(id) NOT VALID;


--
-- Name: HT_questions HT_questions_HTAnswerTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questions"
    ADD CONSTRAINT "HT_questions_HTAnswerTypeId_fkey" FOREIGN KEY ("HTAnswerTypeId") REFERENCES public."HT_answerTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_questions HT_questions_HTQuestionDomainId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questions"
    ADD CONSTRAINT "HT_questions_HTQuestionDomainId_fkey" FOREIGN KEY ("HTQuestionDomainId") REFERENCES public."HT_questionDomains"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_questions HT_questions_HTQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questions"
    ADD CONSTRAINT "HT_questions_HTQuestionId_fkey" FOREIGN KEY ("HTQuestionId") REFERENCES public."HT_questions"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_questions HT_questions_HTQuestionTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_questions"
    ADD CONSTRAINT "HT_questions_HTQuestionTypeId_fkey" FOREIGN KEY ("HTQuestionTypeId") REFERENCES public."HT_questionTypes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_qusnDomainLangMaps HT_qusnDomainLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_qusnDomainLangMaps"
    ADD CONSTRAINT "HT_qusnDomainLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_qusnDomainLangMaps HT_qusnDomainLangMaps_HTQuestionDomainId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_qusnDomainLangMaps"
    ADD CONSTRAINT "HT_qusnDomainLangMaps_HTQuestionDomainId_fkey" FOREIGN KEY ("HTQuestionDomainId") REFERENCES public."HT_questionDomains"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_responses HT_responses_HTAssessmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_responses"
    ADD CONSTRAINT "HT_responses_HTAssessmentId_fkey" FOREIGN KEY ("HTAssessmentId") REFERENCES public."HT_assessments"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_responses HT_responses_HTChoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_responses"
    ADD CONSTRAINT "HT_responses_HTChoiceId_fkey" FOREIGN KEY ("HTChoiceId") REFERENCES public."HT_choices"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_responses HT_responses_HTQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_responses"
    ADD CONSTRAINT "HT_responses_HTQuestionId_fkey" FOREIGN KEY ("HTQuestionId") REFERENCES public."HT_questions"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_stateLangMaps HT_stateLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_stateLangMaps"
    ADD CONSTRAINT "HT_stateLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_stateLangMaps HT_stateLangMaps_HTStateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_stateLangMaps"
    ADD CONSTRAINT "HT_stateLangMaps_HTStateId_fkey" FOREIGN KEY ("HTStateId") REFERENCES public."HT_states"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_states HT_states_HTCountryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_states"
    ADD CONSTRAINT "HT_states_HTCountryId_fkey" FOREIGN KEY ("HTCountryId") REFERENCES public."HT_countries"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_userLogs HT_userLogs_HTUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_userLogs"
    ADD CONSTRAINT "HT_userLogs_HTUserId_fkey" FOREIGN KEY ("HTUserId") REFERENCES public."HT_users"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_userRoleLangMaps HT_userRoleLangMaps_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_userRoleLangMaps"
    ADD CONSTRAINT "HT_userRoleLangMaps_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_userRoleLangMaps HT_userRoleLangMaps_HTUserRoleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_userRoleLangMaps"
    ADD CONSTRAINT "HT_userRoleLangMaps_HTUserRoleId_fkey" FOREIGN KEY ("HTUserRoleId") REFERENCES public."HT_userRoles"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_users HT_users_HTAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_users"
    ADD CONSTRAINT "HT_users_HTAccountId_fkey" FOREIGN KEY ("HTAccountId") REFERENCES public."HT_accounts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_users HT_users_HTCountryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_users"
    ADD CONSTRAINT "HT_users_HTCountryId_fkey" FOREIGN KEY ("HTCountryId") REFERENCES public."HT_countries"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_users HT_users_HTDistrictId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_users"
    ADD CONSTRAINT "HT_users_HTDistrictId_fkey" FOREIGN KEY ("HTDistrictId") REFERENCES public."HT_districts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_users HT_users_HTLanguageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_users"
    ADD CONSTRAINT "HT_users_HTLanguageId_fkey" FOREIGN KEY ("HTLanguageId") REFERENCES public."HT_languages"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_users HT_users_HTStateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_users"
    ADD CONSTRAINT "HT_users_HTStateId_fkey" FOREIGN KEY ("HTStateId") REFERENCES public."HT_states"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HT_users HT_users_HTUserRoleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ht_db_user
--

ALTER TABLE ONLY public."HT_users"
    ADD CONSTRAINT "HT_users_HTUserRoleId_fkey" FOREIGN KEY ("HTUserRoleId") REFERENCES public."HT_userRoles"(id) ON UPDATE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: ht_db_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

