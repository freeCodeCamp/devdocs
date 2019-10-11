FROM ruby:2.6.5-alpine

ENV LANG=C.UTF-8
ENV ENABLE_SERVICE_WORKER=true

WORKDIR /devdocs

COPY . /devdocs

RUN apk --update add nodejs build-base libstdc++ gzip git zlib-dev libcurl && \
    gem install bundler && \
    bundle install --system --without test && \
    thor docs:download --all && \
    thor assets:compile && \
    apk del gzip build-base git zlib-dev && \
    rm -rf /var/cache/apk/* /tmp ~/.gem /root/.bundle/cache \
    /usr/local/bundle/cache /usr/lib/node_modules

EXPOSE 9292
CMD rackup -o 0.0.0.0
