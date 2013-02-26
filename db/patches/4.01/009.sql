INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('009', '');


DROP VIEW v_users;


CREATE VIEW v_users
AS
select 
  `ce`.`entity_id` AS `entity_id`,
  `ce`.`entity_type_id` AS `entity_type_id`,
  `ce`.`attribute_set_id` AS `attribute_set_id`,
  `ce`.`website_id` AS `website_id`,
  `ce`.`email` AS `email`,
  `ce`.`group_id` AS `group_id`,
  `ce`.`increment_id` AS `increment_id`,
  `ce`.`store_id` AS `store_id`,
  `ce`.`created_at` AS `created_at`,
  `ce`.`updated_at` AS `updated_at`,
  `ce`.`is_active` AS `is_active`,
  `ce`.`org_id` AS `org_id`,
  `ce`.`first_name` AS `first_name`,
  `ce`.`last_name` AS `last_name`,
  `ce`.`password` AS `password`,
  `ce`.`is_enabled` AS `is_enabled`,
  `ce`.`is_deleted` AS `is_deleted`,
  `o`.`name` AS `org_name`,
  `d`.`domain_id` AS `domain_id`,
  `d`.`name` AS `domain_name`,
  `d`.`hostname` AS `hostname`,
  `o`.`is_deleted` AS `org_is_deleted`,
  if((`otd`.`orgtype_id` < 3),`otd`.`orgtype_id`,concat_ws('-',3,ifnull(`o`.`allow_sell`,0))) AS `composite_role`,
  CASE  if((`otd`.`orgtype_id` < 3),`otd`.`orgtype_id`,concat_ws('-',3,ifnull(`o`.`allow_sell`,0)))
  WHEN '1' then 'Admin'
  WHEN '2' then 'Market Manager'
  WHEN '3-0' then 'Buyer'
  WHEN '3-1' then 'Seller'
  ELSE '-'
  END AS `role_label`
  
  
from (((`customer_entity` `ce` 
  join `organizations` `o` on
    (
      (`ce`.`org_id` = `o`.`org_id`)
    )) 
  left join `organizations_to_domains` `otd` on
    (
      (
        (`otd`.`org_id` = `o`.`org_id`) and
        (`otd`.`is_home` = 1)
      )
    )) 
  left join `domains` `d` on
    (
      (`d`.`domain_id` = `otd`.`domain_id`)
    ))
;