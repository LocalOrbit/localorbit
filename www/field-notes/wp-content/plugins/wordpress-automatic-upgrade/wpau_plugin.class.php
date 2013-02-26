<?php
/*
PLugin helper class backups plugins stores in it in the db

Can't use oops man as php4 does not support it and most sites
run on php4

*/

class wpauPluginHandler extends wpauHelper {

	//this class depends on it so we need the activated plugins first
	var $pluginArray;
	/**
	the constructor
	takes the current activated plugins as an array
	**/
	function wpauPluginHandler($pluginArray) {
		$this->pluginArray = $pluginArray;
	}

	/*
		Loops thorugh all the plugins and de-activates all those
		Removes this plugin from the list as further task depend
		on this
	*/
	function deActivatePlugins() {
		if(! $this->pluginArray) {
			return 'No calls to the class without calling the constructor';
		}

		if(!current_user_can('edit_plugins')) {
			echo 'Oops sorry you are not authorized to do this';
			return false;
		}
		//remove our plugin from the list or else it will get deactivated too
		array_splice($this->pluginArray, array_search(WPAU_PLUGIN, $this->pluginArray), 1 );
		if(count($this->pluginArray) == 0)
			$this->logMessage('There are no plugins for de-activation');

		foreach($this->pluginArray as $plugin) {
			$this->deActivatePlugin($plugin);
		}
		return true;
	}

	/*
		De-activate the plugin and log it to our DB table
		it will be used while re-activating
	*/
	function deActivatePlugin($plugin) {
			if(!current_user_can('edit_plugins')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
			}
			global $wpdb;
			$current = get_option('active_plugins');
			array_splice($current, array_search($plugin, $current), 1 ); // Array-fu!
			update_option('active_plugins', $current);
			do_action('deactivate_' . trim( '../' . $plugin ));
			$wpdb->query("Insert into ".WPAU_PLUGIN_TABLE." (plugin_name, plugin_status, plugin_deactive_response, plugin_reactive_response) values ('".$plugin."', 0, 1, 0)");
			$this->logMessage('Deactivated the plugin <strong>'.$plugin.'</strong> <br>');
	}

	/*
		get all info from the stored db and
		activate all the plugins
	*/
	function reActivatePlugins($automated = false) {
		if(!current_user_can('edit_plugins')) {
			echo 'Oops sorry you are not authorized to do this';
			return false;
		}
		global $wpdb;
		if(isset($_REQUEST['pluginid'])) {
			$fatalPluginId = $_REQUEST['pluginid'];
			$plugins = $wpdb->get_results("select plugin_name, plugin_reactive_response from ".WPAU_PLUGIN_TABLE." where id = ".intval($fatalPluginId));
			if(count($plugins) > 0)  {
				if(intval($plugins[0]->plugin_reactive_response) != 1) {
					$this->logMessage('<span style="color:red">The Plugin <strong>'.$plugins[0]->plugin_name.'</strong> could not be activated succesfully. You will need to activate it manually.</span><br>');
					$wpdb->query("UPDATE ".WPAU_PLUGIN_TABLE." set fatal_plugin = 1 where id = ".intval($fatalPluginId) );
				}
			}
		}
		$plugins = $wpdb->get_results("select id, plugin_name from ".WPAU_PLUGIN_TABLE." where plugin_status = 0 and plugin_deactive_response = 1 and fatal_plugin = 0");
		if(count($plugins) == 0)
			$this->logMessage('All the plugins were re-activated');
		foreach($plugins as $plugin) {
			if(strlen(trim($plugin->plugin_name)) > 0)
				$this->reActivatePlugin($plugin, $automated);
		}
		return true;
	}

	function reActivatePlugin($plugin, $automated) {
		if(!current_user_can('edit_plugins')) {
			echo 'Oops sorry you are not authorized to do this';
			return false;
		}
		global $wpdb;
		$current = get_option('active_plugins');
		$pluginfile = $plugin->plugin_name;
		$pluginid = $plugin->id;
		$path = "../";
		if ($automated) { $path = "../../"; }
		if ( wpau_validate_file($path.$pluginfile) ) {
			if ( ! file_exists(ABSPATH . PLUGINDIR . '/' . $pluginfile) ) {
				$this->logMessage('Plugin '.$pluginfile.' file does not exist');
			}
			else {
				if (!in_array($pluginfile, $current)) {
					ob_start();
					echo '<script language="JavaScript" type="text/javascript"> '.
					' window.location = "edit.php?page='.WPAU_PAGE.'&task=re-plugin&pluginid='.$plugin->id .'"' .
					'</script>';
					if($file_included = @include(ABSPATH . PLUGINDIR . '/' . $pluginfile))  {
						$current[] = $pluginfile;
						sort($current);
						update_option('active_plugins', $current);
						do_action('activate_' . $pluginfile);
						$wpdb->query("Update ".WPAU_PLUGIN_TABLE." set plugin_status = 1, plugin_reactive_response = 1 where id = $pluginid");
						$this->logMessage('Plugin <strong>'.$pluginfile.'</strong> was activated succesfully<br>');
					}
					else {
						$this->logMessage('<span style="color:red">Plugin <strong>'.$pluginfile.'</strong> could not be activated succesfully. You will need to activate it manually.</span><br>');
					}
					ob_end_clean();
				}
				else {
					$this->logMessage('Plugin <strong>'.$pluginfile.'</strong> is already activated<br>');
				}
			}
		}
		else {
			$this->logMessage('Could not validate the plugin <strong>'.$pluginfile.'</strong><br>');
			//TODO LOG REASONS FOR NOT VALIDATING
		}
	}

	/**
	* Function to de-activate all plugins
	**/
	function wpau_validate_file($file, $allowed_files = '') {
		if ( false !== strpos($file, './'))
			return 1;

		if (':' == substr($file,1,1))
			return 2;

		if ( !empty($allowed_files) && (! in_array($file, $allowed_files)) )
			return 3;

		return 0;
	}

}

?>