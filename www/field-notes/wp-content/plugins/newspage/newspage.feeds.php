<?php
	$del_confirm = "onClick = \"return confirm('Are You Sure You Want to Delete?');\"";
	if($_REQUEST['mode'] == "sort"){
			$oldpage = $_GET['oldpage'];
			$newpage = $_GET['newpage'];
			$id = $_GET['fid'];
			$wpdb->query("UPDATE " . get_option('newspage_dbname')." SET porder='{$oldpage}' WHERE porder='{$newpage}' && Id != '{$id}'");
			$wpdb->query("UPDATE " . get_option('newspage_dbname')." SET porder='{$newpage}' WHERE Id = '{$id}'");
	}	
	if ( preg_match("/delete/i", $_POST['change3']) ){
		$sql = "SELECT * FROM " . get_option('newspage_dbname');
		$posts = $wpdb->get_results($sql);
		foreach ($posts as $row) {
			$key = $_POST["delete_{$row->Id}"];
			if($key){
				if($row->Id == $key){
					$wpdb->query("DELETE FROM " . get_option('newspage_dbname')." WHERE id='{$key}'");
				}
			}
		}
	}
	if ($_POST['change3']){	
		$sql = "SELECT * FROM " . get_option('newspage_dbname');
		$posts = $wpdb->get_results($sql);
		foreach ($posts as $row) {
			if (preg_match("/update/i", $_POST['change3'])){
				$query = "UPDATE " . get_option('newspage_dbname')." SET 
					Title='".$wpdb->escape($_POST["Title_{$row->Id}"])."',
					feedurl='".$wpdb->escape($_POST["feedurl_{$row->Id}"])."',
					topics='".$wpdb->escape($_POST["topics_{$row->Id}"])."',
					active='".$wpdb->escape($_POST["active_{$row->Id}"])."' WHERE id='{$row->Id}';";
				$wpdb->query($query);
			}
		}
	}
	if (preg_match("/add/i", $_POST['change8']) && $_POST['Title_new'] != ''){
		$query = "INSERT INTO " . get_option('newspage_dbname')." SET 
			Title='".$wpdb->escape($_POST["Title_new"])."',
			feedurl='".$wpdb->escape($_POST["feedurl_new"])."',
			topics='".$wpdb->escape($_POST["topics_new"])."',
			porder='".$wpdb->escape($_POST["porder_new"])."',
			active='".$wpdb->escape($_POST["active_new"])."';";
		$wpdb->query($query);
	}	
?>
	<style>
		table.design TD{
			border-collapse: collapse;
			FONT-SIZE: 8pt;
			COLOR: black;
			FONT-FAMILY: Verdana;
		}

		table.design{
			border-collapse:collapse;
			font-size: 		10px;
			border-color: 		#666666 #666666 #666666 #666666;
			border-left-style: 	solid;
			border-left-width: 	1px;
			border-right-style: 	solid;
			border-right-width: 	1px;
			border-top-style: 	solid;
			border-top-width: 	1px;
			border-bottom-style:	solid;
			border-bottom-width:	1px;
		}
		table.design th{
			padding: 3px;
			background-color: #426B8C;
			font-size: 8pt;
			color: #ffffff;
			border-color: #666666 #666666 #666666 #666666;
			border-left-style: none;
			border-left-width: 0px;
			border-right-style: none;
			border-right-width: 0px;
			border-top-style: none;
			border-top-width: 0px;
			border-bottom-style: none;
			border-bottom-width: 0px;
		}
		table.design th a{
			color:#ffffff;
		}
		table.design td{
			border-collapse:collapse;
			padding: 3px;
			font-size: 10px;
			color: #000000;
			border-color: #666666 #666666 #666666 #666666;
			border-left-style: solid;
			border-left-width: 1px;
			border-right-style: solid;
			border-right-width: 1px;
			border-top-style: solid;
			border-top-width: 1px;
			border-bottom-style: solid;
			border-bottom-width: 1px;
		}
		table.empty{
			border: none;
			padding: 0px;
			border-width: 0px;
		}
		table.empty td{
			border: none;
			padding: 0px;
			border-width: 0px;
		}

		td.row1{
			background-color: #FFFFFF;
		}

		td.row2{
			background-color: #F7F7F7;
		}
	</style>
<div class="wrap">
	<h2>NewsPage RSS Feeds</h2>
	<p>
		Here is where you can manage the RSS feed you display on your site.
	</p>
	<form method=POST>
	<table border="0" class="design" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<th>&nbsp;</th>
		<th>#</th>
		<th>Name</th>
		<th>Link URL</th>
		<th>Topic</th>
		<th>Active</th>
		<th>&nbsp;</th>
	</tr>
<?php
	$i = 1;
	$sql = "SELECT * FROM " . get_option('newspage_dbname') . " ORDER BY porder ASC";
	$posts = $wpdb->get_results($sql);
	$lorder = 0;
	$cnt = $wpdb->get_var("SELECT MAX(porder) AS porderc FROM " . get_option('newspage_dbname'))+1;
	if (empty($posts)){
		echo "<tr><td colspan=6>No RSS Feeds have been added yet.</td></tr>";
	}else{
		foreach ($posts as $row) {
			$lorder = $row->porder;
?>	
			<tr>
				<TD width=15><input type=checkbox name="delete_<?php echo $row->Id?>" value="<?php echo $row->Id?>">
				<TD width=15><?php echo $i?></TD> 
				<TD><input type=text name='Title_<?php echo $row->Id?>' size=30 value="<?php echo htmlspecialchars($row->Title);?>"></TD>
				<TD><input type=text name='feedurl_<?php echo $row->Id?>' size=30 value="<?php echo htmlspecialchars($row->feedurl);?>"></TD>
				<TD><input type=text name='topics_<?php echo $row->Id?>' size=30 value="<?php echo htmlspecialchars($row->topics);?>"></TD>
				<TD>
					<select name='active_<?php echo $row->Id?>'>
						<option value="0" <?php if ($row->active == 0)echo "SELECTED";?>>Inactive
						<option value="1" <?php if ($row->active == 1)echo "SELECTED";?>>Active
					</select>
				</TD>
<?php				
					if($row->porder == 0){
						echo "<td><a href='{$_SERVER['PHP_SELF']}?page=npFeeds&mode=sort&fid={$row->Id}&oldpage={$row->porder}&newpage=".($row->porder+1)."'>Move Down</a></td>";
					}else if($row->porder == ($cnt-1) ){
						echo "<td><a href='{$_SERVER['PHP_SELF']}?page=npFeeds&mode=sort&fid={$row->Id}&oldpage={$row->porder}&newpage=".($row->porder-1)."'>Move Up</a></td>";
					}else{
						echo "<td><a href='{$_SERVER['PHP_SELF']}?page=npFeeds&mode=sort&fid={$row->Id}&oldpage={$row->porder}&newpage=".($row->porder+1)."'>Move Down</a> | <a href='{$_SERVER['PHP_SELF']}?page=npFeeds&mode=sort&fid={$row->Id}&oldpage={$row->porder}&newpage=".($row->porder-1)."'>Move Up</a></td>";
					}
?>				
			</tr>
<?php
			$i++;
		}
	}
?>
	<TR><TH colspan=14><input type=submit name=change3 value="Update">
		<input type=submit name=change3 value="Delete selected" <?=$del_confirm?>></TH></TR>
	<TR>
	<tr>
		<TD width=15>&nbsp;</TD>
		<TD><?=$i?></TD>
		<TD><input type=text name=Title_new size=30></TD>
		<TD><input type=text name=feedurl_new size=30></TD>		
		<TD><input type=text name='topics_new' size=30 value=""></TD>
		<TD>
			<select name=active_new>
				<option value="0">Inactive
				<option value="1">Active
			</select>
		</TD>
	</TR>
	<TR><Th colspan=14><input type=submit name=change8 value="Add new record"></Th></TR>
	<input type=hidden name=porder_new value="<?php echo($lorder+1) ?>">
	</FORM>
	</table>
	</form>
</div>