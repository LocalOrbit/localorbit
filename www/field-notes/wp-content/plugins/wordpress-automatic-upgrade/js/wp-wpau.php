<?php 
	require_once("../../../../wp-config.php");
if (!function_exists("wp_automatic_upgrade")) { die("Sorry"); }

if (isset($_POST['task'])) {
	switch($_POST['task']) {
	case 1:
		if (wpau_backup_files(true)) { echo "true"; } else { echo "false"; }
		break;
	case 2:
		if (wpau_backup_db(true)) {  echo "true";  }  else {  echo "false";  }
		break;
	case 3:
		if (wpau_get_latest_version(true)) { echo "true"; } else { echo "false"; }
		break;
	case 4:
		if (wpau_deactivate_plugins(true)) { echo "true"; } else { echo "false"; }
		break;
	case 5:
		if (wpau_site_down(true)) { echo "true"; } else { echo "false"; }
		break;
	case 6:
		if (wpau_upgrade_installation(true)) { echo "true"; } else { echo "false"; }
		break;
	case 7:
		if (wpau_show_reactivate_plugins(true)) { }//echo "true"; } else { echo "false"; }
		break;
	case 8:
		if (wpau_show_backup_log(true)) { echo "true"; } else { echo "false"; }
		break;
	}
}
?>
