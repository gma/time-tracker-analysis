DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
  id BIGSERIAL PRIMARY KEY,
  day DATE NOT NULL,
  customer VARCHAR(255) NOT NULL,
  project VARCHAR(255) NOT NULL,
  service VARCHAR(255) NOT NULL,
  person VARCHAR(255) NOT NULL,
  note VARCHAR(255) NULL,
  hours NUMERIC NOT NULL,
  revenue NUMERIC NULL,
  locked boolean NULL
)
