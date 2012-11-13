alter table organizations add column payment_entity_id int(10) unsigned not null;

update organizations set payment_entity_id = (
	select entity_id from customer_entity where customer_entity.org_id = organizations.org_id order by is_deleted, is_enabled desc, is_active desc, entity_id limit 1
) where is_deleted = false and is_active = true and is_enabled = true;

