<?php
class core_model_directory_country_region extends core_model_base_directory_country_region
{
	function collection()
	{
		$col = new core_collection('select * from directory_country_region');
		$col->filter('country_id','in',array('US','CA'));
		$col->filter('region_id','not in',array(6,7,8,9,10,11,17,46,3,20));
		$col->sort('code')->sort('country_id=\'US\'','desc');
		return $col;
	}
}
?>