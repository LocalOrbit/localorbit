<?
global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();
core::load_library('crypto');

core_db::query('insert into organizations (name,parent_org_id,domain_id,orgtype_id,is_active) values (\'Localorbit\',0,1,1,true);');


$users = core_db::query('
	select ou.*,ce.*,d.domain_id,cev1.value as first_name,cev2.value as last_name,cet1.value as profile
	from OrbitUser ou
	left join customer_entity ce on (ou.EMAIL=ce.email)
	left join customer_entity_varchar cev1 on (cev1.attribute_id=5 and cev1.entity_id=ce.entity_id)
	left join customer_entity_varchar cev2 on (cev2.attribute_id=7 and cev2.entity_id=ce.entity_id)
	left join domains d on ce.website_id=d.mag_store
	left join customer_entity_text cet1 on (cet1.entity_id=ce.entity_id and cet1.attribute_id=511)
');
#exit('here');

$address_sql = '
	select cae.*,
	
	caev1.value as city,
	caev2.value as company,
	caev3.value as postal_code,
	caev4.value as region,
	caev5.value as fax,
	caev6.value as telephone,
	caev7.value as delivery_instructions,
	dcr.region_id as region_id,
	caet1.value as street,
	caev8.value as region_name,
	caei1.value as alt_region_id
	
	from customer_address_entity cae
	left join customer_address_entity_varchar caev1 on (caev1.entity_id=cae.entity_id and caev1.attribute_id=24)
	left join customer_address_entity_varchar caev2 on (caev2.entity_id=cae.entity_id and caev2.attribute_id=22)
	left join customer_address_entity_varchar caev3 on (caev3.entity_id=cae.entity_id and caev3.attribute_id=28)
	left join customer_address_entity_varchar caev4 on (caev4.entity_id=cae.entity_id and caev4.attribute_id=26)
	left join customer_address_entity_varchar caev5 on (caev5.entity_id=cae.entity_id and caev5.attribute_id=30)
	left join customer_address_entity_varchar caev6 on (caev6.entity_id=cae.entity_id and caev6.attribute_id=29)
	left join customer_address_entity_varchar caev7 on (caev7.entity_id=cae.entity_id and caev7.attribute_id=21)
	left join customer_address_entity_varchar caev8 on (caev8.entity_id=cae.entity_id and caev8.attribute_id=26)
	left join customer_address_entity_int     caei1 on (caei1.entity_id=cae.entity_id and caei1.attribute_id=27)
	left join customer_address_entity_text    caet1 on (caet1.entity_id=cae.entity_id and caet1.attribute_id=23)
	left join directory_country_region dcr on dcr.default_name = caev8.value
	where parent_id=';
$address_sql_sort = ' order by cae.entity_id';

# handling conversation of customer_entity, password encryption
$password_updates = 0;
echo("stage 3a: creating organizations, moving addresses\n");

$files_to_resize = array();

while($user = core_db::fetch_assoc($users))
{
	core::log('trying to update user: '.print_r($user,true));
	
	if(is_numeric($user['entity_id']))
	{
		#echo($user['first_name'].': '.$user['last_name'].': '.$user['PASSWORD']."\n");
		$sql = '
			update customer_entity set 
			password=\''.core_crypto::encode_password($user['PASSWORD']).'\',
			first_name=\''.mysql_escape_string($user['first_name']).'\',
			last_name=\''.mysql_escape_string($user['last_name']).'\'
			where entity_id='.$user['entity_id'];
		#echo($sql."\n");
		#echo($user['email']."\n");
		core_db::query($sql);
		
		# build the organization for this user:
		# handle local orbit users
		if(in_array($user['group_id'],array(5,6,7)))
		{
			$sql = 'update customer_entity set org_id=1 where entity_id='.$user['entity_id'];
			core_db::query($sql);
		}
		
		# handle market managers
		else if(in_array($user['group_id'],array(4)))
		{
			$org_created = false;
			$org_id = core_db::query('select org_id from organizations where domain_id='.$user['domain_id'].' and orgtype_id=2');
			if($org_id = core_db::fetch_assoc($org_id))
			{
				$org_id = $org_id['org_id'];
			}
			else
			{
				$org_id = 0;
			}
			
			$addresses = core_db::query($address_sql.$user['entity_id'].$address_sql_sort);
			while($address = core_db::fetch_assoc($addresses))
			{
				if($org_id == 0)
				{
					core_db::query('insert into organizations (name,parent_org_id,domain_id,orgtype_id,is_active) values (\''.core_db::escape_string($address['company']).'\',0,'.$user['domain_id'].',2,true);');
					$org_id = mysql_insert_id();
					
				}

				core_db::query('update customer_entity set org_id='.$org_id.' where entity_id='.$user['entity_id']);

				if(intval($address['region_id']) != 0)
				{
					core_db::query('
						insert into addresses
							(org_id,label,address,city,region_id,postal_code,telephone,fax)
						values 
							(
								'.$org_id.',
								\'Default\',
								\''.core_db::escape_string($address['street']).'\',
								\''.core_db::escape_string($address['city']).'\',
								'.core_db::escape_string($address['region_id']).',
								\''.core_db::escape_string($address['postal_code']).'\',
								\''.core_db::escape_string($address['telephone']).'\',
								\''.core_db::escape_string($address['fax']).'\'
							);
					');
				}
				#print_r($address);
			}
		}
		# handle retail buyers
		else if(in_array($user['group_id'],array(3,9)))
		{

			core_db::query('insert into organizations (name,parent_org_id,domain_id,orgtype_id,buyer_type,is_active) values (\''.core_db::escape_string($user['first_name'].' '.$user['last_name']).'\',0,'.$user['domain_id'].',3,\'Retail\',true);');
			$org_id = mysql_insert_id();
			core_db::query('update customer_entity set org_id='.$org_id.' where entity_id='.$user['entity_id']);
			

			$addresses = core_db::query($address_sql.$user['entity_id'].$address_sql_sort);
			$default_shipping = -1;
			$default_billing  = -1;
		
			while($address = core_db::fetch_assoc($addresses))
			{
				if(intval($address['region_id']) != 0)
				{
					# only set the address to be the default on the first address for the company
					if($default_shipping == -1)
					{
						$default_shipping = 1;
						$default_billing  = 1;
					}
					else
					{
						$default_shipping = 0;
						$default_billing  = 0;
					}
					core_db::query('
						insert into addresses
							(org_id,label,address,city,region_id,postal_code,telephone,fax,default_shipping,default_billing)
						values 
							(
								'.$org_id.',
								\'Default\',
								\''.core_db::escape_string($address['street']).'\',
								\''.core_db::escape_string($address['city']).'\',
								'.core_db::escape_string($address['region_id']).',
								\''.core_db::escape_string($address['postal_code']).'\',
								\''.core_db::escape_string($address['telephone']).'\',
								\''.core_db::escape_string($address['fax']).'\',
								'.$default_shipping.',
								'.$default_billing.'
							);
					');
				}
			}
		}
		# handle wholesale buyers and sellers.
		else
		{
			$org_created = false;
			$addresses = core_db::query($address_sql.$user['entity_id'].$address_sql_sort);
			$default_shipping = -1;
			$default_billing  = -1;
			while($address = core_db::fetch_assoc($addresses))
			{
				if(!$org_created)
				{
					core_db::query('insert into organizations (name,parent_org_id,domain_id,orgtype_id,buyer_type,allow_sell,profile,is_active) values (\''.core_db::escape_string($address['company']).'\',0,'.$user['domain_id'].',3,\'Wholesale\','.(($user['group_id'] == 1)?'true':'false').',\''.mysql_escape_string($user['profile']).'\',true);');
					$org_id = mysql_insert_id();
					core_db::query('update customer_entity set org_id='.$org_id.' where entity_id='.$user['entity_id']);	
					$org_created = true;
				}
				
				if($user['group_id'] == '1')
				{
					exec('scp lo-old:/home/localorb/sites/production/www/lo2/img/profiles/'.$user['entity_id'].'.jpg /var/www/production/www/img/organizations/'.$org_id.'.jpg');
					$files_to_resize[] = '/var/www/production/www/img/organizations/'.$org_id.'.jpg';
					$files_to_resize[] = '/var/www/production/www/img/organizations/'.$org_id.'_resized.jpg';
				}
				
				$domains = explode(',',$user['additional_domain_ids']);
				foreach($domains as $domain)
				{
					if(is_numeric($domain))
					{
						core_db::query('
							insert into organization_cross_sells
								(org_id,sell_on_domain_id)
							values
								('.$org_id.','.$domain.');
						');
					}
				}
				
				
				
				if(intval($address['region_id']) != 0)
				{
					# only set the address to be the default on the first address for the company
					if($default_shipping == -1)
					{
						$default_shipping = 1;
						$default_billing  = 1;
					}
					else
					{
						$default_shipping = 0;
						$default_billing  = 0;
					}
					core_db::query('
						insert into addresses
							(org_id,label,address,city,region_id,postal_code,telephone,fax,default_shipping,default_billing)
						values 
							(
								'.$org_id.',
								\'Default\',
								\''.core_db::escape_string($address['street']).'\',
								\''.core_db::escape_string($address['city']).'\',
								'.core_db::escape_string($address['region_id']).',
								\''.core_db::escape_string($address['postal_code']).'\',
								\''.core_db::escape_string($address['telephone']).'\',
								\''.core_db::escape_string($address['fax']).'\',
								'.$default_shipping.',
								'.$default_billing.'
							);
					');
				}
				#print_r($address);
			}
			#exit();
		}
	}
}

sleep(2);
echo("stage 3b: ressizing images\n");
for ($i = 0; $i < count($files_to_resize); $i+=2)
{
	echo('trying to resize '.$files_to_resize[$i]." to 400x400\n");
	if(file_exists($files_to_resize[$i]))
		exec('php -f /var/www/testing/bin/resize_photo.php '.$files_to_resize[$i].' 600 400 '.$files_to_resize[$i+1]);
}



#============== orders stuff
echo("stage 3c: changing order association\n");
$sql = '
	select ce.org_id,lo.lo_oid
	from lo_order lo
	left join customer_entity ce on lo.buyer_mage_customer_id=ce.entity_id
';
$orders = core_db::query($sql);
while($order = core_db::fetch_assoc($orders))
{
	if(intval($order['org_id']) > 0)
		core_db::query('update lo_order set org_id='.$order['org_id'].' where lo_oid='.$order['lo_oid']);
}

echo("stage 3d: changing fulfillment order association\n");
$sql = '
	select ce.org_id,lfo.lo_foid
	from lo_fulfillment_order lfo
	left join customer_entity ce on lfo.seller_mage_customer_id=ce.entity_id
';
$orders = core_db::query($sql);
while($order = core_db::fetch_assoc($orders))
{
	if(intval($order['org_id']) > 0)
		core_db::query('update lo_fulfillment_order set org_id='.$order['org_id'].' where lo_foid='.$order['lo_foid']);
}

echo("stage 3e: changing newsletter association\n");
$sql = '
	select cont_id,store_id,domain_id
	from newsletter_content
	left join domains on domains.mag_store=newsletter_content.store_id
';
while($newsletter = core_db::fetch_assoc($newsletters))
{
	core_db::query('update newsletter_content set domain_id='.$newsletter['domain_id'].' where cont_id='.$newsletter['cont_id']);
}


#=========== and now, products. omg, products. This is going to suck.
#echo("stage 3e: changing product association\n");

#echo("stage 3e: moving product images\n");

# final drops:
echo("stage 3f: dropping older tables\n");
core_db::query('drop table OrbitUser;');
core_db::query('drop table customer_entity_varchar;');
core_db::query('drop table customer_entity_int;');
#core_db::query('drop table customer_entity_int;');


exit();

#mysql_connect('localhost','localorb_magg','nAvAswu4');
#mysql_select_db('localorb_mag_lo3');

# id == 1, in theory :)
#


#echo("starting stage 3!\n");

?>