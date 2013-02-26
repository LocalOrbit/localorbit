function check_length(mrt_send_sms_form, maxLen)
{
if (mrt_send_sms_form.message.value.length > maxLen) {
mrt_send_sms_form.message.value = mrt_send_sms_form.message.value.substring(0, maxLen);
mrt_send_sms_form.text_num.value = "none";
}
else{ 
mrt_send_sms_form.text_num.value = maxLen - mrt_send_sms_form.message.value.length - 1;

	}
	if (mrt_send_sms_form.text_num.value < 1){ 
	mrt_send_sms_form.text_num.value = 0;
	}
	
}

function ismaxlength(obj){
var mlength=obj.getAttribute? parseInt(obj.getAttribute("maxlength")) : ""
if (obj.getAttribute && obj.value.length>mlength){
alert('You have reached your maximum limit of characters allowed');
obj.value=obj.value.substring(0,mlength)
}
}