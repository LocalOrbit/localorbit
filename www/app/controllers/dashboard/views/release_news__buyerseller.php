<div id="releaseNewsContinue"></div>

		
<div id="releaseNewsModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-header">
		<!-- <button type="button" class="close" data-dismiss="modal" aria-hidden="true">x</button> -->
		<h3 id="myModalLabel">It Keeps Getting Better: Introducing an Updated Design</h3>
	</div>
		 
	<div class="modal-body"> 
		<p>
		You may have noticed a few changes around here. We’re excited to announce a completely updated online marketplace experience with several new features and enhancements to a few of your favorites.
		</p>
	
		What's New:
		<ol>
			<li>Updated design</li>
			<li>New Market Info and News pages</li>
			<li>Streamlined navigation</li>
			<li>Faster ordering and checkout process</li>
			<li>Enhanced Market Manager controls</li>
		</ol>
		<p>
		So go ahead. Take a look around. We hope you love it as much as we do.
		<!--Learn more about the changes <a target="_blank" href="https://localorbit.zendesk.com/entries/22926838-introducing-a-revamped-design">here.</a>	-->
		</p>
	</div>
	
	
	<div class="modal-footer">
		<button class="btn btn-large" onclick="core.doRequest('/dashboard/release_news',{'news_remind_later':'yes'});">Remind Me Later</button>
		<button class="btn btn-large btn-primary" onclick="core.doRequest('/dashboard/release_news',{'has_seen_release_news':'yes'});">Got It</button>
	</div>
</div>