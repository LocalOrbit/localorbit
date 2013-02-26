update phrases 
	set default_value='Please enter your organization''s story in the "Who" field.' 
	where label='error:organizations:profile';
	
update phrases 
	set default_value='Please enter your products'' story in the "How" field.' 
	where label='error:organizations:product_how';
