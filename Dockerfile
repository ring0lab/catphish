# USAGE:
#   TAG=$(git rev-parse --short HEAD)
#   docker build --tag "catphish:${TAG}" .
#   docker run --rm=true "catphish:${TAG}" --Domain ring0labs.com --All
FROM ruby:2.3.4-alpine

RUN apk add --update \
    build-base \
    && rm -rf /var/cache/apk/*

# Install it into the /opt/ dir
WORKDIR /opt/catphish
COPY * /opt/catphish/
RUN bundle install

# Use the script as the entrypoint so we can supply args directly to the docker daemon
# See https://serverfault.com/a/647790
ENTRYPOINT ["/opt/catphish/catphish.rb"]
