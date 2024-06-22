#
# Base layer that both dev and runtime inherit from.
#
FROM ruby:3.3.2-alpine as devdocs-base

ENV LANG=C.UTF-8

ARG USERNAME=devdocs
ARG USER_ID=1000
ARG GROUP_ID=1000
WORKDIR /devdocs
EXPOSE 9292
    
RUN apk --update add nodejs build-base libstdc++ gzip git zlib-dev libcurl && \
    gem install bundler && \
    bundle config set path.system true && \
    bundle config set without test && \
    bundle install && \
    groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    rm -rf /var/cache/apk/* ~/.gem /root/.bundle/cache \
        /usr/local/bundle/cache /usr/lib/node_modules

COPY Gemfile Gemfile.lock Rakefile Thorfile /devdocs/

#
# Development Image
#
FROM devdocs-base as devdocs-dev
RUN bundle config unset without test && \
    bundle install && \
    apk add --update bash && \
    rm -rf ~/.gem /root/.bundle/cache /usr/local/bundle/cache

USER $USERNAME
CMD bash

#
# Runtime Image
#
FROM devdocs-base as devdocs
ENV ENABLE_SERVICE_WORKER=true
RUN thor docs:download --all && \
    thor assets:compile && \
    apk del gzip build-base git zlib-dev && \
    rm -rf /tmp

USER $USERNAME
CMD rackup -o 0.0.0.0
