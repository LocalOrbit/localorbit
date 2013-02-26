<div id="releaseNewsContinue"></div>

		
<div id="releaseNewsModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-header">
		<!-- <button type="button" class="close" data-dismiss="modal" aria-hidden="true">x</button> -->
		<h3 id="myModalLabel">It Keeps Getting Better: Introducing a Revamped Design</h3>
	</div>
		 
	<div class="modal-body"> 
		<p>
		You may have noticed a few changes around here. We’re excited to announce a completely updated online marketplace experience with the introduction of several new features and enhancements to a few of your favorites.
		</p>
		
		<b>What's New:</b>
		<ol>
			<li>Updated design</li>
			<li>New background, font and color options</li>
			<li>New Market Info and News pages</li>
			<li>Extra help tips & descriptive prompts</li>
		</ol>
		<br />
		<b>What's Changed:</b>
		<ol>
			<li>Streamlined back office management</li>
			<li>Faster ordering and checkout process</li>
			<li>Additional product description fields</li>
		</ol>
		<p>
			Our Community Managers will be checking in soon to get your feedback, set up your new custom options, and answer any questions. In the meantime, you can learn more about the update <a href="https://localorbit.zendesk.com/entries/22926838-introducing-an-updated-design" target="_blank">here</a>.
			<br />&nbsp;<br />
			So go ahead. Take a look around. We hope you love it as much as we do.
		</p>
	</div>
	
	
	<div class="modal-footer">
		<button class="btn btn-large" onclick="core.doRequest('/dashboard/release_news',{'news_remind_later':'yes'});">Remind Me Later</button>
		<button class="btn btn-large btn-primary" onclick="core.doRequest('/dashboard/release_news',{'has_seen_release_news':'yes'});">Got It</button>
	</div>
</div>