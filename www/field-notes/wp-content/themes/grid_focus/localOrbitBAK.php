<?php

function getUserId() {
	if (isset($userId))
		$id = $userId;
	else if (isset($_GET['userId']))
		$id = $_GET['userId'];
	else if (isset($_POST['userId']) )
		$id = $_POST['userId'];
	else
		$id = 0;
	return $id;
}

function getAccountType() {
	if (isset($utype))
		$ut = $utype;
	else if (isset($_GET['utype']))
		$ut = $_GET['utype'];
	else if (isset($_POST['utype']) )
		$ut = $_POST['utype'];
	else
		$ut = 0;
	return $ut;
}

include "config.inc";

function loginOrLogoutNav() {
	global $base;
	if (getUserId() > 0)
        echo '<li class="logoutLi"><a href="' . $base . '/index.php?userId=0" title="log out of local orbit" class="logout"><span>logout</span></a></li>';
	else
        echo '<li class="loginLi"><a href="' . $base . '/reg/login2.php" class="login" "log in to local orbit"><span>log in</span></a></li>';
        //echo '<li class="loginLi"><a href="/reg/login.php" onclick="return false;" class="lbOn login" "log in to local orbit"><span>log in</span></a></li>';

}

function myAccountOrRegister() {
	global $base;
	if (getUserId() > 0) {
        echo '<li class="myaccountLi"><a href="' . $base . '/reg/AccountInfo.php" onclick="addParams(this);" title="Click to go to my account" class="myaccount"><span>My Account</span></a></li>';
	}
	else
		echo '<li class="aboutLi"><a href="' . $base . '/reg/register.php" onclick="return false;" class="lbOn signup" title="signup for local orbit"><span>sign up</span></a></li>';
}

function loNav() {
	global $base;
	echo '
	<a href="' . $base . '/" onclick="addParams(this)"><img src="/img/common/logo.gif" alt="Local Orbit"  /></a>
	  <div id="topNavBar">
		<div id="utilityUpperNav">
			<ul>
           <!-- <li><input name="search" type="text" value="product search" size="19" maxlength="30" /> <input name="go" type="submit" value="go" id="search" /></li>-->
			<li class="homeLi"><a href="' . $base . '/index.php" class="home" onclick="addParams(this);" title="click to go to the local orbit home page"><span>home</span></a></li>
            <li class="cartLi"><a href="' . $base . '/cart.html" title="shop local orbit" class="cart"><span>cart wheel</span></a></li>';
			echo loginOrLogoutNav();
			echo '</ul>
		</div>
		<p class="utilNavDivider"></p>
		<div id="utilityLowerNav">
			<ul>
			
			<li class="helpLi"><a href="' . $base . '/help.php" onclick="addParams(this);" class="help" title="find information about local orbit"><span>help</span></a></li>
			<li class="aboutLi"><a href="' . $base . '/about-us/index.php" onclick="addParams(this);" class="about" title="about local orbit"><span>about us</span></a></li>';
            echo myAccountOrRegister();
			echo '</ul>
		</div>
    </div>';

}

function loNav2($selected) {
	global $base;
	global $magstore;
	$type = getAccountType();
	echo '
		<div  id="navigation">
			<ul><!--To have the rollover effect become the YOU ARE HERE icon simply change out the class in the link   -->';
			if ($selected == "knowLi")
				echo '<li class="knowLi"><a href="http://localorb.it/field-notes/" onclick="addParams(this);" title="know local" class="know selected"><span>Know Local</span></a></li>';
			else
				echo '<li class="knowLi"><a href="http://localorb.it/field-notes/" onclick="addParams(this);" title="know local" class="know"><span>Know Local</span></a></li>';
			//=================
			// Sell-Local link
			//=================
			if ($type > 0) {
				// logged in
				if ($selected == "sellLi")
					echo '<li class="sellLi"><a href="" title="sell local" class="sell selected"><span>Sell Local</span></a></li>';
				else
					if ($type == 1)
						// farmer
						echo '<li class="sellLi"><a href="' . $base . '/sell-local/index.php" onclick="addParams(this);" title="sell local" class="sell"><span>Sell Local</span></a></li>';
					else
						// buyer
						echo '<li class="sellLi"><a href="' . $base . '/sell-local/farm.html" onclick="addParams(this);" title="sell local" class="sell"><span>Sell Local</span></a></li>';
			}
			else {
				// logged out
				if ($selected == "sellLi")
					echo '<li class="sellLi"><a href="" title="sell local" class="sell selected"><span>Sell Local</span></a></li>';
				else
					echo '<li class="sellLi"><a href="' . $base . '/sell-local/sell-local.php" onclick="addParams(this);" title="sell local" class="sell"><span>Sell Local</span></a></li>';
			}
			//=================
			// Buy-Local link
			//=================
			if ($type > 0)
				// logged in
				echo '<li class="buyLi"><a href="' . $magstore . '/"  onclick="addParams(this);" title="buy local" class="buy"><span>Buy Local</span></a></li>';
			else {
				// logged out
				if ($selected == "buyLi")
					echo '<li class="buyLi"><a href="" title="buy local" class="buy selected"><span>Buy Local</span></a></li>';
				else
					echo '<li class="buyLi"><a href="' . $base . '/buy-local/index.php" title="buy local" class="buy"><span>Buy Local</span></a></li>';
			}
	echo '
			</ul>
		</div>';
}

?>