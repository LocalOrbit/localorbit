<?
$values = array(
	'hostname'=>$core->config['domain']['hostname'],
	'username'=>$core->view[0],
	'unitsingle'=>$core->view[1],
	'unitplural'=>$core->view[2],
	'notes'=>$core->view[3],
	'prod_id'=>$core->view[4],
	'prod_name'=>$core->view[5],
);


$body  = $this->email_start();
$body .= $this->handle_source('<h1>New Unit Request Received</h1>
<p><strong>{username}</strong> has requested the following new unit:</p>

<dl>
  <dt>Singular:</dt>
  <dd>{unitsingle}</dd>
</dl>
<dl>
  <dt>Plural:</dt>
  <dd>{unitplural}</dd>
</dl>
<dl>
  <dt>Additional Note:</dt>
  <dd>{notes}</dd>
</dl>
<p>
  This request was made while viewing the following product:
  <strong>{prod_name}</strong>.
</p>',$values);

$body .= $this->email_end();

$this->send_email('New Unit Request','service@localorb.it',$body);

?>