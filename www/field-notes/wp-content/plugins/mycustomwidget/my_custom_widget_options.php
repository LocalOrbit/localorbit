<?php 
/*
Author: Janek Niefeldt
Author URI: http://www.janek-niefeldt.de/
Description: Administration of My Custom Widgets - Appearance.
*/
    // technical elements 
    $hidden_field_submit = 'mcw_submit_hidden';
    $element_widget_container = 'mcw_edit_container';
    $element_widget_show_add_html = 'mcw_show add_html';
    
    // data-elements in formular 
    $data_widget_name = 'mcw_new_widget_name';
    $data_widget_title = 'mcw_new_widget_title';
    $data_widget_code = 'mcw_new_widget_code';
    $data_widget_kind = 'mcw_new_widget_kind';
    $data_widget_filter = 'mcw_new_widget_filter';
    $data_widget_backup = 'mcw_backup_check';
    $data_debug_activate = 'mcw_debug_preview';
    $data_foreign_widget_id = 'mcw_foreign_widget_id';
    
    //help array for generic maintenance view
    $mcw_elements = array ('filter'     => $data_widget_filter,
                           'kind'       => $data_widget_kind,
                           'code'       => $data_widget_code,
                           'submit'     => $hidden_field_submit,
                           'title'      => $data_widget_title,
                           'foreign_id' => $data_foreign_widget_id);
    
    
    // button-elements in formular
    $element_widget_submit = 'mcw_submit_button';
    $element_widget_warning = 'mcw_warning_message';  
    $element_widget_backup = 'mcw_backup_button';    
    
    // button-text
    $button_text_delete_single = 'Delete';
    $button_text_save_all = 'Save All';
    $button_text_new_single = 'New';
    $button_text_preview_single = 'Preview';
    $button_text_save_single = 'Save';
    $button_text_set_backup = 'Create Backup';
    $button_text_get_backup = 'Restore Backup';
     
    global $mcw_uniquename_tooltip;
    
    //backup Additions
    $element_help_text_backup = 'mcw_backup_helptext';
    $element_help_text_debug = 'mcw_debug_helptext';
    $description_backup = 'You can save or restore a backup of your widgets. ("'.$button_text_get_backup.'" will overwrite current Widgets.)';
    $description_debug = 'Beta-Feature:<br> After activating the Debug-checkbox you will be able to see your widget splitted into code pieces, when using the preview functionality (<img src="'.MCW_get_url('preview').'">).<br>'.
      'This can help to find mistakes inside of your code. A split will be done whenever html-code changes to php-code and vice versa.<br><br>'.
      'Known issues: <ul>'.
        '<li>The debugger is not able to handle "if" statements in combination with HTML-code.</li>'.
        '<li>Debugger will interpret each "&lt;?php" and "?&gt;" as a php-tag.</li>'.
      '</ul>'; 
    
    // initialize technical variables 
    unset($cache_widget);
    
    $meta = MCW_get_meta();
    if ($meta['initial']){
      $meta['initial'] = false;
      MCW_set_meta($meta);
    }

    
    if ($_POST[$hidden_field_submit] != 'Y' ) {
      $cache_all_widgets=MCW_get_all_widgets();

      $my_options = MCW_get_option();
      $options_are_empty = empty($my_options);
      if ($options_are_empty) {
        $my_options = MCW_get_default_options();
        MCW_set_options($my_options);
        echo '<div id="message" class="updated fade"><p>Options have not been configured, yet. <br>Default values have been loaded. Click <a href="'.get_option('siteurl').'/wp-admin/options-general.php?page='.MCW_get_mainfile_name().'">here &raquo;</a> to configure plugin.</p></div>';
      }     
    } else {
    
/******************/    
/*** set backup ***/
/******************/

      if ($_POST[$element_widget_backup]==$button_text_set_backup) {
        if ( $_POST[ $data_widget_backup ] != $data_widget_backup ) {
          echo '<div id="message" class="updated fade"><p>To save backup you have to check the Backup-Checkbox as well.</p></div>';
        } else {
          $cache_all_widgets=MCW_get_all_widgets();
          MCW_set_widget_backup($cache_all_widgets);
          $max = count($cache_all_widgets);
          echo '<div id="message" class="updated fade"><p>Backup stored successfully.</p></div>';
        }
      } 

/***********************/    
/*** fill cache data ***/
/***********************/ 
      $cache_widget = array('name'       => MCW_make_name_acceptable(trim($_POST[$data_widget_name])),
                            'code'       => $_POST[$data_widget_code], 
                            'kind'       => $_POST[$data_widget_kind],
                            'title'      => $_POST[$data_widget_title], 
                            'filter'     => $_POST[$data_widget_filter], 
                            'beforecode' => $_POST[$data_widget_code.'_before'],
                            'foreign_id' => $_POST[$data_foreign_widget_id]);

      $max = count(MCW_get_all_widget_IDs());
      $help_deleted_flag=0;
      unset($cache_all_widgets);
      for ( $i = 0; $i < $max; ++$i ) {
        //reduce cache count if entry was deleted    
        $help_widget = MCW_get_mywidget_by_index($i-$help_deleted_flag);
        $help_widget = array('name'       => $help_widget['name'],
                             'code'       => $_POST[$data_widget_code.$i], 
                             'kind'       => $_POST[$data_widget_kind.$i],
                             'title'      => $_POST[$data_widget_title.$i], 
                             'filter'     => $_POST[$data_widget_filter.$i], 
                             'beforecode' => $_POST[$data_widget_code.$i.'_before'],
                             'foreign_id' => $_POST[$data_foreign_widget_id.$i]);                         
/**********************/    
/*** delete entries ***/
/**********************/ 
        if ($_POST[$element_widget_submit.$i]==$button_text_delete_single) {
          $error_message = MCW_delete_mywidget($i);
          
          if ($error_message <> ''){
            ?>
            <div id="message" class="error">
              <p><b><?php echo $error_message; ?></b></p>
            </div> 
            <?php
          }
          
          $help_deleted_flag++;
          // do not take entry into cache_all_widgets
          ?>
          <div id="message" class="updated fade">
            <p>
              <strong>
                <?php echo 'Widget "'.$help_widget['name'].'" has been deleted.'; ?>
              </strong>
            </p>
          </div>
          <?php          
        } else {        
          if ($_POST[$element_widget_submit.$i]==$button_text_save_single) {
/*************************/ 
/*** save single entry ***/
/*************************/
            $error_message = MCW_set_mywidget($help_widget);
            if ($error_message <> ''){
            ?>
            <div id="message" class="error">
              <p><b><?php echo $error_message; ?></b></p>
            </div> 
            <?php
            }
            ?>
            <div id="message" class="updated fade">
              <p><b>Widget "<?php echo $help_widget['name']; ?>" has been saved.</b></p>
            </div> 
            <?php
                     
          }
          // insert widget into cache
          $cache_all_widgets[]=$help_widget;
        }
      }
      
/**********************/    
/*** restore backup ***/
/**********************/
      
      if ($_POST[$element_widget_backup]==$button_text_get_backup){
        if ( $_POST[ $data_widget_backup ] != $data_widget_backup ) {
          echo '<div id="message" class="updated fade"><p>To restore backup you have to check the Backup-Checkbox as well.</p></div>';
        } else {
          //$cache_all_widgets=MCW_get_widget_backup();
          //MCW_set_allwidgets($cache_all_widgets);
          $error_message = MCW_restore_widget_backup();
          
          if (is_numeric($error_message)){
            $max = $error_message;
            echo '<div id="message" class="updated fade"><p>'.$error_message.' Widgets restored from Backup.</p></div>';
          } else {
            ?>
            <div id="message" class="error">
              <p><b><?php echo $error_message; ?></b></p>
            </div> 
            <?php
          }
          
          $cache_all_widgets = MCW_get_all_widgets();
          
        }
      }
      
/************************/    
/*** save all entries ***/
/************************/
      if ($_POST[$element_widget_submit]==$button_text_save_all){
        //$cache_widget = array();
        if (empty($cache_all_widgets)){
          ?>
          <div id="message" class="updated fade">
            <p>
              <strong>
                <?php echo 'There is no widget. Therefore nothing was saved.'; ?>
              </strong>
            </p>
          </div>
          <?php 
        } else {
          $error_message = MCW_set_allwidgets($cache_all_widgets);
          
          if ($error_message <> ''){
            ?>
            <div id="message" class="error">
              <p><b><?php echo $error_message; ?></b></p>
            </div> 
            <?php
          }
          
          //$cache_all_widgets=MCW_get_all_widgets();
          ?>
          <div id="message" class="updated fade">
            <p>
              <strong>
                <?php
                if ($max <= 1) echo $max.' Widget has been saved.'; 
                else echo $max.' Widgets have been saved.'; 
                ?>
              </strong>
            </p>
          </div>
          <?php 
        }
      }

/************************/    
/*** create new entry ***/
/************************/
      if( $_POST[ $element_widget_submit ] == $button_text_new_single ) {
        if ($cache_widget['name'] == ""){
          echo '<div class="error"><p><b>Please enter a unique name for your custom-widget!</b></p></div>';
        } else {
          if (MCW_widget_already_exist($cache_widget['name'])){
            echo '<div class="error"><p><b>Widget-ID allready exist!</b></p></div>';
          } else {
            $error_message = MCW_add_mywidget($cache_widget);
            
            if ($error_message <> ''){
            ?>
              <div id="message" class="error">
                <p><b><?php echo $error_message; ?></b></p>
              </div> 
            <?php
            }
            
            $cache_all_widgets[] = $cache_widget;
            $cache_all_widgets = MCW_sort_my_elements($cache_all_widgets, 'name');
            echo '<div id="message" class="updated fade"><p><strong>New custom-widget "'.$cache_widget['name'].'" created.</strong></p></div>';          
            $help_plausi_failed=MCW_plausibility_check($cache_widget);
            if ($help_plausi_failed){
              echo '<div id="'.$element_widget_warning.'" class="error" ><p><b>Code did not pass the plausibility check. Please review your code!</b> <br><i>('.$help_plausi_failed.')</i></p></div>';
            }
            $cache_widget = array();
          }        
        }
      }
    }
    


$backup_available = MCW_get_widget_backup(); 
//print_r($backup_available); 
$backup_available = !(empty($backup_available[0]));
$javascript_is_allowed = MCW_get_option('allow_js');

if (empty($cache_widget)){
  $cache_widget['filter'] = array('all' => 1); //hopefully filter "all" does exist
  $cache_widget['kind'] = MCW_get_option('std_kind');
}	

?>


<!-- display existing widgets -->

<?php if ($javascript_is_allowed){ 
  echo '<script type="text/javascript" src="'.MCW_get_url('js_1').'"></script>';
  echo '<script type="text/javascript" src="'.MCW_get_url('js_2').'"></script>';
  echo '<script type="text/javascript" src="'.MCW_get_url('js_tooltip').'"></script>'; // thanks to http://www.walterzorn.de/tooltip/tooltip.htm
?>

<script type="text/javascript">
<!--
function mcw_submit_form(id, action){
  document.forms["form_mycustomwidget"].elements["<?php echo $element_widget_submit; ?>"+id].value = action;
  document.forms["form_mycustomwidget"].submit();
} 
//-->
</script>
<?php } ?>
  
  <div class="wrap">
    <h2>Edit My Custom Widgets</h2>
    <fieldset class="options">
      <h3> My Custom Widgets</h3>
      <form name="form_mycustomwidget" method="post" action="<?php echo str_replace( '%7E', '~', $_SERVER['REQUEST_URI']); ?>">
        <table class="mcw_option_table" width="100%"  border="1" cellspacing="3" cellpadding="3">
          <?php
          $max = count($cache_all_widgets);
          ?>
          <tr valign="top">
				    <th align="left" width="0%">
              Unique name (<?php echo $max?>)
            </th>
            <?php if ($javascript_is_allowed){ ?>
              <th align="left" width="0%">&nbsp;
              </th>
            <?php } ?>
            <th align="left" width="100%">
              Content
            </th>
  				  <th align="right" width="0%">
  				    Process
         	  </th>
			    </tr>
			    <?php
          if (!empty($cache_all_widgets)){ 
            for ( $i = 0; $i < $max; ++$i ) {
              $help_widget=$cache_all_widgets[$i];
          ?>
  		        <tr valign="center">
				        <th align="left" width="0%">
                  <?php echo $help_widget['name']; ?>
                </th>
                <?php if ($javascript_is_allowed){ ?>
                  <th align="left" width="0%">
                    <a href="#" title="Edit Widget">
                      <img src="<?php echo MCW_get_url('edit'); ?>" onClick="Effect.toggle('<?php echo $element_widget_container.$i; ?>', 'slide', {duration:0.5}); return true;">
                    </a>
                  </th>
                <?php } ?>
        	      <td align="left" width="100%">
                  <?php $help_plausi_failed=MCW_plausibility_check($help_widget); ?>
                  <?php 
                  if ($help_plausi_failed){
                    echo '<div id="'.$element_widget_warning.$i.'" class="mcw_error" onClick="Effect.toggle(\''.$element_widget_container.$i.'\', \'slide\', {duration:0.5});return true;"><p><b>Code did not pass the plausibility check. Please review!</b> <br><i>('.$help_plausi_failed.')</i></p></div>';
                  } 
                  ?>
                  <div id="<?php echo $element_widget_container.$i; ?>" style="display:<?php if ($javascript_is_allowed){ echo 'none'; } else { echo 'block';} ?>;">
                    <?php MCW_get_widget_maintenance($help_widget, $mcw_elements, $i); ?>
                  </div>
        	      </td>
                <td align="center" align="center" width="0%">
                  <nobr>
                    <?php if ($javascript_is_allowed){ ?>
                      <a href="#" title="Save Widget">
                        <img src="<?php echo MCW_get_url('save'); ?>" onClick="mcw_submit_form('<?php echo $i; ?>', '<?php echo $button_text_save_single; ?>');return true;">
                      </a>
                      <a href="#" title="Show Widget">
                        <img src="<?php echo MCW_get_url('preview'); ?>" onClick="mcw_submit_form('<?php echo $i; ?>', '<?php echo $button_text_preview_single; ?>');return true;">
                      </a>
                      <a href="#" title="Delete Widget">
                        <img src="<?php echo MCW_get_url('remove'); ?>" onClick="mcw_submit_form('<?php echo $i; ?>', '<?php echo $button_text_delete_single; ?>');return true;">
                      </a>
                      <input type="hidden" name="<?php echo $element_widget_submit.$i; ?>" value="">
                    <?php } else { ?>
  				            <input type="submit" src="<?php echo MCW_get_url('save'); ?>" title="<?php echo $button_text_save_single; ?>" alt="show" name="<?php echo $element_widget_submit.$i; ?>"  value="<?php echo $button_text_save_single; ?>">
                      <input type="submit" src="<?php echo MCW_get_url('preview'); ?>" title="<?php echo $button_text_preview_single; ?>" alt="show" name="<?php echo $element_widget_submit.$i; ?>"  value="<?php echo $button_text_preview_single; ?>">
                      <input type="submit" src="<?php echo MCW_get_url('remove'); ?>" title="<?php echo $button_text_delete_single; ?>" alt="-" name="<?php echo $element_widget_submit.$i; ?>"  value="<?php echo $button_text_delete_single; ?>">            
                    <?php } ?>
                  </nobr>
        	      </td>
			        </tr>          
            <?php } ?>
          <?php } ?>
          <tr valign="center">
            <th align="left" width="0%">
              <input class="input" onmouseover="Tip('<?php echo $mcw_uniquename_tooltip; ?>')" onmouseout="UnTip()" type="text" name="<?php echo $data_widget_name; ?>" value="<?php echo $cache_widget['name']; ?>" size="20">
            </th>
            <?php if ($javascript_is_allowed){ ?>
              <th align="left" width="0%">
                <a href="#" title="Edit Widget">
                  <img src="<?php echo MCW_get_url('edit'); ?>" onClick="Effect.toggle('<?php echo $element_widget_container; ?>', 'slide', {duration:0.5}); return true;">
                </a>
              </th>
            <?php } ?>
            <td align="left" width="100%">&nbsp;              
              <div id="<?php echo $element_widget_container; ?>" style="display:none;">
                <?php MCW_get_widget_maintenance($cache_widget, $mcw_elements); ?>
              </div>
            </td>
				    <td align="center" valign="center" width="0%">
				      <?php if ($javascript_is_allowed){ ?>
                <a href="#" title="Add Widget">
                  <img src="<?php echo MCW_get_url('add'); ?>" onClick="mcw_submit_form('', '<?php echo $button_text_new_single; ?>');return true;">
                </a>
                <input type="hidden" name="<?php echo $element_widget_submit; ?>" value="">
              <?php } else { ?>
   		          <input type="submit" alt="Add" name="<?php echo $element_widget_submit; ?>"  value="<?php echo $button_text_new_single; ?>">
              <?php } ?>
            </td>
			    </tr>
        </table>
        <div width="100%" align="right">
          to add widgets to sidebar <a href="<?php echo get_option('siteurl'); ?>/wp-admin/widgets.php">click here &raquo;</a>
        </div>
        <p class="submit">
				  <?php if ($javascript_is_allowed){ ?>
            <div align="left">
              <a href="#" onClick="mcw_submit_form('', '<?php echo $button_text_save_all; ?>');return true;">
                <img src="<?php echo MCW_get_url('save'); ?>"> Save All
              </a>
            </div>
          <?php } else { ?>
   		      <div align="left">
              <input type="submit" alt="Save All" name="<?php echo $element_widget_submit; ?>" value="<?php echo $button_text_save_all; ?>">
            </div>
          <?php } ?>       
          <div align="left">
            <input type="hidden" name="<?php echo $hidden_field_submit; ?>" value="Y">
          </div>
		    </p>
		    
		    <p class="submit">
		      <h3>Administration</h3>
          <table class="mcw_config_table" width="100%"  border="1" cellspacing="3" cellpadding="3">
          <!-- Backup -->          
            <tr>
              <th align="left" width="20%">
                <label for="<?php echo $data_options_backup; ?>">
                  <input type="checkbox" id="<?php echo $data_widget_backup; ?>" name="<?php echo $data_widget_backup; ?>" value="<?php echo $data_widget_backup; ?>"> Backup
                </label>
              </th>
              <td align="left" width="80%">
                <input type="submit" name="<?php echo $element_widget_backup; ?>" value="<?php echo $button_text_set_backup; ?>">
                <?php if ($backup_available) { ?>
                  <input type="submit" name="<?php echo $element_widget_backup; ?>" value="<?php echo $button_text_get_backup; ?>">
                <?php } ?>  
                <div id="<?php echo $element_help_text_backup; ?>" style="display:none;">
                  <div id="message" class="mcw_updated">
                    <p>
                      <b>
                        <?php echo $description_backup; ?>
                      </b>
                    </p>
                  </div>
                </div>
              </td>
              <?php if ($javascript_is_allowed){ ?>
                <td valign="center" align="center" width="0%">
                  <a href="#<?php echo $element_help_text_backup; ?>" title="Info"><img src="<?php echo MCW_get_url('info'); ?>" onClick="Effect.toggle('<?php echo $element_help_text_backup; ?>', 'slide', {duration:0.5}); return false;"></a>
                </td>
              <?php } ?>
            </tr>
          <!-- Debugging --> 
            <tr>
              <th align="left" width="20%">
                <label for="<?php echo $data_debug_activate; ?>">
                  <input type="checkbox" id="<?php echo $data_debug_activate; ?>" name="<?php echo $data_debug_activate; ?>" value="<?php echo $data_debug_activate; ?>"> Debug-Mode
                </label>
              </th>
              <td align="left" width="80%">
                <div id="<?php echo $element_help_text_debug; ?>" style="display:none;">
                  <div id="message" class="mcw_updated">
                    <b>
                      <?php echo $description_debug; ?>
                    </b>
                  </div>
                </div>
              </td>
              <?php if ($javascript_is_allowed){ ?>
                <td valign="center" align="center" width="0%">
                  <a href="#<?php echo $element_help_text_debug; ?>" title="Info"><img src="<?php echo MCW_get_url('info'); ?>" onClick="Effect.toggle('<?php echo $element_help_text_debug; ?>', 'slide', {duration:0.5}); return false;"></a>
                </td>
              <?php } ?>
            </tr> 
          </table>
        </p>
      </form> 
    </fieldset>
    <div width="100%" align="right">
      for plugin options <a href="<?php echo get_option('siteurl'); ?>/wp-admin/options-general.php?page=<?php echo MCW_get_mainfile_name(); ?>">click here &raquo;</a><br>
    </div>
  </div> 
  
<?php
  if ($_POST[$hidden_field_submit] == 'Y' ) {
    for ( $i = 0; $i < $max; ++$i ) {
      if ($_POST[$element_widget_submit.$i]==$button_text_preview_single) {
        if ($_POST[$data_debug_activate]==$data_debug_activate){
          $args = array('i' => $i, 'name' => $cache_all_widgets[$i]['name'], 'force_eval' => true, 'debug_mode' => true);
        } else {
          $args = array('i' => $i, 'name' => $cache_all_widgets[$i]['name'], 'force_eval' => true, 'debug_mode' => false);
        }
        echo '<div class="wrap"><h2>Preview of widget "'.$cache_all_widgets[$i]['name'].'"</h2><fieldset class="options"><legend>Look can differ because of different StyleSheets.<div class="mcw_preview">';

        MCW_eval_code($args);
        echo '</legend></fieldset></div></div>';
      }
    }
  }
 ?>
 

      
        