# Base heroku-16 stack image
FROM heroku/heroku:16

# Remove existing xenial ruby2.3 (2.3.1) that came with base image
RUN apt-get autoremove -y ruby2.3

# Skip installing gem documentation
RUN mkdir -p /usr/local/etc \
	&& { \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc

# Install newer ruby via Brightbox repo
#   from: https://www.brightbox.com/docs/ruby/ubuntu/#adding-the-repository
RUN apt-get update && apt-get install -y software-properties-common
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update && apt-get install -y ruby2.3 ruby-switch
RUN ruby-switch --set ruby2.3
RUN ruby -v

# Gems
RUN gem update --system 2.7.7
RUN gem install bundler --version 1.16.4
