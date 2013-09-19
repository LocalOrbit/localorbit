<?php
class core_model_sent_emails extends core_model_base_sent_emails
{
	function send()
	{
		global $core;
		
		$to = $this['to_address'];
		$subject = $this['subject'];
		$body = $this['body'];
		$attachment_file_location = $this['attachment_file_location'];
		
		$core::log('sending email to '.$to.': '.$subject . " with attachement? " . $attachment_file_location);

		# startup the mail sender
		$core::load_library('core_phpmailer');
		$mail = new core_phpmailer(false,$this['from_email'],$this['from_name']);
		$mail->IsHTML(true);
		
		$to = explode(',',$to);
		if(is_array($to))
			foreach($to as $to_address)
				$mail->AddAddress($to_address);
		else
			$mail->AddAddress($to);

		$mail->Subject = $subject;
		$mail->Body = $body;
		
		if($from_name != '')
		{
			$mail->SetFrom('service@localorb.it',$from_name);
		}

		//add attachment AddAttachment($path,$name,$encoding,$type);
		if ($attachment_file_location > "") {
			$mail->AddAttachment($attachment_file_location);
		}
		
		
		$mail->Send();
		if($mail->ErrorInfo != '')
		{
			core::log('email send failure: '.$mail->ErrorInfo);
			$body = 'Error while trying to send email to '.$to.' with subject '.$subject;
			$body .='<br />&nbsp;<br />'.$mail->ErrorInfo;
			core_phpmailer::send_email('Error sending e-mail',$body,'mike@localorb.it','Mike Thorn');
			$this['emailstatus_id'] = 3;
			$this->save();
		}
		else
		{
			core::log('email sent');
			$this['emailstatus_id'] = 2;
			$this->save();
		}
	}
}
?>