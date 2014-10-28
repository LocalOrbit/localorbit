# 3rd Party Services

Whenever possible, we isolate environments. For Amazon AWS, we use different buckets/credentials/etc. for each environment. For Balanced, Mandril, and Mapbox, we use the same account, but separate API keys (Balanced has a test mode).

## App Services

Stuff the app needs to run (or at least do one small thing), and notification services.

Service | Purpose | Owner | Notes
--------|---------|-------|------
[Heroku](https://heroku.com) | Hosting | LO
[Heroku Postgres](https://postgres.heroku.com)<br>(via Heroku add-on) | Database | LO
[Balanced Payments](https://www.balancedpayments.com) | Payment Processing | LO
[Amazon AWS](https://aws.amazon.com) | Image Hosting (S3), CDN (CloudFront) | LO
[DNSMadeEasy](https://dnsmadeeasy.com) | DNS | LO
[Mandrill](https://mandrillapp.com) | Email | LO
[Mapbox](https://mandrillapp.com) | Geocoding, Maps | LO
[Google Maps](https://developers.google.com/maps/) | Backup Geocoding | LO | Mapbox can't find a few addresses.
[Twitter](https://twitter.com) | Widget for displaying Tweets | LO | @localorbit provides a token
[Zendesk](https://localorbit.zendesk.com) | Uses LO for SSO | LO
[Heroku Scheduler](https://scheduler.heroku.com)<br>(via Heroku add-on) | Periodic tasks | LO | offsite backups (daily), check ACH status (daily), update metrics (hourly)
[New Relic](http://newrelic.com)<br>(via Heroku add-on) | App stats & notifications | LO
[Papertrail](https://papertrailapp.com)<br>(via Heroku add-on) | App logs | LO | Archived to S3
[Honeybadger](https://www.honeybadger.io) | Error Reporting | [i]
[Dead Man's Snitch](https://deadmanssnitch.com)<br>(via Heroku add-on) | Failed Heroku Scheduler notification | LO


## Dev Services

Stuff used by devs but doesn't affect functionality.

Service | Purpose | Owner | Notes
--------|---------|-------|------
[GitHub](https://github.com) | Git repo | [i]
[Pivotal Tracker](http://pivotaltracker.com) | Project Management | LO
[Basecamp](http://basecamp.com) | Communication | [i]
[Travis CI](https://travis-ci.com) | Continuous integration | [i]
[Code Climate](https://codeclimate.com) | Code metrics | [i]
[Gemnasium](https://gemnasium.com) | Gem update notification | [i] | May magically keep working after moving the app.

