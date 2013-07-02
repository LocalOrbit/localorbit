<?php
class core_model_domains extends core_model_base_domains
{
	function init_fields()
	{
		global $core;

		$this->autojoin(
			'left',
			'timezones tz',
			'(domains.tz_id=tz.tz_id)',
			array('tz.offset_seconds','tz.tz_code','tz.tz_name')
		);

		$this->autojoin(
			'left',
			'daylight_savings ds',
			'(ds.ds_year='.date('Y').')',
			array('ds_start','ds_end')
		);
		/*
		$this->autojoin(
			'left',
			'domains_branding branding',
			'(domains.domain_id=branding.domain_id and branding.is_temp = 0)',
			array('branding_id','font_color','header_font', 'background_color', 'background_id', 'is_temp')
		);
		*/

		parent::init_fields();
	}

	function get_mm_emails($domain_id)
	{
		global $core;
		$domain_id = intval($domain_id);
		$emails = array();
		$sql = '
			select email
			from customer_entity
			where 
				is_deleted = 0
				AND is_enabled = 1
				AND is_active = 1
				
				AND org_id in (
				select otd.org_id
				from organizations_to_domains otd
				where otd.domain_id='.$domain_id.'
				and otd.orgtype_id=2
			);
		';
		$results = new core_collection($sql);
		foreach($results as $result)
		{
			$emails[] = $result['email'];
		}
		return $emails;
	}

	function load_sellers()
	{
		global $core;
		$sql = '
			select distinct o.*,address,city,postal_code,latitude,longitude,dcr.code
			from organizations o
			left join organizations_to_domains otd on otd.org_id = o.org_id
			left join addresses a on (a.org_id=o.org_id and a.default_shipping=1 and latitude is not null and latitude<>0)
			left join directory_country_region dcr on (a.region_id=dcr.region_id)
			where allow_sell=1
			and o.is_active=1
			and o.is_enabled=1
			and o.is_deleted=0
			and public_profile=1
		';

		# admins and market managers should see ALL sellers
		# that can hypothetically sell on this marketplace
		$sql .= '
			and (
				o.org_id in (
					select org_id
					from organization_cross_sells ocs
					where ocs.sell_on_domain_id = '.$core->config['domain']['domain_id'].'
				) ';
				$sql .= 'or otd.domain_id = '.$core->config['domain']['domain_id'].'
			)
		';

		/*
		# normal users only see sellers for which there are public
		# prices, or have org-specific prices for them on this hub.
		*/
		if(lo3::is_customer())
		{
			# apply product rules
			$sql .= '
				and o.org_id in (
					select p.org_id
					from products p
					where (
						select count(price_id)
						from product_prices
						where product_prices.prod_id=p.prod_id
						and (
							product_prices.org_id=0
							or product_prices.org_id='.$core->session['org_id'].'
						)
					) > 0
					and (
						(
							select coalesce(product_prices.min_qty,0)
							from product_prices
							where product_prices.prod_id=p.prod_id
							and (product_prices.org_id=0 or product_prices.org_id='.$core->session['org_id'].')
							order by min_qty limit 1
						)
						<=
						(
							select sum(qty) from product_inventory where product_inventory.prod_id=p.prod_id
						)
					)
					and (select sum(qty) from product_inventory where product_inventory.prod_id=p.prod_id) > 0
					and p.unit_id is not null
					and p.unit_id <> 0
					and (
						p.prod_id in (
							select prod_id
							from product_delivery_cross_sells
							where dd_id in (
								select dd_id from delivery_days where domain_id='.$core->config['domain']['domain_id'].'
							)
						)
					)
			)
			';
		}

		$sellers = new core_collection($sql);
		$sellers->__model = core::model('organizations');
		$sellers->sort('o.name');
		return $sellers;
	}

	function loadrow_by_hostname($hostname)
	{
		global $core;
		if($hostname == 'localorb.it' || $hostname == 'www.localorb.it' || $hostname == 'qa.localorb.it' || $hostname == 'testing.localorb.it' || $hostname == 'dev.localorb.it' || $hostname == 'testing.foodhubresource.com' || $hostname == 'www.foodhubresource.com' || $hostname == 'qa.foodhubresource.com')
		{
			$hostname = $core->config['hostname_prefix'].$core->config['default_hostname'];
		}
		return parent::loadrow_by_hostname($hostname);
	}
	
	function get_domain_info($domain_id) {
		global $core;
		$sql = 'select secondary_contact_email, secondary_contact_phone
			from domains
			where domain_id = '.$domain_id;
		return new core_collection($sql);
	}
	
	function get_sellers($store_id=0)
	{
		global $core;

		if($store_id == 0)
			$store_id = $core->config['domain']['mag_store'];

		$sql = '
			select distinct ce.entity_id,cae.entity_id as address_id,
			caev1.value as city,caev2.value as postcode,caev3.value as telephone,caev4.value as company,caet1.value as street,caev5.value as state
			from customer_entity ce
			left join core_store cs on cs.website_id=ce.website_id
			left join customer_address_entity cae on cae.parent_id=ce.entity_id
			left join customer_address_entity_varchar caev1 on (caev1.attribute_id=24 and caev1.entity_id=cae.entity_id)
			left join customer_address_entity_varchar caev2 on (caev2.attribute_id=28 and caev2.entity_id=cae.entity_id)
			left join customer_address_entity_varchar caev3 on (caev3.attribute_id=29 and caev3.entity_id=cae.entity_id)
			left join customer_address_entity_varchar caev4 on (caev4.attribute_id=22 and caev4.entity_id=cae.entity_id)
			left join customer_address_entity_varchar caev5 on (caev5.attribute_id=26 and caev5.entity_id=cae.entity_id)
			left join customer_address_entity_text caet1 on (caet1.attribute_id=23 and caet1.entity_id=cae.entity_id)
			where ce.group_id=1
			and ce.is_active=1
			and caev4.value <> \'\'
			and cs.store_id='.$store_id.'
			order by caev4.value';
		return new core_collection($sql);
	}

	function get_addresses()
	{
		global $core;
		$col = new core_collection('
			select a.*,dcr.default_name as region,dcr.code
			from addresses a
			left join organizations o on a.org_id=o.org_id
			left join directory_country_region dcr on (a.region_id=dcr.region_id)
			left join organizations_to_domains otd on otd.org_id = o.org_id
			where otd.domain_id='.$this['domain_id'].'
			and a.is_deleted=0
			and otd.orgtype_id=2
		');
		return $col;
	}
}
?>