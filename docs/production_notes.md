# Production Notes

We try to stick to the principles of [The Twelve-Factor App](http://12factor.net) whenever possible. Heroku's platform ~~limitations~~ features make this easier. 

Nothing is stored with the app. Assets and logs are through other services. Configuration is done with environment variables.

Below are some specific areas of interest.

## Assets

Static assets are served through the application, though we use AWS CloudFront as a pass-through CDN. The first request for a file will hit the application and cache it "forever" in CloudFront. All subsequent requests will only hit the cache and be much faster.

This pattern requires many fewer moving parts than uploading assets to S3 as part of the deploy process and works very well in practice. 

We use the standard Rails Asset Pipeline.

## Domains

We rely heavily on subdomains, so there is code throughout the app to properly handle the variety of situations that arise.

We use [Rack::CanonicalHost](https://github.com/tylerhunt/rack-canonical-host) to ensure non-supported hostnames get redirected.

In the `routes.rb` we use the `NonMarketDomain` constraint to short-circuit requests to fake subdomains and redirect. 

Finally, the app will often show different data depending on the subdomain. In production, we use `app.localorbit.com` as our "base" domain (meaning no selected market).

Note: Due to SSL wildcard limitations, adding a www to a subdomain (for example, `www.marketname.localorbit.com`) will show a nasty browser error saying that the SSL Certificate doesn't match the domain. An alternative solution is to not respond to these requests, though then it may appear to the user that the app is down when it isn't.


## App Server

We're using Passenger & Nginx for our app servers. 

Users like to upload (overly) large images which can quickly hang Heroku workers. Nginx is better handle file uploads and avoid blocking workers. 

Nginx also helps free up passenger processes when dealing with slow clients. 

The included `passenger_nginx.erb` config has a couple small additions:

1. Better font header support.
2. Keep at least one passenger process running at all times to avoid them all stopping.

## Staging Differences

We try to keep the staging server as identical to production as possible. Some of the few differences, all to save money:


1. We don't have any worker process for background jobs so instead `rake jobs:workoff` runs every 10 minutes via Heroku Scheduler.
2. Uploads use reduced-redundancy storage.
3. CDN uses only US regions.
4. We use Heroku's SSL certificate. 
5. Balanced marketplace is in test mode. Use their [test bank accounts](https://docs.balancedpayments.com/1.0/overview/resources/#test-credit-card-numbers).
6. RAILS_ENV=staging

Emails *do* send in staging, so don't use real email addresses unless you want it to actually send!

