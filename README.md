# Local Orbit

[![CircleCI](https://circleci.com/gh/LocalOrbit/localorbit/tree/master.svg?style=svg)](https://circleci.com/gh/LocalOrbit/localorbit/tree/master)

* **[Staging Deploy (Preview)](https://github.com/LocalOrbit/localorbit/compare/staging...master)**
* **[Production Deploy (Preview)](https://github.com/LocalOrbit/localorbit/compare/production...staging)**

See the `docs/` directory for more documentation.

## Developer Setup

1. Install `ruby 2.4.10` (use a ruby version manage like [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/))
1. Clone this repo `git clone git@github.com:LocalOrbit/localorbit.git`, `cd localorbit` into it
1. Install dependencies (for MacOs) via [Homebrew](https://brew.sh/) with `brew bundle`. Other platforms see requirements in [`Brewfile`](./Brewfile).
1. `bundle`
1. `cp config/application.yml{.example,}` and modify if needed, see [Environment variables](#environment_variables) below
1. `cp config/database.yml{.example,}` and modify if needed (Some modification is probably necessary. Try adding `template: template0`)
1. `cp .env.sample .env` and customize with your own api keys, etc.
1. `yarn`
1. `rake db:setup` - runs `db:create`, `db:schema:load` and `db:seed`
1. `rake db:seed:development` - See [Test Accounts](#test-accounts) section for usernames and passwords
1. `rails server`
1.  Add `127.0.0.1 localtest.me` to `/etc/hosts`
1.  Go to http://localtest.me:3000 in a browser (we use localtest.me to always point to 127.0.0.1 so we can use subdomains, which localhost doesn't allow.)
1.  Run delayed job in foreground with `./bin/delayed_job run` (caveat: delete jobs from that table first if loading in production data)

#### Other required services to setup

* See [stripe howto](docs/stripe_in_development.md) for configuring stripe for development.
* Setup a [mailtrap](https://mailtrap.io/) account and put the username and password into your application.yml
* AWS is used by the app to store images as well as transferring db backups between environments.
  1. Get an invitation to the AWS account
  2. Configure an API key and secret
  3. [Configure the AWS cli tools](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) (which should already be installed via `brew bundle`.)

## Environment variables

`ENV` is accessed via [dotenv](https://github.com/bkeepers/dotenv). For `build`, `staging` and `production` environments the `ENV` vars are populated via ansible automation, see [localorbit-ansible](https://github.com/thermistor/localorbit-ansible). For [CircleCI](https://circleci.com/gh/LocalOrbit), sensitive `ENV` vars like API keys and other secrets are managed via the [Circle CI web application](https://circleci.com/gh/LocalOrbit/localorbit/edit#env-vars), and non-sensitive `ENV` vars are managed via the [`.circleci/config.yml`](./.circleci/config.yml).


## Data Setup

* At least one Market must be created before creating Organizations

### Test Accounts
Running `rake db:seed:development` makes the following test accounts available

*Selling Organization*
Email: seller@example.com
Password: password1

*Buying Organization*
Email: buyer@example.com
Password: password1

*Market Manager*
Email: mm@example.com
Password: password1

*Admin*
Email: admin@example.com
Password: password1

## Testing

To run rspec tests:

    rspec

or

    rake

[CircleCI](https://circleci.com/gh/LocalOrbit/localorbit/tree/master) auatomatically runs tests on every commit.

### Javascript Specs

Specs live in spec/javascripts/\*.js.coffee

Run suite on command line:  `bundle exec rake konacha:run`
Run suite via browser:  `bundle exec rake konacha:serve (then visit http://localhost:3500)`
Run suite automatically on changes to javascript sources or specs:  bundle exec guard

## Deployment

We have a `build` environment that is setup via the [localorbit-ansible](https://github.com/thermistor/localorbit-ansible) project with Vagrant.

As well there are `staging` and `production` environments which are hosted on AWS. You will need your ssh keys configured and pre-installed on the target environments servers by a colleague as per the `localorbit-ansible` project's instructions before you can deploy.

To deploy changes to the the `staging` environment, do the following command from the project directlry. This will deploy new code from the `staging` branch, and restart `passenger` and `delayed_job`.

    bundle exec cap staging deploy

The command is similar for `build` and `production`, just change the environment, eg.

    bundle exec cap production deploy

### Error reporting

Errors are logged at [Rollbar](https://rollbar.com/LocalOrbit/all/items/).

## Contributing

See [development process](docs/development_process.md).
