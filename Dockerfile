FROM ruby:2.2.8

# Force git to use HTTPS transport
RUN git config --global url.https://github.com/.insteadOf git://github.com/

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs clamav clamav-daemon python-software-properties software-properties-common
RUN freshclam
RUN gem install pg
RUN mkdir /management
WORKDIR /management
ADD Gemfile /management/Gemfile
ADD Gemfile.lock /management/Gemfile.lock

RUN bundle install

ADD . /management
ENV RAILS_ENV development
#RUN rake db:create db:setup db:seed