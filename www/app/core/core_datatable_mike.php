<?php 
# this is the core frameowrk data table library. Data tables created using it having the following capabilities:
#   * paging
#   * resizing
#   * sorting
#   * filtering using any form field
#   * exporting to csv, pdf, and in future xlse
#
# here's an example data table:
/*

$users = new core_datatable('users','users/listusers',core::model('users')->collection());
$users->add(new core_datacolumn('user_id','ID',true,'20%'));
$users->add(new core_datacolumn('name','Name',true,'80%','<a href="#users-viewuser--user_id-{user_id}">{name}</a>'));
$users->render();
*/



class core_datatable_mike extends core_datatable
{
	function render_data()
	{
		global $core;
		# set collection properties and load the collection
		#$this->data->load();
		
		# loop through the size of table
		$style = false;
		$this->display_size = 0;
		
		# handle 'all'
		$final_row = $this->size;
		if($final_row == (-1))
			$final_row = $this->data->__num_rows;
			
		$html = '';
			
		for ($i = 0; $i < $final_row; $i++)
		{
			# get the next row of data
			$this->data->next();
			
			# only render the data if there's actually valid data in this row of the collection
			if($this->data->valid())
			{
				$data = $this->data->current();
				$this->display_size++;
				$row = '<tr class="dt'.$style.'" id="dt_'.$this->name.'_'.$i.'">';
				
				# loop through the columns and render the data for that column
				for ($j = 0; $j < count($this->columns); $j++)
				{
					
					if($this->columns[$j]->autoformat != '')
					{
						switch($this->columns[$j]->autoformat)
						{
							case 'price':
								$data[$this->columns[$j]->dbname] = core_format::price($data[$this->columns[$j]->dbname],false);
								break;
							case 'date-long':
								$data[$this->columns[$j]->dbname] = core_format::date($data[$this->columns[$j]->dbname],'long');
								break;
							case 'date-long-wrapped':
								if($format == 'html')
									$data[$this->columns[$j]->dbname] = core_format::date($data[$this->columns[$j]->dbname],'long-wrapped');
								else
									$data[$this->columns[$j]->dbname] = core_format::date($data[$this->columns[$j]->dbname],'long');
									
								break;
							case 'date-short':
								$data[$this->columns[$j]->dbname] = core_format::date($data[$this->columns[$j]->dbname],'short');
								
								break;
						}
					}
					
					$row .= '<td class="dt" id="dt_'.$this->name.'_'.$i.'_'.$j.'">'.$this->columns[$j]->render_data('html').'</td>';
				}
				$row .= '</tr>';
				if(is_array($data))
				{
					foreach($data as $key=>$value)
					{
						$row = str_replace('{'.$key.'}',$value,$row);
					}
				}
				else
				{
					foreach($data->__data as $key=>$value)
					{
						$row = str_replace(
							'{'.$key.'}',
							$value,
							$row
						);
					}
				}
				$html .= $row;
				$style = (!$style);
			}
			else
			{
				$i = $this->size;
			}
		}
		echo($html);
	}
}

?>