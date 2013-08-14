<?php
class core_model_products extends core_model_base_products
{
	function init_fields()
	{
		global $core;

		$this->autojoin(
			'left',
			'Unit u',
			'(products.unit_id = u.UNIT_ID)',
			array('u.NAME as single_unit','u.PLURAL as plural_unit')
		);
		$this->autojoin(
			'left',
			'organizations o',
			'(o.org_id=products.org_id)',
			array('o.name as org_name')
		);
		parent::init_fields();
	}
	
	function load_dd_ids()
	{
		$this->add_custom_field('
			(
				select group_concat(dd_id)
				from product_delivery_cross_sells
				WHERE product_delivery_cross_sells.prod_id=products.prod_id
			) as dd_ids
		');
		return $this;
	}

	function get_taxonomy()
	{
		if(!isset($this->__data['category_ids']))
			$this->load();
		$cat_ids = explode(',',$this->__data['category_ids']);
		array_shift($cat_ids);
		$this->taxonomy = core::model('categories')
			->collection()
			->filter('cat_id','in',$cat_ids);
		for	($i=0;$i<count($cat_ids);$i++)
		{
			$this->taxonomy->sort('(cat_id='.$cat_ids[$i].')');
		}
		return $this->taxonomy;
	}

	function join_address()
	{

		$this->autojoin(
			'left',
			'addresses a',
			'(products.addr_id=a.address_id)',
			array('a.address','a.city','a.postal_code','a.latitude','a.longitude')
		);
		$this->autojoin(
			'left',
			'directory_country_region dcr',
			'(a.region_id=dcr.region_id)',
			array('dcr.code')
		);
		return $this;
	}

	function get_inventory($prod_id=null)
	{
		if(is_null($prod_id ))
			$prod_id = $this['prod_id'];

		return floatval(core_db::col('
			select sum(qty) as inv
			from product_inventory
			where prod_id='.$prod_id.' and (expires_on > now() or expires_on is null) and (good_from <= now() or good_from is null)
		','inv'));
	}

	function get_image($width=200,$height=160)
	{
		global $core;
		$img = core::model('product_images')->load_by_prod_id($this['prod_id'])->to_array();
		return $img[0];
		#core::log(print_r($img->dump(),true));
	}

	function get_list_for_dropdown()
	{
		global $core;
		$sql = '
			select prod_id,CONCAT(organizations.name,\' - \',products.name) as product_name
			from products
			left join organizations on products.org_id=organizations.org_id
			where products.name <> \'\'
			and products.name is not null
			and products.is_deleted=0
			and organizations.name <> \'\'
			and organizations.is_deleted=0
			and organizations.name is not null
		';
		if(lo3::is_market())
		{
			$sql .= ' and '.$core->config['domain']['domain_id'].' in (select domain_id from organizations_to_domains where org_id=products.org_id) ';
		}

		$col = new core_collection($sql);
		$col->sort('products.name');
		$col->sort('organizations.name');
		return $col;
	}

	function get_catalog($domain_id=null,$org_id=-1)
	{
		global $core;

		$org_id = intval($org_id);

		if(is_null($domain_id))
			$domain_id = intval($core->config['domain']['domain_id']);
		if($org_id == -1)
			$org_id = intval($core->session['org_id']);
		$core->session['domains_by_orgtype_id'][2][] = 0;
		$core->session['domains_by_orgtype_id'][3][] = 0;
		$sql = '
			select p.prod_id,p.name,p.how,p.how,p.who as product_who,description,
			p.short_description,
			
			category_ids,p.org_id,
			pi.pimg_id,pi.width,pi.height,pi.extension,u.NAME as single_unit,u.PLURAL as plural_unit,
			o.name as org_name,
			(
				select group_concat(price_id)
				from product_prices
				where product_prices.prod_id=p.prod_id
				and (product_prices.org_id = 0 or product_prices.org_id='.$org_id.')
				and (product_prices.domain_id = 0 or product_prices.domain_id='.$domain_id.')
			) as price_ids,
			(select group_concat(dd_id) from product_delivery_cross_sells where product_delivery_cross_sells.prod_id=p.prod_id) as dd_ids,
			(select sum(qty) from product_inventory inv where inv.prod_id=p.prod_id and (expires_on > now() or expires_on is null) and (good_from <= now() or good_from is null)) as inventory,
			a.address,a.city,a.postal_code,dcr.code,a.latitude,a.longitude
			from products p
			left join product_images pi on pi.prod_id=p.prod_id
			left join organizations o on o.org_id=p.org_id
			left join addresses a on p.addr_id=a.address_id
			left join directory_country_region dcr on a.region_id=dcr.region_id
			left join Unit u on p.unit_id=u.UNIT_ID
			where p.prod_id > 0
			and (
				select count(price_id)
				from product_prices
				where product_prices.prod_id=p.prod_id
				and (product_prices.org_id=0 or product_prices.org_id='.$org_id.')
				and (product_prices.domain_id=0 or product_prices.domain_id='.$domain_id.')
			) > 0
			and (
					(
						select coalesce(product_prices.min_qty,0)
						from product_prices
						where product_prices.prod_id=p.prod_id
						and (product_prices.org_id=0 or product_prices.org_id='.$org_id.')
						order by min_qty limit 1
					)
					<=
					(
						select sum(qty) from product_inventory where product_inventory.prod_id=p.prod_id
					)
			)
			and p.unit_id is not null
			and p.unit_id <> 0
			and p.is_deleted=0
			and o.is_deleted=0
			and o.is_active=1
			and o.is_enabled=1
			and (
				p.prod_id in (
					select prod_id
					from product_delivery_cross_sells
					where dd_id in (
						select dd_id from delivery_days where domain_id='.$domain_id.'
					)
				)
			)
			and (
				'.$domain_id.' in (
					select sell_on_domain_id
					from organization_cross_sells
					where org_id =p.org_id
				)
				or '.$domain_id.' in (select domain_id from organizations_to_domains where org_id='.$org_id.')
				'.((lo3::is_admin())?'or true':'').'
			)

		';
		#order by prod_id desc


		$col = new core_collection($sql);
		$col->sort('p.category_ids');
		$col->group('p.prod_id');
		return $col;
	}

	function get_catalog_for_seller($org_id)
	{
		$col = $this->get_catalog();
		$col->sort('p.name');
		$col->filter('p.org_id',$org_id);
		return $col;
	}
}
?>