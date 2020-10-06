CREATE TABLE techie_activity (
  techie_id UUID NOT NULL REFERENCES techies (id),
  year SMALLINT NOT NULL,
  week SMALLINT NOT NULL,
  type TEXT NOT NULL,
  value INTEGER NOT NULL
);

CREATE INDEX techie_activity_techie ON techie_activity (techie_id);
CREATE INDEX techie_activity_year ON techie_activity (year);
CREATE INDEX techie_activity_type ON techie_activity (type);
