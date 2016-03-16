-- db schema
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
SET search_path = public, pg_catalog;
SET default_tablespace = '';
SET default_with_oids = false;

-- Name: user_config; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
CREATE TABLE user_config (
  id serial PRIMARY KEY,
  type text NOT NULL,
  data json NOT NULL
);

COPY user_config (id, type, data) FROM stdin;
1	exchanges	{"exchanges" : {\
    "settings": {\
      "commission": 1.0\
    },\
    "plugins" : {\
      "current": {\
        "ticker": "coinbase",\
        "trade": "coinbase",\
        "transfer": "coinbase"\
      },\
      "settings": {\
        "bitpay": {},\
        "bitstamp": {"currency": "USD", "key": "test", "secret": "test", "clientId": "test" },\
        "blockchain" : {},\
        "coinbase" : {}\
      }\
    }\
  }\
}
\.

COPY user_config (id, type, data) FROM stdin;
2	software	{"brain": {\
    "qrTimeout": 60000,\
    "goodbyeTimeout": 2000,\
    "billTimeout": 60000,\
    "completedTimeout": 60000,\
    "networkTimeout": 20000,\
    "triggerRetry": 5000,\
    "idleTime": 600000,\
    "checkIdleTime": 60000,\
    "maxProcessSize": 104857600,\
    "freeMemRatio": 0.15\
  },\
  "updater": {\
    "caFile": "/usr/local/share/sencha/certs/lamassu.pem",\
    "certFile": "/usr/local/share/sencha/keys/client.pem",\
    "keyFile": "/usr/local/share/sencha/keys/client.key",\
    "port": 8000,\
    "host": "updates.lamassu.is",\
    "downloadDir": "/tmp/download",\
    "extractDir": "/tmp/extract",\
    "updateInterval": 30000,\
    "deathInterval": 600000,\
    "extractor": {\
      "lamassuPubKeyFile": "/usr/local/share/sencha/pubkeys/lamassu.pub.key",\
      "sigAlg": "RSA-SHA256",\
      "hashAlg": "sha256"\
    }\
  },\
  "exchanges": {\
    "settings": {\
      "fastPoll": 5000,\
      "fastPollLimit": 10,\
      "tickerInterval": 5000,\
      "balanceInterval": 5000,\
      "tradeInterval": 5000,\
      "retryInterval": 5000,\
      "retries": 3,\
      "lowBalanceMargin": 1.05,\
      "transactionFee": 10000,\
      "tickerDelta": 0,\
      "minimumTradeFiat": 0\
    },\
    "plugins": {\
      "settings": {\
        "blockchain": {\
          "retryInterval": 10000,\
          "retryTimeout": 60000\
        }\
      }\
    }\
  }\
}
\.

COPY user_config (id, type, data) FROM stdin;
3	unit	{ "brain": {\
    "unit": {\
      "ssn": "xx-1234-45",\
      "owner": "Lamassu, Inc. / Trofa / Portugal"\
    },\
    "locale": {\
      "currency": "USD",\
      "localeInfo": {\
        "primaryLocale": "en-US",\
        "primaryLocales": ["en-US"]\
      }\
    }\
  }\
}
\.

CREATE TABLE devices (
  id serial PRIMARY KEY,
  fingerprint text NOT NULL UNIQUE,
  name text,
  authorized boolean,
  unpair boolean NOT NULL DEFAULT false
);

CREATE TABLE pairing_tokens (
  id serial PRIMARY KEY,
  token text,
  created timestamp NOT NULL DEFAULT now()
);
CREATE TYPE transaction_stage AS ENUM (
    'initial_request',
    'partial_request',
    'final_request',
    'partial_send',
    'deposit',
    'dispense_request',
    'dispense'
);
CREATE TYPE transaction_authority AS ENUM (
    'timeout',
    'machine',
    'pending',
    'rejected',
    'published',
    'authorized',
    'confirmed'
);

CREATE TABLE transactions (
    id serial PRIMARY KEY,
    session_id uuid,
    device_fingerprint text,
    to_address text NOT NULL,
    satoshis integer NOT NULL DEFAULT 0,
    fiat integer NOT NULL DEFAULT 0,
    currency_code text NOT NULL,
    fee integer NOT NULL DEFAULT 0,
    incoming boolean NOT NULL,
    stage transaction_stage NOT NULL,
    authority transaction_authority NOT NULL,
    tx_hash text,
    error text,
    created timestamp NOT NULL DEFAULT now(),
    UNIQUE (session_id, to_address, stage, authority)
);

CREATE INDEX ON transactions (session_id);
CREATE TABLE bills (
    id uuid PRIMARY KEY,
    device_fingerprint text,
    denomination integer NOT NULL,
    currency_code text NOT NULL,
    satoshis integer NOT NULL,
    to_address text NOT NULL,
    session_id uuid,
    device_time bigint NOT NULL,
    created timestamp NOT NULL DEFAULT now()
);

-- Name: users; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
CREATE TABLE users (
  id serial PRIMARY KEY,
  userName text NOT NULL UNIQUE,
  salt text NOT NULL,
  pwdHash text NOT NULL
);

CREATE TABLE pending_transactions (
    id serial PRIMARY KEY,
    device_fingerprint text NOT NULL,
    session_id uuid UNIQUE,
    incoming boolean NOT NULL,
    currency_code text NOT NULL,
    to_address text NOT NULL,
    satoshis integer NOT NULL,
    updated timestamp NOT NULL DEFAULT now()
);

CREATE TABLE dispenses (
    id serial PRIMARY KEY,
    device_fingerprint text NOT NULL,
    transaction_id integer UNIQUE REFERENCES transactions(id),
    dispense1 integer NOT NULL,
    reject1 integer NOT NULL,
    count1 integer NOT NULL,
    dispense2 integer NOT NULL,
    reject2 integer NOT NULL,
    count2 integer NOT NULL,
    refill boolean NOT NULL,
    error text,
    created timestamp NOT NULL DEFAULT now()
);
CREATE INDEX ON dispenses (device_fingerprint);
