FROM ruby:3.3.0
ENV LANG=C.UTF-8
ENV ENABLE_SERVICE_WORKER=true
ENV RUBY_YJIT_ENABLE="1"

WORKDIR /devdocs

RUN apt-get update && \
    apt-get -y install git nodejs libcurl4 && \
    gem install bundler && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock Rakefile /devdocs/

RUN bundle install --system && \
    rm -rf ~/.gem /root/.bundle/cache /usr/local/bundle/cache

COPY . /devdocs

RUN thor docs:download --all && \
    thor assets:compile && \
    rm -rf /tmp

EXPOSE 9292
CMD rackup -o 0.0.0.0
