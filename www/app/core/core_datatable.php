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



class core_datatable
{
	function __construct($name,$url,$data)
	{
		global $core;
		#core::log('data table construction: '.print_r($core->data,true));
		# ->name is used to specify the name/id of various html elements that comprise the table
		# ->url is the url loaded to request new data for the table
		$this->name = $name;
		$this->url  = $url;
		$this->columns = array();
		$this->handler_onoutput = null;

		# misc properties to determine the paging, sorting, size
		$this->page = 0;
		$this->max_page = -1;
		$this->sort_column = -1;
		$this->sort_direction = 'asc';
		$this->no_data_message = '<h3>No Results</h3>This table is empty, either because there is no data, or because the filter you\'ve applied is hiding it.';
		
		# load misc settings from core/config
		$this->size           = $core->config['datatables']['size_default'];
		$this->size_options   = $core->config['datatables']['size_options'];
		$this->size_allow_all = $core->config['datatables']['size_allow_all'];
		
		$this->render_page_arrows = $core->config['datatables']['render_page_arrows'];
		$this->render_page_select = $core->config['datatables']['render_page_select'];
		$this->render_resizer     = $core->config['datatables']['render_resizer'];
		$this->render_exporter    = $core->config['datatables']['render_exporter'];
		$this->render_filter_expander = $core->config['datatables']['render_filter_expander'];
		$this->display_filter_resizer = true;
		$this->display_exporter_pager = true;
		$this->write_to_session   = $core->config['datatables']['write_to_session'];
		
		# prep the data a bit
		$this->data = $data;
		$this->data->__determine_max_page = true;	
		
		# these are used to store the data used for filtering and their current state
		$this->filters = array();
		$this->filter_html = '';
		$this->filter_states = array();
		
		# try to load the settings for the table from the session
		if(isset($core->session['datatables'][$this->name]))
		{
			$this->page = $core->session['datatables'][$this->name]['page'];
			$this->sort_column = $core->session['datatables'][$this->name]['sort_column'];
			$this->sort_direction = $core->session['datatables'][$this->name]['sort_direction'];
			$this->size = $core->session['datatables'][$this->name]['size'];
		}
	}
	
	function add_filter($new_filter)
	{
		global $core;

		
		$new_filter->parent =& $this;
		$new_filter->get_value();
		$this->filters[] = $new_filter;
		
		return $this;
	}
	
	# adds a new column to the data table
	function add($col)
	{
		$col->index = count($this->columns);
		$col->parent =& $this;
		$this->columns[] = $col;
		return $this;
	}
	
	# this is the master render function
	function render()
	{
		global $core;
		
		# this figures out the page, sorting, sizing, etc.
		$this->check_request_parameters();
		$this->prepare_data();
		
		# check if this call is JUST to refresh the data in the table
		if($core->data['get_datatable_data'] == 1)
		{
			# it is, just package up the data and return it
			$js = $core->response['js'];
			core::clear_response();
			
			if($core->data['format'] == 'csv')
			{
				
				core::log('outputting to csv ');
				
				# write headers for a csv file download
				header("Content-type: application/csv");
				header('Content-Type: application/force-download'); 
				header("Content-Type: application/download"); 
				header("Content-Disposition: attachment; filename=".$this->name.".csv");
				header("Pragma: no-cache");
				header("Expires: 0");
				
				# print out the column headers
				for ($i = 0; $i < count($this->columns); $i++)
				{
					echo(($i==0)?'':',');
					echo($this->columns[$i]->render_header('csv'));
				}
				echo("\n");
				
				# change the output type in the collection to 'csv' (used by the collection's formatters)
				$this->data->__output_type = 'csv';
				
				core::log('total data: '.$this->data->__num_rows);
				# loop through and output
				foreach($this->data as $data)
				{
					for ($i = 0; $i < count($this->columns); $i++)
					{
						echo(($i==0)?'':',');
						echo('"'.$this->columns[$i]->render_data($data,'csv').'"');
					}
					echo("\n");
				}
				
				# call output handler
				if(!is_null($this->handler_onoutput))
				{
					$function = $this->handler_onoutput;
					$function('csv',$this);
				}
				exit();
			}
			else if($core->data['format'] == 'pdf')
			{
				# write headers for a pdf file download
				header("Content-type: application/pdf");
				header('Content-Type: application/force-download'); 
				header("Content-Type: application/download"); 
				header("Content-Disposition: attachment; filename=".$this->name."-".$core->config['time'].".pdf");
				header("Pragma: no-cache");
				header("Expires: 0");
				
				# load up the library and color options
				$options = core::model('template_options')->get_options(array('color'));
				core::load_library('pdf');				
				$pdf = new core_pdf();
				$pdf->SetFont('Arial','B',10);
				
				# convert some colors to their rgb equivs
				$headbg = core_format::hex2rgb($options['p4f']);
				$headfg = core_format::hex2rgb($options['p1e']);
				$text   = core_format::hex2rgb($options['p4d']);
				$row0   = core_format::hex2rgb($options['p4a']);
				$row1   = core_format::hex2rgb($options['p1a']);
				
				# setup some basic properties
				$page = 0;
				$max_page = 10;
				$row_height = 8;
				$start_y = 22;
				$start_x =  10;
				$cell_height = 8;
				$rows_per_page = 29;
				
				# this will force col headers on page 1
				$current_row = 1000;
				
				# build the master data array which includes the model data,
				# but also includes how many rows each cell will take up.
				$row_data = array();
				foreach($this->data as $data)
				{
					$row = array();
					$height = 1;
					for ($i = 0; $i < count($this->columns); $i++)
					{
						$col_rows = $this->columns[$i]->determine_pdf_num_rows($data,$pdf,$row_height);
						$row[$i] = $this->columns[$i]->render_data($data,'pdf');
						
						# if this cell requires a greater number of rows than previous columns,
						# then ALL columns in this row should be rendered at this height
						if($col_rows > $height)
							$height = $col_rows;
					}
					
					# store the row with height data into the master data array
					$row['__height'] = $height;
					$row_data[] = $row;
				}
				

				# ok, render away!!!!
				for ($i = 0; $i < count($row_data); $i++)
				{
					# determine if we need to start a new page
					if(($current_row + $row_data[$i]['__height']) > $rows_per_page)
					{
						$page++;
						$pdf->AddPage('Portrait','A4');
						$this->render_pdf_column_headers($pdf,$headfg,$headbg,$text);
						$this->render_pdf_pagecount($pdf,$page,$max_page);
						$current_row = 0;
					}
					
					# start left to right and render the data
					$x = $start_x;
					for ($j = 0; $j < count($this->columns); $j++)
					{
						$pdf->setXY($x,($start_y + ($current_row * $row_height)));
						$pdf->Cell(
							($this->columns[$j]->width * 2),
							$row_height * $row_data[$i]['__height'],
							$row_data[$i][$j],
							0,0,'L',true
						);
						$x += ($this->columns[$j]->width * 2);	
					}
					$current_row += $row_data[$i]['__height'];
				}		
				
				# call output handler
				if(!is_null($this->handler_onoutput))
				{
					$function = $this->handler_onoutput;
					$function('pdf',$this);
				}				
				$pdf->Output($this->name."-".$core->config['time'].'.pdf','D');
				core::deinit(false);	
			}
			else
			{
				# we're not outputting in CSV or PDF, 
				# which means we just need to send back the json
				$core->response['js'] = $js;
				$core->response['datatable'] = array(
					'name'=>$this->name,
					'page'=>$this->page,
					'size'=>$this->size,
					'sort_column'=>$this->sort_column,
					'sort_direction'=>$this->sort_direction,
					'max_page'=>$this->max_page,
					'data'=>array(),
				);
				
				$index = 0;
				# loop through all the data in the collection and construct a json response
				# base64 encode to prevent quote/escaping problems 
				foreach($this->data as $data)
				{
					$core->response['datatable']['data'][$index] = array();
					for ($i = 0; $i < count($this->columns); $i++)
					{
						$core->response['datatable']['data'][$index][$i] = base64_encode($this->columns[$i]->render_data($data,'html'));
					}
					
					$index++;
				}
			}
			core::log('sending back js: '.$core->response['js']);
			
			# call output handler
			if(!is_null($this->handler_onoutput))
			{
				$function = $this->handler_onoutput;
				$function('data',$this);
			}
			core::deinit();
		}
		else
		{	
			# the table is rendered in this order:
			$this->render_filter_resizer();
			$this->render_action_options();
			
			$this->render_start();
			$this->render_no_data();
			$this->render_column_headers();
			$this->render_data();
			$this->render_exporter_pager();
			$this->render_end();
			$this->render_js();
			# call output handler
			if(!is_null($this->handler_onoutput))
			{
				$function = $this->handler_onoutput;
				$function('html',$this);
			}
		}
	}
	
	function render_fake_row($style)
	{
		$row = func_get_args();
		array_shift($row);
		$out = '<tr class="dt'.$style.'">';
		foreach($row as $col)
		{
			$out .= '<td class="dt">'.$col.'</td>';
		}
		$out .= '</tr>';
		return $out;
	}
	
	function render_pdf_column_headers($pdf,$headfg,$headbg,$text)
	{
		global $core;
		$x = 10;
		$pdf->setXY(10,10);
		$pdf->SetTextColor($headfg[0],$headfg[1],$headfg[2]);
		$pdf->setFillColor($headbg[0],$headbg[1],$headbg[2]);
		for ($i = 0; $i < count($this->columns); $i++)
		{
			$pdf->Cell(($this->columns[$i]->width * 2),10,$this->columns[$i]->render_header('pdf'),'B',0,'L',true);
			$x += ($this->columns[$i]->width * 2);
			$pdf->setXY($x,10);
		}
		$pdf->SetTextColor($text[0],$text[1],$text[2]);
	}
	
	function render_pdf_pagecount($pdf,$page,$max_page)
	{
		$pdf->setXY(150,260);
		$pdf->Cell(50,10,'Page '.($page),0,0,'R',true);
	}
	
	# this looks for new parameters for the table in the request_parameters
	function check_request_parameters()
	{
		global $core;
		
		# if any of these are set, they're all set
		if(is_numeric($core->data[$this->name.'_page']))
		{
			$this->page = intval($core->data[$this->name.'_page']);
			$this->size = intval($core->data[$this->name.'_size']);
			$this->sort_column = intval($core->data[$this->name.'_sort_column']);
			$this->sort_direction = ($core->data[$this->name.'_sort_direction'] == 'desc')?'desc':'asc';
		}
	}
	
	function prepare_data()
	{
		global $core;
		$this->data->__page = $this->page;
		$this->data->__size = $this->size;
		
		# if a sort column isn't set, look for the first one in the list of columns and use it.
		if($this->sort_column < 0)
		{
			for ($i = 0; $i < count($this->columns); $i++)
			{
				if($this->columns[$i]->sortable)
				{
					$this->sort_column = $i;
					$i = count($this->columns);
				}
			}
		}
		
		# if we've got a sort column, set the collection to it.
		if($this->sort_column >= 0)
		{
			$this->data->sort($this->columns[$this->sort_column]->dbname,$this->sort_direction);
		}
		
		# now apply the filter states to the collection
		foreach($this->filters as $filter)
		{
			$filter->apply_to_collection();
		}
		
		# now that we have all the parameters, save them to the session
		# so if we change pages and come back to this table, we'll be on teh same page
		if($this->write_to_session)
		{
			$core->session['datatables'][$this->name] = array(
				'page'=>$this->page,
				'sort_column'=>$this->sort_column,
				'sort_direction'=>$this->sort_direction,
				'size'=>$this->size,
				'filter_states'=>$this->filter_states,
			);
		}
		
		# finally, load the data and determine max_page
		$this->data->load();
		$this->max_page = $this->data->__max_page;
	}
	
	# writes out the table tag and column widths. That's it.
	function render_start()
	{
		global $core;
		
		echo('<table class="dt table table-striped" id="dt_'.$this->name.'">');
		for ($j = 0; $j < count($this->columns); $j++)
		{
			echo($this->columns[$j]->render_width());
		}
	}

	# renders a row that contains the filters in the upper left, and the resizer in the upper right.
	function render_filter_resizer()
	{
		global $core;
		echo('<div class="dt_filter_resizer"');
		if(!$this->filter_html)
			echo(' style="display: none;"');
		echo('>');
		
		echo('<div class="dt_filter" id="dt_'.$this->name.'_filters">');
		
		if($this->filter_html != '')
		{
			echo('<h4 class="pull-left">Filter Results:</h4> ');
			$this->render_filter_expander();
			echo('<div class="dt_filter_area">'.$this->filter_html.'</div>');
		}
		echo('</div><div class="clearfix"></div>');
		echo('</div>');
	}
	
	function render_action_options()
	{
		global $core;
		echo('<div class="dt_action_options alert alert-info"');
		if(!$this->action_html)
			echo(' style="display: none;"');
		echo('>');
		
		if($this->action_html != '')
		{
			echo('<strong>Actions:</strong> ');
			echo($this->action_html);
		}
		echo('</div>');
	}
	
	function render_filter_expander()
	{
		if($this->render_filter_expander)
			echo('<a onclick="core.ui.dataTable.filterToggle(\''.$this->name.'\');" class="dt_filter_expander">&raquo;</a>');
	}

	# renders the column headers, which are used for sorting. 
	function render_column_headers()
	{
		global $core;
		echo('<thead><tr id="dt_'.$this->name.'_columns"'.(($this->data->__num_rows > 0)?'':' style="display:none;"').'>');
		for ($j = 0; $j < count($this->columns); $j++)
		{
			echo($this->columns[$j]->render_header('html'));
		}
		echo('</tr></thead>');
	}
	
	# this adds a row that is used to inform the user that there is no data available 
	# given teh current filter set
	function render_no_data()
	{
		echo('<tr id="dt_'.$this->name.'_nodata"'.(($this->data->__num_rows > 0)?' style="display:none;"':'').'>');
		echo('<td class="dt dt_nodata" colspan="'.count($this->columns).'">');
		echo('<div class="alert alert-info alert-block span5 offset3" style="margin-top: 20px;">' . $this->no_data_message . '</div>');
		echo('</td>');
		echo('</tr>');		
	}
	
	# this loops through the data and renders all necessary table rows.
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
			
		for ($i = 0; $i < $final_row; $i++)
		{
			# get the next row of data
			$this->data->next();
			
			# only render the data if there's actually valid data in this row of the collection
			if($this->data->valid())
			{
				$data = $this->data->current();
				$this->display_size++;
				echo('<tr class="dt'.$style.'" id="dt_'.$this->name.'_'.$i.'">');
				
				# loop through the columns and render the data for that column
				for ($j = 0; $j < count($this->columns); $j++)
				{
					echo('<td class="dt" id="dt_'.$this->name.'_'.$i.'_'.$j.'">');
					echo($this->columns[$j]->render_data($data,'html'));
					echo('</td>');
				}
				echo('</tr>');
				$style = (!$style);
			}
			else
			{
				$i = $this->size;
			}
		}
	}
	
	# renders the exporter area (save as csv/xls/pdf), and the pager (first/previous/next/last) areas
	function render_exporter_pager()
	{
		global $core;
		echo('<tr><td class="dt_exporter_pager" colspan="'.count($this->columns).'"');
		if(!$this->display_exporter_pager)
			echo(' style="display: none;"');
		echo('>');
			echo('<div class="dt_exporter">');
			if($this->render_exporter)
			{
				echo('<a class="dt" onclick="core.ui.dataTables[\''.$this->name.'\'].loadData(\'csv\');"><i class="icon-table"></i> Export CSV</a> &nbsp; <a onclick="core.ui.dataTables[\''.$this->name.'\'].loadData(\'pdf\');" class="dt"><i class="icon-file"></i> Export PDF</a>');
			}
			echo('</div>');
			
			echo('<div class="dt_pager">');
				if($this->render_page_arrows)
				{
					echo('<a class="dt_pager first" onclick="core.ui.dataTables[\''.$this->name.'\'].changePage(\'first\');"><i class="icon-caret-left"></i> First</a>&nbsp;&nbsp;&nbsp;');
					echo('<a class="dt_pager previous" onclick="core.ui.dataTables[\''.$this->name.'\'].changePage(\'previous\');"><i class="icon-caret-left"></i> Previous</a>');
				}
				if($this->render_page_select)
				{
					echo('<select class="dt" name="dt_'.$this->name.'_pager" id="dt_'.$this->name.'_pager"');
					echo(' onchange="core.ui.dataTables[\''.$this->name.'\'].changePage(this.selectedIndex);">');
					for ($i = 0; $i < ($this->max_page); $i++)
					{
						echo('<option value="'.$i.'"');
						echo((($this->page == $i)?' selected="selected"':''));
						echo('>Page '.($i + 1).' of '.($this->max_page).'</option>');
					}
					echo('</select>');
				}
				if($this->render_page_arrows)
				{
					echo('&nbsp;&nbsp;');
					echo('<a class="dt_pager next" onclick="core.ui.dataTables[\''.$this->name.'\'].changePage(\'next\');">Next <i class="icon-caret-right"></i></a>&nbsp;&nbsp;&nbsp;');
					echo('<a class="dt_pager last" onclick="core.ui.dataTables[\''.$this->name.'\'].changePage(\'last\');">Last <i class="icon-caret-right"></i></a>');
				}
			echo('</div>');
			
			echo('<div class="dt_resizer">');
				if($this->render_resizer)
				{
					echo('<select class="dt" name="dt_'.$this->name.'_resizer" id="dt_'.$this->name.'_resizer"');
					echo(' onchange="core.ui.dataTables[\''.$this->name.'\'].changeSize(this.options[this.selectedIndex].value);">');
					for ($i = 0; $i < count($this->size_options); $i++)
					{
						echo('<option value="'.$this->size_options[$i].'"');
						if($this->size == $this->size_options[$i])
							echo(' selected="selected"');
						echo('>Show '.$this->size_options[$i].' rows</option>');
					}
				
					if($this->size_allow_all)
					{
						echo('<option value="-1"');
						if($this->size == (-1))
							echo(' selected="selected"');
						echo('>Show all rows</option>');
					}
					echo('</select>');
				}
			echo('</div>');
			
		echo('</td></tr>');
	}
	
	# finishes up the table, and that's it.
	function render_end()
	{
		global $core;
		echo('</table>');
	}
	
	# renders the js needed to init the table
	function render_js()
	{
		core::js('core.ui.dataTable.construct(\''.$this->name.'\','.count($this->columns).',\''.$this->url.'\','.$this->sort_column.',\''.$this->sort_direction.'\','.$this->page.','.$this->max_page.','.$this->size.','.$this->display_size.','.json_encode($this->filter_states).');');
	}
	
	public static function js_reload($name)
	{
		global $core;
		core::log(print_r($core->response,true));
		core::js('if(core.ui.dataTables[\''.$name.'\']){ core.ui.dataTables[\''.$name.'\'].loadData();};');
		core::log($core->response['js']);
	}
}

?>