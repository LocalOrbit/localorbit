# Disaster Recovery

The application relies heavily on Heroku and AWS, though has a minimal set of dependencies, so setting up on a fresh Heroku instance (or an entirely different server) is fairly straightforward.

Major tasks:

* Setup app server
	* Ruby, Rails
	* Passenger
	* Memcache
* Restore Database
* Setup SSL
* Setup application configs (database.yml, application.yml or ENV vars)
* Deploy code
* Change DNS
* Setup task/cron server



## DNS

The DNS CNAME for `app.localorbit.com` is the most important piece. It currently points to Heroku (`kyoto-1603.herokussl.com`) but it can point anywhere.

The TTL is set fairly low (30 minutes) to allow fast switching.

The app relies on a CNAME for `*.localorbit.com` but that points to `app.localorbit.com` so no change is necessary.

## Database

The PostgreSQL database is backed up by Heroku (PG Backups addon) daily.

Running `$ heroku pgbackups` gives a list of available backup files and you can download/restore/etc using the commands availble. See: `$ heroku help pgbackups`

A daily backup is also stored offsite in an AWS S3 bucket in a different region. If Heroku is unavailable, you can sign in to S3 and download the backup.

## Application

The Application can be set up as explained in the README. For a production environment, passenger is recommended.

Ensure required ENV vars are set. See `application.yml.example` for expected variables.

## SSL

A production environment requires an SSL certificate. Using a self-signed one will work in a pinch, but you'll want to install the real certificate.

For Heroku, see See: `$ heroku help certs`

## CDN

CloudFront provides a pass-through CDN for static assets. We can use the app server in the unlikely event CloudFront disappears.

## Assets

Currently uploaded images are *not* backed up, though S3 is usually pretty reliable.

The app may error if it cannnot reach a valid S3 bucket though missing images shouldn't break anything.