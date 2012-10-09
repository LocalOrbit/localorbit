<?php
$lo->config['pagetitle'] = "Work with Local Orbit";
$lo->config['keywords'] = "jobs, employment, hiring, partnership";
$lo->config['description'] = "";

core::ensure_navstate(array('left'=>'left_company'));

core::head('Work with Local Orbit','Work with Local Orbit');
lo3::require_permission();

?>
<div class="public_content">
<!-- Use this when there are no jobs
	<h1>Work with Us</h1>
	<img src="img/misc/work_with_us.jpg" class="public_content_photo" style="margin-left: 15px;float:right;" />
	We're always interested in hearing from talented, motivated people who share our passion for creating tools to build a better food system.
	<br />&nbsp;<br />
	Over the next few months, we will be adding sales, community management, software development and design positions.
	<br />&nbsp;<br />
	Keep an eye on this page for the formal postings. You can also <a href="http://localorbit.zendesk.com/anonymous_requests/new" target="_blank">drop us a note and attach your resume</a> if you’d like to get a jump on things.
	<br />&nbsp;<br />
	<br />&nbsp;<br />
-->
<!-- Use this when there are jobs -->
	<h1>Work with Us</h1>
	<img src="img/misc/work_with_us.jpg" class="public_content_photo" style="margin-left: 15px;float:right;" />
	Local Orbit is hiring! Click the link to apply for<br />
	<a href="http://localorbit.theresumator.com/apply/ak48vG/Software-Developer-For-A-Better-Food-System.html" target="_blank">Software Developer for a Better Food System</a>
	<br />&nbsp;<br />
	If you don't see a job posting that fits your interests and experience, feel free to <a href="http://localorbit.zendesk.com/anonymous_requests/new" target="_blank">drop us a note with your resume</a>. We might be looking for you soon!
	<br />&nbsp;<br />
	<br />&nbsp;<br />

</div>
<!--
<h2  class="no_underline">Become an Affiliate</h2>
 <p>pread the word about Local Orbit and earn cash and food for your referrals (tied to discount code and RSS widget features)<a href="/lo2/misc/affiliates.php">Find out how to start your own hub</a></p>
-->

