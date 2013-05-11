DROP VIEW IF EXISTS v_payables;

CREATE VIEW v_payables
(
  payable_id,
  domain_id,
  from_org_id,
  to_org_id,
  payable_type,
  parent_obj_id,
  amount,
  invoice_id,
  creation_date,
  from_org_name,
  to_org_name,
  domain_name,
  due_date,
  invoice_date,
  order_nbr,
  days_left,
  payable_info,
  delivery_start_time,
  delivery_end_time,
  amount_paid,
  po_number,
  `status`,
  invoiced,
  searchable_fields,
  delivery_status,
  order_status
)
AS
select 
  `p`.`payable_id` AS `payable_id`,
  `p`.`domain_id` AS `domain_id`,
  `p`.`from_org_id` AS `from_org_id`,
  `p`.`to_org_id` AS `to_org_id`,
  `p`.`payable_type` AS `payable_type`,
  `p`.`parent_obj_id` AS `parent_obj_id`,
  `p`.`amount` AS `amount`,
  `p`.`invoice_id` AS `invoice_id`,
  `p`.`creation_date` AS `creation_date`,
  `o1`.`name` AS `from_org_name`,
  `o2`.`name` AS `to_org_name`,
  `d`.`name` AS `domain_name`,
  ifnull(`i`.`due_date`,9999999999999) AS `due_date`,
  `i`.`creation_date` AS `invoice_date`,
  if((`p`.`payable_type` = 'seller order'),`lfo`.`lo3_order_nbr`,`lo`.`lo3_order_nbr`) AS `order_nbr`,
  floor((
    (`i`.`due_date` - unix_timestamp(now())) / 86400
  )) AS `days_left`,
  concat_ws('|',convert(if((`p`.`payable_type` = 'seller order'),`lfo`.`lo3_order_nbr`,`lo`.`lo3_order_nbr`) using utf8),`p`.`payable_type`,if((`p`.`payable_type` = 'seller order'),`loi`.`lo_foid`,`loi`.`lo_oid`),convert(`loi`.`product_name` using utf8),`loi`.`qty_ordered`,convert(`loi`.`seller_name` using utf8),`loi`.`seller_org_id`,unix_timestamp(`lo`.`order_date`)) AS `payable_info`,
  if((`p`.`payable_type` = 'seller order'),`lod`.`delivery_start_time`,if((`lod`.`pickup_start_time` = 0),`lod`.`delivery_start_time`,`lod`.`pickup_start_time`)) AS `delivery_start_time`,
  if((`p`.`payable_type` = 'seller order'),`lod`.`delivery_end_time`,if((`lod`.`pickup_end_time` = 0),`lod`.`delivery_end_time`,`lod`.`pickup_end_time`)) AS `delivery_end_time`,


  round(coalesce((select 
    sum(`xpp`.`amount`) 
  from `x_payables_payments` `xpp` 
  where
    (`xpp`.`payable_id` = `p`.`payable_id`)),0.0),2) AS `amount_paid`,
  `lo`.`payment_ref` AS `po_number`,
  (
    round(coalesce((select 
      sum(`xpp`.`amount`) 
    from `x_payables_payments` `xpp` 
    where
      (`xpp`.`payable_id` = `p`.`payable_id`)),0.0),2) > 0
  ) AS `status`,


  if((ifnull(`i`.`invoice_id`,0) = 0),0,1) AS `invoiced`,


  concat_ws(' ',`loi`.`product_name`,`lo`.`payment_ref`,if((`p`.`payable_type` = 'seller order'),`lfo`.`lo3_order_nbr`,`lo`.`lo3_order_nbr`),`p`.`amount`) AS `searchable_fields` ,
lods.delivery_status,


CASE 
WHEN loi.lbps_id=2 THEN 'paid'
WHEN loi.ldstat_id=2 THEN 'awaiting delivery'
WHEN loi.lbps_id in (1,3,4) THEN 'awaiting buyer payment'
WHEN loi.lbps_id=2 AND loi.ldstat_id THEN 'awaiting MM or LO transfer'
END
AS order_status


from `payables` `p` 
  join `organizations` `o1` on
   
      (`p`.`from_org_id` = `o1`.`org_id`)

  join `organizations` `o2` on

      (`p`.`to_org_id` = `o2`.`org_id`)

  join `domains` `d` on

      (`d`.`domain_id` = `p`.`domain_id`)
 
  left join `invoices` `i` on
 
      (`i`.`invoice_id` = `p`.`invoice_id`)

  left join `lo_order_line_item` `loi` on

      (`loi`.`lo_liid` = `p`.`parent_obj_id`)

  left join `lo_order_deliveries` `lod` on

      (`loi`.`lodeliv_id` = `lod`.`lodeliv_id`)
 
  left join `lo_order` `lo` on

      (`lo`.`lo_oid` = `loi`.`lo_oid`)

  left join `lo_fulfillment_order` `lfo` on

      (`lfo`.`lo_foid` = `loi`.`lo_foid`) 


inner join lo_delivery_statuses lods on (lo.ldstat_id=lods.ldstat_id);