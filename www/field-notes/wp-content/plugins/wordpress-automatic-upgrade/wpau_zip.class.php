<?php
/*
ZIp functionality class for wordpress automatic upgrades
*/

//require_once('lib/pclzip.lib.php');
class wpauZipFuncs extends wpauHelper {
	var $archiveName;
	var $fileName;
	var $isFileWritten;
	var $absPath;
	var $absNewPath;
	var $backupPath;
	var $slash;
	var $files;
	var $archiver;
	var $includeDirs;
	var $backupDir;
	var $includeExtensions;
	var $ignoreFiles;

	function wpauZipFuncs($absPath, $isNix, $archiveName, $backupDir, $includeDirs, $archiveExt = '.zip') {
		$this->isFileWritten = false;
		$this->backupDir = $backupDir;
		$this->files = array();
		$this->absPath = $absPath;
		$this->ignoreFiles = array('wp-config.php', 'wp-config-sample.php');
		$this->absNewPath = substr($this->absPath, 0, -1);
		$this->includeDirs = $includeDirs;
		$this->includeExtensions = array('php', 'txt', 'htm', 'html', 'js', 'css', 'jpg', 'png', 'gif'); // the extensions we need to backup

		if($isNix)
			$this->slash = "/";
		else
			$this->slash = "\\";

		$this->backupPath = $this->absPath . $this->slash . $backupDir;

		//create the backup directory if it does not exist
		if(is_dir($this->backupPath)) {
			//nada
		}
		else {
			$backdir = @mkdir($this->backupPath);
			$this->createIndexes();
			@closedir($this->backupPath);
		}
		$this->archiveName = $this->backupPath. $this->slash. $archiveName . $archiveExt;
		$this->fileName = $archiveName . '-' . $this->random() . $archiveExt;
		$_SESSION['filesbakname'] = $this->fileName;
    	if(! class_exists('PclZip')) {
		  require_once('lib/pclzip.lib.php');
	  	}
		$this->archiver = new PclZip(trailingslashit($this->backupPath) . $this->fileName);
		$this->logMessage('<br /><br /><br /><strong>Creating</strong> files backup archive at '.$this->fileName.'<br /><br /><br />');
	}

	/** creates a archive based on current object **/
	function createArchive() {
		if( ! current_user_can('edit_files')) {
			echo 'Oops sorry you are not authorized to do this';
			return false;
		}
		$parentDir = $this->absNewPath;
		/*
		* We only backup essential directories and only extensions required
		*/
		//create the main dir
		$this->logMessage('Archiving the main folder located at '. $parentDir.'<br />');
		$this->archiveDir($parentDir, $parentDir, $parentDir, false);

		//only run for wp-admin and wp-includes
		foreach($this->includeDirs as $dirs) {
			$this->logMessage('Archiving the folder '. $parentDir.' recursively including sub directories<br >');
			$this->archiveDir($parentDir . $this->slash. $dirs, $parentDir . $this->slash. $dirs, $parentDir . $this->slash. $dirs, true);
		}
		$this->writeToDisk();
	} //end createArchive

	function writeToDisk() {
		$v_list = $this->archiver->create($this->files);
		if ($v_list == 0) {
		$this->logMessage('Could not archive the files ' .$this->archiver->errorInfo(true));
		//$this->logMessage('Could not archive the files ');
		 $this->isFileWritten = false;
  	}
		else {
			$this->logMessage('<br /><strong>Succesfully Created </strong>files backup archive at '. $this->archiveName .'<br /><br />');
			if(is_file($this->archiveName)) {
				@chmod($this->archiveName, 0646);
			}
			$this->isFileWritten = true;
		}
	} //end writeToDisk

	function archiveDir($start, $dirName, $zipPath, $addSubDir = false){
	    $basename = pathinfo($start);
	    $basename = $basename['basename'];
	    $ls=array();
	    $dir = dir($start);
	    while($item = $dir->read()) {
        	if(($item != "." && $item != ".." && is_dir($start. $this->slash .$item)) && $addSubDir) {
			$this->archiveDir($start. $this->slash. $item, $start . $this->slash . $item, $zipPath . $this->slash . $item);
        	}
		else{
	            if( ( $item!="."&&$item!=".." ) && ( ! is_dir($start. $this->slash .$item) ) && ($this->checkIncludeFile($item)) ) {
			array_push($this->files, $dirName . $this->slash . $item);
			$this->logMessage('Adding File '.$dirName.$this->slash.$item.' to '.$zipPath.$this->slash.$item.'<br />');
            	}
           }
         }
        }  //end archiveDir


	function checkIncludeFile($filename) {
		$pathinfo = pathinfo($filename);
		if(is_array($this->includeExtensions)) {
			if(in_array($filename, $this->ignoreFiles)) {
				return false;
			}
			if(in_array($pathinfo['extension'], $this->includeExtensions)) {
				return true;
			}
			else {
				return false;
			}
		}
	}
}

?>