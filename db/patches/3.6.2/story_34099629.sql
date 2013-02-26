drop table if exists organizations_to_domains;

create table organizations_to_domains (
    otd_id INT AUTO_INCREMENT PRIMARY KEY,
    domain_id INT NOT NULL,
    org_id int not null,
    orgtype_id int not null,
    is_home tinyint default 0
);

insert into organizations_to_domains (domain_id, org_id, orgtype_id, is_home)
select domain_id, org_id, orgtype_id, 1 from organizations;


CREATE index organizations_to_domains_idx1 on organizations_to_domains (domain_id) using hash;
CREATE index organizations_to_domains_idx2 on organizations_to_domains (org_id) using hash;
CREATE index organizations_to_domains_idx3 on organizations_to_domains (orgtype_id) using hash;
CREATE index organizations_to_domains_idx4 on organizations_to_domains (is_home) using hash;

CREATE index lo_order_idx3 on lo_order (ldstat_id) using hash;
CREATE index lo_order_idx4 on lo_order (lbps_id) using hash;
CREATE index lo_fulfillment_order_idx1_idx2 on lo_fulfillment_order (ldstat_id) using hash;
CREATE index lo_fulfillment_order_idx1_idx3 on lo_fulfillment_order (lsps_id) using hash;
CREATE index lo_order_line_item_idx1_idx4 on lo_order_line_item (ldstat_id) using hash;
CREATE index lo_order_line_item_idx1_idx5 on lo_order_line_item (lsps_id) using hash;
CREATE index lo_order_line_item_idx1_idx6 on lo_order_line_item (lbps_id) using hash;
--
--
--

---alter table organizations drop domain_id; alter table organizations drop orgtype_id;

/*
id
domainid
orgid
orgtypeid
isHome
*/