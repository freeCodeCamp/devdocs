
FROM ruby:2.2.2
MAINTAINER Conor Heine <conor.heine@gmail.com>

RUN apt-get update
RUN apt-get -y install git nodejs
RUN git clone https://github.com/Thibaut/devdocs.git /devdocs
RUN gem install bundler

WORKDIR /devdocs

RUN bundle install --system
RUN thor docs:download --all

EXPOSE 9292
CMD rackup -o 0.0.0.0

