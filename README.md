# Local Orbit

[![Build Status](https://magnum.travis-ci.com/collectiveidea/localorbit.png?token=bJRCSztHn61AphkJHARX&branch=rails)](https://magnum.travis-ci.com/collectiveidea/localorbit)
[![Code Climate](https://codeclimate.com/repos/52a73cb289af7e754500955b/badges/642075ad612c37af61c9/gpa.png)](https://codeclimate.com/repos/52a73cb289af7e754500955b/feed)

## Running

### Requirements

* Ruby 2.0.0
* PostgreSQL

### Setup

1. Clone the repo
2. `bundle`
3. `cp config/database.example.yml config/database.yml` and modify if needed
4. `rake db:setup`
5. `rails server`

## Contributing

1. Clone repository. `git clone git@github.com:collectiveidea/localorbit.git`
2. Checkout the rails branch. `git checkout -b rails origin/rails`
2. Create a branch for your feature. `git checkout -b my-awesome-feature-name rails`
3. Make changes and commit.
4. Run the tests. `rake`
5. Push to remote branch. `git push origin my-awesome-feature-name`
6. Create a Pull Request. Visit `https://github.com/collectiveidea/localorbit/compare/rails...my-awesome-feature-name`

![mmmmk](http://cdn.memegenerator.net/instances/400x/36691061.jpg)
