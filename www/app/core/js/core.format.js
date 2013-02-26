core.format={};

core.format.price=function(input){
	
	input *= 100;
	input = Math.round(input);
	input /= 100;

	var input = new String(input);

	
	if(input.indexOf('.') < 0)
		input += '.';
	
	if((input.length - input.lastIndexOf('.')) < 3)
		input = input + '0';
	if((input.length - input.lastIndexOf('.')) < 3)
		input = input + '0';
	
	
	input = '$'+input;
	return input;
	
}

core.format.parsePrice=function(input){
	var input = new String(input);
	input = input.replace('$','');
	input = input.replace(' ','');
	return parseFloat(input);
}

core.format.parseDate=function(input,return_format){
	if(return_format+'' == 'undefined')
		return_format = 'db';
	var months={
		'jan':'01',
		'feb':'02',
		'mar':'03',
		'apr':'04',
		'may':'05',
		'jun':'06',
		'jul':'07',
		'aug':'08',
		'sep':'09',
		'oct':'10',
		'nov':'11',
		'dec':'12'
	};
	var input =  new String(input).toLowerCase().split(/[\s,]+/); 
	switch(return_format)
	{
		case 'db':
			return input[2]+'-'+months[input[0]]+'-'+input[1];
			break;
		case 'timestamp':
			var date = new Date();
			date.setYear(input[2]);
			date.setMonth(parseInt(months[input[0]]));
			date.setDate(input[1]);
			//alert(date.getUTCFullYear() + '-'+date.getUTCMonth()+'-'+date.getUTCDate());
			return date.valueOf();
			break;
		default:
			exit('unknown return type for core_format::parse_date();');
			break;
	}
}