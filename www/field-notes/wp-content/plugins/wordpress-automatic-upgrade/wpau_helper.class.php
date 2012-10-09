<?php
/**
 Wordpress Automatic upgrades helper class
 Helps sub classes log all data
 Helps to update db with logs
 Helps to run miscelleaneous functions
 **/

/*global $wp_version;
if($_REQUEST['action'] != 'upgrade-plugin' && $wp_version <= 2.6) {
	if(! class_exists('PclZip')) {
		require_once('lib/pclzip.lib.php');
	}
}*/

require_once('lib/snoopy.class.php');

if(! function_exists('ftp_base')) {
	require_once('lib/ftp_class.php');
}

class wpauHelper {
	var $loggedData;
	var $errorData;
	var $errorFlag;
	var $fatalError; // if its flagged as a fatal error we cannot continue with further process

	function wpauHelper() {
		$this->loggedData = '';
		$this->errorData = '';
		$this->errorFlag = false;
		$this->fatalError = false;
	}

	/** log messages **/
	function logMessage($logText) {
		$this->loggedData .= $logText;
	}

	function logError($logError, $fatalError = false) {
		$this->errorFlag = true;
		$this->fatalError .= $fatalError;
		$this->errorData .= $logErrort;
	}

	/** create a random name **/
	function random() {
		$chars = "abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ023456789";
		srand((double)microtime()*1000000);
		$i = 0;
		$rand = '' ;

		while ($i <= 7) {
			$num = rand() % 33;
			$tmp = substr($chars, $num, 1);
			$rand = $rand . $tmp;
			$i++;
		}
		return $rand;
	}

	function writeLogToDisk($filePath, $fileName, $fileData) {
		$filePath = trailingslashit($filePath);
		if(@file_exists($filePath . $fileName))  @unlink($filePath . $fileName);
		$fileHandle = @fopen($filePath . $fileName, 'w');
		if(@fwrite($fileHandle, $fileData) === false) {
			echo '<br>Some error while writing the log file<br>';
			return false;
		}
		else {
			@fclose($fileHandle);
			return true;
		}
	}

	function createIndexes() {
		$indexFile = trailingslashit(ABSPATH.'wpau-backup') . 'index.html';
		$indexFile1 = trailingslashit(ABSPATH.'wpau-backup') . 'index.php';
		if(!file_exists($indexFile)) {
			if (!$handle = fopen($indexFile, 'w')) {
				echo "Cannot open file ($indexFile). Please create a empty $indexFile file manually";
			}
			else {
				fclose($handle);
				chmod($indexFile, 0755);
			}
		}

		if(!file_exists($indexFile1)) {
			if (!$handle = fopen($indexFile1, 'w')) {
				echo "Cannot open file ($indexFile1).  Please create a empty $indexFile file manually";
			}
			else {
				fclose($handle);
				chmod($indexFile1, 0755);
			}
		}
	}

}

?>
