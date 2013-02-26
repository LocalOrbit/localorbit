<?php
class core_model_categories extends core_model_base_categories
{
	function load_for_products($cats)
	{
		global $core;
		
		$this->categories = new core_collection('
			select * 
			from categories 
			where cat_id in ('.implode(',',$cats).') 
			order by cat_name
		');
		
		$this->by_parent = $this->categories->to_hash('parent_id');
		$this->by_id     = $this->categories->to_hash('cat_id');
		$this->roots     = array();
		
		foreach($this->categories as $category)
		{
			#echo('looping: '.$category['parent_id'].'/'.$category['cat_id'].'<br />');
			if($category['parent_id'] == 2)
			{
				#echo('found a root: '.$category['cat_id'].'<br />');
				$this->roots[] = $category['cat_id'];
			}
		}
		
		return $this;
	}
}
?>