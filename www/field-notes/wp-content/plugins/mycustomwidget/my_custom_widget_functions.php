<?php
/*
Author: Janek Niefeldt
Author URI: http://www.janek-niefeldt.de/
Description: Configuration of My Custom Widgets Plugin.
*/


  function MCW_logfile($entry) { 
    global $mcw_write_log;
    if ($mcw_write_log){ //only used during plugin development
      global $mcw_path;
      $filename = $mcw_path["log"];
      if (!file_exists($filename)){
        $answer = "file ".$filename." does not exist. <br>";
      } else {
        if (!$handle = fopen($filename, "a")) {
          $answer = $answer. "File ".$filename." cannot be opened.<br>";
        } else {
          // Schreibe $somecontent in die geöffnete Datei.
          $somecontent = '<strong>'.date("F j, Y, g:i a").'</strong> - '.$entry.'<br>';        
          if (!fwrite($handle, $somecontent)) {
            $answer = $answer. "File ".$filename." is not writeable.<br>";
          } else {
            $answer = $answer."done ";
          }
        }
        fclose($handle);
      }
    }
  }


/****************************/    
/***       GETTER         ***/
/****************************/  

  function MCW_get_url($param){
    global $mcw_path;
    return $mcw_path[$param];
  }
  
  function MCW_get_option($option = '') {
    //returns plugin-options 
    global $mcw_prefix;
    global $mcw_configoption;
    $temp = get_option($mcw_prefix.$mcw_configoption);
    if ($option == ''){
     return $temp;
    } else {
      if ($temp[$option]=='yes'){
        return true;
      } else {
        if ($temp[$option]=='no'){
          return false;
        } else {
          return $temp[$option];
        }
      }
    }  
  }
  
  function MCW_get_mainfile_name(){
    return basename(__FILE__);
  } 
  
  function MCW_get_option_backup(){
    global $mcw_prefix;
    global $mcw_configoption;
    global $mcw_backup_postfix;
    return get_option($mcw_prefix.$mcw_configoption.$mcw_backup_postfix);
  }
  
  function MCW_get_all_filters(){
 	  $temp=MCW_get_option('filters');
 	  $temp=MCW_sort_my_elements($temp);
 	  return $temp;
  }
     
  function MCW_get_meta(){
  //returns plugin-meta-data 
    global $mcw_prefix;
    global $mcw_metaoption;
    $temp = get_option($mcw_prefix.$mcw_metaoption);
    if (empty($temp)){
      $temp = MCW_get_default_meta();
      MCW_set_meta($temp);
    }
    return $temp;
  }  
  
  
/****************************/    
/***   Default GETTER     ***/
/****************************/ 
  
  function MCW_get_default_meta(){
    global $mcw_version;    
    $meta = array('initial'  => true, 
                  'now'      => 0,
                  'version'  => $mcw_version);      
		return $meta; 
  } 
   
  function MCW_get_default_options() {
 	  // returns predefined default plugin-options
    $cache_filters = array(array('all',      'true'), 
                           array('home',     'is_home()'),
                           array('single',   'is_single()'),
                           array('page',     'is_page()'),
                           array('category', 'is_category()'), 
                           array('tag',      'is_tag()'),
                           array('archive',  'is_archive()'),
                           array('search',   'is_search()'));

    $cache_options = array('filters'      => $cache_filters, 
                           'use_add_html' => 'no', 
                           'allow_js'     => 'yes',
                           'copy_widget'  => 'no',
                           'std_kind'     => 'html', 
                           'code_height'  => 200,
                           'filter_width' => 75,
                           'wpfilter'     => '',
                           'outfilter'    => 'the_content',
                           'use_custag'   => 'yes',
                           'use_wpfilter' => 'no',
                           'css_wrapper'  => 'no');      
		return $cache_options;    
 	}
  
  
/****************************/    
/***    Input_Screens     ***/
/****************************/ 
 
  function MCW_get_official_form($name){
    global $mcw_officialform_tooltip;
    global $mcw_custag_tooltip;
    
    include(MCW_get_url('style'));
    $MyWidget = MCW_get_mywidget_by_name($name);
    $outsidecall = '&lt;!--'.$name.'--&gt;';
        
    echo '<a href="'.get_option('siteurl').'/wp-admin/themes.php?page='.MCW_get_mainfile_name().'">&raquo; Click here to configure Widget';
    echo '</a>';
//  had to be deactivated because cannot be handled by firefox
//  echo '<script type="text/javascript" src="'.MCW_get_url('js_tooltip').'"></script>'; // thanks to http://www.walterzorn.de/tooltip/tooltip.htm
	  echo '<br><div style ="margin-left: 20px; margin-top: 5px;" onmouseover="Tip(&#39;'.$mcw_custag_tooltip.'&#39;)" onmouseout="UnTip()"><input type="text" value="'.$outsidecall.'" size="'.strlen($outsidecall).'" class="mcw_readonly" readonly="readonly"></div><br>';
    echo '<div class="mcw_maint_display" onmouseover="Tip(&#39;'.$mcw_officialform_tooltip.'&#39;)" onmouseout="UnTip()">';
    MCW_get_widget_maintenance($MyWidget, '', '', true);
    echo '</div>';
    
  } 
 
  function MCW_get_widget_maintenance($MyWidget, $elements= '', $widgetindex = '', $display_only = false){
    global $mcw_title_tooltip;
    $data_widget_filter = $elements['filter'];
    $data_widget_title = $elements['title'];
    $data_widget_kind = $elements['kind'];
    $data_widget_code = $elements['code'];
    $mcw_submit_trigger = $elements['submit'];
    $data_foreign_widget_id = $elements['foreign_id'];
    
    $mcw_name = htmlspecialchars($MyWidget['name'], ENT_QUOTES);
		$mcw_kind = $MyWidget['kind'];
		$mcw_filter = $MyWidget['filter'];
		$mcw_title = $MyWidget['title'];
		
		$disabler='';
    if (($MyWidget['foreign_id']<>'') || ($display_only)){
      $disabler = ' class="mcw_readonly" readonly="readonly"';
    }
    
    if ($display_only){
      $display_only = ' disabled= "true"';
    }
    
    echo '<div class="mcw-row-" onmouseover="Tip(&#39;'.$mcw_title_tooltip.'&#39;)" onmouseout="UnTip()"><label for="'.$data_widget_title.$widgetindex.'"><input type="text" id="'.$data_widget_title.$widgetindex.'" name="'.$data_widget_title.$widgetindex.'" value="'.$mcw_title.'" size="13" '.$disabler.'></label></div>';
	  echo '<div class="mcw-row-small"><nobr><label for="'.$data_widget_kind.$widgetindex.'_php"><input type="radio" id="'.$data_widget_kind.$widgetindex.'_php" name="'.$data_widget_kind.$widgetindex.'" value="php" checked="checked" '.$display_only.'> PHP</label></nobr>';
    echo '<nobr><label for="'.$data_widget_kind.$widgetindex.'_html"><input type="radio" id="'.$data_widget_kind.$widgetindex.'_html" name="'.$data_widget_kind.$widgetindex.'" value="html"'. mcw_check($mcw_kind,"html") .' '.$display_only.'> HTML</label></nobr></div><br>';
    echo '<div class="mcw-row">'.MCW_get_input_code($MyWidget, $data_widget_code, $widgetindex, $display_only).'</div>';
	  echo '<div class="mcw-row-small">'.MCW_get_input_filters($data_widget_filter, $widgetindex, $mcw_filter, $display_only).'</div>';
    echo '<br><div class="mcw-row">'.MCW_get_input_foreign($MyWidget, $widgetindex, $data_foreign_widget_id, $display_only).'</div>';
	  echo '<input type="hidden" name="'.$mcw_submit_trigger.$widgetindex.'" value="1" />';
  }
  	
  function MCW_get_input_code($MyWidget, $name, $widgetindex = '', $display_only = false){
    $result='';
    $disabler='';
    if (($MyWidget['foreign_id']<>'') || ($display_only)){
      $disabler = ' background:#EEEEEE" readonly="readonly';
    }
    
    $maxheight=MCW_get_option('code_height');
    $mainheight=$maxheight;
    $subheight=0;
    $beforecode = trim(stripslashes($MyWidget["beforecode"]));
    $showadd = ((MCW_get_option('use_add_html'))||(!empty($beforecode)));
    if ($showadd) {
      $mainheight=0.7*$maxheight;
      $subheight=0.3*$maxheight;
    } else {
      $mainheight=$maxheight;
    }
    
    $result=$result.'<div id="'.$name.$widgetindex.'_container_before'.'"><textarea cols="60" id="'.$name.$widgetindex.'_before'.'" name="'.$name.$widgetindex.'_before'.'" style="height:'.$subheight.'px;'; 
    if ($showadd) {$result=$result.'display:block;';} else {$result=$result.'display:none;';}
    $result=$result.' font-family:Courier, Monaco, monospace; '.$disabler.'">'.$beforecode.'</textarea></div>';
    
    $result= $result.'<textarea cols="60" name="'.$name.$widgetindex.'" style="height:'.$mainheight.'px; font-family:Courier, Monaco, monospace; '.$disabler.'" >'.stripslashes($MyWidget["code"]).'</textarea>';
    
    $result=$result.'<br>';
    return $result;
  }


  function MCW_get_input_foreign($MyWidget, $widgetindex, $data_foreign_widget_id, $display_only = false){
    global $wp_registered_widgets;
    $all_registered_widgets = $wp_registered_widgets;
    
    if ((MCW_get_option('copy_widget') == true)){
      $result = '<div>';
    } else {
      $result = '<div class="mcw_hidden">';
    }
    
    if ($display_only){
      $disabler = ' disabled= "true"';
    } else {
      $disabler = '';
    }
    
    $result = $result.'<label for="'.$data_foreign_widget_id.$widgetindex.'">copy from widget ';
    $result = $result.'<select name="'.$data_foreign_widget_id.$widgetindex.'" id="'.$data_foreign_widget_id.$widgetindex.'" size="1" '.$disabler.'>';
    //empty value
    $result = $result.'<option value=""></option>';
    
    //print_r($all_registered_widgets);
    
    foreach($all_registered_widgets as $value) :
      //own widget must not be selected
      if ($value["id"]<>$MyWidget['name']){
        //choosen entry
        if ($MyWidget['foreign_id']==$value["id"]){
          $result = $result.'<option value="'.$value["id"].'" selected="selected">';
          
          if ($value["id"]<>$value["name"]){
            $result = $result.$value["name"].' ('.$value["id"].')</option>';
          } else {
            $result = $result.$value["name"].'</option>';
          } 
        }else{
        //selectable entry
          $rec_check = MCW_check_chain(MCW_get_mywidget_by_name($value["id"]));
          if ($rec_check['clean']==true){
            $result = $result.'<option value="'.$value["id"].'">'; 
            
            if ($value["id"]<>$value["name"]){
              $result = $result.$value["name"].' ('.$value["id"].')</option>';
            } else {
              $result = $result.$value["name"].'</option>';
            }  
          }  
        }        
      }       
    endforeach;
    $result = $result.'</select></label></div>';
    
    return $result;
  }
  
  function MCW_get_input_filters($filtername, $widgetindex = '', $filtervalue = array('all' => 1), $display_only = false){
    $myfilteroptions = MCW_get_all_filters();
    global $mcw_filters_tooltip;
    if ($display_only){
      $disabler = ' disabled= "true"';
    } else {
      $disabler = '';
    }
    $max = count($myfilteroptions);
    $result = '<div onmouseover="Tip(&#39;'.$mcw_filters_tooltip.'&#39;)" onmouseout="UnTip()">';
    for ( $i = 0; $i < $max; ++$i ) {
        $result = $result.'<nobr><label for="'.$filtername.$widgetindex.'['.$myfilteroptions[$i][0].']"><input type="checkbox" id="'.$filtername.$widgetindex.'['.$myfilteroptions[$i][0].']" name="'.$filtername.$widgetindex.'['.$myfilteroptions[$i][0].']" value="1" '.MCW_check($filtervalue[$myfilteroptions[$i][0]],"1").$disabler.'> '.$myfilteroptions[$i][0].' </label></nobr>';
    }
    $result = $result.'</div>';
    return $result;
  }


/****************************/
/***    Help functions    ***/
/****************************/

  function MCW_sort_my_elements($myelements, $primarykey = 0){
    // sorts your array after given primary key
    $liste = array();
    $erg = array();
    $max = count($myelements);
    for ( $i = 0; $i < $max; ++$i ) { 
      $liste[] = $myelements[$i][$primarykey];
    }
    sort($liste);
    for ( $i = 0; $i < $max; ++$i ) {
      for ( $j = 0; $j < $max; ++$j ) {
        if ($myelements[$j][$primarykey] == $liste[$i]){
          $erg[] = $myelements[$j];
        }
      }
    }
    return $erg;
  }

  function MCW_loadedfirsttime(){
    $meta = mcw_get_meta();
    return $meta['initial'];
  }
  
  function MCW_generaterequired(){
    $meta = mcw_get_meta();
    $result = ($meta['generated']<>'no');
    $meta['generated'] = 'no';
    MCW_set_meta($meta);
    return $result;
  }
 
  function MCW_check($value1, $value2){
    if ($value1==$value2){
      return ' checked="checked"';
    }
  }
  
  function MCW_widget_already_exist($name){
    $all_widget_IDs = MCW_get_all_widget_IDs(); 
    $max = count($all_widget_IDs);
    $erg=false;
    for ( $i = 0; $i < $max && !$erg; ++$i ) {
      $erg = ($all_widget_IDs[$i]['name'] == $name);
    }
    return $erg;
  }
  
  function MCW_filter_already_exist($name){
    $all_filters = MCW_get_all_filters(); 
    $max = count($all_filters);
    $erg=false;
    for ( $i = 0; $i < $max && !$erg; ++$i ) {
      $erg = (trim($all_filters[$i][0]) == trim($name));
    }
    return $erg;
  }
   
  function MCW_checkshow($MyFilter){
  // checks whether the widget should be displayed on this screen or not
    $myfilteroptions = MCW_get_all_filters();
    $max = count($myfilteroptions);
    $erg = false;
    for ( $i = 0; $i < $max; ++$i ) {
      $c="if ((".stripslashes($myfilteroptions[$i][1]).") && isset(\$MyFilter[\$myfilteroptions[\$i][0]])) {\$erg = true;}";
      eval($c);
    }
    return $erg;
  }
  
  function MCW_check_chain($widget, $start=''){
    //echo $widget['name'].'-->'.$widget['foreign_id'].' |';
    if ($start==''){
     $start=$widget['name']; 
    }
    
    if ($widget['foreign_id']==''){
      $result['clean'] = true;
      $result['chain'] = '';
    } else {
      if ($widget['foreign_id']==$start){
        $result['clean'] = false;
        $result['chain'] = $widget['name'].' -->'.$widget['foreign_id'];
      } else {
        $nextstep = MCW_get_mywidget_by_name($widget['foreign_id']);
        $temp = MCW_check_chain($nextstep, $start);
        $result['clean']=$temp['clean'];
        if ($temp['chain']==''){
          $result['chain']=$widget['name'];
        } else {
          $result['chain']=$widget['name'].' --> '.$temp['chain'];
        }
      }
    } 
    return $result;
  } 
  
  function MCW_plausibility_check($widget){
  // 0 if code is correct
  // error message if code is incorrect
    $res = false; // = 0 = ''
    $code = stripslashes($widget['code']);
    $kind = $widget['kind'];
    
    //check 0
    $rec_check = MCW_check_chain($widget);
    if ($rec_check['clean']==false){
      $res=$res.'DANGER: Current widget configuration would lead to infinite loops: <code>'.$rec_check['chain'].'</code>';
    }
    
    //check 1
    $code_a='<?php';
    $code_b='?'.'>';
    $code_a_count=substr_count($code, $code_a);
    $code_b_count=substr_count($code, $code_b);
    if ($code_a_count <> $code_b_count) 
      $res=$res.$code_a_count.' php-open-tag (<code>'.MCW_make_html_writeable($code_a).'</code>) vs. '.$code_b_count.' php-close-tag (<code>'.MCW_make_html_writeable($code_b).'</code>)';
    
    //check 2
    if ($kind=='html'){
      $code_a='?'.'>';
      $code_b='<?php';      
    } else {
      $code_a='<?php';
      $code_b='?'.'>';          
    }
    $code_a_pos=strpos($code, $code_a);
    $code_b_pos=strpos($code, $code_b);
    if ($code_a_pos < $code_b_pos){
      if ($res) $res=$res.',<br>';
      $res=$res.'You should not use <code>'.MCW_make_html_writeable($code_a).'</code> before <code>'.MCW_make_html_writeable($code_b).'</code> in '.$kind.'-code. Please select html or remove these tags.';
    }
      
    return $res;
    //return false;    
  }
  
  function MCW_make_html_writeable($code){
    $code = str_replace('<','&lt;',$code);
    $code = str_replace('>','&gt;',$code);
    return $code;
  }
  function MCW_make_php_writeable($code){
    $code = str_replace('<'.'?php','&lt;'.'?php', $code);
    $code = str_replace('?'.'>','?'.'&gt;', $code);
    return $code;
  }

  function MCW_make_name_acceptable($name) {
    // people do have crazy ideas
  
    $name = strtr($name," ","_");
    $name=preg_replace("/[^a-zA-Z0-9_äöüÄÖÜ]/" , "" , $name);
    return $name;
  }
/******************************/    
/*** start option-functions ***/
/******************************/  
  
  function MCW_set_options($myoptions) {
    global $mcw_prefix;
    global $mcw_configoption; 
    update_option($mcw_prefix.$mcw_configoption, $myoptions); 
  }  

  function MCW_set_option_backup($myoptions) {
    global $mcw_prefix;
    global $mcw_configoption;
    global $mcw_backup_postfix; 
    update_option($mcw_prefix.$mcw_configoption.$mcw_backup_postfix, $myoptions); 
  }
   
  function MCW_set_filters($myfilter) {
    global $mcw_prefix;
    global $mcw_configoption; 
    $myoption = MCW_get_option();
    $myoption['filters'] = $myfilter;
    update_option($mcw_prefix.$mcw_configoption, $myoption);  
  }
  
  function MCW_delete_filter($index) {
    $myfilter= MCW_get_all_filters();
    unset($myfilter[$index]);
    $myfilter= array_values($myfilter);
    MCW_set_filters($myfilter);
  }
    
  function MCW_set_meta($meta){
  //returns plugin-meta-data 
    global $mcw_prefix;
    global $mcw_metaoption;
    update_option($mcw_prefix.$mcw_metaoption, $meta);
  }
  

/******************************/
/*** start widget-functions ***/
/******************************/

  function MCW_swap_widgetdata($index){
    //moves widget-data from central storrage to individual db-entries
    //required for change from release 1.8 to 1.9  
    $all_widget_IDs = MCW_get_all_widget_IDs();
    MCW_set_mywidget($all_widget_IDs[$index]); //create new entry
    
    $mcw_widget_ID = array ( 'name' => $all_widget_IDs[$index]['name']);
    unset($all_widget_IDs[$index]);
    $all_widget_IDs[$index] = $mcw_widget_ID; //clear widget
    //echo 'widget '.$mcw_widget_ID['name'].' swaped.';
    MCW_set_all_widget_IDs($all_widget_IDs);  
  }
  
  function MCW_get_all_widget_IDs(){ //2.0 compatible
    global $mcw_prefix;
    global $mcw_widgetsoption;
    global $mcw_all_widget_IDs;
    //if (empty($mcw_all_widgets)){    
      $mcw_all_widget_IDs = get_option($mcw_prefix.$mcw_widgetsoption);
      $mcw_all_widget_IDs = MCW_sort_my_elements($mcw_all_widget_IDs, 'name'); 
    //}
    return $mcw_all_widget_IDs;  
  }
  
  function MCW_get_all_widgets() { //2.0 compatible
    global $mcw_prefix;
    global $mcw_widgetsoption;
    global $mcw_all_widgets;
    if (empty($mcw_all_widgets)){    
      $mcw_all_widget_IDs = get_option($mcw_prefix.$mcw_widgetsoption);
      $mcw_all_widget_IDs = MCW_sort_my_elements($mcw_all_widget_IDs, 'name');
      $max = count($mcw_all_widget_IDs);
      //$mcw_all_widgets = $mcw_all_widget_IDs; // if not updated yet
      
      for ( $i = 0; $i < $max; ++$i ) {
        $single_widget = MCW_get_mywidget_by_name($mcw_all_widget_IDs[$i]['name']);
        if (empty($single_widget)){ // if not updated yet        
          //Move widgets to own db-entry   
          MCW_swap_widgetdata($i);
          $mcw_all_widgets[$i] = $mcw_all_widget_IDs[$i];
        } else {
          $mcw_all_widgets[$i] = $single_widget;
        }
      } 
    }
    return $mcw_all_widgets;    
  }
  
  function MCW_set_all_widget_IDs($myWidget_IDs){ //2.0 compatible
    global $mcw_prefix;
    global $mcw_widgetsoption;
    update_option($mcw_prefix.$mcw_widgetsoption, $myWidget_IDs);
  }
  
  function MCW_set_allwidgets($widgets) { //2.0 compatible

    global $mcw_prefix;

    global $mcw_widgetsoption;

    

    if (!empty($widgets)){

      //update_option($mcw_prefix.$mcw_widgetsoption, $widgets); //obsolete

      $max = count($widgets);

      for ( $i = 0; $i < $max; ++$i ) {

        update_option($mcw_prefix.'w_'.$widgets[$i]['name'], $widgets[$i]);

      }

      return MCW_generate_class();

    }

  }



  function MCW_get_mywidget_by_name($widgetname) { //2.0 compatible

    global $mcw_prefix;

    global $mcw_widgetsoption;

    $myWidget = get_option($mcw_prefix.'w_'.$widgetname);

    if (!empty($myWidget)){

      return $myWidget;

    }

    else //not upgraded yet? 

    {       

      //$myWidgets = MCW_get_all_widgets(); //has to be deactivated for some reason

      $max = count($myWidgets);

      if (!empty($myWidgets)){ 

        for ( $i = 0; $i < $max; ++$i ) {

          if ($myWidgets[$i]['name']==$widgetname){

            return $myWidgets[$i];

          }

        }

      }    

    }

    return '';

  }

    

  function MCW_get_mywidget_by_index($widgetindex) { //2.0 compatible

    $myWidget_names = MCW_get_all_widget_IDs();    

    $myWidget = MCW_get_mywidget_by_name($myWidget_names[$widgetindex]['name']);

    if (empty($myWidget)){ //not upgraded yet?

      $myWidget = $myWidget_names[$widgetindex]; 

      MCW_swap_widgetdata($widgetindex);

    }    

    return $myWidget;

  }

  

  function MCW_get_widget_info($name, $parameter){

    $MyWidget = MCW_get_mywidget_by_name($name);

    return $MyWidget[$parameter];

  }

  

  function MCW_set_mywidget($widgetcontent) { //2.0 compatible

    global $mcw_prefix;

    //$myWidgets = MCW_get_all_widgets();

    //$myWidgets[$widgetindex] = $widgetcontent;

    //MCW_set_allwidgets($myWidgets); //obsolete till version 2.0

    

    update_option($mcw_prefix.'w_'.$widgetcontent['name'], $widgetcontent);

    return MCW_generate_class();

  }

  

  function MCW_add_mywidget($content) { //2.0 compatible

    

    //update widget repository

    $myWidget_IDs = MCW_get_all_widget_IDs();

    $index = count($myWidget_IDs);

    $mcw_widget_ID = array ( 'name' => $content['name']);

    $myWidget_IDs[$index] = $mcw_widget_ID; //append widget

    MCW_set_all_widget_IDs($myWidget_IDs);

    

    //update widget content

    return MCW_set_mywidget($content); //includes MCW_generate_class();

  }

  

  function MCW_delete_mywidget($index) { //2.0 compatible

    global $mcw_prefix;

    global $mcw_widgetsoption;

    

    $allwidget_IDs = MCW_get_all_widget_IDs();

    $widgetname = $allwidget_IDs[$index]['name'];

    unset($allwidget_IDs[$index]);

    $allwidget_IDs= array_values($allwidget_IDs);

    

    MCW_set_all_widget_IDs($allwidget_IDs);

    delete_option($mcw_prefix.'w_'.$widgetname);

    return MCW_generate_class();

    

  }



/********************************/    

/*** start widget realization ***/

/********************************/ 

  function MCW_php_replace($match){

    // replacing WPs strange PHP tag handling with a functioning tag pair

    $output = '<?php'. $match[2]. '?'.'>';

    return $output;

  }

  

  function MCW_run_code($MyWidget, $printpreview=false, $mcw_theme=""){    

    

    //thanks to EXEC-PHP

    $pattern = '/'.

    '(<[\s]*\?php)'. // the opening of the <?php tag

    '(((([\'\"])([^\\\5]|\\.)*?\5)|(.*?))*)'. // ignore content of PHP quoted strings

    '(\?'.'>)'. // the closing ? > tag

    '/is';

    $code = $MyWidget['code']; //html or php

    $precode = $MyWidget['beforecode']; //html

    $mcw_id= $MyWidget['name']; //widget-ID

    $mcw_title= $MyWidget['title']; //widget-title

    

    $before_widget = $mcw_theme['before_widget'];

    $after_widget = $mcw_theme['after_widget'];

    $before_title = $mcw_theme['before_title'];

    $after_title = $mcw_theme['after_title'];

    

    $code = stripslashes($code);

    $precode = stripslashes($precode);

      

    $code = preg_replace_callback($pattern, 'MCW_php_replace', $code);

          

    if ($printpreview) echo '<div class="mcw_debug"><pre><code>'.MCW_make_html_writeable($mcw_title).'<br>'.MCW_make_html_writeable($precode).MCW_make_html_writeable($code).'</pre></code></div>';

          

    if ($MyWidget['kind']=="html"){

      $code = '?'.'> '.$code.'<'.'?php '; 

    } else {

      $code = $code.'?'.'>';

    } 

          

    // to be compatible with older PHP4 installations

    // don't use fancy ob_XXX shortcut functions       

    ob_start();

      eval($code);

      $output = ob_get_contents();

    ob_end_clean();

          

    $output = $precode.$output;

    

    //$output = "<!--Before widget-->".$output;

    

    //add title to widget code

    $mcw_title = apply_filters('widget_title', $mcw_title);

    if ($mcw_title!=""){

      if (trim($mcw_title)!=""){

        $output = $before_title.$mcw_title.$after_title.$output;   

      }

      $output = $before_widget.$output.$after_widget;

    }

         

    $output = MCW_make_php_writeable($output);

    if (MCW_get_option('css_wrapper')){          

      $output = '<div id="'.$mcw_id.'" class="mcw">'.$output.'</div>';

    }

    return $output;

  }

  

/****************************************/    

/*** start foreign widget realization ***/

/****************************************/  

 



   

  function MCW_eval_foreign_widget($id, $mcw_theme){

    global $wp_registered_widgets;



    $params = array_merge(

    array( array_merge( $mcw_theme, array('widget_id' => $id, 'widget_name' => $wp_registered_widgets[$id]['name']) ) ),

    (array) $wp_registered_widgets[$id]['params']

    );

// Substitute HTML id and class attributes into before_widget

    $classname_ = '';

    foreach ( (array) $wp_registered_widgets[$id]['classname'] as $cn ) {

      if ( is_string($cn) )

        $classname_ .= '_' . $cn;

      elseif ( is_object($cn) )

        $classname_ .='_' . get_class($cn);

    }

    $classname_ = ltrim($classname_, '_');

    $params[0]['before_widget'] = sprintf($params[0]['before_widget'], $id, $classname_);

    $params = apply_filters('dynamic_sidebar_params', $params );

    $callback = $wp_registered_widgets[$id]['callback'];

    if ( is_callable($callback) ) {

      ob_start();

        call_user_func_array($callback, $params);

        $output = ob_get_contents();

      ob_end_clean();

    }

    return $output;

  }

  

  

 /********************************/

 /***    Main function         ***/

 /********************************/ 

    

  function MCW_eval_code($args){

    extract($args);    

    if(!isset($i)) {

      $funcArgs = func_get_args();  // for wp2.2.1

      $i = $funcArgs[1];

    } 

    if(!isset($name)) {

      $name = $args['name']; // for wp2.2.1

    }   

    if(!isset($force_eval)) {

      $force_eval = $args['force_eval']; // for wp2.2.1

    }

    if(!isset($debug_mode)) {

      $debug_mode = $args['debug_mode']; // for wp2.2.1

    }

    

    $MyWidget = MCW_get_mywidget_by_name($name);

    if(!isset($MyWidget)){

      $MyWidget = MCW_get_mywidget_by_index($i);

    }

    

    $code = $MyWidget['code']; //html or php

    $precode = $MyWidget['beforecode']; //html

    $mcw_id= $MyWidget['name']; //widget-ID

    $mcw_title= $MyWidget['title']; //widget-title

    $mcw_theme = array ( 'before_widget'   => $before_widget,

                         'after_widget'   => $after_widget,

                         'before_title'   => $before_title,

                         'after_title'   => $after_title);

        

    if(isset($code)) {

      $code = stripslashes($code);

      $precode = stripslashes($precode);



      if (MCW_checkshow($MyWidget['filter']) || $force_eval) {

        if ($debug_mode==''){

          /* productive code evaluation */

          

          if (($MyWidget['foreign_id']=='') || (MCW_get_option('copy_widget')==false)){

            $output=MCW_run_code($MyWidget, $force_eval, $mcw_theme);

          }else{

            $rec_check = MCW_check_chain($MyWidget);

            if ($rec_check['clean']==false){

              $output=$before_widget.'<div class="mcw_error">DANGER: Current widget configuration would lead to infinite loops: <br><code>'.$rec_check['chain'].'</code></div>'.$after_widget;

            } else {

              $output=MCW_eval_foreign_widget($MyWidget['foreign_id'], $mcw_theme);

            }

          }

          $wpfilter = MCW_get_option('wpfilter');                    

          if (MCW_get_option('use_wpfilter')){

            $output = apply_filters($wpfilter, $output);

          }

                     

          echo $output;   

        

        } else { 

          if (($MyWidget['foreign_id']<>'') && (MCW_get_option('copy_widget') == true)){

            $widget_buffer = MCW_get_mywidget_by_name($MyWidget['foreign_id']);

            if ($widget_buffer==''){

              echo '<br><div class="mcw_debug"><b>Debugging is not possible for foreign widgets.</b></div>';

            } else {

              // evaluate "foreign" MyCustomWidget

              $widget_buffer = MCW_check_chain($widget_buffer);

              echo '<br><div class="mcw_debug"><b>Debugging is not possible for this CustomWidget. <br>Please try again with the original one. <code>'.$widget_buffer['chain'].'</code></b></div>';

            }

          } else {

       // title

            if ($mcw_title){ 

              echo '<br><div class="mcw_debug"><b>Title:</b> <pre><code>'.MCW_make_html_writeable($mcw_title).'</pre></code></div>';

            } 

            echo $mcw_title;

            

          // true html-code

            if ($precode){ 

              echo '<br><div class="mcw_debug"><b>Precode:</b> <pre><code>'.MCW_make_html_writeable($precode).'</pre></code></div>';

            }

            echo $precode;     

               

            if ($MyWidget['kind']=="html"){

              // html-code

              $true_html=substr_count($code, '<?php');

              if ($true_html == 0){

                //true html-code --> easy

                echo '<br><div class="mcw_debug"><b>HTML:</b> <pre><code>'.MCW_make_html_writeable($code).'</pre></code></div>';

                echo $code;

              } else {

                // html-php-mix --> this can be tricky

                $help_open_tag = '<?php';

                $help_close_tag = '?'.'>';

              

                $temp_widget = array('code'       => $code, 

                                     'kind'       => 'hmtl',

                                     'foreign_id'    => '',

                                     'name'       => $mcw_id);  

                             

                echo MCW_plausibility_check($temp_widget);

/* NEW Code-evaluation */

                $i = substr_count($code, $help_open_tag);

                $counter = 1;

                while ($i > 0) {

                //split code into php- and html-pieces

                

                 //GRAB HTML-CODE

                  $temp_html = substr($code, 0, strpos($code,$help_open_tag));

                  //remove leading php-open-tag

                  $code = stristr($code, $help_open_tag);

                  $code = substr($code, 5, strlen($code)-5); 

                  

                  //GRAB PHP-CODE

                  //$temp_php = stristr($code_rest, $help_close_tag, true); // only with php 6.0.0 

                  $temp_php = substr($code, 0, strpos($code,$help_close_tag));

                  //remove leading php-close-tag                

                  $code = stristr($code, $help_close_tag);

                  $code = substr($code, 2, strlen($code)-2);

                  

                  $i = substr_count($code, $help_open_tag);



                  echo '<br><div class="mcw_debug"><b>'.$counter.'. HTML:</b><pre><code> '.MCW_make_html_writeable($temp_html).'</pre></code></div>';

                  echo $temp_html;

                  echo '<br><div class="mcw_debug"><b>'.$counter.'. PHP:</b><pre><code> '.MCW_make_html_writeable($temp_php).'</pre></code></div>';

                  eval($temp_php);

                  $counter = $counter+1;

                }

                if (strlen($code)>0){ //HTML code left

                  echo '<br><div class="mcw_debug"><b>'.$counter.'. HTML:</b><pre><code> '.MCW_make_html_writeable($code).'</pre></code></div>';

                  echo $code;

                }       

              }

            } else {

              $help_open_tag = '<?php';

              $help_close_tag = '?'.'>';

              $true_php = substr_count($code, $help_close_tag);

              $true_php = ($true_php==0);

              if ($true_php){

                //true php-code --> high performance

                echo '<br><div class="mcw_debug"><b>PHP:</b> '.MCW_make_html_writeable($code).'</div>';

                eval($code);

              } else {

                $temp_widget = array('code'       => $code, 

                                     'kind'       => 'php',

                                     'foreign_id'    => '',

                                     'name'       => $mcw_id);  

                echo MCW_plausibility_check($temp_widget);

/* NEW Code-evaluation */

                $i = substr_count($code, $help_close_tag);

                $counter = 1;

                while ($i > 0) {

                //split code into php- and html-pieces

                  

                //GRAB PHP-CODE

                  $temp_php = substr($code, 0, strpos($code,$help_close_tag));

                //remove leading php-close-tag

                  $code = stristr($code, $help_close_tag);

                  $code = substr($code, 2, strlen($code)-2); 

                  

                //GRAB HTML-CODE

                  $temp_html = substr($code, 0, strpos($code,$help_open_tag));

                //remove leading php-open-tag                

                  $code = stristr($code, $help_open_tag);

                  $code = substr($code, 5, strlen($code)-5);

                

                  $i = substr_count($code, $help_close_tag);



                  echo '<br><div class="mcw_debug"><b>'.$counter.'. PHP:</b><pre><code> '.MCW_make_html_writeable($temp_php).'</pre></code></div>';

                  eval($temp_php);

                  echo '<br><div class="mcw_debug"><b>'.$counter.'. HTML:</b><pre><code> '.MCW_make_html_writeable($temp_html).'</pre></code></div>';

                  echo $temp_html;

                  $counter = $counter+1;                

                }

                if (strlen($code)>0){ //PHP code left

                  echo '<br><div class="mcw_debug"><b>'.$counter.'. PHP:</b><pre><code> '.MCW_make_html_writeable($code).'</pre></code></div>';

                  eval($code);

                }       

              }

            }

          } 

        }

      }

    }

  }

  

/************************************/

/***        start filter          ***/

/************************************/ 

  function MCW_make_available_outside($content){       

    $Widget_IDs_all = MCW_get_all_widget_IDs();

    $maxi = count($Widget_IDs_all);

    if (!empty($Widget_IDs_all)){

      for ( $windex = 0; $windex < $maxi; ++$windex ) {

        $widget = MCW_get_mywidget_by_index($windex);

        if (MCW_get_option('use_custag')){

          if (MCW_checkshow($widget['filter'])){

            //MCW_logfile('filter anwenden für '.$maxi.' widgets'); //debugging only

            $output=MCW_run_code($widget);

            $content = eregi_replace('<!--'.$widget["name"].'-->',$output, $content);

          }

        }    

      }      

    }

    return $content;

  }





/**********************/    

/*** backup routine ***/

/**********************/ 

  function MCW_set_widget_backup($myWidgets) {

    global $mcw_prefix;

    global $mcw_widgetsoption;

    global $mcw_backup_postfix;

    

    //delete obsolete backup-data

    $all_backup_widget_IDs = get_option($mcw_prefix.$mcw_widgetsoption.$mcw_backup_postfix);       

    $max = count($all_backup_widget_IDs);

    for ( $i = 0; $i < $max; ++$i ) {

      delete_option($mcw_prefix.$mcw_backup_postfix.'w_'.$all_backup_widget_IDs[$i]['name']);

    }

    

    //create new backup-data

    $max = count($myWidgets);

    for ( $i = 0; $i < $max; ++$i ) {

      $all_widget_IDs[$i] = array ( 'name' => $myWidgets[$i]['name']);      

      $backup_widget = get_option($mcw_prefix.'w_'.$myWidgets[$i]['name']);

      update_option($mcw_prefix.$mcw_backup_postfix.'w_'.$myWidgets[$i]['name'], $backup_widget);

    }

    update_option($mcw_prefix.$mcw_widgetsoption.$mcw_backup_postfix, $all_widget_IDs);    

  }

  

  function MCW_restore_widget_backup() {

    global $mcw_prefix;

    global $mcw_widgetsoption;

    global $mcw_backup_postfix;

    

    //delete obsolete data

    $current_ID = MCW_get_all_widget_IDs();

    $max = count($current_ID);

    for ( $i = 0; $i < $max; ++$i ) {

      delete_option($mcw_prefix.'w_'.$current_ID[$i]['name']);

    }

    

    //restore backup data

    $backup_IDs = get_option($mcw_prefix.$mcw_widgetsoption.$mcw_backup_postfix);

    MCW_set_all_widget_IDs($backup_IDs);

    $max = count($backup_IDs);

    for ( $i = 0; $i < $max; ++$i ) {

      $backup_widget = get_option($mcw_prefix.$mcw_backup_postfix.'w_'.$backup_IDs[$i]['name']);

      if (empty($backup_widget)){

        MCW_swap_widgetdata($i);

      } else {

        update_option($mcw_prefix.'w_'.$backup_IDs[$i]['name'], $backup_widget);

      }

    }

    $error_message = MCW_generate_class();

    if ($error_message ==''){

      return $max; 

    } else {

      return $error_message;

    }   

  }

  

  function MCW_get_widget_backup() {

    global $mcw_prefix;

    global $mcw_widgetsoption;

    global $mcw_backup_postfix;

    $res = get_option($mcw_prefix.$mcw_widgetsoption.$mcw_backup_postfix);

    //$res = MCW_sort_my_elements($res, 'name'); 

    return $res;    

  }



/***********************/    

/*** WP 2.8 overhead ***/

/***********************/

  function MCW_generate_class_content($mcwname){

    //convert widget-name into class-name

    $classname = 'MCW_'.MCW_make_name_acceptable($mcwname);

    $classname = eregi_replace('-','_', $classname);

    

    MCW_logfile('widgetname "'.$mcwname.'" converted into classname "'.$classname.'"');

    $res = "<?"."php";

    $res = $res."\n"."class ".$classname." extends WP_Widget";

    $res = $res."\n"."{";

    $res = $res."\n"."	function ".$classname."(){";

    $res = $res."\n"."		$"."widget_ops = array('classname' => '".$classname."', 'description' => 'CustomWidget generated with MCW &raquo;' );";

    $max_width = MCW_get_option('filter_width')*4+30+15; //4*filters+margin+padding+"IE-bug"

    $res = $res."\n"."		$"."control_ops = array('width' => ".$max_width.");";

    $res = $res."\n"."		$"."this->WP_Widget('".$classname."', 'MCW: ".$mcwname."', $"."widget_ops, $"."control_ops);";

    $res = $res."\n"."	}";

	

    $res = $res."\n"."	function widget($"."args, $"."instance){";

    $res = $res."\n"."		$"."args['name'] = '".$mcwname."';";

    

    $res = $res."\n"."		MCW_eval_code($"."args);";

    $res = $res."\n"."	}";

	

    $res = $res."\n"."	function update($"."new_instance, $"."old_instance){";

    $res = $res."\n"."	  $"."new_instance['title'] = MCW_get_widget_info('".$mcwname."', 'title');";

    $res = $res."\n"."		return $"."new_instance;";

    $res = $res."\n"."	}";

	

    $res = $res."\n"."	function form($"."instance){";

    $res = $res."\n"."    MCW_get_official_form('".$mcwname."');	  ";

    $res = $res."\n"."  }";

    $res = $res."\n"."}";

	

    $res = $res."\n"."	function ".$classname."Init() {";

    $res = $res."\n"."	  register_widget('".$classname."');";

    $res = $res."\n"."	}";



    $res = $res."\n"."	add_action('widgets_init', '".$classname."Init');";



    $res = $res."\n"."?".">";  

    return $res;

  }

  

  function MCW_generate_class(){
    global $mcw_path;
    MCW_logfile('start class generation:'); //debugging only
    
    $myWidget_IDs_all = MCW_get_all_widget_IDs();
    $maxindex = count($myWidget_IDs_all);
    
    $filename = $mcw_path["include_class"];
    MCW_logfile('start to write '.$maxindex.' widgets into '.$filename);//debugging only
    if (!file_exists($filename)){
		  copy(dirname(__FILE__).'/'.$mcw_path["function_source"],$filename);
		}
    if (!file_exists($filename)){
      $answer = "file ".$filename." does not exist. Please create the file (chmod 0666).<br>";
      $bug = $answer;
      //echo "MyCustomWidget-Plugin: ".$answer;
    } else {
      if (!$handle = fopen($filename, "w")) {
        $answer = $answer. 'File "'.$filename.'" cannot be opened.<br>Please grant write access (chmod 0666)';
        $bug = $answer;
      } else {
        // Write $somecontent into the open file.
        $res = "<?"."php";
        $res = $res."\n"."/"."*";
        $res = $res."\n"."Author: Janek Niefeldt";
        $res = $res."\n"."Author URI: http://www.janek-niefeldt.de/";
        $res = $res."\n"."Description: Configuration of My Custom Widgets Plugin.";
        $res = $res."\n"."*"."/";
        $res = $res."\n"."include_once('my_custom_widget_functions.php');";
        $res = $res."\n"."include_once('my_custom_widget_meta.php');";
        $res = $res."\n"."?".">"; 
    
        if (!fwrite($handle, $res)) {
          $answer = "File ".$filename." is not writeable (please chmod 0666 or change owner).<br>";
          $bug = $answer;
        } else {
          for ( $widgetindex = 0; $widgetindex < $maxindex; ++$widgetindex ) {          
            $somecontent = MCW_generate_class_content($myWidget_IDs_all[$widgetindex]['name']);
            if (!fwrite($handle, $somecontent)) {
              $answer = $answer. "File ".$filename." is not writeable.<br>";
              $bug = $answer;
              //echo "MyCustomWidget-Plugin: ".$answer;
            } else {
              MCW_logfile('class generated: '.$myWidget_IDs_all[$widgetindex]['name']);//debugging only
              $answer = $answer."done <br>";
            }
          }
        }
      }
      fclose($handle);
    }
  MCW_logfile($answer);//debugging only
  return $bug;
  }

?>