DROP TABLE IF EXISTS migrations;

CREATE TABLE migrations (
  version_id    varchar(10) NOT NULL,
  date_ran   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  pt_ticket_no   varchar(10),
  /* Keys */
  PRIMARY KEY (version_id)
) ENGINE = InnoDB;



INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('004', '');