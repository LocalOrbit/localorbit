drop view if exists v_organizations;

create view v_organizations as 
	select o.*,d.domain_id,d.name as domain_name,d.hostname,
	if(otd.orgtype_id<3,otd.orgtype_id,concat_ws('-',3,ifnull(o.allow_sell,0)))
	 as composite_role
	from organizations o
	left join organizations_to_domains otd on (otd.org_id=o.org_id and otd.is_home=1)
	left join domains d on d.domain_id=otd.domain_id
;