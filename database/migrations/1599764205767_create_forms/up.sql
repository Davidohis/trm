CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE forms (
  uuid UUID NOT NULL DEFAULT uuid_generate_v1(),
  location TEXT NOT NULL REFERENCES locations (value),
  semester TEXT NOT NULL REFERENCES semesters (value),
  form_id TEXT NOT NULL,
  secret UUID NOT NULL DEFAULT uuid_generate_v1(),
  description TEXT,
  webhook_installed_at TIMESTAMP WITHOUT TIME ZONE,
  imports_techies BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT forms_pkey PRIMARY KEY (uuid)
);

CREATE UNIQUE INDEX forms_uuid ON forms (uuid);
CREATE INDEX forms_location ON forms (location);
