SET FOREIGN_KEY_CHECKS = 0;

CREATE OR REPLACE TABLE employees (
  employee_id      INT UNSIGNED   NOT NULL AUTO_INCREMENT,

  first_name       VARCHAR(50)    NOT NULL,
  last_name        VARCHAR(50)    NOT NULL,
  birth_date       DATE           NULL,

  email            VARCHAR(255)   NOT NULL,
  phone            VARCHAR(30)    NULL,
  address          VARCHAR(255)   NULL,

  hire_date        DATE           NOT NULL,
  position         VARCHAR(100)   NULL,
  employment_type  VARCHAR(40)    NULL,
  salary           DECIMAL(10, 2) NOT NULL,

  is_active        BOOLEAN        NOT NULL,

  PRIMARY KEY (employee_id),
  UNIQUE KEY uk_employees_email (email),
  UNIQUE KEY uk_employees_phone (phone)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE OR REPLACE TABLE sponsors (
  sponsor_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  company_name     VARCHAR(255) NOT NULL,
  tax_number       VARCHAR(30)  NOT NULL,
  country          VARCHAR(80)  NULL,
  city             VARCHAR(120) NULL,
  category         ENUM('Natural', 'Formula_H') NOT NULL,

  rep_first_name   VARCHAR(50)  NOT NULL,
  rep_last_name    VARCHAR(50)  NOT NULL,
  rep_email        VARCHAR(255) NOT NULL,
  rep_phone        VARCHAR(30)  NULL,

  PRIMARY KEY (sponsor_id),
  UNIQUE KEY uk_sponsors_tax_number (tax_number)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE OR REPLACE TABLE sponsorship_contracts (
  contract_id     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  sponsor_id      INT UNSIGNED  NOT NULL,

  start_date      DATE          NOT NULL,
  end_date        DATE          NULL,

  contract_value  DECIMAL(12,2) NULL,
  offer_type      VARCHAR(30)   NULL,

  PRIMARY KEY (contract_id),
  FOREIGN KEY (sponsor_id) REFERENCES sponsors(sponsor_id) ON UPDATE CASCADE ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE OR REPLACE TABLE financings (
  financing_id    INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  source          VARCHAR(100)   NOT NULL,
  value           DECIMAL(12, 2) NOT NULL,
  income_date     DATE           NOT NULL,

  PRIMARY KEY (financing_id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE OR REPLACE TABLE costs (
  cost_id     INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  year        INT            NOT NULL,
  value       DECIMAL(12, 2) NOT NULL,
  
  PRIMARY KEY (cost_id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE OR REPLACE TABLE owners (
  owner_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name      VARCHAR(50)  NOT NULL,
  last_name       VARCHAR(50)  NOT NULL,
  wealth_rating   INT          NOT NULL,

  PRIMARY KEY (owner_id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE OR REPLACE TABLE hamsters (
  hamster_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name          VARCHAR(50)  NOT NULL,
  race          VARCHAR(50)  NOT NULL,
  weight        INT          NOT NULL, 
  birth_date    DATE         NOT NULL,
  death_date    DATE         NULL,
  specialty     VARCHAR(20)  NULL,
  owner_id      INT UNSIGNED NOT NULL,

  PRIMARY KEY (hamster_id),
  FOREIGN KEY (owner_id) REFERENCES owners(owner_id) ON UPDATE CASCADE ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE OR REPLACE TABLE disciplines (
  discipline_id INT UNSIGNED                                    NOT NULL AUTO_INCREMENT,
  name          VARCHAR(100)                                    NOT NULL,
  category      ENUM('Natural', 'Formula_H')                    NOT NULL,
  surface       ENUM('Tarmac', 'Gravel', 'Sand', 'Ice', 'Snow') NOT NULL,
  distance      INT                                             NOT NULL,

  PRIMARY KEY (discipline_id),
  UNIQUE KEY uk_disciplines_name (name)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE OR REPLACE TABLE competitions (
  competition_id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  discipline_id   INT UNSIGNED NOT NULL,
  name            VARCHAR(100) NOT NULL,
  date            DATE         NOT NULL,
  time            TIME         NOT NULL,
  city            VARCHAR(100) NOT NULL,
  spectators      INT UNSIGNED NULL,

  PRIMARY KEY (competition_id),
  FOREIGN KEY (discipline_id) REFERENCES disciplines(discipline_id) ON UPDATE CASCADE ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE OR REPLACE TABLE participations (
  participation_id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  competition_id    INT UNSIGNED NOT NULL,
  hamster_id        INT UNSIGNED NOT NULL,
  place             INT          NULL,
  disqualified      BOOLEAN      NOT NULL,

  PRIMARY KEY (participation_id),
  FOREIGN KEY (competition_id) REFERENCES competitions(competition_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (hamster_id)     REFERENCES hamsters(hamster_id)         ON UPDATE CASCADE ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE OR REPLACE TABLE doping_tests(
  test_id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  employee_id       INT UNSIGNED NOT NULL,
  participation_id  INT UNSIGNED NOT NULL,
  substance_name    VARCHAR(50)  NOT NULL,
  positive          BOOLEAN      NOT NULL,

  PRIMARY KEY (test_id),
  FOREIGN KEY (employee_id)      REFERENCES employees(employee_id)           ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (participation_id) REFERENCES participations(participation_id) ON UPDATE CASCADE ON DELETE RESTRICT
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;