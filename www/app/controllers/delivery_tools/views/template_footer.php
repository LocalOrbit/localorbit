<?
$multi_view = $core->view[0];
$domain_id = $core->view[1];	
$domain_infos = core::model('domains')->get_domain_info($domain_id);
?>
	<div class="row">
		<div class="span4">
			<h4>Questions or problems?</h4>
						
			<?
				foreach($domain_infos as $domain_info) {
					echo 'Email <a href="mailTo:'.$domain_info["secondary_contact_email"].'">'.$domain_info["secondary_contact_email"].'</a> <br />';
					echo 'or call '.$domain_info["secondary_contact_phone"].'<br />';
				}
			?>
		</div>
	</div>