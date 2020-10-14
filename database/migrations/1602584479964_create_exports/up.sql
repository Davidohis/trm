CREATE TABLE exports (
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  digest TEXT NOT NULL,
  exported_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,

  CONSTRAINT name_type_unique UNIQUE (name, type)
);

CREATE FUNCTION techie_export(location text)
  RETURNS SETOF techies
AS
$body$
  SELECT * FROM techies WHERE location=location
$body$
LANGUAGE SQL STABLE;

CREATE FUNCTION techie_anonymous_export()
  RETURNS SETOF techies
AS
$body$
  SELECT * FROM techies
$body$
LANGUAGE SQL STABLE;

CREATE FUNCTION techie_export_digest(location text)
  RETURNS TEXT
AS
$body$
  SELECT encode(digest(array_to_json(ARRAY_AGG(row_to_json(t)))::text, 'md5'), 'hex')
  FROM (
    SELECT id, updated_at FROM techie_export(location)
  ) t
$body$
LANGUAGE SQL STABLE;

CREATE FUNCTION techie_anonymous_export_digest()
  RETURNS TEXT
AS
$body$
  SELECT encode(digest(array_to_json(ARRAY_AGG(row_to_json(t)))::text, 'md5'), 'hex')
  FROM (
    SELECT id, updated_at FROM techie_anonymous_export
  ) t
$body$
LANGUAGE SQL STABLE;

CREATE FUNCTION techie_pending_exports()
  RETURNS SETOF exports
AS
$body$
WITH location_export_base AS (
	SELECT 'techies' AS name, value AS type FROM locations
), location_digests AS (
	SELECT name, type, techie_export_digest(b.type) AS digest FROM location_export_base b
	UNION
	SELECT 'techies' AS name, 'anonymous' AS type, techie_anonymous_export_digest() AS digest
), location_existing_digests AS (
	SELECT name, type, digest FROM location_digests WHERE digest IS NOT NULL
) SELECT d.name, d.type, d.digest, 'now()'::timestamp AS exported_at FROM location_existing_digests d LEFT JOIN exports e ON d.name = e.name AND d.type = e.type AND d.digest = e.digest WHERE e.digest IS NULL;
$body$
LANGUAGE SQL STABLE;

CREATE FUNCTION techie_semester_activity_reports(semester_id uuid)
  RETURNS SETOF techie_activity
AS
$body$
  SELECT r.techie_id, r.year, r.week, r.type, r.value
  FROM semesters s
  LEFT JOIN LATERAL techie_activity_reports(s.starts_at::text, s.ends_at::text) r ON true
  WHERE s.id = semester_id AND s.starts_at IS NOT NULL and s.ends_at IS NOT NULL
$body$
LANGUAGE SQL STABLE;

CREATE FUNCTION techie_semester_activity_report_digest(semester_id uuid)
  RETURNS TEXT
AS
$body$
  SELECT encode(digest(array_to_json(ARRAY_AGG(row_to_json(t)))::text, 'md5'), 'hex')
  FROM (
    SELECT techie_semester_activity_reports(semester_id)
  ) t
$body$
LANGUAGE SQL STABLE;

CREATE FUNCTION techie_semester_activity_pending_exports()
  RETURNS SETOF exports
AS
$body$
WITH semester_export_base AS (
	SELECT 'techie_semester_activity' AS name, id AS type FROM semesters WHERE starts_at IS NOT NULL AND ends_at IS NOT NULL
), semester_digests AS (
	SELECT name, type, techie_semester_activity_report_digest(b.type) AS digest FROM semester_export_base b
), semester_existing_digests AS (
	SELECT name, type, digest FROM semester_digests WHERE digest IS NOT NULL
) SELECT d.name, d.type, d.digest, 'now()'::timestamp AS exported_at FROM semester_existing_digests d LEFT JOIN exports e ON d.name = e.name AND d.type = e.type AND d.digest = e.digest WHERE e.digest IS NULL;
$body$
LANGUAGE SQL STABLE;
