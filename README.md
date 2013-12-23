# Local Orbit

[![Build Status](https://magnum.travis-ci.com/collectiveidea/localorbit.png?token=bJRCSztHn61AphkJHARX&branch=master)](https://magnum.travis-ci.com/collectiveidea/localorbit)
[![Code Climate](https://codeclimate.com/repos/52b30c60c7f3a3648e02206b/badges/2d672c7e68247d48df79/gpa.png)](https://codeclimate.com/repos/52b30c60c7f3a3648e02206b/feed)

## Running

### Requirements

* Ruby 2.0.0
* PostgreSQL

### Setup

1. Clone the repo
2. `bundle`
3. `cp config/application.yml{.example,}` and modify if needed
4. `cp config/database.yml{.example,}` and modify if needed
5. `rake db:setup`
6. `rails server`

## Contributing

1. Clone repository. `git clone git@github.com:collectiveidea/localorbit.git`
2. Create a branch for your feature. `git checkout -b my-awesome-feature-name master`
3. Make changes and commit.
4. Run the tests. `rake`
5. Push to remote branch. `git push origin my-awesome-feature-name`
6. Create a Pull Request. Visit `https://github.com/collectiveidea/localorbit/compare/master...my-awesome-feature-name`

![mmmmk](http://cdn.memegenerator.net/instances/400x/36691061.jpg)
