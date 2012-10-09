<?php
/*
Runs all the critical upgrade functions to upgrade the wordpress version

*/

class wpauUpgradeHelper extends wpauHelper {

	var $theDirToDoThings;
	var $absPath;
	var $slash;
	var $relativeSlash;
	var $zipName;
	var $extension;
	var $archiveName;
	var $relativePath;
	var $relativeArchiveName;
	var $includeDirs;
	var $ignoreFiles;
	var $backupDir;
	var $zipFileName;
	var $operationError;
	var $includeExtensions;

	function wpauUpgradeHelper($absPath, $isNix, $backupDir = 'wpau-backup', $relativePath = ABSPATH) {
		$this->absPath = $absPath; //the abs path to wordpress installation
		$this->backupDir = $backupDir;
		if($isNix)  //change slash if we are running on windows
			$this->slash = '/';
		else
			$this->slash = '\\';

		$this->includeDirs = array('wp-admin', 'wp-includes'); //the directories we have to upgrade
		$this->ignoreFiles = array('wp-config.php', 'wp-config-sample.php');
		$this->includeExtensions = array('php', 'txt', 'htm', 'html', 'js', 'css', 'jpg', 'png', 'gif');
		$this->relativeSlash = '/'; //relative is always this
		$this->theDirToDoThings = trailingslashit($this->absPath). $backupDir; //the dir where we gonna store all our stuff
		$this->zipName = 'wpau-latest'; // the name for the zip file
		$this->extension = '.zip'; // the extension for the zip file
		$this->zipFileName = $this->zipName . $this->extension; //the zip file name
		$this->archiveName = $this->theDirToDoThings . $this->slash. $this->zipFileName; //the path to the archive
		$this->relativePath = $relativePath; //relative path will be needed for the unzip process
		$this->relativeArchiveName = $this->relativePath . $this->relativeSlash . "wpau-backup". $this->relativeSlash . $this->zipFileName; //the archive paht for relative

		$this->operationError = false;

    if(! is_dir($this->theDirToDoThings)) {
			mkdir ($this->theDirToDoThings);
			$this->createIndexes();
		}

	}

	/**
	* Downloads the files from wordpress
	*/
	function getFilesFromWP($downFilePath) {
		@unlink($this->archiveName);
		set_time_limit ( 0 ) ;
		$this->logMessage('Starting to download the file from ' .$downFilePath . '<br />');
		//$filename = $this->theDirToDoThings . $this->slash. $this->zipName . '-' . $this->random() . $this->extension;
		if($this->download($downFilePath, $this->archiveName)) {
			if($this->unzip()) {
        return true;
			}
			else {
        return false;
			}
		}
		else {
			return false;
		}
	}

	function downloadFilesFromWP($startUrl, $fileName) {
		@unlink($this->archiveName);
		set_time_limit ( 0 ) ;
		$this->logMessage('Starting to download the file from ' .$downFilePath . '<br />');
		if($this->downloadFSock($startUrl, $fileName, $this->archiveName)) {
			if($this->unzip()) {
				return true;
			}
			else {
				return false;
			}
		}
		else {
			return false;
		}
	}

	/**
	* Reads uploaded files from users
	**/
	function getUploadedFilesFromUser($fileData) {
		if(isset($fileData)) {
			$pathinfo = pathinfo($fileData['thefile']['name']);
			if($this->validUploadedExtension($pathinfo['extension'])) {
				$this->logMessage('We got a valid file to be uploaded<br />');
				if($this->upload($fileData)) {
					if(is_file($this->relativeArchiveName)) {
						if($this->unzip()) {
							return true;
						}
					}
					else {
						return false;
					}
				}
				else {
					$this->logMessage('ERROR -> Could not upload the file to the directory<br />');
				}
			}
			else {
				$this->logMessage('ERROR -> The file you are trying to upload is not a valid file, please upload only zip or tar.gz files<br />');
				return false;
			}
		}
		else {
			$this->logMessage('ERROR -> You did not select any files to be uploaded<br />');
			return false;
		}
	}

	/**
	* Upgrades the file from downloaded location
	**/

	function upgradeFiles() {
		if( ! current_user_can('edit_files')) {
			echo 'Oops sorry you are not authorized to do this';
			return false;
		}
		set_time_limit(0);
		$theNewWPFiles = $this->theDirToDoThings . $this->slash . 'wordpress';
		if($upgradeFilesDir = @opendir($theNewWPFiles)) {
			@closedir($theNewWPFiles);
			chmod($theNewWPFiles, 0755);
			//first copy all the directory files
			foreach($this->includeDirs as $dir) {
				$this->copyFiles($this->theDirToDoThings . $this->slash . 'wordpress'. $this->slash. $dir, $this->absPath. $dir, true);
			}

			$this->logMessage('<br /><br /><strong>Overwriting MAIN Directory files</strong><br/>');
			if(! $this->copyFiles($this->theDirToDoThings . $this->slash . 'wordpress', $this->absPath, false) ) {
				return false;
			}
			$this->logMessage('<br /><br />The files have been succesfully upgraded.');

			if(!$operationError)
				return true;
			else
				return false;
		}
		else {
			$this->logMessage('<br /><br /><strong>Could not open the downloaded directory to read</strong><br/>');
			return false;
		}
	}

	function copyFiles($dirFrom, $dirTo, $includeSubDirs = false) {
		if( ! current_user_can('edit_files')) {
			echo 'Oops sorry you are not authorized to do this';
			return false;
		}
		//check if we have both the directories
		//older versions may now have new dirs so create them
		if(! $dir =  @opendir($dirTo)) {
			@mkdir($dirTo);
			@chmod($dirTo, 0757);
			@closedir($dirTo);
		}
		if($sourceFiles = @opendir($dirFrom)) {
			$this->logMessage('<br /><strong>Copying over files</strong> from '.$dirFrom.' to '.$dirTo.'<br />');
			@closedir($dirFrom);
			$dir = dir($dirFrom);
			@chmod($dirFrom, 0757);
			while($item = $dir->read()) {
				if((is_dir($dirFrom. $this->slash .$item)
								&& $item != "." && $item != "..")
								&& $includeSubDirs) {
					$this->copyFiles($dirFrom . $this->slash. $item, $dirTo . $this->slash . $item, $includeSubDirs);
				}
				else {
					if($item!="."&&$item!=".." && ! is_dir($dirFrom. $this->slash .$item) && $this->checkIncludeFile($item)) {
						if(copy($dirFrom . $this->slash . $item, $dirTo . $this->slash. $item) ) {
							$this->logMessage('Overwriting file '.$item.' to '. $dirTo .'<br/>');
						}
						else {
							$this->logMessage('ERROR -> Could not copy '.$dirFrom . $this->slash . $item. 'to '. $dirTo . $this->slash.'<br />');
							$this->operationError = true;
						}
					}
				}
			}
		}
		else {
			$this->logMessage('ERROR -> Could not read either the source directory '.$dirFrom.' or the traget directory '.$dirTo.'<br />');
			$this->operationError = true;
		}
		return true;
	}

	/**
	* Downloads the zip file from the given directory
	* Cannot use it due to restrtictions in *nix based sites
	* where the fopen cannot open remote sites
	**/
	function download($remoteFileLoc, $localFileLoc) {
	    $this->logMessage('Downloading the files using Snoopy<br />');
	    if (file_exists($localFileLoc)) {
		$this->logMessage('ERROR -> Some files already exists, please delete all files from '. $this->theDirToDoThings. ' and start the process again <br />' , true);
		return false;
	    }
    //open a handle for the destination file
    $handle = fopen($localFileLoc, 'w');
    if( ! $handle ){
		  $this->logMessage('ERROR -> Could not write the file, please delete all files from '. $this->theDirToDoThings. ' and start the process again <br />' , true);
      return false;
		}

		$remoteFileLoc = str_replace(' ', '%20', html_entity_decode($remoteFileLoc)); // fix url format
		$snoopy = new WPAU_Snoopy();
		$snoopy->fetch($remoteFileLoc);
		if( $snoopy->status != '200' ){
		  $this->logMessage('ERROR -> Could not download latest files from WordPress. Cannot continue with the process.' , true);
      return false;
		}

    //write the downloaded file to disk
    fwrite($handle, $snoopy->results);
  	fclose($handle);
    return true;
  }

	/**
	* Downloads the zip file from the given directory
	* Cannot use it due to restrtictions in *nix based sites
	* where the fopen cannot open remote sites
	**/

	function downloadold ($remoteFileLoc, $localFileLoc) {
		@unlink($localFileLoc);
		$this->logMessage('Downloading the file using FOPEN method');
	  $remoteFileLoc = str_replace(' ', '%20', html_entity_decode($remoteFileLoc)); // fix url format
	  if (file_exists($localFileLoc)) {
			//chmod($localFileLoc, 0755);
			$this->logMessage('ERROR -> Could not write the file, please delete all files from '. $this->theDirToDoThings. ' and start the process again <br />' , true);
			return false;
		}

	  if (($remoteFile = fopen($remoteFileLoc, 'rb')) === FALSE) {
			$this->logMessage('ERROR -> Remote File Error -> Could not read remote file. Please specify a proper path <br />', true);
			return false;
		} // remote file
	  if (($localFile = fopen($localFileLoc, 'wb')) === FALSE) {
			$this->logMessage('ERROR ->  Could not write the file, please delete all files from '. $this->theDirToDoThings. ' and start the process again <br />' , true);
			return false;
		} // local files

	  while (!feof($remoteFile)) {
	    if (fwrite($localFile, fread($remoteFile, 1024)) === FALSE) {
				fclose($remoteFile);
				fclose($localFile);
				$this->logMessage('ERROR -> Could not write the file, please delete all files from '. $this->theDirToDoThings. ' and start the process again <br />' , true);
				return false;
			}
  	}
		$this->logMessage('Finished downloading the upgrade files from the server, it has been save to the location ' . $localFileLoc .'<br />');

	  // Finished without errors
	  fclose($remoteFile);
	  fclose($localFile);
	  return true;
	}

	function downloadFSock($remoteSite, $remoteFile, $localFileLoc) {
		$fp = fsockopen($remoteSite, 80, $errno, $errstr, 30);
		if(!$fp) {
			$this->logMessage('Unable to open connection with '.$remoteSite);
			return false;
		}
		else {
			$out = "GET /$remoteFile HTTP/1.0\r\n";
	    $out .= "Host: $remoteSite\r\n";
  	  $out .= "Connection: Close\r\n\r\n";
			fwrite($fp, $out);
			$data = '';
			while (!feof($fp)) {
				$data .= fgets($fp, 128);
   		}
			//seperate the header and actual content
			$responseData = explode("\r\n\r\n", $data);
			if($localFile = fopen($localFileLoc, 'w')) {
	     	if(! fwrite($localFile, $responseData[1])) {
					$this->logMessage('Could not write to local file');
					return false;
				}
			}
      $this->logMessage('Finished downloading the upgrade files from the server, it has been save to the location ' . $localFileLoc .'<br />');
			@fclose($fp);
			@fclose($localFile);
			return true;
		}
	}

	/**
	* Upload the files to the directory
	**/
	function upload($fileData) {
		if (is_uploaded_file($fileData['thefile']['tmp_name'])) {
			if(move_uploaded_file($fileData['thefile']['tmp_name'], $this->archiveName)) {
				$this->logMessage('Succesfully moved the uploaded file to the directory<br />');
				return true;
			}
			else {
				return false;
			}
		}
		else {
			$this->logMessage('ERROR -> Oops no files uploaded could be some error<br />', true);
			return false;
		}
	}

	/**
	* Unzips the downloaded or uploaded files
	* to a directory
	**/
	function unzip() {
		if( ! current_user_can('edit_files')) {
			echo 'Oops sorry you are not authorized to do this';
			return false;
		}
		//require_once('pclzip.lib.php');
    	if(! class_exists('PclZip')) {
		  require_once('lib/pclzip.lib.php');
	  	}
		$unzipArchive = new PclZip($this->relativeArchiveName);
		$this->logMessage('Unzipping the files to ' . $this->theDirToDoThings . $this->slash);
		if($unzipArchive->extract(PCLZIP_OPT_PATH, $this->theDirToDoThings . $this->slash) == 0) {
			$this->logMessage('ERROR -> Could not unarchive the file maybe it is a corrupted archive. <br /> Please delete all the files before you can do this. Refresh or click here to delete all the files');
			return false;
		}
		else {
			$this->logMessage('<br />All set all files have been extracted<br />');
			@chmod($this->theDirToDoThings . $this->slash . 'wordpress' . $this->slash, 0755);
			return true;
		}
	}

	function doMaintenanceMode($filePath, $fileName) {
		if( ! current_user_can('edit_files')) {
			echo 'Oops sorry you are not authorized to do this';
			return false;
		}
		$this->logMessage('<br />Putting the site into maintenance mode '.$filePath.'<br />');
		$theTmpFile = $filePath . $this->slash. $fileName;
		$theFile = $this->absPath . 'index.php';
		$toFile = $theFile  . '.wpau.bak';
		$this->logMessage('Copying  ' . $theFile . ' to ' . $toFile. '<br/>');
		if(copy($theFile, $toFile)) {
			$this->logMessage('The file was successfully copied<br/>Moving the maintenance file to root<br />');
			if(copy($theTmpFile, $theFile)) {
				$this->logMessage('Copying success ' . $theTmpFile . ' to ' . $theFile. '<br/>');
				$this->logMessage('The site is now under maintenance mode. If you want to revert back please rename the file '. $toFile. ' to '. $theFile. '<br />');
				return true;
			}
			else {
					$this->logMessage('ERROR -> Could not put the site into maintenance mode <br />');
					return false;
			}
		}
		else {
			return false;
		}
	}

	function updateDatabase() {
		if( ! current_user_can('manage_options')) {
			echo 'Oops sorry you are not authorized to do this';
			return false;
		}
		$this->logMessage('Updating your wordpress database');
		require_once(ABSPATH . '/wp-admin/upgrade-functions.php');
		if ( get_option('db_version') == $wp_db_version ) {
			$this->logMessage('Everything seems to be upgraded. No need to update the database<br />');
			return true;
		}
		else {
			wp_upgrade();
			$this->logMessage('The wordpress database was succesfully upgraded to the latest version ' . get_option('db_version') . '<br />');
			return true;
		}
		return true;
	}

	/**
	* Checks whether a the uploaded file has the right extension
	**/
	function validUploadedExtension($extension) {
		$this->logMessage("<br />File Extension is $extension<br />");
		if(in_array($extension,  array('zip' , 'tar.gz'))) {
			return true;
		}
		else {
			return false;
		}
	}

	function cleanUpProcess() {
		if(file_exists(trailingslashit(ABSPATH) . WPAU_LOG_FILE)) {
			unlink(trailingslashit(ABSPATH) . WPAU_LOG_FILE);
		}
		if($dir = @dir($this->theDirToDoThings)) {
			@chmod ($this->theDirToDoThings, 0757);
			$this->recursive_remove_directory($this->theDirToDoThings);
			return true;
		}
		else {
			return false;
		}
		return false;
	}


	function recursive_remove_directory($directory, $empty=FALSE) {
		if(substr($directory,-1) == '/') {
			$directory = substr($directory,0,-1);
		}
		if(!file_exists($directory) || !is_dir($directory)) {
			return FALSE;
		}
		elseif(is_readable($directory)) {
			$handle = opendir($directory);
			while (FALSE !== ($item = readdir($handle))) {
				if($item != '.' && $item != '..') {
					$path = $directory.'/'.$item;
					if(is_dir($path))  {
						$this->recursive_remove_directory($path);
					}
					else{
						unlink($path);
					}
				}
			}
			closedir($handle);
			if($empty == FALSE && $directory != $this->theDirToDoThings) {
				if(!rmdir($directory)) {
					return FALSE;
				}
			}
		}
		return TRUE;
	}

	function recursive_chmod_directory($directory) {
		if(substr($directory,-1) == '/') {
			$directory = substr($directory,0,-1);
		}
		if(!file_exists($directory) || !is_dir($directory)) {
			return FALSE;
		}
		elseif(is_readable($directory)) {
			$handle = @opendir($directory);
			while (FALSE !== ($item = @readdir($handle))) {
				if($item != '.' && $item != '..') {
					$path = $directory.'/'.$item;
					if(is_dir($path))  {
						chmod($path, 0757);
						$this->recursive_chmod_directory($path);
					}
					else{
						chmod($path, 0646);
					}
				}
			}
			closedir($handle);
		}
	}

	function checkIncludeFile($filename) {
		$pathinfo = pathinfo($filename);
		if(is_array($this->ignoreFiles)) {
			if(in_array($filename, $this->ignoreFiles)) {
				return false;
			}
		}
		if(is_array($this->includeExtensions)) {
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
