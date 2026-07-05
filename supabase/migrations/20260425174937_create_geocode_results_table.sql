CREATE TABLE IF NOT EXISTS _whateka_geocode_results (
  submission_id BIGINT PRIMARY KEY,
  status_code INT,
  api_error TEXT,
  new_lat FLOAT,
  new_lng FLOAT,
  distance_km FLOAT,
  raw_content TEXT
);
