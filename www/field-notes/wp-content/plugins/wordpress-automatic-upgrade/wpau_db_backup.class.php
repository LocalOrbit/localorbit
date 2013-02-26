<?php
/*
This class is used from the popular plugin wordpress database backup authored by  Austin Matzko  http://www.ilfilosofo.com/blog/

Development continued from that done by Skippy (http://www.skippy.net/)

Much of this was modified from Mark Ghosh's One Click Backup, which
in turn was derived from phpMyAdmin.

Many thanks to Owen (http://asymptomatic.net/wp/) for his patch
   http://dev.wp-plugins.org/ticket/219

Copyright 2007  Austin Matzko  (email : if.website at gmail.com)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/


define('ROWS_PER_SEGMENT', 100);

class wpauBackup extends wpauHelper {

	var $backup_complete = false;
	var $isFileWritten = false;
	var $backup_file;
	var $backup_dir;
	var $backup_errors = array();

	function gzip() {
		return function_exists('gzopen');
	}

	function wpauBackup($backup_dir) {
		global $table_prefix, $wpdb, $wp_version;
		$current_version = (float)$wp_version;
		$table_prefix = ( isset( $table_prefix ) ) ? $table_prefix : $wpdb->prefix;
		if($current_version < 2.3) {
			if ( isset( $wpdb->link2cat ) ) {
				$this->core_table_names = explode(',',"$wpdb->categories,$wpdb->comments,$wpdb->link2cat,$wpdb->links,$wpdb->options,$wpdb->post2cat,$wpdb->postmeta,$wpdb->posts,$wpdb->users,$wpdb->usermeta");
			}
			else {
				$this->core_table_names = explode(',',"$wpdb->categories,$wpdb->comments,$wpdb->linkcategories,$wpdb->links,$wpdb->options,$wpdb->post2cat,$wpdb->postmeta,$wpdb->posts,$wpdb->users,$wpdb->usermeta");
			}
		}
		else { //WP 2.3+ needs database diff table names
			$this->core_table_names = array(
				$wpdb->comments,
				$wpdb->linkcategories,
				$wpdb->links,
				$wpdb->options,
				$wpdb->postmeta,
				$wpdb->posts,
				$wpdb->terms,
				$wpdb->term_taxonomy,
				$wpdb->term_relationships,
				$wpdb->users,
				$wpdb->usermeta,
			);
		}
		$this->backup_dir = trailingslashit($backup_dir);
	}

	function perform_backup($automated = false) {
		if(!current_user_can('manage_options')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
		}
		// are we backing up any other tables?
		$also_backup = array();

		if (isset($_POST['other_tables'])) {
			$also_backup = $_POST['other_tables'];
		}
		$core_tables = $_POST['core_tables'];
		if($automated) {
			$core_tables = $this->core_table_names;
		}

		$this->backup_file = $this->db_backup($core_tables, $also_backup);
		if (FALSE !== $this->backup_file) {
			$this->backup_complete = true;
			return true;
		}
		else
			return false;
	}

	/**
	 * Better addslashes for SQL queries.
	 * Taken from phpMyAdmin.
	 */
	function sql_addslashes($a_string = '', $is_like = FALSE) {
		if ($is_like) $a_string = str_replace('\\', '\\\\\\\\', $a_string);
		else $a_string = str_replace('\\', '\\\\', $a_string);
		return str_replace('\'', '\\\'', $a_string);
	}

	/**
	 * Add backquotes to tables and db-names in
	 * SQL queries. Taken from phpMyAdmin.
	 */
	function backquote($a_name) {
		if (!empty($a_name) && $a_name != '*') {
			if (is_array($a_name)) {
				$result = array();
				reset($a_name);
				while(list($key, $val) = each($a_name))
					$result[$key] = '`' . $val . '`';
				return $result;
			} else {
				return '`' . $a_name . '`';
			}
		} else {
			return $a_name;
		}
	}

	function open($filename = '', $mode = 'w') {
		if ('' == $filename) return false;
		if ($this->gzip())
			$fp = @gzopen($filename, $mode);
		else
			$fp = @fopen($filename, $mode);
		return $fp;
	}

	function close($fp) {
		if ($this->gzip())
			gzclose($fp);
		else
			fclose($fp);
	}

	function stow($query_line) {
		if ($this->gzip()) {
			if(@gzwrite($this->fp, $query_line) === FALSE) {
				$this->backup_error(__('There was an error writing a line to the backup script:','wp-db-backup'));
				$this->backup_error('&nbsp;&nbsp;' . $query_line);
			}
		} else {
			if(@fwrite($this->fp, $query_line) === FALSE) {
				$this->backup_error(__('There was an error writing a line to the backup script:','wp-db-backup'));
				$this->backup_error('&nbsp;&nbsp;' . $query_line);
			}
		}
	}

	function backup_error($err) {
		if(count($this->backup_errors) < 20)
			$this->backup_errors[] = $err;
		elseif(count($this->backup_errors) == 20)
			$this->backup_errors[] = __('Subsequent errors have been omitted from this log.','wp-db-backup');
	}

	/**
	 * Taken partially from phpMyAdmin and partially from
	 * Alain Wolf, Zurich - Switzerland
	 * Website: http://restkultur.ch/personal/wolf/scripts/db_backup/

	 * Modified by Scott Merril (http://www.skippy.net/)
	 * to use the WordPress $wpdb object
	 */
	function backup_table($table, $segment = 'none') {
		global $wpdb;
		if('' == $table) {
			return;
		}
		$table_structure = $wpdb->get_results("DESCRIBE $table");
		if (! $table_structure) {
			$this->backup_error(__('Error getting table details','wp-db-backup') . ": $table");
			return FALSE;
		}

		if(($segment == 'none') || ($segment == 0)) {
			// Add SQL statement to drop existing table
			$this->stow("\n\n");
			$this->stow("#\n");
			$this->stow("# Delete any existing table " . $this->backquote($table) . "\n");
			$this->stow("#\n");
			$this->stow("\n");
			$this->stow("DROP TABLE IF EXISTS " . $this->backquote($table) . ";\n");

			// Table structure
			// Comment in SQL-file
			$this->stow("\n\n");
			$this->stow("#\n");
			$this->stow("# Table structure of table " . $this->backquote($table) . "\n");
			$this->stow("#\n");
			$this->stow("\n");

			$create_table = $wpdb->get_results("SHOW CREATE TABLE $table", ARRAY_N);
			if (FALSE === $create_table) {
				$this->backup_error(sprintf(__("Error with SHOW CREATE TABLE for %s.",'wp-db-backup'), $table));
				$this->stow("#\n# Error with SHOW CREATE TABLE for $table!\n#\n");
			}
			$this->stow($create_table[0][1] . ' ;');

			if (FALSE === $table_structure) {
				$this->backup_error(sprintf(__("Error getting table structure of %s",'wp-db-backup'), $table));
				$this->stow("#\n# Error getting table structure of $table!\n#\n");
			}

			// Comment in SQL-file
			$this->stow("\n\n");
			$this->stow("#\n");
			$this->stow('# Data contents of table ' . $this->backquote($table) . "\n");
			$this->stow("#\n");
		}

		if(($segment == 'none') || ($segment >= 0)) {
			$ints = array();
			foreach ($table_structure as $struct) {
				if ( (0 === strpos($struct->Type, 'tinyint')) ||
					(0 === strpos(strtolower($struct->Type), 'smallint')) ||
					(0 === strpos(strtolower($struct->Type), 'mediumint')) ||
					(0 === strpos(strtolower($struct->Type), 'int')) ||
					(0 === strpos(strtolower($struct->Type), 'bigint')) ||
					(0 === strpos(strtolower($struct->Type), 'timestamp')) ) {
						$ints[strtolower($struct->Field)] = "1";
				}
			}


			// Batch by $row_inc

			if($segment == 'none') {
				$row_start = 0;
				$row_inc = ROWS_PER_SEGMENT;
			} else {
				$row_start = $segment * ROWS_PER_SEGMENT;
				$row_inc = ROWS_PER_SEGMENT;
			}

			do {
				if ( !ini_get('safe_mode')) @set_time_limit(15*60);
				$table_data = $wpdb->get_results("SELECT * FROM $table LIMIT {$row_start}, {$row_inc}", ARRAY_A);

				/*
				if (FALSE === $table_data) {
					$wp_backup_error .= "Error getting table contents from $table\r\n";
					fwrite($fp, "#\n# Error getting table contents fom $table!\n#\n");
				}
				*/

				$entries = 'INSERT INTO ' . $this->backquote($table) . ' VALUES (';
				//    \x08\\x09, not required
				$search = array("\x00", "\x0a", "\x0d", "\x1a");
				$replace = array('\0', '\n', '\r', '\Z');
				if($table_data) {
					foreach ($table_data as $row) {
						$values = array();
						foreach ($row as $key => $value) {
							if ($ints[strtolower($key)]) {
								$values[] = $value;
							} else {
								$values[] = "'" . str_replace($search, $replace, $this->sql_addslashes($value)) . "'";
							}
						}
						$this->stow(" \n" . $entries . implode(', ', $values) . ') ;');
					}
					$row_start += $row_inc;
				}
			} while((count($table_data) > 0) and ($segment=='none'));
		}

		if(($segment == 'none') || ($segment < 0)) {
			// Create footer/closing comment in SQL-file
			$this->stow("\n");
			$this->stow("#\n");
			$this->stow("# End of data contents of table " . $this->backquote($table) . "\n");
			$this->stow("# --------------------------------------------------------\n");
			$this->stow("\n");
		}
	} // end backup_table()

	function return_bytes($val) {
		$val = trim($val);
		$last = strtolower($val{strlen($val)-1});
		switch($last) {
		// The 'G' modifier is available since PHP 5.1.0
			case 'g':
				$val *= 1024;
			case 'm':
				$val *= 1024;
			case 'k':
				$val *= 1024;
		}
		return $val;
	}

	function db_backup($core_tables, $other_tables) {
		global $table_prefix, $wpdb;
		$datum = date("Ymd_B");
		$wp_backup_filename = DB_NAME . "_$table_prefix$datum.sql";

		if ($this->gzip())
			$wp_backup_filename .= '.gz';

		if (is_writable(ABSPATH . $this->backup_dir)) {

			$this->fp = $this->open(ABSPATH . $this->backup_dir . $wp_backup_filename);
			if(!$this->fp) {
				$this->backup_error(__('Could not open the backup file for writing!','wp-db-backup'));
				return false;
			}
		} else {
			$this->backup_error(__('The backup directory is not writeable!','wp-db-backup'));
			return false;
		}

		//Begin new backup of MySql
		$this->stow("# WordPress MySQL database backup\n");
		$this->stow("#\n");
		$this->stow("# Generated: " . date("l j. F Y H:i T") . "\n");
		$this->stow("# Hostname: " . DB_HOST . "\n");
		$this->stow("# Database: " . $this->backquote(DB_NAME) . "\n");
		$this->stow("# --------------------------------------------------------\n");

			if ( (is_array($other_tables)) && (count($other_tables) > 0) )
			$tables = array_merge($core_tables, $other_tables);
		else
			$tables = $core_tables;

		foreach ($tables as $table) {
			// Increase script execution time-limit to 15 min for every table.
			if ( !ini_get('safe_mode')) @set_time_limit(15*60);
			// Create the SQL statements
			$this->stow("# --------------------------------------------------------\n");
			$this->stow("# Table: " . $this->backquote($table) . "\n");
			$this->stow("# --------------------------------------------------------\n");
			$this->backup_table($table);
		}

		$this->close($this->fp);

		if (count($this->backup_errors)) {
			return false;
		} else {
			return $wp_backup_filename;
		}

	} //wp_db_backup



	function backup_menu() {
		global $table_prefix, $wpdb;
		$feedback = '';
		$WHOOPS = FALSE;
		// did we just do a backup?  If so, let's report the status
		if ( $this->backup_complete ) {
			$feedback = '<div class="updated"><p>' . __('Backup Successful','wp-db-backup') . '!';
			$file = $this->backup_file;
			switch($_POST['deliver']) {
			case 'http':
				$feedback .= '<br />' . sprintf(__('Your backup file: <a href="%1s">%2s</a> should begin downloading shortly.','wp-db-backup'), get_option('wpurl') . "/{$this->backup_dir}{$this->backup_file}", $this->backup_file);
				break;
			case 'smtp':
				if (! is_email($_POST['backup_recipient'])) {
					$feedback .= get_option('admin_email');
				} else {
					$feedback .= $_POST['backup_recipient'];
				}
				$feedback = '<br />' . sprintf(__('Your backup has been emailed to %s','wp-db-backup'), $feedback);
				break;
			case 'none':
				$feedback .= '<br />' . __('Your backup file has been saved on the server. If you would like to download it now, right click and select "Save As"','wp-db-backup');
				$feedback .= ':<br /> <a href="' . get_option('wpurl') . "/{$this->backup_dir}$file\">$file</a> : " . sprintf(__('%s bytes','wp-db-backup'), filesize(ABSPATH . $this->backup_dir . $file));
			}
			$feedback .= '</p></div>';
		}

		if (count($this->backup_errors)) {
			$feedback .= '<div class="updated error">' . __('The following errors were reported:','wp-db-backup') . "<pre>";
			foreach($this->backup_errors as $error) {
				$feedback .= "{$error}\n";  //Errors are already localized
			}
			$feedback .= "</pre></div>";
		}

		// did we just save options for wp-cron?
		if ( (function_exists('wp_schedule_event') || function_exists('wp_cron_init'))
			&& isset($_POST['wp_cron_backup_options']) ) :
			if ( function_exists('wp_schedule_event') ) {
				wp_clear_scheduled_hook( 'wp_db_backup_cron' ); // unschedule previous
				$scheds = (array) wp_get_schedules();
				$name = strval($_POST['wp_cron_schedule']);
				$interval = ( isset($scheds[$name]['interval']) ) ?
					(int) $scheds[$name]['interval'] : 0;
				update_option('wp_cron_backup_schedule', $name, FALSE);
				if ( ! 0 == $interval ) {
					wp_schedule_event(time() + $interval, $name, 'wp_db_backup_cron');
				}
			}
			else {
				update_option('wp_cron_backup_schedule', intval($_POST['cron_schedule']), FALSE);
			}
			update_option('wp_cron_backup_tables', $_POST['wp_cron_backup_tables']);
			if (is_email($_POST['cron_backup_recipient'])) {
				update_option('wp_cron_backup_recipient', $_POST['cron_backup_recipient'], FALSE);
			}
			$feedback .= '<div class="updated"><p>' . __('Scheduled Backup Options Saved!','wp-db-backup') . '</p></div>';
		endif;

		$other_tables = array();
		$also_backup = array();

		// Get complete db table list
		$all_tables = $wpdb->get_results("SHOW TABLES", ARRAY_N);
		$all_tables = array_map(create_function('$a', 'return $a[0];'), $all_tables);
		// Get list of WP tables that actually exist in this DB (for 1.6 compat!)
		$wp_backup_default_tables = array_intersect($all_tables, $this->core_table_names);
		// Get list of non-WP tables
		$other_tables = array_diff($all_tables, $wp_backup_default_tables);

		if ('' != $feedback)
			echo $feedback;

		// Give the new dirs the same perms as wp-content.
		$stat = stat( ABSPATH . 'wp-content' );
		$dir_perms = $stat['mode'] & 0000777; // Get the permission bits.

		if ( !file_exists( ABSPATH . $this->backup_dir) ) {
			if ( @ mkdir( ABSPATH . $this->backup_dir) ) {
				@ chmod( ABSPATH . $this->backup_dir, $dir_perms);
			} else {
				echo '<div class="updated error"><p style="text-align:center">' . __('WARNING: Your wp-content directory is <strong>NOT</strong> writable! We can not create the backup directory.','wp-db-backup') . '<br />' . ABSPATH . $this->backup_dir . "</p></div>";
			$WHOOPS = TRUE;
			}
		}

		if ( !is_writable( ABSPATH . $this->backup_dir) ) {
			echo '<div class="updated error"><p style="text-align:center">' . __('WARNING: Your backup directory is <strong>NOT</strong> writable! We can not create the backup directory.','wp-db-backup') . '<br />' . ABSPATH . "</p></div>";
		}

		?><div class='wrap'>
		<h2><?php _e('Backup','wp-db-backup') ?></h2>
		<form method="post" action="edit.php?page=<?php echo WPAU_PAGE ?>&task=backupdb">
		<?php
			if(function_exists('wp_nonce_field')) {
				wp_nonce_field('wordpress_automatic_upgrade' );
			}
		?>
		<fieldset class="options"><legend><?php _e('Tables','wp-db-backup') ?></legend>
		<table align="center" cellspacing="5" cellpadding="5"><tr><td width="50%" align="left" class="alternate" valign="top">
		<?php _e('These core WordPress tables will always be backed up:','wp-db-backup') ?><br /><ul><?php
		foreach ($wp_backup_default_tables as $table) {
			echo "<li><input type='hidden' name='core_tables[]' value='$table' />$table</li>";
		}
		?></ul></td><td width="50%" align="left" valign="top"><?php
		if (count($other_tables) > 0) {
			echo __('You may choose to include any of the following tables:','wp-db-backup') . ' <br />';
			foreach ($other_tables as $table) {
				echo "<label style=\"display:block;\"><input type='checkbox' name='other_tables[]' value='{$table}' /> {$table}</label>";
			}
		}
		?></td></tr></table></fieldset>
		<div align="center">
		<fieldset>
	<input type="Submit" name="wpaudbbackup" value="Start DB Backup" />
	</fieldset>
	</div>
		<?php
		echo '</form>';
		echo '</div>';

	} // end wp_backup_menu()


	function user_can_backup() {
		return current_user_can('import');
	}

	function validate_file($file) {
		if (false !== strpos($file, '..'))
			die(__("Cheatin' uh ?",'wp-db-backup'));

		if (false !== strpos($file, './'))
			die(__("Cheatin' uh ?",'wp-db-backup'));

		if (':' == substr($file, 1, 1))
			die(__("Cheatin' uh ?",'wp-db-backup'));
	}

	function zip_backup($fileName) {
		//require_once('lib/pclzip.lib.php');
		//echo "In here $fileName";
		$archiveName = ABSPATH.$this->backup_dir. $fileName;
		$this->logMessage('Creating a archive with the name '.$archiveName.'<br/ >');
		if(! class_exists('PclZip')) {
			require_once('lib/pclzip.lib.php');
		}
		$archiver = new PclZip($archiveName);
		$list = $archiver->create(ABSPATH.$this->backup_dir.$this->backup_file);
		if ($list == 0) {
			$this->logMessage('Could not archive the files ' .$archiver->errorInfo(true));
			$this->isFileWritten = false;
			return false;
		}
		else {
			$this->logMessage('<br /><strong>Succesfully Created </strong>database backup archive at '. $archiveName .'<br /><br />');
			$this->isFileWritten = true;
			if(!$basedir = @opendir(ABSPATH.$this->backup_dir)) {
				@chmod($archiveName, 0755);
				@closedir($this->backupPath);
			}
			else {
				exec("chmod 755 $archiveName");
			}
			unlink(ABSPATH.$this->backup_dir.$this->backup_file);
			return true;
		}
		unset($archiver);
	}

}


?>
