
INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('005', '');

DROP VIEW v_organizations;


CREATE VIEW v_organizations
AS

select 
  `o`.`org_id` AS `org_id`,
  `o`.`parent_org_id` AS `parent_org_id`,
  `o`.`name` AS `name`,
  `o`.`profile` AS `profile`,
  `o`.`buyer_type` AS `buyer_type`,
  `o`.`allow_sell` AS `allow_sell`,
  `o`.`is_active` AS `is_active`,
  `o`.`is_enabled` AS `is_enabled`,
  `o`.`creation_date` AS `creation_date`,
  `o`.`activation_date` AS `activation_date`,
  `o`.`public_profile` AS `public_profile`,
  `o`.`facebook` AS `facebook`,
  `o`.`twitter` AS `twitter`,
  `o`.`product_how` AS `product_how`,
  `o`.`payment_allow_purchaseorder` AS `payment_allow_purchaseorder`,
  `o`.`payment_allow_paypal` AS `payment_allow_paypal`,
  `o`.`is_deleted` AS `is_deleted`,
  `o`.`payment_entity_id` AS `payment_entity_id`,
  `o`.`po_due_within_days` AS `po_due_within_days`,
  `d`.`domain_id` AS `domain_id`,
  `d`.`name` AS `domain_name`,
  `d`.`hostname` AS `hostname`,
  if((`otd`.`orgtype_id` < 3),`otd`.`orgtype_id`,concat_ws('-',3,ifnull(`o`.`allow_sell`,0))) AS `composite_role` ,
  CASE otd.orgtype_id 
  WHEN '1' then 'Admin'
  WHEN '2' then 'Market Manager'
  WHEN '3-0' then 'Buyer'
  WHEN '3-1' then 'Seller'
  ELSE '-'
  END AS `role_label`
from ((`organizations` `o` 
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
    ));
    