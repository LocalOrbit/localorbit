<?
$multi_view = $core->view[0];
$domain_id = $core->view[1];	
$domain_info = core::model('domains')->get_domain_info($domain_id);
?>
	<div class="row">
		<div class="span4">
			<h4>Questions or problems?</h4>
						
			<?
				echo 'Email <a href="mailTo:'.$domain_info["email"].'">'.$domain_info["email"].'</a> <br />';
				echo 'Call '.$domain_info["phone"].'<br />';
			?>
		</div>
	</div>