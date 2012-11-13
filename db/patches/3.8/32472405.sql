select org_id, count(*) from customer_entity where is_deleted = false and is_enabled = true and is_active = true group by org_id having count(*) > 1;
