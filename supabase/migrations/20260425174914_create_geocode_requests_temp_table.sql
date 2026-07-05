CREATE TABLE IF NOT EXISTS _whateka_geocode_requests (
  submission_id BIGINT PRIMARY KEY,
  request_id BIGINT,
  created_at TIMESTAMPTZ DEFAULT now()
);
