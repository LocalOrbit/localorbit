<?php
/*
Runs all the critical upgrade functions to upgrade the wordpress version
FTP functions are mostly used from php.net/ftp_rawlist
*/

//require_once('lib/ftp_class.php');

class wpauPrelimHelper extends wpauHelper {

	var $theDirToDoThings;
	var $slash;
	var $relativeSlash;
	var $ftpUser;
	var $ftpPass;
	var $ftpHost;
	var $ftpBaseDir;
	var $includeDirs;
	var $includeExtensions;
	var $runRegularFtpOps;
	var $theFtpConn;
	var $isConnected;
	var $couldNotUpdatePermsFile;
	var $backupDir;
	var $isRollback;
	
	
	function wpauPrelimHelper($rollback = false, $backupDir = 'wpau-backup') {
		$this->theDirToDoThings = trailingslashit(ABSPATH) . $backupDir; //the dir where we gonna store all our stuff
		//runs php inbuilt ftp funcs
		$this->runRegularFtpOps = true;
		$this->isConnected = false;
		$this->includeDirs = array('wp-admin', 'wp-includes');
		$this->includeExtensions = array('php', 'txt', 'htm', 'html', 'js', 'css', 'jpg', 'png', 'gif');
		$this->isRollback = $rollback;
		$this->backupDir = $backupDir;
	}
	

	function checkCleanUpRequired() {
		if(file_exists(trailingslashit(ABSPATH) . WPAU_LOG_FILE)) {
			return true;
		}
		if(!is_dir($this->theDirToDoThings)) {
			return false;
		}
		if($dir = @opendir($this->theDirToDoThings)) {
			while (FALSE !== ($item = @readdir($dir))) {
				if($item != '.' && $item != '..') {
					return true;
				}
			}
		}
		return false;
	}
	
	function runRegularChangeMode() {
		$chmod = @chmod(ABSPATH . 'index.php', 0646);
		return $chmod;
	}
	
	/**
	* Checks if upgrade is required or not
	**/
	function runUpgradeRequiredCheck() {
		global $wp_version;
    //if this function does not exist, it means upgrade is definitely required
		if(! function_exists('wp_version_check')) {
			return true;
		}
		else {
			//run the core check
      if($wp_version >= 2.7) {
        $update_array = get_core_updates();
      
        if(is_array($update_array)) {
          if('upgrade' == $update_array[0]->response) {
            return true;
          }
        }
      }
      else {
        wp_version_check();
        $cur = get_option( 'update_core' );
      	if ( isset( $cur->response ) || 'upgrade' == $cur->response ) {
    	    return true;
        }
      }
		}
    
    return false;
	}
	
	/**
	* Runs preliminary checks on the installation to check
	* if we can write to the directory, if we cannot it will
	* check if we can use ftp on the site and then 
	* ask the user for the username and password
	* so that we can change the permissions and run the
	* upgrade for the user
	*/
	function runFTPPrelimChecks() {
		$canRun = true;
		$theFile = ABSPATH . 'index.php';
		$chmod = @chmod($theFile, 0644);
		if($chmod) {
			return true;
		}
		
		$permission =  exec("ls -l $theFile |awk '{print $1}'", $output, $error);
		if($error == 0) {
			//get the perms
			$thePerms = $this->chmodnum(substr($permission, 1));
			//if its 644 or 744 we cannot run man
			//tell our wpau guy out there we need to change perms
			//we only can write files when they are 766 or 666 lets see
			$this->userPermission = $thePerms[0];
			if($thePerms[2] < 6) {
				$canRun = false;
			}
		}
		else {
			$canRun = false;
		}
		
		if($canRun == true) {
			if(! is_dir(ABSPATH.'wpau-backup')) {
				if($mkdir = @mkdir(ABSPATH.'wpau-backup')) {
					@chmod(ABSPATH.'wpau-backup', 0757);
					$this->canMakeBackupDir = true;
					$this->createIndexes();
				}
				else {
					$canRun = false;
				}
			}
			else {
				$this->createIndexes();
				$this->canMakeBackupDir = true;
			}
		}
		return $canRun;
	}
	
	function checkFtpMode() {
		//does the server allow us to connect using ftp ??
		if(!function_exists('ftp_connect')) {
			$this->runRegularFtpOps = false;
		}
	}
	
	function checkFTPCredentials() {
		if($this->runRegularFtpOps) {
			$this->theFtpConn = @ftp_connect($this->ftpHost);
			$this->isConnected = @ftp_login($this->theFtpConn, $this->ftpUser, $this->ftpPass);
			if($this->isConnected) {
				return true;
			}
			else {
				return false;
			}
		}
		else {
			$this->theFtpConn = new ftp(TRUE);
			$this->theFtpConn->Verbose = TRUE;
			$this->theFtpConn->LocalEcho = TRUE;
			if($this->theFtpConn->SetServer($this->ftpHost)) {
				$this->theFtpConn->quit();
			}
			if (!$this->theFtpConn->connect()) {
				return false;
			}
			$this->isConnected = $this->theFtpConn->login($this->ftpUser, $this->ftpPass);
			if($this->isConnected) {
				return true;
			}
			else {
				$this->theFtpConn->quit();
				return false;
			}
		}
	}
	
	function runFTPOperation() {
		if(!$this->theFtpConn || !$this->isConnected ) {
			return false;
		}
		$directory = $this->ftpBaseDir;
		$ignoreFiles = array('wp-config.php', 'wpau-backup', 'error_log', 'index.php.wpau.bak', '.htaccess', 'wp-config-sample.php', 'wpau-log-data.txt');
		if($this->runRegularFtpOps) {
			if(! $this->isRollback)
				$chmod_cmd='CHMOD 0777 '.$directory;
			else 
				$chmod_cmd='CHMOD 0755 '.$directory;
				
			$chmod=ftp_site($this->theFtpConn, $chmod_cmd);
			$this->chmodRegularFTP("/" . $directory, $ignoreFiles, false);
			foreach($this->includeDirs as $dir) {
				$this->chmodRegularFTP("/" . $directory. "/" . $dir, '', true);
			}
			@ftp_close($this->theFtpConn);
		}
		else {
			if(! $this->isRollback)
				$chmod=$this->theFtpConn->chmod($directory, 0777);
			else 
				$chmod=$this->theFtpConn->chmod($directory, 0755);
			
			$this->chmodPemFTP("/" . $directory, $ignoreFiles, false);
			foreach($this->includeDirs as $dir) {
				$this->chmodPemFTP("/" . $directory. "/" . $dir, '', true);
			}
			$this->theFtpConn->quit();
		}
		
		//return true;
		if ( count($this->couldNotUpdatePermsFile) > 0 && $this->showError) {
			$this->logMessage('Looks like we cannot run the upgrade as we could not change permissions for these files. <br /> You can change the permissions to 646 manually and try again. Below are the list of files.');
			foreach($this->couldNotUpdatePermsFile as $file) {
				$this->logMessage($file.'<br />');
			}
			return false;
		}
		else
			return true;
	}
	
	/* see http://us.php.net/manual/en/function.ftp-rawlist.php#71315 */
	function chmodRegularFTP($directory, $ignoreFiles, $traverseSubDir = false) {
		if(!$this->theFtpConn || !$this->isConnected ) {
			return false;
		}
		ftp_chdir($this->theFtpConn, $directory);
		$array = ftp_rawlist($this->theFtpConn, $directory);

		if (is_array($array)) {
			foreach ($array as $folder) {
	$current = preg_split("/[\s]+/",$folder,9);
				$permission = $current[0];
				$name = str_replace('//','',$current[8]);
				
				if($this->get_type($permission) == "folder") {
					if($name != '.' && $name != '..') {
						$subdir = $directory . '/' . $name;
						$subdir = str_replace('//','/', $subdir);
						if($traverseSubDir || in_array($name, $this->includeDirs)) {
							if(! $this->isRollback)
								$chmod_cmd="CHMOD 0757 $name";
							else
								$chmod_cmd="CHMOD 0755 $name";
							
							$chmod=@ftp_site($this->theFtpConn, $chmod_cmd);
							if(! $chmod) {
								$uid = @fileowner("$name");
								$userinfo = @posix_getpwuid($uid);
								if(is_array($userinfo)) {
									if($userinfo['name'] == $this->ftpUser) {
										$this->couldNotUpdatePermsFile[] = $directory . "/" . $name;
									}
								}
								else {
									$this->couldNotUpdatePermsFile[] = $directory . "/" . $name;
								}
							}
							$this->chmodRegularFTP($subdir, $ignoreFiles, $traverseSubDir);
							ftp_chdir($this->theFtpConn, $directory);
						}
					}
				}
				else {
					if(is_array($ignoreFiles)) {
						if(in_array($name, $ignoreFiles)) {
							continue;
						}
					}
					if(($name != '.' && $name != '..') && $this->checkIncludeFile($name)) {
						$name = str_replace('//','/', $name);
						if(! $this->isRollback)
							$chmod_cmd="CHMOD 0646 $name";
						else
							$chmod_cmd="CHMOD 0644 $name";
						
						$chmod=@ftp_site($this->theFtpConn, $chmod_cmd);
						if(! $chmod) {
							$uid = @fileowner("$name");
							$userinfo = @posix_getpwuid($uid);
							if(is_array($userinfo)) {
								if($userinfo['name'] == $this->ftpUser) {
									$this->couldNotUpdatePermsFile[] = $directory . "/" . $name;
								}
							}
							else {
								$this->couldNotUpdatePermsFile[] = $directory . "/" . $name;
							}
						}
					}
				}
			}
		}
	}
	
	function checkIncludeFile($filename) {
		$pathinfo = pathinfo($filename);
		if(is_array($this->includeExtensions)) {
			if(in_array($pathinfo['extension'], $this->includeExtensions)) {
				return true;
			}
			else {
				return false;
			}
		}
	}
	
	function chmodPemFTP($directory, $ignoreFiles, $traverseSubDir = false) {
		if(!$this->theFtpConn || !$this->isConnected ) {
			return false;
		}
		
		$this->theFtpConn->chdir($directory);
		$array=$this->theFtpConn->rawlist(".", "-lA");
		if (is_array($array)) {
			foreach ($array as $folder) {
	$current = preg_split("/[\s]+/",$folder,9);
				$permission = $current[0];
				$name = str_replace('//','',$current[8]);
				
				if($this->get_type($permission) == "folder") {
					if($name != '.' && $name != '..') {
						$subdir = $directory . '/' . $name;
						$subdir = str_replace('//','/', $subdir);
						if($traverseSubDir || in_array($name, $this->includeDirs)) {
							if(! $this->isRollback)
								$chmod=$this->theFtpConn->chmod($name, 0757);
							else 
								$chmod=$this->theFtpConn->chmod($name, 0755);
								
							if(! $chmod) {
								$uid = @fileowner("$name");
								$userinfo = @posix_getpwuid($uid);
								if(is_array($userinfo)) {
									if($userinfo['name'] == $this->ftpUser) {
										$this->couldNotUpdatePermsFile[] = $directory . "/" . $name;
									}
								}
								else {
									$this->couldNotUpdatePermsFile[] = $directory . "/" . $name;
								}
							}
							$this->chmodPemFTP($subdir, $ignoreFiles, $traverseSubDir);
							$this->theFtpConn->chdir($directory);
						}
					}
				}
				else {
					if(is_array($ignoreFiles)) {
						if(in_array($name, $ignoreFiles)) {
							continue;
						}
					}
					if(($name != '.' && $name != '..' )  && $this->checkIncludeFile($name)) {
						if(! $this->isRollback)
							$chmod=$this->theFtpConn->chmod($name, 0646);
						else
							$chmod=$this->theFtpConn->chmod($name, 0644);
						
						if(! $chmod) {
							$uid = @fileowner("$name");
							$userinfo = @posix_getpwuid($uid);
							if(is_array($userinfo)) {
								if($userinfo['name'] == $this->ftpUser) {
									$this->couldNotUpdatePermsFile[] = $directory . "/" . $name;
								}
							}
							else {
								$this->couldNotUpdatePermsFile[] = $directory . "/" . $name;
							}
						}
					}
				}
			}
		}
	}
	
	
	/* see http://us.php.net/manual/en/function.ftp-rawlist.php#71315 */
	function get_type($perms) {
      if (substr($perms, 0, 1) == "d") {
	  return 'folder';
       }
      elseif (substr($perms, 0, 1) == "l") {
	  return 'link';
       }
      else {
	  return 'file';
       }
   }
	 
	 /* see http://us.php.net/manual/en/function.ftp-rawlist.php#71315 */
	 function chmodnum($mode) {
       $realmode = "";
       $legal =	 array("","w","r","x","-");
       $attarray = preg_split("//",$mode);
       for($i=0;$i<count($attarray);$i++){
	   if($key = array_search($attarray[$i],$legal)){
	       $realmode .= $legal[$key];
	   }
       }
       $mode = str_pad($realmode,9,'-');
       $trans = array('-'=>'0','r'=>'4','w'=>'2','x'=>'1');
       $mode = strtr($mode,$trans);
       $newmode = array();
       $newmode[0] = $mode[0]+$mode[1]+$mode[2];
       $newmode[1] = $mode[3]+$mode[4]+$mode[5];
       $newmode[2] = $mode[6]+$mode[7]+$mode[8];
       return $newmode;
    }
		
		/** makes a backup directory if it does not exist or if we cannot create it using normal way **/
	function makeBackupDir() {
		if(!$this->theFtpConn || !$this->isConnected ) {
			return false;
		}
		$this->checkFTPCredentials();
		if($this->runRegularFtpOps) {
			ftp_chdir($this->theFtpConn, $this->ftpBaseDir);
			if($dirExists = @ftp_chdir($this->theFtpConn, $this->backupDir)) {
				//dir exists no need to create
				return true;
			}
			if(!$makeBackupDir = @ftp_mkdir($this->theFtpConn, $this->backupDir))
				return false;
			if(! $this->isRollback)
				$chmod_cmd="CHMOD 0757 ".$this->backupDir;
			else
				$chmod_cmd="CHMOD 0755 ".$this->backupDir;
				
			$chmod=@ftp_site($this->theFtpConn, $chmod_cmd);
			if(! $chmod) {
				$this->logMessage('Could not change mode of backup directory');
			}
			$this->createIndexes();
			return true;
		}
		else {
			$this->theFtpConn->chdir($this->ftpBaseDir);
			if(! $theBackupDir = $this->theFtpConn->mkdir($this->backupDir))
				return false;
			if(! $this->isRollback)
				$chmod=$this->theFtpConn->chmod($this->backupDir, 0757);
			else 
				$chmod=$this->theFtpConn->chmod($this->backupDir, 0755);
			if(!$chmod) {
				$this->logMessage('Could not change mode of backup directory');
			}
			$this->createIndexes();
			return true;
		}
	}
	
}

?>
