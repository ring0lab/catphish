# USAGE:
#   TAG=$(git rev-parse --short HEAD)
#   docker build --tag "catphish:${TAG}" .
#   docker run --rm=true "catphish:${TAG}" --Domain ring0labs.com --All
FROM ruby:2.3.4-alpine

RUN apk --no-cache add g++ make
RUN gem install unf_ext --no-ri --no-rdoc

# Install it into the /opt/ dir
WORKDIR /opt/catphish
ADD Gemfile \
    catphish.rb /opt/catphish/
RUN bundle install

# Use the script as the entrypoint so we can supply args directly to the docker daemon
# See https://serverfault.com/a/647790
ENTRYPOINT ["/opt/catphish/catphish.rb"]
