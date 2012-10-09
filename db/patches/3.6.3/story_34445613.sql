insert into phrases (pcat_id,label,default_value,edit_type) values (6,'nav2:marketadmin:metrics','Metrics','text');

DROP TABLE IF EXISTS `domains_is_live_history`;

CREATE TABLE `domains_is_live_history` (
  dhistlive_id bigint(20) NOT NULL AUTO_INCREMENT,
  domain_id int,
  is_live_start timestamp NOT NULL default CURRENT_TIMESTAMP,
  is_live_end   timestamp NOT NULL default '2038-01-01 00:00:00',
  is_current int default 1,
  KEY `domains_is_live_history_idx1` (`dhistlive_id`) USING HASH,
  KEY `domains_is_live_history_idx2` (`domain_id`) USING HASH,
  KEY `domains_is_live_history_idx3` (`domain_id`) USING HASH,
  KEY `domains_is_live_history_idx4` (`is_live_end`) USING HASH
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

delete from domains_is_live_history;

insert into domains_is_live_history (domain_id, is_live_start)
select domain_id, '2010-01-01 00:00:00' as is_live_start from domains where is_live=1;
