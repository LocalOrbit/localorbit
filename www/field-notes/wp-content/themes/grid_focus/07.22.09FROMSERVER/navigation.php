<?php

    class Navigation
    {
	var $globalmenu;
	var $topUtilmenu;
	var $footerUtilmenu;

	var $usertype;
	var $usertypeID;
	var $userid;

	function Navigation()
	    {
		$this->usertype = $_COOKIE['usertype'];
		$this->userid = $_COOKIE['userid'];

		//  Find the location.

		$location = explode('/', $_SERVER['REQUEST_URI']);
		$location = $location[1];

		$base = "http://" . $_SERVER['HTTP_HOST'];
		$switch['guest']
		 ['globalmenu'] =
		 array('from' => array('/{{know-local}}/',
				       '/{{buy-local}}/',
				       '/{{sell-local}}/',
				       '/{{kl-selected}}/',
				       '/{{bl-selected}}/',
				       '/{{sl-selected}}/'),
		       'to' => array("$base/field-notes/",
				     "$base/buy-local/index.php",
				     "$base/sell-local/sell-local.php",
				     ($location == "field-notes")
				     ? "selected" : "",
				     ($location == "MAGstore" ||
				      $location == "buy-local")
				     ? "selected" : "",
				     ($location == "sell-local")
				     ? "selected" : ""));
		$switch['buyer']
		 ['globalmenu'] =
		 array('from' => array('/{{know-local}}/',
				       '/{{buy-local}}/',
				       '/{{sell-local}}/',
				       '/{{kl-selected}}/',
				       '/{{bl-selected}}/',
				       '/{{sl-selected}}/'),
		       'to' => array("$base/field-notes/",
				     "$base/MAGstore/",
				     "$base/sell-local/seller.php",
				     ($location == "field-notes")
				     ? "selected" : "",
				     ($location == "MAGstore" ||
				      $location == "buy-local")
				     ? "selected" : "",
				     ($location == "sell-local")
				     ? "selected" : ""));

		$switch['seller']
		 ['globalmenu'] =
		 array('from' => array('/{{know-local}}/',
				       '/{{buy-local}}/',
				       '/{{sell-local}}/',
				       '/{{kl-selected}}/',
				       '/{{bl-selected}}/',
				       '/{{sl-selected}}/'),
		       'to' => array("$base/field-notes/",
				     "$base/MAGstore/",
				     "$base/sell-local/index.php?userId=" .
				     $this->userid . "&utype=" .
				     $this->usertypeID,
				     ($location == "field-notes")
				     ? "selected" : "",
				     ($location == "MAGstore" ||
				      $location == "buy-local")
				     ? "selected" : "",
				     ($location == "sell-local")
				     ? "selected" : ""));
		
		$switch['guest']
		 ['topUtilmenu'] =
		 array('from' => array('/{{regMyAcct}}/',
				       '/{{nodispcart}}/',
				       '/{{loginout}}/'),
		       'to' => array("<li class=\"aboutLi\"><a href=\"$base/reg/register.php\" onclick=\"return false;\" class=\"lbOn signup\" title=\"signup for local orbit\"><span>sign up</span></a></li>",
				     'display:none;',
				     '<li class="loginLi"><a href="' . $base . '/reg/login2.php" class="login" "log in to local orbit"><span>log in</span></a></li>'));
		
		$switch['buyer']
		 ['topUtilmenu'] =
		 array('from' => array('/{{regMyAcct}}/',
				       '/{{nodispcart}}/',
				       '/{{loginout}}/'),
		       //		       'to' => array("<li class=\"myaccountLi\"><a href=\"" . $base . "/buy-local/index.php?userId=" . $this->userid . "&utype=" . $this->usertypeID . "\" onclick=\"addParams(this);\" title=\"Click to go to my account\" class=\"myaccount\"><span>My Account</span></a></li>",
		       'to' => array("<li class=\"myaccountLi\"><a href=\"" . $base . "/buy-local/buyer-dashboard.php\" onclick=\"addParams(this);\" title=\"Click to go to my account\" class=\"myaccount\"><span>My Account</span></a></li>",
				     '',
				     '<li class="logoutLi"><a href="' . $base . '/logout.php" title="log out of local orbit" class="logout"><span>logout</span></a></li>'));
		
		$switch['seller']
		 ['topUtilmenu'] =
		 array('from' => array('/{{regMyAcct}}/',
				       '/{{nodispcart}}/',
				       '/{{loginout}}/'),
		       'to' => array("<li class=\"myaccountLi\"><a href=\"" . $base . "/sell-local/index.php?userId=" . $this->userid . "&utype=" . $this->usertypeID . "\" onclick=\"addParams(this);\" title=\"Click to go to my account\" class=\"myaccount\"><span>My Account</span></a></li>",
				     '',
				     '<li class="logoutLi"><a href="' . $base . '/logout.php" title="log out of local orbit" class="logout"><span>logout</span></a></li>'));
		
		$switch['guest']['footerUtilmenu'] = array('from' => array(),
							   'to' => array());
		
		$switch['seller']['footerUtilmenu'] = array('from' => array(),
							    'to' => array());
		
		$switch['buyer']['footerUtilmenu'] = array('from' => array(),
							   'to' => array());
		       
		$this->globalmenu =
		 preg_replace($switch[$this->usertype]['globalmenu']['from'],
			      $switch[$this->usertype]['globalmenu']['to'],
			      '<ul><!--To have the rollover effect become the YOU ARE HERE icon simply change out the class in the link   --><li class="knowLi"><a href="{{know-local}}" onclick="addParams(this);" title="know local" class="know {{kl-selected}}"><span>Know Local</span></a></li><li class="sellLi"><a href="{{sell-local}}" onclick="addParams(this);" title="sell local" class="sell {{sl-selected}}"><span>Sell Local</span></a></li><li class="buyLi"><a href="{{buy-local}}" title="buy local" class="buy {{bl-selected}}"><span>Buy Local</span></a></li></ul>');
		
		$this->topUtilmenu =
		 preg_replace($switch[$this->usertype]['topUtilmenu']['from'],
			      $switch[$this->usertype]['topUtilmenu']['to'],
			      "<div id=\"utilityUpperNav\"> <ul><li class=\"homeLi\"><a href=\"$base/index.php\" class=\"home\" onclick=\"addParams(this);\" title=\"click to go to the local orbit home page\"><span>home</span></a></li> <li class=\"cartLi\" style=\"{{nodispcart}}\"><a href=\"$base/MAGstore/index.php/checkout/cart/\" title=\"shop local orbit\" class=\"cart\"><span>cart wheel</span></a></li>{{loginout}}</ul> </div> <p class=\"utilNavDivider\"></p> <div id=\"utilityLowerNav\"> <ul> <li class=\"helpLi\"><a href=\"$base/help.php\" onclick=\"addParams(this);\" class=\"help\" title=\"find information about local orbit\"><span>help</span></a></li> <li class=\"aboutLi\"><a href=\"$base/about-us/index.php\" onclick=\"addParams(this);\" class=\"about\" title=\"about local orbit\"><span>about us</span></a></li>{{regMyAcct}}</ul> </div>");
			      
		$this->footerUtilmenu =
		 preg_replace($switch[$this->usertype]['footerUtilmenu']['from'],
			      $switch[$this->usertype]['footerUtilmenu']['to'],
			      "<ul><li>&copy; 2009</li> <li><a href=\"$base/index.php\" class=\"home\" onclick=\"addParams(this);\" title=\"click to go to's local orbit home page\">Home</a></li> <li><a href=\"$base/contact.php\">Contact Us</a></li> <li><a href=\"$base/privacy.php\">Privacy</a></li> <li><a href=\"$base/tos.php\">Terms of Service</a></li> <li><a href=\"$base/about-us/index.php\">About Us</a></li> <li><a href=\"$base/help.php\">Help</a></li> </ul>");
	    }

	function topUtilmenu()
	    {
		printf("%s", $this->topUtilmenu);
	    }

	function footerUtilmenu()
	    {
		printf("%s", $this->footerUtilmenu);
	    }

	function globalmenu()
	    {
		printf("%s", $this->globalmenu);
	    }
    }

    ?>