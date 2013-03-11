<?php
class core_model_customer_entity extends core_model_base_customer_entity
{

	function init_fields()
	{
		global $core;
		parent::init_fields();
/*
		$this->autojoin(
			'left',
			'customer_entity_varchar cev1',
			'(cev1.entity_id=customer_entity.entity_id and cev1.attribute_id=5)',
			array('cev1.value as first_name')
		);
		$this->autojoin(
			'left',
			'customer_entity_varchar cev2',
			'(cev2.entity_id=customer_entity.entity_id and cev2.attribute_id=7)',
			array('cev2.value as last_name')
		);
*/
	}

	function loadrow_by_email($username)
	{
		$this->import(core_db::row('select * from customer_entity inner join organizations on customer_entity.org_id = organizations.org_id where organizations.is_deleted = 0 and organizations.is_enabled = 1 and customer_entity.is_deleted = 0 and customer_entity.is_enabled = 1 and lower(email)=lower(\''.mysql_escape_string($username).'\')'));
		return $this;
	}

	function authenticate($username,$password)
	{
		global $core;
		core::load_library('crypto');

		$sql = '
			select ce.*,d.hostname,d.domain_id,
			o.name,o.buyer_type,o.allow_sell,o.is_active as org_is_active,
			o.is_enabled as org_is_enabled,otd.orgtype_id,
			d.name as hub_name,d.detailed_name as hub_detailed_name,
			tz.offset_seconds as offset_seconds,
			d.do_daylight_savings as do_daylight_savings

			from customer_entity ce
			inner join organizations o on (ce.org_id=o.org_id)
			inner join organizations_to_domains otd on (o.org_id=otd.org_id)
			inner join domains d on (d.domain_id=otd.domain_id and otd.is_home=1)
			inner join timezones tz using (tz_id)
			where trim(lower(ce.email))=lower(\''.mysql_escape_string($username).'\')
			and ce.is_deleted=0
			and o.is_deleted=0
		';
		$row = core_db::row($sql);


		if(!$row)
		{
			return array(
				'entity_id'=>0,
			);
		}
		else
		{
			if(core_crypto::compare_password(trim($row['password']),trim($password)))
			{
				list(
					$row['home_domain_id'],
					$row['all_domains'],
					$row['domains_by_orgtype_id']
				) = $this->get_domain_permissions($row['org_id']);

				return $row;
			}
			else
			{
				return array(
					'entity_id'=>0,
				);
			}
		}
/*

		$sql = '
			select ce.entity_id, cev1.value as first_name,cev2.value as last_name,ce.email,
			ce.group_id,ce.store_id,d.hostname
			from customer_entity ce
			inner join customer_entity_varchar cev1 on (cev1.entity_id=ce.entity_id and cev1.attribute_id=5)
			inner join customer_entity_varchar cev2 on (cev2.entity_id=ce.entity_id and cev2.attribute_id=7)
			inner join OrbitUser ou on ou.EMAIL=ce.email
			inner join core_store cs on ce.website_id=cs.website_id
			inner join domains d on cs.store_id=d.mag_store
			where (ce.email=\''.mysql_escape_string($username).'\' or ou.LOGIN_NAME=\''.mysql_escape_string($username).'\')
			and ou.PASSWORD=\''.mysl_escape_string($password).'\'
		';
*/
		$row = core_db::row($sql);
		if(!$row)
		{
			return array(
				'entity_id'=>0,
			);
		}
		else
		{
			return $row;
		}
	}

	function get_domain_permissions($org_id)
	{
		global $core;
		$row = array();
		$domain_ids= core::model('organizations_to_domains')
				->collection()
				->filter('org_id',$org_id)
				->to_hash('domain_id',false);
		$row[0] = array_values(array_map(function ($var) {return $var['domain_id'];}, array_filter($domain_ids, function ($var) { return $var['is_home']; })));
		$row[0] = $row[0][0];

		$row[1] = array_values(array_map(function ($var) { return $var['domain_id'];}, $domain_ids));
		$domains = array();
		foreach ($domain_ids as $domain)
		{
			$domains[$domain['orgtype_id']] = isset($domains[$domain['orgtype_id']]) ? $domains[$domain['orgtype_id']] : array();
			$domains[$domain['orgtype_id']][] = $domain['domain_id'];
		}
		$row[2] = $domains;
		return $row;
	}

	function force_auth($entity_id)
	{
		$sql = '
			select ce.entity_id, cev1.value as first_name,cev2.value as last_name,ce.email,
			ce.group_id,ce.store_id,d.hostname
			from customer_entity ce
			inner join core_store cs on ce.website_id=cs.website_id
			inner join domains d on cs.store_id=d.mag_store
			where ce.entity_id='.intval($entity_id).'
		';
		return core_db::row($sql);
	}
}

function enable_suspend_links($data)
{
	$data['activate_action'] = ($data['is_active'] == 1)?'deactivate':'activate';
	$data['enable_action'] = ($data['is_enabled'] == 1)?'suspend':'enable';
	$data['enable_icon'] = ($data['is_enabled'] == 1)?'minus':'plus';
	return $data;
}

?>