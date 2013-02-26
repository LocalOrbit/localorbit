update products p
	set p.how=(
		select o.product_how 
		from organizations o 
		where o.org_id=p.org_id
	)
where p.how='';

update products p
	set p.who=(
		select o.profile 
		from organizations o 
		where o.org_id=p.org_id
	)
where p.who='';