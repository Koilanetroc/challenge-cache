FROM ruby:2.6.3

RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/

RUN gem install bundler:2.0.1

RUN gem install foreman

RUN bundle install --without development test

ADD . $APP_HOME
