INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.075', '002', '55181184');
alter table domains add address_id int;

update domains set address_id = (
	select a.address_id
	from addresses a
	left join organizations o on a.org_id=o.org_id
	left join directory_country_region dcr on (a.region_id=dcr.region_id)
	left join organizations_to_domains otd on otd.org_id = o.org_id
	where otd.domain_id=domains.domain_id
	and a.is_deleted=0
	and otd.orgtype_id=2
	and default_shipping=1
	limit 1
);