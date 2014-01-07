<?
$to_email = $core->view[0];
$values = array(
	'hostname'=>$core->config['domain']['hostname'],
	'fullname'=>$core->view[1],
	'product'=>$core->view[2],
);
$from_email=$core->view[3];
$from_name=$core->view[4];


$body  = $this->email_start();
$body .= $this->handle_source('<h1>New Product Request Received</h1>
      <p><strong>{fullname}</strong> has requested a new product.</p>

      <dl>
        <dt>Product requested:</dt>
        <dd>{product}</dd>
      </dl>',$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email('New Product Request',$to_email,$body,'',$from_email,$from_name);
?>