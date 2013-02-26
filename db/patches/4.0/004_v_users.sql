drop view if exists v_users;

create view v_users as 
	select ce.*,o.name as org_name,d.domain_id,d.name as domain_name,d.hostname,
	o.is_deleted as org_is_deleted,
	if(otd.orgtype_id<3,otd.orgtype_id,concat_ws('-',3,ifnull(o.allow_sell,0)))
	 as composite_role
	from customer_entity ce
	inner join organizations o on ce.org_id=o.org_id
	left join organizations_to_domains otd on (otd.org_id=o.org_id and otd.is_home=1)
	left join domains d on d.domain_id=otd.domain_id
;