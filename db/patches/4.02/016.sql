INSERT INTO migrations (version_id, pt_ticket_no) VALUES ('016', '');DROP TABLE IF EXISTS phrase_overrides;CREATE TABLE phrase_overrides (  pover_id        int AUTO_INCREMENT NOT NULL,  phrase_id       int,  domain_id       int,  lang_id         int,  override_value  varchar(255),  /* Keys */  PRIMARY KEY (pover_id)) ENGINE = MyISAM  CHARACTER SET latin1 COLLATE latin1_swedish_ci;