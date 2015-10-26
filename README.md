# Local Orbit

* **[Staging Deploy (Preview)](https://github.com/LocalOrbit/localorbit/compare/staging...master)**
* **[Production Deploy (Preview)](https://github.com/LocalOrbit/localorbit/compare/production...staging)**
* **[Fix Deploy (Preview)](https://github.com/LocalOrbit/localorbit/compare/production...fix)**

See the `docs/` directory for more documentation.

## Running

### Requirements

* Ruby 2.1.2
* PostgreSQL
* PhantomJS (for running tests)
* ImageMagick

### Setup

1. Clone the repo
2. `brew bundle` (on OS X. Install Requirements above for other platforms. May require you to unlink and reinstall previously installed packages.)
3. `bundle`
4. `cp config/application.yml{.example,}` and modify if needed
5. `cp config/database.yml{.example,}` and modify if needed (Some modification is probably necessary. Try adding `template: template0`)
7. `rake db:setup`
9. `rake db:seed`
10. `rake db:seed:development`
11. `rails server`
12. Add `127.0.0.1 localtest.me` to `/etc/hosts`
13. Go to http://localtest.me:3000 in a browser (we use localtest.me to always point to 127.0.0.1 so we can use subdomains, which localhost doesn't allow.)

### Production Setup
* At least one Market must be created before creating Organizations

### Updating Passenger
`config/passenger_nginx.erb` is copied from `resources/templates/standalone/config.erb` in the gem.

After updating the gem copy the file from the gem, then use git to keep the section between the keep me comments.
Everything in this section has been added so just keep it all.

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

### Javascript Specs

Specs live in spec/javascripts/*.js.coffee

Run suite on command line:  bundle exec rake konacha:run
Run suite via browser:  bundle exec rake konacha:serve (then visit http://localhost:3500)
Run suite automatically on changes to javascript sources or specs:  bundle exec guard


### Cloning staging for local development
Run `rake db:dump:staging`

**WARNING: This will replace EVERYTHING in your development db with what is currently on staging**

## Contributing

1. Clone repository. `git clone git@github.com:collectiveidea/localorbit.git`
2. Create a branch for your feature. `git checkout -b my-awesome-feature-name master`
3. Make changes and commit.
4. Run the tests. `rake`
5. Push to remote branch. `git push origin my-awesome-feature-name`
6. Create a Pull Request. Visit `https://github.com/collectiveidea/localorbit/compare/master...my-awesome-feature-name`

![mmmmk](http://cdn.memegenerator.net/instances/400x/36691061.jpg)
