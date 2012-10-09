<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

$queries = array(

// "select t.*,tor.*
//       from template_options t
//       left join template_option_overrides tor on (t.tempopt_id=tor.tempopt_id and tor.domain_id=6)
//      where t.value_type in ('footer') ;",
// "select phrases.* from phrases;",
// "select domains.*,tz.offset_seconds,tz.tz_code,tz.tz_name,ds_start,ds_end from domains left join timezones tz on (domains.tz_id=tz.tz_id) left join daylight_savings ds on (ds.ds_year=2012) where hostname='testingtasteofmichigan.localorb.it';",
"select SQL_NO_CACHE organizations.*,unix_timestamp(organizations.creation_date) as creation_date,unix_timestamp(organizations.activation_date) as activation_date from organizations where organizations.org_id='190'",
"  select SQL_NO_CACHE addresses.*,code from addresses left join directory_country_region on (directory_country_region.region_id=addresses.region_id) where is_deleted=0 and org_id='190'",
"select SQL_NO_CACHE addresses.*,code from addresses left join directory_country_region on (directory_country_region.region_id=addresses.region_id) where is_deleted=0 and org_id='190' order by label",
"select SQL_NO_CACHE directory_country_region.* from directory_country_region where country_id in ('US','CA')  and region_id not in (6,7,8,9,10,11,17,46,3,20)  and country_id='US' order by country_id='US' desc,code",
"select SQL_NO_CACHE customer_entity.*,unix_timestamp(customer_entity.created_at) as created_at,unix_timestamp(customer_entity.updated_at) as updated_at from customer_entity where org_id='190' order by first_name",
"select SQL_NO_CACHE organization_cross_sells.* from organization_cross_sells where org_id='190'",
"select SQL_NO_CACHE organization_delivery_cross_sells.* from organization_delivery_cross_sells where org_id='190'",
"select SQL_NO_CACHE delivery_days.*,a.address,a.city,a.postal_code from delivery_days left join addresses a on (a.address_id=delivery_days.deliv_address_id)",

/*
"
      select p.prod_id,p.name,how,p.who as product_who,description,category_ids,p.org_id,
      pi.pimg_id,pi.width,pi.height,pi.extension,u.NAME as single_unit,u.PLURAL as plural_unit,
      o.name as org_name,
      (
        select group_concat(price_id) 
        from product_prices 
        where product_prices.prod_id=p.prod_id 
        and (product_prices.org_id = 0 or product_prices.org_id=88)
        and (product_prices.domain_id = 0 or product_prices.domain_id=6)
      ) as price_ids,
      (select group_concat(dd_id) from product_delivery_cross_sells where product_delivery_cross_sells.prod_id=p.prod_id) as dd_ids,
      (select sum(qty) from product_inventory inv where inv.prod_id=p.prod_id) as inventory,
      a.address,a.city,a.postal_code,dcr.code,a.latitude,a.longitude
      from products p
      left join product_images pi on pi.prod_id=p.prod_id
      left join organizations o on o.org_id=p.org_id
      left join addresses a on p.addr_id=a.address_id
      left join directory_country_region dcr on a.region_id=dcr.region_id
      left join Unit u on p.unit_id=u.UNIT_ID
      where p.prod_id > 0
      and (select count(price_id) from product_prices where product_prices.prod_id=p.prod_id and (product_prices.org_id=0 or product_prices.org_id=88)) > 0
      and (select sum(qty) from product_inventory where product_inventory.prod_id=p.prod_id) > 0
      and p.unit_id is not null
      and p.unit_id <> 0
      and o.is_active=1
      and o.is_enabled=1
      and (
        p.prod_id in (
          select prod_id
          from product_delivery_cross_sells
          where dd_id in (
            select dd_id from delivery_days where domain_id=6
          )
        )
      )
      
     group by p.prod_id order by p.category_ids",
     */
     
     // "select * 
     //  from categories 
     //  where cat_id in (2,121,137,146,379,227,228,265,28,339,3,4,787,30,34,638,500,501,502,62,508,509,66,67,73,90,94) 
     //  order by cat_name",
    
// "select organizations.*,unix_timestamp(organizations.creation_date) as creation_date,unix_timestamp(organizations.activation_date) as activation_date from organizations where org_id in ('90','712','10','910','626','648','88','87','89')  order by name;",
// "select product_prices.*,unix_timestamp(product_prices.creation_date) as creation_date,d.name as domain,o.name as org_name from product_prices left join domains d on (product_prices.domain_id=d.domain_id) left join organizations o on (product_prices.org_id=o.org_id) where price_id in ('27','1008','1009','20','655','1395','1396','1398','28','692','311','433','999','225','699','26','669','312','698','997')  and price>0;",
// 'select delivery_days.*,a.address,a.city,a.postal_code from delivery_days left join addresses a on (a.address_id=delivery_days.deliv_address_id) where dd_id in (6,26,28,23);',

//       'select * 
//       from lo_order 
//       where session_id=\'7gfr738pbm0bqthh43gtb2uq34\' 
//       and org_id=88 
//       and status=\'cart\';',
    
// 		'select lo_order_line_item.* from lo_order_line_item where lo_oid=1060 order by seller_name,deliv_time',
// 		'select weekly_specials.*,domains.name as domain_name from weekly_specials left join domains on (domains.domain_id=weekly_specials.domain_id) where weekly_specials.domain_id=6 and is_active=1;',


	// 'select lo_order_line_item.*,UNIX_TIMESTAMP(lo_fulfillment_order.order_date) as order_date,fee_percen_lo,fee_percen_hub from lo_order_line_item left join lo_fulfillment_order on (lo_fulfillment_order.lo_foid=lo_order_line_item.lo_foid) left join lo_order on (lo_order.lo_oid=lo_order_line_item.lo_oid) where lo_order_line_item.status not in (\'cart\',\'CANCELED\')  and lo_fulfillment_order.order_date>\'2012-05-02 08:22:38\' and lo_fulfillment_order.order_date<\'2012-06-01 08:22:38\' order by lo_fulfillment_order.order_date desc;',

	// 'select categories.* from categories where parent_id=2;',

	// 'select concat(\'2,\',cat_id,\',\') as cat_id,cat_name from categories where parent_id=2 order by cat_name;',

	// 'select distinct prod_id,product_name from lo_order_line_item where lo_order_line_item.status <>\'cart\' order by product_name,seller_name;',

	// 'select lo_order_line_item.*,UNIX_TIMESTAMP(lo_fulfillment_order.order_date) as order_date,category_ids,fee_percen_lo,fee_percen_hub from lo_order_line_item left join lo_fulfillment_order on (lo_fulfillment_order.lo_foid=lo_order_line_item.lo_foid) left join products on (lo_order_line_item.prod_id=products.prod_id) left join lo_order on (lo_order.lo_oid=lo_order_line_item.lo_oid) where lo_order_line_item.status not in (\'cart\',\'CANCELED\')  and lo_fulfillment_order.order_date>\'2012-05-02 08:22:38\' and lo_fulfillment_order.order_date<\'2012-06-01 08:22:38\' order by lo_fulfillment_order.order_date desc;',

	// 'select org_id,name from organizations where domain_id=1 order by name;',

	// 'select lo_order_line_item.*,UNIX_TIMESTAMP(lo_fulfillment_order.order_date) as order_date,fee_percen_lo,fee_percen_hub,organizations.name as org_name,organizations.org_id from lo_order_line_item left join lo_fulfillment_order on (lo_fulfillment_order.lo_foid=lo_order_line_item.lo_foid) left join lo_order on (lo_order.lo_oid=lo_order_line_item.lo_oid) left join organizations on (organizations.org_id=lo_order.org_id) where lo_order_line_item.status not in (\'cart\',\'CANCELED\')  and lo_fulfillment_order.order_date>\'2012-05-02 08:22:38\' and lo_fulfillment_order.order_date<\'2012-06-01 08:22:38\' order by order_date desc;',

	// 'select lo_order_line_item.*,UNIX_TIMESTAMP(lo_fulfillment_order.order_date) as order_date,fee_percen_lo,fee_percen_hub,payment_method from lo_order_line_item left join lo_fulfillment_order on (lo_fulfillment_order.lo_foid=lo_order_line_item.lo_foid) left join lo_order on (lo_order.lo_oid=lo_order_line_item.lo_oid) where lo_order_line_item.status not in (\'cart\',\'CANCELED\')  and lo_fulfillment_order.order_date>\'2012-05-02 08:22:38\' and lo_fulfillment_order.order_date<\'2012-06-01 08:22:38\' order by order_date desc;',

	// 'select categories.* from categories where parent_id=2;',

	// 'select org_id,name from organizations where allow_sell=1 and domain_id=1 order by name;',

	// 'select lo_order_line_item.*,UNIX_TIMESTAMP(lo_fulfillment_order.order_date) as order_date,category_ids,fee_percen_lo,fee_percen_hub from lo_order_line_item left join lo_fulfillment_order on (lo_fulfillment_order.lo_foid=lo_order_line_item.lo_foid) left join products on (lo_order_line_item.prod_id=products.prod_id) left join lo_order on (lo_order.lo_oid=lo_order_line_item.lo_oid) where lo_order_line_item.status not in (\'cart\',\'CANCELED\')  and lo_fulfillment_order.order_date>\'2012-05-02 08:22:38\' and lo_fulfillment_order.order_date<\'2012-06-01 08:22:38\' order by order_date desc;',

	// 'select lo_order_line_item.*,UNIX_TIMESTAMP(lo_fulfillment_order.order_date) as order_date,fee_percen_lo,fee_percen_hub from lo_order_line_item left join lo_fulfillment_order on (lo_fulfillment_order.lo_foid=lo_order_line_item.lo_foid) left join lo_order on (lo_order.lo_oid=lo_order_line_item.lo_oid) where lo_order_line_item.status not in (\'cart\',\'CANCELED\')  and lo_fulfillment_order.order_date>\'2012-05-2\' and lo_fulfillment_order.order_date<\'2012-06-1\' order by order_date desc;',

	// 'select categories.* from categories where parent_id=2;',

	// 'select distinct prod_id,concat(product_name,\' from \',seller_name) as product_name from lo_order_line_item where lo_order_line_item.status <>\'cart\' order by product_name,seller_name;',

	// 'select lo_order_line_item.*,UNIX_TIMESTAMP(lo_fulfillment_order.order_date) as order_date,category_ids,fee_percen_lo,fee_percen_hub from lo_order_line_item left join lo_fulfillment_order on (lo_fulfillment_order.lo_foid=lo_order_line_item.lo_foid) left join products on (lo_order_line_item.prod_id=products.prod_id) left join lo_order on (lo_order.lo_oid=lo_order_line_item.lo_oid) where lo_order_line_item.status not in (\'cart\',\'CANCELED\')  and lo_fulfillment_order.order_date>\'2012-05-2\' and lo_fulfillment_order.order_date<\'2012-06-1\' order by order_date desc;',
);

$start = microtime(true);
for ($i=0; $i < 10; $i++)
{ 
  foreach($queries as $query)
  {
    #echo($query);
    $result = new core_collection($query);
    foreach($result as $res)
    {
      echo($res->__data[0]);
    }
  }
  echo("\n");
}

$end = microtime(true);

echo("total time: ".($end - $start)."seconds \n");
exit();

?>

