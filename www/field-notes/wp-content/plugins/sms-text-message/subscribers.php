<?php

function mrt_sms_subscribers_page() { ?>
    <br /><em>For comments, suggestions, bug reporting, etc please <a href="http://semperfiwebdesign.com/contact/">click here</a>.</em>
	
		<div class="wrap">
			<h2>SMS Text Message Subscribers</h2>
			<em>Click on a header to sort.</em><br />
			<table class="sortable widefat" cellspacing="0">
				<thead>
				<tr>
					<th scope="col" >ID</th>
					<th scope="col" >Phone Number</th>
					<th scope="col" >Carrier</th>
					<th scope="col" >Submit Date</th>
					<th scope="col" >Action</th>
				</tr>
				</thead>
				<tbody>
	<?php

	$current_url = $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'] . '?' . $_SERVER['QUERY_STRING'];
	
	if( $_POST['remove_req'] != ''){
	$remove_req = $_POST['remove_req'];
	   //$result = $wpdb->get_results("SELECT * FROM " . $table_name);
	global $wpdb;
	$table_name = $wpdb->prefix . "mrt_sms_list";
	$quer = "DELETE FROM " . $table_name . " WHERE id = " . $remove_req; 
	$wpdb->query($quer);

	echo "<div style='color:red'>" . $remove_req . " removed</div>";
	}
	
	if($_GET['id'] && $_GET['mode']=='delete'){
		global $wpdb;
		$table_name = $wpdb->prefix . "mrt_sms_list";
		$quer = "DELETE FROM " . $table_name . " WHERE id = " . $_GET['id']; 
		$wpdb->query($quer);

		echo "<div style='color:red'>" . $_GET['id'] . " removed</div>";
	}
	
	
	GLOBAL $wpdb;
   $table_name = $wpdb->prefix . "mrt_sms_list";
   $result = $wpdb->get_results("SELECT * FROM " . $table_name);

if($result){
 foreach ($result as $results) {
      $tablenum = $results->number;
      $tablecar = $results->carrier;
      $tabledate = $results->date;
      $tableid = $results->id;

?>
<tr onmouseover="this.style.backgroundColor='lightblue';" onmouseout="this.style.backgroundColor='white';">
	<td><?php echo $tableid; ?></td>
	<td><?php echo $tablenum; ?></td>
	<td><?php echo $tablecar; ?></td>
	<td><?php echo $tabledate; ?></td>
	<td><a href="http://<?php echo $current_url; ?>&amp;mode=delete&amp;id=<?php echo $tableid; ?>" onclick="javascript:check=confirm( '<?php echo "Delete this subscriber?"?>');if(check==false) return false;"><?php _e('Delete') ?></a></td>
</tr>
<?php    }	
}else{
	echo '<tr><td colspan="7" align="center"><strong>'. 'No entries found' .'</strong></td></tr>';
	
}			
?>
				</tbody>
			</table>
		</div>
		
   <div style="margin-top:50px">
         Plugin by <a href="http://semperfiwebdesign.com/" title="Semper Fi Web Design">Semper Fi Web Design</a>
      </div>

<?php } ?>
