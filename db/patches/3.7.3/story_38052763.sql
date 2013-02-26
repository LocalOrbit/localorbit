
select lo_order_deliveries.lodeliv_id,
a.org_id,a.address_id,a.address,a.city,a.postal_code,a.telephone
from lo_order_deliveries 
left join lo_order on lo_order.lo_oid=lo_order_deliveries.lo_oid
left join addresses a on a.org_id=lo_order.org_id
where pickup_address_id=0 and deliv_address_id=0
and lo_order_deliveries.lo_oid not in (select lo_oid from lo_order where ldstat_id=1)
and lo_order_deliveries.lo_oid>=2796
and lo_order.domain_id not in (23,24,25,26,3,6);

update lo_order_deliveries set 
deliv_org_id		=776,
deliv_address_id	=797,
deliv_address		='111 Harvard Drive SE',
deliv_postal_code	='87106',
deliv_telephone		='(505) 266-0000',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1696);

update lo_order_deliveries set 
deliv_org_id		=725,
deliv_address_id	=741,
deliv_address		='8917 4th St. NW',
deliv_postal_code	='87114',
deliv_telephone		='505-503-7124',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1701,1703,1705);

update lo_order_deliveries set 
deliv_org_id		=755,
deliv_address_id	=774,
deliv_address		='3128 Central Ave NE',
deliv_postal_code	='87106',
deliv_telephone		='1 505.266.4455',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1714,1723);

update lo_order_deliveries set 
deliv_org_id		=725,
deliv_address_id	=741,
deliv_address		='8917 4th St. NW',
deliv_postal_code	='87114',
deliv_telephone		='505-503-7124',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1729,1732);


update lo_order_deliveries set 
deliv_org_id		=756,
deliv_address_id	=775,
deliv_address		='10601 Montgomery Blvd',
deliv_postal_code	='87111',
deliv_telephone		='1 505.294.9463',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1737);

update lo_order_deliveries set 
deliv_org_id		=725,
deliv_address_id	=741,
deliv_address		='8917 4th St. NW',
deliv_postal_code	='87114',
deliv_telephone		='505-503-7124',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1751,1774);

update lo_order_deliveries set 
deliv_org_id		=755,
deliv_address_id	=774,
deliv_address		='3128 Central Ave NE',
deliv_postal_code	='87106',
deliv_telephone		='1 505.266.4455',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1756);

update lo_order_deliveries set 
deliv_org_id		=746,
deliv_address_id	=765,
deliv_address		='424 Central Blvd S.E.',
deliv_postal_code	='87102',
deliv_telephone		='1 505.243.0200',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1758);

update lo_order_deliveries set 
deliv_org_id		=815,
deliv_address_id	=837,
deliv_address		='2201 Q St. Suite B ABQ Uptown Center,',
deliv_postal_code	='87110',
deliv_telephone		='505-837-2467',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1762);


update lo_order_deliveries set 
deliv_org_id		=977,
deliv_address_id	=1013,
deliv_address		='355 Platinum St. SW',
deliv_postal_code	='87102',
deliv_telephone		='5053218856',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1772);


update lo_order_deliveries set 
deliv_org_id		=749,
deliv_address_id	=768,
deliv_address		='510 Central Ave SE',
deliv_postal_code	='87102',
deliv_telephone		='1 505.243.0130',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1768);




update lo_order_deliveries set 
deliv_org_id		=775,
deliv_address_id	=796,
deliv_address		='600 Central Ave SE # A',
deliv_postal_code	='87102',
deliv_telephone		='(505) 248-9800',
deliv_region_id		=42,
deliv_city			='Albuquerque'
where lodeliv_id in (1770);
