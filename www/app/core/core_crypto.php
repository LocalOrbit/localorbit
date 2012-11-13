<?php
# this library contains all functions needed for password/encryption.
# there are only 3 functions in here so far, of which you generally only need 2.
# they're pretty self explanatory.
# NOTE this library is NOT auto-loaded (as it might be big, but is only used by a few pages),
# so you need to manually load it by calling core::load_library('crypto');

class core_crypto
{
	public static function generate_password($max=8)
	{
		global $core;
		$characters = $core->config['password_characters'];
		$new_password = '';
		for ($p = 0; $p <= $max; $p++) {
			$new_password .= $characters[mt_rand(0, strlen($characters))];
		}
		return $new_password;
	}
	
	public static function generate_salt($max=null)
	{
		global $core;
		
		if(is_null($max))
			$max = $core->config['hash_salt_length'];
		
		$characterList = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		$i = 0;
		$salt = "";
		do {
			$salt .= $characterList{mt_rand(0,strlen($characterList)-1)};
			$i++;
		} while ($i <= $max);
		return $salt;
	}
	
	public static function encode_password($password)
	{
		global $core;
		$salt = core_crypto::generate_salt();
		return $salt.'-'.hash($core->config['hash_algo'],$salt.$password);
	}
	
	public static function compare_password($old,$new)
	{
		global $core;
		$passparts = explode('-',$old);
		return (hash($core->config['hash_algo'],$passparts[0].$new) == $passparts[1]);
	}
	
	public static function encrypt($input, $key = null)
	{
		global $core;
		
		if(is_null($key))
			$key = $core->config['crypt_key'];
		core::log('trying to encrypt '.$input.' using key '.$key);
		core::log(base64_encode(mcrypt_encrypt(
					constant($core->config['crypt_algo']),
					md5($key),
					$input,
					MCRYPT_MODE_CBC, md5(md5($key))
				)));
		$s = strtr(
			base64_encode(
				mcrypt_encrypt(
					constant($core->config['crypt_algo']),
					md5($key),
					$input,
					MCRYPT_MODE_CBC, md5(md5($key))
				)
			),
			'+/=',
			'-_,'
		);
		return $s;
	}

	public static function decrypt($input, $key = null)
	{
		global $core;

		if(is_null($key))
			$key = $core->config['crypt_key'];

		$s = rtrim(
			mcrypt_decrypt(
				constant($core->config['crypt_algo']), 
				md5($key), 
				base64_decode(
					strtr($input, '-_,', '+/=')
				), 
				MCRYPT_MODE_CBC, 
				md5(md5($key))
			),
			"\0"
		);
		return $s;
	}
}

?>