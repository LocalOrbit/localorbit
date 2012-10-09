<?php
/*WP Ajax Edit Script
--Created by Ronald Huereca/Keith Dsouza
--Created on: 07/14/2007
--Last modified on: 07/14/2007
--Relies on jQuery
*/
	require_once("../../../../wp-config.php");
?>
jQuery(document).ready(function(){
   wpauAutomaticUpgrade.init();

});
var wpauAutomaticUpgrade = function() {
	var $j = jQuery;
	var PluginUrl = "<?php bloginfo('wpurl') ?>/wp-content/plugins/wordpress-automatic-upgrade";
	var BackupUrl = "<?php bloginfo('wpurl') ?>/wpau-backup/";
	var FileBakName = "wpau-files-bak.zip";
	var DbBakName = "wpau-db-backup.zip";
	var statusBar = $j("#wpau-status-bar");
	var statusMessage = $j("#wpau-status-message");
	var status = 0;

	function linkSetup() {
		$j("#wpau-automated").bind("click", function() { step1(); return false; });
	}
	//Number to set the status bar to (0-100)
	function setStatus(number) {
		$j("#wpau-status-bar").css({height: "10px", border: "1px solid #000", width: "70%"});
		$j("#wpau-status-bar-indicator").css({float: "left", height: "100%", background: "#191970", width: number + "%"});
	}
	function setStatusBar(msg) {
		$j("#wpau-status-message").html("<p>" + msg + "</p>");
	}

	function setFileDownload() {
		//$j("#wpau-file-download").html("<p><a href='" + BackupUrl + FileBakName + "'>DOWNLOAD</a> Backup files.</p>");
	}

	function showUpgradeLink() {
		//$j("#wpau-update-db").html("<p>Please do not forget to <a href='<?php bloginfo('wpurl') ?>/wp-admin/upgrade.php' target='_blank'>UPGRADE Wordpress DB</a></p>");
	}

	function setDbDownload() {
		//$j("#wpau-db-download").html("<p><a href='" + BackupUrl + DbBakName + "'>DOWNLOAD</a> Database backup</p>");
	}

	function step1() {
		msg = "<strong>Current Step</strong> -> Backing up your original wordpress files";
		setStatusBar(msg);
		setStatus(0);
		$j.ajax({
			type: "post",
			url: PluginUrl + '/js/wp-wpau.php',
			timeout: 30000,
			data: {
				task: 1},
			success: function(msg) { step1Complete(msg); },
			error: function(msg) { step1Failure(msg); }
		})
	}

	function step1Complete(msg) { //WordPress files backup
		if (msg == "true") {
			msg = "Backed up your WordPress files. <br /><strong>Current Step</strong> -> Backing up your database files";
			setStatusBar(msg);
			setStatus(10);
			$j.ajax({
			type: "post",
			url: PluginUrl + '/js/wp-wpau.php',
			timeout: 30000,
			data: {
				task: 2},
			success: function(msg) { step2Complete(msg); },
			error: function(msg) { step2Failure(msg); }
		})
		} else {
			msg = "Could not backup your WordPress files.  Failed at Step 1.";
			setStatusBar(msg);
		}
	}
	function step1Failure(msg) {
		alert("Step 1 Failed");
	}
	function step2Complete(msg) { //database backup
		if (msg == "true") {
			msg = "The database has been succesfully backed up. <br /><strong>Current Step</strong> -> Downloading the WP Latest Install.  Please be patient as this process may take between 15 - 300 seconds.";
			setFileDownload();
			setStatusBar(msg);
			setStatus(20);
			$j.ajax({
			type: "post",
			url: PluginUrl + '/js/wp-wpau.php',
			timeout: 300000,
			data: {
				task: 3},
			success: function(msg) { step3Complete(msg); },
			error: function(msg) { step3Failure(msg); }
		});
			//setStatusBar("");
		} else {
			msg = "Database files could not be backed up.  Failed at Step 2.";
			setStatusBar(msg);
		}
	}

	function step2Failure(msg) {
		alert("Step 2 Failed");
	}
	function step3Complete(msg) { //wp download
		if (msg == "true") {
			msg = "Successfully downloaded and unzipped all WordPress files. <br /><strong>Current Step</strong> -> De-activating all your plugins";
			setDbDownload();
			setStatusBar(msg);
			setStatus(30);
			$j.ajax({
			type: "post",
			url: PluginUrl + '/js/wp-wpau.php',
			timeout: 15000,
			data: {
				task: 4},
			success: function(msg) { step4Complete(msg); },
			error: function(msg) { step4Failure(msg); }
		})
		} else {
			msg = "Could not successfully get the latest WordPress installation.  Failed at Step 3.";
			setStatusBar(msg);
		}
	}

	function step3Failure(msg) {
		alert("Step 3 Failed");
	}
	function step4Complete(msg) { //WordPress plugin deactivation
		if (msg == "true") {
			msg = "Successfully deactivated your plugins. <br /><strong>Current Step</strong> -> Putting the site into maintenance mode.";
			setStatusBar(msg);
		} else {
			msg = "Could not deactivate your plugins.  Failed at Step 4..";
			setStatusBar(msg);
		}
		setStatus(40);
		$j.ajax({
			type: "post",
			url: PluginUrl + '/js/wp-wpau.php',
			timeout: 15000,
			data: {
				task: 5},
			success: function(msg) { step5Complete(msg); },
			error: function(msg) { step5Failure(msg); }
		})
	}

	function step4Failure(msg) {
		alert("Step 4 Failed");
	}
	function step5Complete(msg) { //wp maintenance mode
		if (msg == "true") {
			msg = "Successfully activated maintenance mode for your site. <br /><strong>Current Step</strong> -> Upgrading your installation files.";
			setStatusBar(msg);
			setStatus(50);
			$j.ajax({
			type: "post",
			url: PluginUrl + '/js/wp-wpau.php',
			timeout: 300000,
			data: {
				task: 6},
			success: function(msg) { step6Complete(msg); },
			error: function(msg) { step6Failure(msg); }
		})
		} else {
			msg = "Could not initiate maintenance mode.";
			setStatusBar(msg);
		}
	}

	function step5Failure(msg) {
		alert("Step 5 Failed");
	}
	
	function step6Complete(msg) { //Upgrading Your files
		if (msg == "true") {
			msg = "Upgraded Your Files. <br /><strong>Current Step</strong> -> Reactivate all your plugins";
			showUpgradeLink();
			setStatusBar(msg);
			setStatus(80);
			$j.ajax({
			type: "post",
			url: PluginUrl + '/js/wp-wpau.php',
			timeout: 180000,
			data: {
				task: 7},
			success: function(msg) { step7Complete(msg); },
			error: function(msg) { step7Failure(msg); }
		})
		} else {
			msg = "Could not upgrade your files.";
			setStatusBar(msg);
		}
	}

	function step6Failure(msg) {
		alert("Step 6 Failed");
	}

		function step7Complete(msg) { //Show Log
			setStatusBar(msg);
			setStatus(100);
		}
	
		function step7Failure(msg) {
			alert("Step 8 Failed");
		}
	function step7oldComplete(msg) {
		if (msg == "true") {
			msg = "Successfully reactivated your plugins. <br /><strong>Current Step</strong> -> Shows you upgradation logs.";
			setStatusBar(msg);
			setStatus(80);
			$j.ajax({
			type: "post",
			url: PluginUrl + '/js/wp-wpau.php',
			timeout: 15000,
			data: {
				task: 8},
			success: function(msg) { step8Complete(msg); },
			error: function(msg) { step8Failure(msg); }
		})
		} else {
			msg = "Could not upgrade the database.";
			setStatusBar(msg);
		}
	}

	function step7Failure(msg) {
		alert("Step 7 Failed");
	}

	function step8Complete(msg) { //Show Log
		setStatusBar(msg);
			setStatus(100);
	}

	function step8Failure(msg) {
		alert("Step 9 Failed");
	}
	return {
			init : function() { //AKA the constructor - Plugin authors can tap into the plugin by calling AjaxEditComments.init()
				linkSetup();
			}
	};

}();